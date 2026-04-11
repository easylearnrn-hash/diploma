// Supabase Edge Function to receive inbound emails via Resend webhook
// Resend webhooks only contain metadata - we fetch the actual body via API

// @ts-ignore
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// @ts-ignore
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from "./cors.ts"

declare const Deno: {
  env: {
    get: (key: string) => string | undefined
  }
}

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY_DIPLOMA') || Deno.env.get('RESEND_API_KEY') || ''
const RESEND_WEBHOOK_SECRET = Deno.env.get('RESEND_WEBHOOK_SECRET') // Optional: for signature verification
const ATTACHMENTS_BUCKET = 'email-attachments'
const DISABLE_EMAIL_FORWARDING = (Deno.env.get('DISABLE_EMAIL_FORWARDING') || '').toLowerCase() === 'true'

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

    const resultJson = await response.json();
    
    // Resend's API now returns JSON with a `download_url` for larger
    // or standalone attachments, or `content` for embedded base64
    if (resultJson.download_url) {
       console.log('Found download_url, fetching binary directly...');
       return await fetchAttachmentBytesFromUrl(resultJson.download_url);
    }
    
    if (resultJson.content) {
      let base64str = String(resultJson.content);
      if (base64str.includes('base64,')) base64str = base64str.split('base64,')[1];
      base64str = base64str.replace(/-/g, '+').replace(/_/g, '/');
      base64str = base64str.replace(/[^A-Za-z0-9+/=]/g, '');

      const binaryString = atob(base64str);
      const bytes = new Uint8Array(binaryString.length);
      for (let i = 0; i < binaryString.length; i++) {
        bytes[i] = binaryString.charCodeAt(i);
      }
      return bytes;
    }
    return null;
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

