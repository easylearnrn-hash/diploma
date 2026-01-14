// Supabase Edge Function to send emails via Resend API
// This function acts as a secure server-side proxy for sending emails

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from "../_shared/cors.ts"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY_DIPLOMA')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface EmailRequest {
  to: string
  subject: string
  html: string
  from?: string
  fromName?: string
  replyTo?: string
  attachments?: Array<{
    filename: string
    content: string
    type: string
  }>
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse request body
    const { to, subject, html, from, fromName, replyTo, attachments }: EmailRequest = await req.json()

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
    const emailPayload: any = {
      from: `${senderName} <${senderEmail}>`,
      to: [to],
      subject: subject,
      html: html,
      text: html.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').replace(/&amp;/g, '&'), // Fallback plain text version
    }

    // Add reply_to based on replyTo parameter or sender email
    const replyToEmail = replyTo || (senderEmail !== 'do-not-reply@acnhs.am' ? senderEmail : undefined)
    if (replyToEmail) {
      emailPayload.reply_to = replyToEmail
    }

    // Add attachments if provided
    if (attachments && attachments.length > 0) {
      emailPayload.attachments = attachments.map((att: any) => ({
        filename: att.filename,
        content: att.content
      }))
      console.log(`Adding ${attachments.length} attachment(s) to email`)
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

    // Save to email_history database
    try {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
      
      // For contact form emails (with replyTo), the sender is the student
      // For admin emails (no replyTo), the sender is the ACNHS email
      const emailSender = replyTo || senderEmail
      
      // Determine if this is incoming or outgoing
      // Incoming: Student/External → ACNHS (recipient is @acnhs.am)
      // Outgoing: ACNHS → Student/External (sender is @acnhs.am)
      const isIncoming = to.toLowerCase().includes('@acnhs.am')
      const emailStatus = isIncoming ? 'received' : 'sent'
      
      console.log('Attempting to save email to database:', {
        recipient: to,
        sender: emailSender,
        subject: subject,
        direction: isIncoming ? '📥 Incoming' : '📤 Outgoing',
        status: emailStatus
      })
      
      const { data, error } = await supabase
        .from('email_history')
        .insert([{
          recipient: to,
          sender: emailSender,
          subject: subject,
          body: html.replace(/<[^>]*>/g, '').substring(0, 500), // Strip HTML tags for preview
          html_body: html.substring(0, 50000), // Store full HTML for display (limit 50KB)
          status: emailStatus,
          sent_at: new Date().toISOString(),
          resend_id: resendData.id
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
    console.error('Edge function error:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Internal server error' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
