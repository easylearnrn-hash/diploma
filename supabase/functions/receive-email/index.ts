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
      
      // Extract only the original email HTML (remove the reply text at the top)
      fullHtml = extractOriginalHtml(rawHtml)
      
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

    console.log('Final - Sender:', senderEmail, 'Recipient:', recipientEmail)

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    const { data, error } = await supabase
      .from('email_history')
      .insert([{ 
        recipient: recipientEmail,
        sender: senderEmail,
        subject: emailData.subject,
        body: emailBody.substring(0, 5000),
        html_body: fullHtml ? fullHtml.substring(0, 50000) : null,
        status: 'received',
        sent_at: new Date().toISOString()
      }])
      .select()

    if (error) {
      console.error('Database save error:', error)
      throw error
    }

    console.log('Email saved to database with HTML content')

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
