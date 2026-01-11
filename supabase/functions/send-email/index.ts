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
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse request body
    const { to, subject, html, from, fromName, replyTo }: EmailRequest = await req.json()

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
      'admissions@acnhs.am': 'ACNHS Admissions',
      'info@acnhs.am': 'ACNHS Office',
      'documents@acnhs.am': 'ACNHS Documents',
      'international@acnhs.am': 'ACNHS International Relations',
      'registrar@acnhs.am': 'ACNHS Registrar',
      'finance@acnhs.am': 'ACNHS Finance',
      'ceo@acnhs.am': 'ACNHS CEO',
      'dean@acnhs.am': 'ACNHS Dean',
      'academic@acnhs.am': 'ACNHS Academic Affairs',
      'student-services@acnhs.am': 'ACNHS Student Services',
      'legal@acnhs.am': 'ACNHS Legal',
      'hr@acnhs.am': 'ACNHS Human Resources',
      'it@acnhs.am': 'ACNHS IT Support',
      'library@acnhs.am': 'ACNHS Library',
      'alumni@acnhs.am': 'ACNHS Alumni Relations',
      'research@acnhs.am': 'ACNHS Research',
      'do-not-reply@acnhs.am': 'ACNHS - Do Not Reply'
    }
    // Use provided fromName or fallback to default mapping or 'ACNHS'
    const senderName = fromName || defaultSenderNames[senderEmail] || 'ACNHS'

    // Build email payload with proper name format
    const emailPayload: any = {
      from: `"${senderName}" <${senderEmail}>`,
      to: [to],
      subject: subject,
      html: html,
    }

    // Add reply_to based on replyTo parameter or sender email
    const replyToEmail = replyTo || (senderEmail !== 'do-not-reply@acnhs.am' ? senderEmail : undefined)
    if (replyToEmail) {
      emailPayload.reply_to = replyToEmail
    }

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
      
      console.log('Attempting to save email to database:', {
        recipient: to,
        sender: emailSender,
        subject: subject
      })
      
      const { data, error } = await supabase
        .from('email_history')
        .insert([{
          recipient: to,
          sender: emailSender,
          subject: subject,
          body: html.replace(/<[^>]*>/g, '').substring(0, 500), // Strip HTML tags for preview
          status: 'sent',
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
