// Supabase Edge Function to receive inbound emails via Resend webhook
// Resend webhooks only contain metadata - we fetch the actual body via API

// @ts-ignore
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// @ts-ignore
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from "../_shared/cors.ts"

declare const Deno: {
  env: {
    get: (key: string) => string | undefined
  }
}

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY_DIPLOMA')!
const ATTACHMENTS_BUCKET = 'email-attachments'

function normalizeEmailAddress(value?: string | null) {
  if (!value) return value
  return value.trim().toLowerCase()
}

function base64ToUint8Array(base64: string) {
  const clean = base64.replace(/\s/g, '')
  const binary = atob(clean)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes
}

function sanitizeFileName(name: string, fallback: string) {
  if (!name) return fallback
  return name.replace(/[^a-zA-Z0-9._-]/g, '_')
}

function uniqueSuffix() {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) {
    return crypto.randomUUID()
  }
  return Math.random().toString(36).slice(2)
}

function extractEmailFromValue(value: unknown): string | null {
  if (!value) return null

  if (Array.isArray(value)) {
    for (const entry of value) {
      const result = extractEmailFromValue(entry)
      if (result) return result
    }
    return null
  }

  if (typeof value === 'string') {
    const trimmed = value.trim()
    if (!trimmed) return null
    const match = trimmed.match(/<([^>]+)>/)
    return (match ? match[1] : trimmed).trim()
  }

  if (typeof value === 'object') {
    const obj = value as Record<string, unknown>
    return (
      extractEmailFromValue(obj.address) ||
      extractEmailFromValue(obj.email) ||
      extractEmailFromValue(obj.value) ||
      extractEmailFromValue(obj.name)
    )
  }

  return null
}

function findReplyToAddress(emailData: Record<string, unknown>): string | null {
  const candidates: unknown[] = []

  if ('reply_to' in emailData) candidates.push((emailData as any).reply_to)
  if ('replyTo' in emailData) candidates.push((emailData as any).replyTo)

  const headers = (emailData as any)?.headers
  if (headers) {
    if (Array.isArray(headers)) {
      const headerEntry = headers.find((header: any) =>
        typeof header?.name === 'string' && header.name.toLowerCase() === 'reply-to'
      )
      if (headerEntry) candidates.push(headerEntry.value ?? headerEntry.content)
    } else if (typeof headers === 'object') {
      for (const [key, value] of Object.entries(headers)) {
        if (key.toLowerCase() === 'reply-to') {
          candidates.push(value)
        }
      }
    }
  }

  const envelope = (emailData as any)?.envelope
  if (envelope) {
    if ('reply_to' in envelope) candidates.push(envelope.reply_to)
    if ('replyTo' in envelope) candidates.push(envelope.replyTo)
  }

  const message = (emailData as any)?.message
  if (message) {
    if ('reply_to' in message) candidates.push(message.reply_to)
    if ('replyTo' in message) candidates.push(message.replyTo)

    const messageHeaders = (message as any)?.headers
    if (messageHeaders) {
      if (Array.isArray(messageHeaders)) {
        const headerEntry = messageHeaders.find((header: any) =>
          typeof header?.name === 'string' && header.name.toLowerCase() === 'reply-to'
        )
        if (headerEntry) candidates.push(headerEntry.value ?? headerEntry.content)
      } else if (typeof messageHeaders === 'object') {
        for (const [key, value] of Object.entries(messageHeaders)) {
          if (key.toLowerCase() === 'reply-to') {
            candidates.push(value)
          }
        }
      }
    }
  }

  for (const candidate of candidates) {
    const email = extractEmailFromValue(candidate)
    if (email) return email
  }

  return null
}

function findHeaderValue(emailData: Record<string, unknown>, headerName: string): string | null {
  if (!headerName) return null
  const target = headerName.toLowerCase()

  const checkHeaders = (headers: unknown) => {
    if (!headers) return null

    if (Array.isArray(headers)) {
      for (const header of headers) {
        const name = (header as any)?.name || (header as any)?.key
        if (typeof name === 'string' && name.toLowerCase() === target) {
          const value = (header as any)?.value ?? (header as any)?.content
          const email = extractEmailFromValue(value)
          if (email) return email
          if (typeof value === 'string') return value
        }
      }
    } else if (typeof headers === 'object') {
      for (const [key, value] of Object.entries(headers)) {
        if (key.toLowerCase() === target) {
          const email = extractEmailFromValue(value)
          if (email) return email
          if (typeof value === 'string') return value
        }
      }
    }

    return null
  }

  return (
    checkHeaders((emailData as any)?.headers) ||
    checkHeaders((emailData as any)?.message?.headers) ||
    checkHeaders((emailData as any)?.envelope?.headers)
  )
}