async function fetchEmailFromResend(emailId: string): Promise<{ html?: string; text?: string; error?: string } | null> {
  try {
    console.log('Fetching email content for ID:', emailId)

    if (!RESEND_API_KEY) {
      const errorMessage = 'Missing RESEND_API_KEY_DIPLOMA/RESEND_API_KEY in function secrets'
      console.error(errorMessage)
      return { error: errorMessage }
    }
    
    // Try inbound endpoint first, fall back to outbound endpoint
    let response = await fetch('https://api.resend.com/emails/receiving/' + emailId, {
      headers: {
        'Authorization': 'Bearer ' + RESEND_API_KEY
      }
    })

    if (!response.ok && (response.status === 404 || response.status === 422)) {
      console.log('Inbound endpoint returned', response.status, '— trying outbound endpoint')
      response = await fetch('https://api.resend.com/emails/' + emailId, {
        headers: {
          'Authorization': 'Bearer ' + RESEND_API_KEY
        }
      })
    }

    if (!response.ok) {
      const errorText = await response.text()
      const errorMessage = `Resend API error ${response.status} ${response.statusText}: ${errorText}`
      console.error(errorMessage)
      return { error: errorMessage }
    }

    const emailData = await response.json()
    console.log('Successfully fetched email from Resend')
    console.log('Has HTML:', !!emailData.html)
    console.log('Has text:', !!emailData.text)
    console.log('HTML length:', emailData.html?.length || 0)
    console.log('Text length:', emailData.text?.length || 0)
    console.log('Text preview:', emailData.text?.substring(0, 100) || 'No text')
    console.log('HTML preview:', emailData.html?.substring(0, 100) || 'No HTML')
    
    return {
      html: emailData.html,
      text: emailData.text
    }
  } catch (error) {
    const errorMessage = `Error fetching email from Resend: ${(error as Error).message || String(error)}`
    console.error(errorMessage)
    return { error: errorMessage }
  }
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  console.log('Webhook request received')
  console.log('Headers:', Object.fromEntries(req.headers.entries()))
  console.log('Method:', req.method)

  try {
    // Get raw body for signature verification if needed
    const rawBody = await req.text()
    console.log('Raw body length:', rawBody.length)
    
    let payload
    try {
      payload = JSON.parse(rawBody)
    } catch (parseError) {
      console.error('Failed to parse JSON:', parseError)
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid JSON' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log('Webhook type:', payload.type)
    console.log('Payload:', JSON.stringify(payload, null, 2))

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    if (payload.type === 'fetch-body') {
      const fetchData = payload.data || payload
      const recordId = fetchData?.record_id
      const resendId = fetchData?.email_id

      if (!recordId || !resendId) {
        return new Response(
          JSON.stringify({ success: false, error: 'Missing record_id or email_id' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const emailContent = await fetchEmailFromResend(resendId)
      if (!emailContent || emailContent.error) {
        return new Response(
          JSON.stringify({ success: false, error: emailContent?.error || 'Failed to fetch email content from Resend' }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      const rawHtml = emailContent.html || ''
      const extractedHtml = extractOriginalHtml(rawHtml)
      const fullHtml = extractedHtml || rawHtml
      const emailBody = (emailContent.text || stripHtml(rawHtml) || '').trim()

      const { error: updateError } = await supabase
        .from('email_history')
        .update({
          body: emailBody || '(No body text available)',
          html_body: fullHtml ? fullHtml.substring(0, 50000) : null,
          error: null
        })
        .eq('id', recordId)

      if (updateError) {
        return new Response(
          JSON.stringify({ success: false, error: updateError.message || 'Failed to update email body' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify({ success: true, body: emailBody, html_body: fullHtml || null }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    
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
  const fetchError = emailContent?.error || null
    
    let emailBody = ''
    let fullHtml = ''
    
    if (emailContent && !emailContent.error) {
      const rawHtml = emailContent.html || ''
      const rawText = emailContent.text || ''
      
      console.log('Raw text length:', rawText.length)
      console.log('Raw HTML length:', rawHtml.length)
      
      // Try to extract only the original email HTML (remove reply text at the top if present)
      const extractedHtml = extractOriginalHtml(rawHtml)
      
      // If extraction found a reply marker and returned content, use it
      // Otherwise, use the full HTML (this is a new/original email, not a reply)
      fullHtml = extractedHtml || rawHtml
      
      // For body text, prefer the text version, but fall back to stripped HTML
      if (rawText && rawText.trim()) {
        emailBody = rawText.trim()
      } else if (rawHtml) {
        const stripped = stripHtml(rawHtml)
        emailBody = stripped.trim()
      }
    }

    // Only use fallback if we truly have no content
    if (!emailBody || emailBody.trim() === '') {
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

    const normalizedSender = normalizeEmailAddress(actualSender) || actualSender
    const normalizedRecipient = normalizeEmailAddress(recipientEmail) || recipientEmail
    const storedAttachments = await processInboundAttachments({
      emailId,
      emailContent: emailContent as Record<string, unknown> | null,
      emailData,
      supabase
    })

    console.log('Attachments processed:', storedAttachments.length)

    // ── DEDUPLICATION: skip if this resend_id was already stored ──────────
    if (emailId) {
      const { data: existingRecord } = await supabase
        .from('email_history')
        .select('id')
        .eq('resend_id', emailId)
        .maybeSingle()

      if (existingRecord) {
        console.log(`⚠️ Duplicate webhook: email_id ${emailId} already stored — skipping insert and forward`)
        return new Response(
          JSON.stringify({ success: true, message: 'Duplicate — already processed' }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

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
        attachments: storedAttachments.length ? storedAttachments : null,
        resend_id: emailId,
        error: fetchError
      }])
      .select()

    if (error) {
      console.error('Database save error:', error)
      throw error
    }

    console.log('Email saved to database with HTML content')

    // ========================================
    // AUTO-FORWARDING LOGIC FOR INCOMING EMAILS
    // ========================================
    try {
      if (DISABLE_EMAIL_FORWARDING) {
        console.log('⛔ Auto-forwarding disabled via DISABLE_EMAIL_FORWARDING=true')
      } else if (
        normalizedRecipient?.endsWith('@acnhs.am') ||
        normalizedRecipient?.endsWith('@acnhs.us') ||
        normalizedRecipient?.endsWith('@ana-us.com')
      ) {
        console.log('📧 Checking auto-forwarding rules for recipient:', normalizedRecipient)

        // ── LOOP-BREAK GUARD 1: never forward system-generated emails ──
        // Emails sent BY the system (hub@acnhs.am, do-not-reply@acnhs.am, etc.) or
        // BETWEEN ACNHS addresses must never be forwarded — doing so causes infinite loops
        // because the forwarded copy arrives back at an @acnhs.am inbox and triggers again.
        const senderIsAcnhsDomain = normalizedSender?.endsWith('@acnhs.am') ?? false
        const isSystemSender = [
          'hub@acnhs.am',
          'do-not-reply@acnhs.am',
          'noreply@acnhs.am',
          'admissions@acnhs.am',
          'info@acnhs.am',
          'student-services@acnhs.am',
        ].includes(normalizedSender || '')

        if (senderIsAcnhsDomain || isSystemSender) {
          console.log(`⏭️ Skipping forward — sender is ACNHS address (${normalizedSender}). Forwarding this would cause a loop.`)
          // Fall through to normal response — no forwarding
        } else {

        // ── LOOP-BREAK GUARD 2: never forward already-forwarded emails ──
        // If the inbound email already carries X-Forwarded-From (set by us when we forward),
        // it is a forwarded copy arriving back via the recipient's own inbox — skip it.
        const alreadyForwarded = !!(
          findHeaderValue(emailData as Record<string, unknown>, 'x-forwarded-from') ||
          findHeaderValue(emailData as Record<string, unknown>, 'x-acnhs-forwarded')
        )

        if (alreadyForwarded) {
          console.log('⏭️ Skipping forward — email already carries X-Forwarded-From header (forwarding loop detected)')
        } else {

        // Look up forwarding rule for this specific ACNHS email
        const { data: forwardingRule, error: ruleError } = await supabase
          .from('email_forwarding_rules')
          .select('forward_to_email, enabled, acnhs_email')
          .eq('acnhs_email', normalizedRecipient)
          .eq('enabled', true)
          .maybeSingle()

        if (!ruleError && forwardingRule && forwardingRule.forward_to_email) {
          console.log(`⤴️ Auto-forwarding enabled for ${normalizedRecipient} → ${forwardingRule.forward_to_email}`)

          const forwardToNormalized = normalizeEmailAddress(forwardingRule.forward_to_email)
          const forwardToIsAcnhs = (
            forwardToNormalized?.endsWith('@acnhs.am') ||
            forwardToNormalized?.endsWith('@acnhs.us') ||
            forwardToNormalized?.endsWith('@ana-us.com')
          ) ?? false
          const isSelfForward = forwardToNormalized === normalizedRecipient
          const isSenderForward = forwardToNormalized === normalizedSender

          if (forwardToIsAcnhs || isSelfForward || isSenderForward) {
            console.log('⛔ Skipping forward — unsafe target (ACNHS domain or self/sender).', {
              forwardTo: forwardToNormalized,
              normalizedRecipient,
              normalizedSender
            })
          } else {
          
          // Forward the email via Resend API - preserving original sender identity
          const forwardFromEmail = normalizedRecipient || 'admissions@acnhs.am'
          const defaultSenderNames: Record<string, string> = {
            'admissions@acnhs.am': 'Admissions Office - ACNHS',
            'info@acnhs.am': 'Information Office - ACNHS',
            'documents@acnhs.am': 'Records & Documentation - ACNHS',
            'international@acnhs.am': 'International Relations - ACNHS',
            'registrar@acnhs.am': 'Registrar Office - ACNHS',
            'finance@acnhs.am': 'Finance Department - ACNHS',
            'ceo@acnhs.am': 'Chief Executive Officer - ACNHS',
            'dean@acnhs.am': 'Office of the Dean - ACNHS',
            'academic@acnhs.am': 'Academic Affairs - ACNHS',
            'student-services@acnhs.am': 'Student Services - ACNHS',
            'legal@acnhs.am': 'Legal Affairs - ACNHS',
            'hr@acnhs.am': 'Human Resources - ACNHS',
            'it@acnhs.am': 'IT Support - ACNHS',
            'library@acnhs.am': 'Library & Resources - ACNHS',
            'alumni@acnhs.am': 'Alumni Relations - ACNHS',
            'research@acnhs.am': 'Research Department - ACNHS',
            'do-not-reply@acnhs.am': 'ACNHS Notifications'
          }
          const forwardFromName = defaultSenderNames[forwardFromEmail] || 'ACNHS'
          const originalFromHeader = (typeof fromField === 'string' && fromField.trim().length > 0)
            ? fromField.trim()
            : actualSender
          const originalFromAddress = normalizeEmailAddress(originalFromHeader) || actualSender
          const originalFromForResend = originalFromHeader.includes('<')
            ? originalFromHeader
            : originalFromAddress

          const rawDisplayName = originalFromHeader.includes('<')
            ? originalFromHeader.split('<')[0].trim()
            : ''
          const cleanedDisplayName = rawDisplayName.replace(/^"|"$/g, '').trim()
          const forwardFromDisplayName = cleanedDisplayName
            ? `${cleanedDisplayName} (${originalFromAddress})`
            : originalFromAddress

          const forwardPayload = {
            from: `${forwardFromDisplayName} <${forwardFromEmail}>`,
            to: forwardingRule.forward_to_email,
            subject: emailData.subject || '(No Subject)',
            html: fullHtml || emailBody.replace(/\n/g, '<br>'),
            reply_to: originalFromAddress,
            headers: {
              'X-Forwarded-From': normalizedRecipient,
              'X-Original-Sender': originalFromAddress,
              'X-Forwarded-To': recipientEmail,
              'X-ACNHS-Forwarded': 'true'
            }
          }

          const forwardResponse = await fetch('https://api.resend.com/emails', {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${RESEND_API_KEY}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(forwardPayload),
          })

          const forwardData = await forwardResponse.json()

          if (forwardResponse.ok) {
            console.log(`✅ Email auto-forwarded successfully to ${forwardingRule.forward_to_email}:`, forwardData.id)
            
            // Log the forwarding action in email_history
            await supabase
              .from('email_history')
              .insert([{
                recipient: forwardingRule.forward_to_email,
                sender: originalFromAddress,
                subject: `Fwd: ${emailData.subject || '(No Subject)'}`,
                body: `Forwarded from ${normalizedRecipient}`,
                status: 'sent',
                sent_at: new Date().toISOString(),
                sent_by_admin: 'system-auto-forward'
              }])
          } else {
            console.error('❌ Auto-forward failed:', forwardData)
          }
          }
        } else {
          console.log('⏭️ No auto-forwarding rule enabled for this recipient')
        }

        } // end: !alreadyForwarded
        } // end: !senderIsAcnhsDomain && !isSystemSender
      }
    } catch (forwardError) {
      console.error('⚠️ Error in auto-forwarding logic (non-fatal):', forwardError)
      // Don't fail the main function - forwarding is optional
    }
    // ========================================
    // END AUTO-FORWARDING LOGIC
    // ========================================

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
