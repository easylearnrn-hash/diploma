// Supabase Edge Function to send emails via Resend API
// This function acts as a secure server-side proxy for sending emails

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from "../_shared/cors.ts"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY_DIPLOMA')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const ATTACHMENTS_BUCKET = 'email-attachments'
const GLOBAL_BCC_EMAIL = 'acnhs9@gmail.com'

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

async function storeAttachmentsInBucket(
  supabase: ReturnType<typeof createClient>,
  attachments: Array<{ filename: string; content: string; type?: string }> = [],
  direction: 'outgoing' | 'incoming' = 'outgoing'
) {
  if (!attachments || attachments.length === 0) return []

  const stored: Array<Record<string, unknown>> = []
  for (let index = 0; index < attachments.length; index++) {
    const attachment = attachments[index]
    try {
      if (!attachment?.content) continue
      const bytes = base64ToUint8Array(attachment.content)
      const sanitizedName = (attachment.filename || `attachment-${index}`).replace(/[^a-zA-Z0-9._-]/g, '_')
      const path = `${direction}/${Date.now()}-${index}-${sanitizedName}`

      const { data: uploadData, error: uploadError } = await supabase
        .storage
        .from(ATTACHMENTS_BUCKET)
        .upload(path, bytes, {
          contentType: attachment.type || 'application/octet-stream'
        })

      if (uploadError) {
        console.error('Attachment upload error:', uploadError)
        continue
      }

      const { data: publicUrlData } = supabase.storage.from(ATTACHMENTS_BUCKET).getPublicUrl(uploadData?.path || path)

      stored.push({
        filename: attachment.filename || sanitizedName,
        content_type: attachment.type || 'application/octet-stream',
        size: bytes.length,
        storage_path: uploadData?.path || path,
        public_url: publicUrlData?.publicUrl || null,
        direction
      })
    } catch (error) {
      console.error('Error processing attachment:', error)
    }
  }

  return stored
}

interface EmailRequest {
  to: string
  subject: string
  html: string
  text?: string
  from?: string
  fromName?: string
  replyTo?: string
  attachments?: Array<{
    filename: string
    content: string
    type: string
  }>
  headers?: Record<string, string>
}

serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse request body
  const { to, subject, html, text, from, fromName, replyTo, attachments, headers: customHeaders }: EmailRequest = await req.json()

    // Validate inputs
    if (!to || !subject || !html) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Missing required fields: to, subject, html' 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(to)) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Invalid email address format' 
        }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Determine sender name and email
    const senderEmail = from || 'admissions@acnhs.am'
    const defaultSenderNames: { [key: string]: string } = {
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
    // Use provided fromName or fallback to default mapping or 'ACNHS'
    const senderName = fromName || defaultSenderNames[senderEmail] || 'Armenian College of Nurses'

    // Build email payload with proper name format
    // CRITICAL: Send both html and text versions for better email client compatibility
    const strippedHtml = html.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&')
    
    // CRITICAL: Use ONLY inline base64 images - never extract to CID/attachments
    // This prevents logos from appearing as attachments to recipients
    // All email templates MUST embed images as data:image/... URLs
    
    const emailPayload: any = {
      from: `${senderName} <${senderEmail}>`,
      to: [to],
      bcc: [GLOBAL_BCC_EMAIL],
      subject: subject,
      html: html, // Use original HTML with inline base64 - no processing
      text: (text?.trim() || strippedHtml)
    }

    if (customHeaders && typeof customHeaders === 'object') {
      const filteredHeaders = Object.entries(customHeaders)
        .filter(([key, value]) => typeof key === 'string' && key && typeof value === 'string' && value.trim().length > 0)
        .reduce((acc, [key, value]) => {
          acc[key] = value
          return acc
        }, {} as Record<string, string>)

      if (Object.keys(filteredHeaders).length > 0) {
        emailPayload.headers = filteredHeaders
      }
    }

    // Add reply_to based on replyTo parameter or sender email
    const replyToEmail = replyTo || (senderEmail !== 'do-not-reply@acnhs.am' ? senderEmail : undefined)
    if (replyToEmail) {
      emailPayload.reply_to = replyToEmail
    }

    // Add attachments ONLY if explicitly provided (e.g., PDFs, documents)
    // NEVER extract images from HTML - they must be inline base64
    if (attachments && attachments.length > 0) {
      emailPayload.attachments = attachments.map((att: any) => ({
        filename: att.filename,
        content: att.content,
        type: att.type
      }))
      console.log(`Adding ${attachments.length} document attachment(s) (PDFs, etc.) - NOT extracting images from HTML`)
    }
    
    console.log('Sending email with payload:', {
      from: emailPayload.from,
      to: emailPayload.to,
      subject: emailPayload.subject,
      hasHtml: !!emailPayload.html,
      htmlLength: html?.length || 0
    })

    // Call Resend API
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailPayload),
    })

    const resendData = await resendResponse.json()

    // Check if Resend API call was successful
    if (!resendResponse.ok) {
      console.error('Resend API error:', resendData)
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: resendData.message || 'Failed to send email',
          details: resendData
        }),
        { 
          status: resendResponse.status, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log('✅ Email sent successfully via Resend:', resendData.id)

    // ========================================
    // AUTO-FORWARDING LOGIC
    // ========================================
    try {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
      const normalizedRecipient = normalizeEmailAddress(to)
      
      // Check if this is an incoming email to an ACNHS address
      if (normalizedRecipient?.endsWith('@acnhs.am')) {
        console.log('📧 Checking auto-forwarding rules for recipient:', normalizedRecipient)
        
        // Look up forwarding rule for this specific ACNHS email
        const { data: forwardingRule, error: ruleError } = await supabase
          .from('email_forwarding_rules')
          .select('forward_to_email, enabled, acnhs_email')
          .eq('acnhs_email', normalizedRecipient)
          .eq('enabled', true)
          .maybeSingle()

        if (!ruleError && forwardingRule && forwardingRule.forward_to_email) {
          console.log(`⤴️ Auto-forwarding enabled for ${normalizedRecipient} → ${forwardingRule.forward_to_email}`)
          
          // Forward the email
          const forwardPayload = {
            from: senderEmail || 'do-not-reply@acnhs.am',
            to: forwardingRule.forward_to_email,
            bcc: [GLOBAL_BCC_EMAIL],
            subject: `Fwd: ${subject}`,
            html: `
              <div style="padding: 20px; background: #f8f9fa; border-left: 4px solid #2dd4bf; margin-bottom: 20px;">
                <div style="font-weight: 600; color: #0a2540; margin-bottom: 8px;">📧 Forwarded Email</div>
                <div style="font-size: 14px; color: #64748b;">
                  <strong>From:</strong> ${replyTo || senderEmail}<br>
                  <strong>To:</strong> ${to}<br>
                  <strong>Date:</strong> ${new Date().toLocaleString()}<br>
                  <strong>Subject:</strong> ${subject}
                </div>
              </div>
              ${html}
            `,
            reply_to: replyTo || senderEmail
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
          } else {
            console.error('❌ Auto-forward failed:', forwardData)
          }
        } else {
          console.log('⏭️ No auto-forwarding rule configured for this recipient')
        }
      }
    } catch (forwardError) {
      console.error('⚠️ Error in auto-forwarding logic (non-fatal):', forwardError)
      // Don't fail the main request if forwarding fails
    }
    // ========================================
    // END AUTO-FORWARDING LOGIC
    // ========================================

    // Save to email_history database
    try {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
      
      // For contact form emails (with replyTo), the sender is the student
      // For admin emails (no replyTo), the sender is the ACNHS email
      const emailSender = normalizeEmailAddress(replyTo || senderEmail)
      const normalizedRecipient = normalizeEmailAddress(to)
      
      console.log('🔍 Routing check:', {
        senderEmail,
        to,
        replyTo,
        senderIsAcnhs: senderEmail?.toLowerCase().includes('acnhs.am'),
        recipientIsAcnhs: to?.toLowerCase().includes('acnhs.am'),
        hasReplyTo: !!replyTo,
        replyToIsExternal: replyTo ? !replyTo?.toLowerCase().includes('acnhs.am') : false
      })
      
      // Check if this is student-to-student email (both @acnhs.am)
      const senderIsAcnhs = emailSender?.toLowerCase().endsWith('@acnhs.am')
      const recipientIsAcnhs = normalizedRecipient?.toLowerCase().endsWith('@acnhs.am')
      const isStudentToStudent = senderIsAcnhs && recipientIsAcnhs
      
      console.log('🔍 Email type:', {
        isStudentToStudent,
        senderIsAcnhs,
        recipientIsAcnhs
      })
      
      // For student-to-student emails, create TWO records:
      // 1. One for the sender (status: 'sent')
      // 2. One for the recipient (status: 'received')
      if (isStudentToStudent) {
        console.log('📧 Student-to-student email detected - creating dual records')
        
        const textPreview = (text?.trim() || strippedHtml).substring(0, 500)
        const storedAttachments = await storeAttachmentsInBucket(
          supabase,
          attachments || [],
          'outgoing'
        )
        
        // Record 1: For the SENDER (shows in their "Sent" folder)
        const { data: senderRecord, error: senderError } = await supabase
          .from('email_history')
          .insert([{
            recipient: normalizedRecipient,
            sender: emailSender,
            subject: subject,
            body: textPreview,
            html_body: html.substring(0, 50000),
            status: 'sent',
            sent_at: new Date().toISOString(),
            resend_id: resendData.id,
            attachments: storedAttachments.length ? storedAttachments : null
          }])
          .select()
        
        if (senderError) {
          console.error('❌ Error creating sender record:', senderError)
        } else {
          console.log('✅ Sender record created:', senderRecord)
        }
        
        // Record 2: For the RECIPIENT (shows in their "Inbox")
        const { data: recipientRecord, error: recipientError } = await supabase
          .from('email_history')
          .insert([{
            recipient: normalizedRecipient,
            sender: emailSender,
            subject: subject,
            body: textPreview,
            html_body: html.substring(0, 50000),
            status: 'received',
            sent_at: new Date().toISOString(),
            resend_id: resendData.id,
            attachments: storedAttachments.length ? storedAttachments : null
          }])
          .select()
        
        if (recipientError) {
          console.error('❌ Error creating recipient record:', recipientError)
        } else {
          console.log('✅ Recipient record created:', recipientRecord)
        }
        
        return new Response(
          JSON.stringify({ 
            success: true, 
            message: 'Email sent successfully',
            id: resendData.id 
          }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      // Skip logging for external contact form submissions that route through ACNHS
      // These have: from=acnhs.am, to=acnhs.am, replyTo=student@external.com
      const isInternalRouting = 
        senderEmail?.toLowerCase().includes('acnhs.am') &&
        to?.toLowerCase().includes('acnhs.am') &&
        !!replyTo &&
        !replyTo?.toLowerCase().includes('acnhs.am')
      
      console.log('🔍 isInternalRouting:', isInternalRouting)
      
      if (isInternalRouting) {
        console.log('⏭️ Skipping database log for internal routing email (will be captured by receive-email webhook)')
        return new Response(
          JSON.stringify({ 
            success: true, 
            message: 'Email sent successfully',
            id: resendData.id 
          }),
          { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      
      // Determine if this is incoming or outgoing
      // Incoming: Student/External → ACNHS (recipient is @acnhs.am)
      // Outgoing: ACNHS → Student/External (sender is @acnhs.am)
      const isIncoming = normalizedRecipient?.endsWith('@acnhs.am') || false
      const emailStatus = isIncoming ? 'received' : 'sent'
      const textPreview = (text?.trim() || strippedHtml).substring(0, 500)
      const storedAttachments = await storeAttachmentsInBucket(
        supabase,
        attachments || [],
        isIncoming ? 'incoming' : 'outgoing'
      )
      
      console.log('Attempting to save email to database:', {
        recipient: normalizedRecipient,
        sender: emailSender,
        subject: subject,
        direction: isIncoming ? '📥 Incoming' : '📤 Outgoing',
        status: emailStatus,
        attachmentCount: storedAttachments.length
      })

      const { data, error } = await supabase
        .from('email_history')
        .insert([{
          recipient: normalizedRecipient,
          sender: emailSender,
          subject: subject,
          body: textPreview,
          html_body: html.substring(0, 50000), // Store full HTML for display (limit 50KB)
          status: emailStatus,
          sent_at: new Date().toISOString(),
          resend_id: resendData.id,
          attachments: storedAttachments.length ? storedAttachments : null
        }])
        .select()
      
      if (error) {
        console.error('Database save error:', error)
      } else {
        console.log('Email saved to history successfully:', data)
      }
    } catch (dbError) {
      console.error('Error saving to database (exception):', dbError)
      // Don't fail the request if database save fails
    }

    // Success response
    return new Response(
      JSON.stringify({ 
        success: true, 
        id: resendData.id,
        message: 'Email sent successfully'
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    const err = error instanceof Error ? error : new Error(String(error))
    console.error('Edge function error:', err)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: err.message || 'Internal server error' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