async function uploadAttachmentBytes({
  supabase,
  bytes,
  filename,
  contentType,
  direction,
  emailId
}: {
  supabase: ReturnType<typeof createClient>
  bytes: Uint8Array
  filename: string
  contentType: string
  direction: 'incoming' | 'outgoing'
  emailId: string
}) {
  const safeName = sanitizeFileName(filename, 'attachment')
  const emailFolder = sanitizeFileName(emailId || 'unknown-email', 'unknown-email')
  const path = `${direction}/${emailFolder}/${Date.now()}-${uniqueSuffix()}-${safeName}`

  const { data: uploadData, error: uploadError } = await supabase
    .storage
    .from(ATTACHMENTS_BUCKET)
    .upload(path, bytes, {
      contentType: contentType || 'application/octet-stream'
    })

  if (uploadError) {
    throw uploadError
  }

  const { data: publicUrlData } = supabase
    .storage
    .from(ATTACHMENTS_BUCKET)
    .getPublicUrl(uploadData?.path || path)

  return {
    filename: filename || safeName,
    content_type: contentType || 'application/octet-stream',
    size: bytes.length,
    storage_path: uploadData?.path || path,
    public_url: publicUrlData?.publicUrl || null,
    direction
  }
}

async function fetchAttachmentBytesById(emailId: string, attachmentId: string) {
  try {
    const response = await fetch(`https://api.resend.com/emails/receiving/${emailId}/attachments/${attachmentId}`, {
      headers: {
        'Authorization': 'Bearer ' + RESEND_API_KEY
      }
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Attachment fetch error:', response.status, errorText)
      return null
    }

    const buffer = await response.arrayBuffer()
    return new Uint8Array(buffer)
  } catch (error) {
    console.error('Error fetching attachment by ID:', error)
    return null
  }
}

async function fetchAttachmentBytesFromUrl(url: string) {
  try {
    const response = await fetch(url, {
      headers: {
        'Authorization': 'Bearer ' + RESEND_API_KEY
      }
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Attachment URL fetch error:', response.status, errorText)
      return null
    }

    const buffer = await response.arrayBuffer()
    return new Uint8Array(buffer)
  } catch (error) {
    console.error('Error downloading attachment URL:', error)
    return null
  }
}

async function processInboundAttachments({
  emailId,
  emailContent,
  emailData,
  supabase
}: {
  emailId: string
  emailContent: Record<string, unknown> | null
  emailData: Record<string, unknown>
  supabase: ReturnType<typeof createClient>
}) {
  const attachments: any[] = []
  const contentAttachments = Array.isArray((emailContent as any)?.attachments) ? (emailContent as any).attachments : []
  const dataAttachments = Array.isArray((emailData as any)?.attachments) ? (emailData as any).attachments : []

  if (contentAttachments.length) attachments.push(...contentAttachments)
  if (dataAttachments.length) attachments.push(...dataAttachments)

  if (attachments.length === 0) {
    return []
  }

  const stored: Array<Record<string, unknown>> = []
  for (let index = 0; index < attachments.length; index++) {
    const attachment = attachments[index]
    try {
      const filename = attachment?.filename || attachment?.name || `attachment-${index + 1}`
      const contentType = attachment?.content_type || attachment?.mime_type || attachment?.type || 'application/octet-stream'
      let bytes: Uint8Array | null = null

      if (attachment?.content) {
        bytes = base64ToUint8Array(attachment.content)
      } else if (attachment?.base64) {
        bytes = base64ToUint8Array(attachment.base64)
      } else if (attachment?.download_url) {
        bytes = await fetchAttachmentBytesFromUrl(attachment.download_url)
      } else if (attachment?.id) {
        bytes = await fetchAttachmentBytesById(emailId, attachment.id)
      }

      if (!bytes || bytes.length === 0) {
        console.warn('Skipping attachment with no data:', filename)
        continue
      }

      const uploaded = await uploadAttachmentBytes({
        supabase,
        bytes,
        filename,
        contentType,
        direction: 'incoming',
        emailId
      })

      stored.push(uploaded)
    } catch (error) {
      console.error('Error processing inbound attachment:', error)
    }
  }

  return stored
}

function stripHtml(html: string) {
  return html
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
    .replace(/<br\s*\/?>(?=\s*<)/gi, '\n')
    .replace(/<br\s*\/?>(?!\n)/gi, '\n')
    .replace(/<p[^>]*>/gi, '\n')
    .replace(/<\/p>/gi, '\n')
    .replace(/<[^>]*>/g, '')
    .replace(/\n\s*\n/g, '\n')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .trim()
}

function extractOriginalHtml(html: string): string {
  if (!html) return ''
  
  // Try to find where the original email starts
  // Look for common email reply markers in HTML
  const markers = [
    /<div class="gmail_quote"/i,
    /<div class="yahoo_quoted"/i,
    /<blockquote[^>]*type=["']cite["']/i,
    /<div[^>]*id=["']divRplyFwdMsg["']/i,
    /On .+? wrote:/i,
    /<hr[^>]*>/i
  ]
  
  // Find the earliest marker
  let splitIndex = -1
  for (const marker of markers) {
    const match = html.match(marker)
    if (match && match.index !== undefined) {
      if (splitIndex === -1 || match.index < splitIndex) {
        splitIndex = match.index
      }
    }
  }
  
  // If we found a marker, get everything after it
  if (splitIndex > 0) {
    let originalHtml = html.substring(splitIndex)
    
    // Clean up the marker itself
    originalHtml = originalHtml.replace(/^<div class="gmail_quote"[^>]*>/i, '')
    originalHtml = originalHtml.replace(/^<blockquote[^>]*>/i, '')
    originalHtml = originalHtml.replace(/^<hr[^>]*>/i, '')
    originalHtml = originalHtml.replace(/^On .+? wrote:<br\s*\/?>/i, '')
    
    return originalHtml.trim()
  }
  
  return ''
}

async function fetchEmailFromResend(emailId: string): Promise<{ html?: string; text?: string } | null> {
  try {
    console.log('Fetching email content for ID:', emailId)
    
    const response = await fetch('https://api.resend.com/emails/receiving/' + emailId, {
      headers: {
        'Authorization': 'Bearer ' + RESEND_API_KEY
      }
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('Resend API error:', response.status, response.statusText, errorText)
      return null
    }

    const emailData = await response.json()
    console.log('Successfully fetched email from Resend')
    console.log('Has HTML:', !!emailData.html)
    console.log('Has text:', !!emailData.text)
    
    return {
      html: emailData.html,
      text: emailData.text
    }
  } catch (error) {
    console.error('Error fetching email from Resend:', error)
    return null
  }
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  console.log('Webhook request received')

  try {
    const payload = await req.json()
    console.log('Webhook type:', payload.type)
    
    if (payload.type !== 'email.received') {
      return new Response(
        JSON.stringify({ success: true, message: 'Not an email.received event' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const emailData = payload.data
    const emailId = emailData.email_id

    console.log('Email ID:', emailId)
    console.log('From:', emailData.from)
    console.log('To:', emailData.to)
    console.log('Subject:', emailData.subject)

    const emailContent = await fetchEmailFromResend(emailId)
    
    let emailBody = ''
    let fullHtml = ''
    
    if (emailContent) {
      const rawHtml = emailContent.html || ''
      
      // Try to extract only the original email HTML (remove reply text at the top if present)
      const extractedHtml = extractOriginalHtml(rawHtml)
      
      // If extraction found a reply marker and returned content, use it
      // Otherwise, use the full HTML (this is a new/original email, not a reply)
      fullHtml = extractedHtml || rawHtml
      
      // For body text, use the text version or strip HTML
      emailBody = emailContent.text || (emailContent.html ? stripHtml(emailContent.html) : '')
    }

    if (!emailBody) {
      emailBody = '(No body text available)'
    }

    console.log('Final body length:', emailBody.length)
    console.log('Body preview:', emailBody.substring(0, 200))
    console.log('Has full HTML:', !!fullHtml)
    console.log('HTML length:', fullHtml.length)

  const fromField = Array.isArray(emailData.from) ? emailData.from[0] : emailData.from
  const toField = Array.isArray(emailData.to) ? emailData.to[0] : emailData.to
  const contactEmailHeader = findHeaderValue(emailData as Record<string, unknown>, 'x-acnhs-contact-email')
  const replyToField = findReplyToAddress(emailData as Record<string, unknown>) || contactEmailHeader
    
    let senderEmail = 'unknown@unknown.com'
    if (fromField) {
      if (typeof fromField === 'string' && fromField.includes('<') && fromField.includes('>')) {
        const match = fromField.match(/<(.+?)>/)
        senderEmail = match ? match[1] : fromField
      } else {
        senderEmail = fromField
      }
    }

    let recipientEmail = 'unknown@acnhs.am'
    if (toField) {
      if (typeof toField === 'string' && toField.includes('<') && toField.includes('>')) {
        const match = toField.match(/<(.+?)>/)
        recipientEmail = match ? match[1] : toField
      } else {
        recipientEmail = toField
      }
    }

    // For contact form submissions (from=to=student-services@acnhs.am), use reply_to as sender
    let actualSender = senderEmail
    const senderIsAcnhs = senderEmail.toLowerCase().includes('acnhs.am')
    const recipientIsAcnhs = recipientEmail.toLowerCase().includes('acnhs.am')
    const shouldOverrideSender = replyToField && (contactEmailHeader || (senderIsAcnhs && recipientIsAcnhs))

    if (shouldOverrideSender) {
      actualSender = replyToField
      console.log('Contact form detected - overriding sender with:', actualSender)
    }

    console.log('Final - Sender:', actualSender, 'Recipient:', recipientEmail, 'Reply-To:', replyToField || 'none')

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    const normalizedSender = normalizeEmailAddress(actualSender) || actualSender
    const normalizedRecipient = normalizeEmailAddress(recipientEmail) || recipientEmail
    const storedAttachments = await processInboundAttachments({
      emailId,
      emailContent: emailContent as Record<string, unknown> | null,
      emailData,
      supabase
    })

    console.log('Attachments processed:', storedAttachments.length)

    const { data, error } = await supabase
      .from('email_history')
      .insert([{ 
        recipient: normalizedRecipient,
        sender: normalizedSender,
        subject: emailData.subject,
        body: emailBody.substring(0, 5000),
        html_body: fullHtml ? fullHtml.substring(0, 50000) : null,
        status: 'received',
        sent_at: new Date().toISOString(),
        attachments: storedAttachments.length ? storedAttachments : null
      }])
      .select()

    if (error) {
      console.error('Database save error:', error)
      throw error
    }

    console.log('Email saved to database with HTML content')

    // CRITICAL FIX: Forward the email to admin inbox
    try {
      console.log('Forwarding email to admin inbox...')
      
      // Build forwarded email HTML with proper formatting
      const forwardedHtml = `
        <div style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto;">
          <div style="background: #f3f4f6; padding: 16px; border-radius: 8px; margin-bottom: 20px;">
            <h3 style="margin: 0 0 12px 0; color: #374151;">📧 Forwarded Email</h3>
            <table style="width: 100%; font-size: 14px; color: #6b7280;">
              <tr>
                <td style="padding: 4px 0;"><strong>From:</strong></td>
                <td style="padding: 4px 0;">${actualSender}</td>
              </tr>
              <tr>
                <td style="padding: 4px 0;"><strong>To:</strong></td>
                <td style="padding: 4px 0;">${recipientEmail}</td>
              </tr>
              <tr>
                <td style="padding: 4px 0;"><strong>Subject:</strong></td>
                <td style="padding: 4px 0;">${emailData.subject || '(No Subject)'}</td>
              </tr>
              <tr>
                <td style="padding: 4px 0;"><strong>Date:</strong></td>
                <td style="padding: 4px 0;">${new Date().toLocaleString()}</td>
              </tr>
              ${storedAttachments.length > 0 ? `
              <tr>
                <td style="padding: 4px 0;"><strong>Attachments:</strong></td>
                <td style="padding: 4px 0;">${storedAttachments.length} file(s)</td>
              </tr>
              ` : ''}
            </table>
          </div>
          <div style="border-top: 2px solid #e5e7eb; padding-top: 20px;">
            ${fullHtml || emailBody.replace(/\n/g, '<br>')}
          </div>
          ${storedAttachments.length > 0 ? `
          <div style="margin-top: 20px; padding: 16px; background: #fef3c7; border-radius: 8px;">
            <h4 style="margin: 0 0 8px 0; color: #92400e;">📎 Attachments:</h4>
            <ul style="margin: 0; padding-left: 20px;">
              ${storedAttachments.map(att => `
                <li><a href="${att.public_url}" style="color: #2563eb;">${att.filename}</a> (${((att.size as number) / 1024).toFixed(1)} KB)</li>
              `).join('')}
            </ul>
          </div>
          ` : ''}
        </div>
      `
      
      // Forward to admin email (Hrachfilm@gmail.com)
      const forwardResponse = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${RESEND_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: 'do-not-reply@acnhs.am',
          to: ['Hrachfilm@gmail.com'],
          subject: `FWD: ${emailData.subject || '(No Subject)'}`,
          html: forwardedHtml,
          reply_to: actualSender // Reply goes to original sender
        })
      })
      
      if (forwardResponse.ok) {
        console.log('✅ Email forwarded to admin inbox successfully')
      } else {
        const errorData = await forwardResponse.json()
        console.error('❌ Failed to forward email:', errorData)
      }
    } catch (forwardError) {
      console.error('Error forwarding email to admin:', forwardError)
      // Don't fail the webhook - email is still saved to database
    }

    return new Response(
      JSON.stringify({ success: true, message: 'Email received and saved' }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Error processing inbound email:', error)
    return new Response(
      JSON.stringify({ success: false, error: (error as Error).message || 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
