// Supabase Edge Function for sending verification codes via SMS
// Deploy: supabase functions deploy send-verification-sms

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const TWILIO_ACCOUNT_SID = Deno.env.get('TWILIO_ACCOUNT_SID')!
const TWILIO_AUTH_TOKEN = Deno.env.get('TWILIO_AUTH_TOKEN')!
const TWILIO_PHONE_NUMBER = Deno.env.get('TWILIO_PHONE_NUMBER')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface VerificationRequest {
  phoneNumber: string
  purpose: 'admission' | 'login' | 'password-reset'
}

// Generate 6-digit verification code
function generateCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString()
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    const { phoneNumber, purpose }: VerificationRequest = await req.json()

    // Validate phone number
    const phoneRegex = /^\+1[2-9]\d{9}$/
    if (!phoneRegex.test(phoneNumber)) {
      return new Response(
        JSON.stringify({
          error: 'Invalid US phone number. Format: +1XXXXXXXXXX',
          success: false,
        }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        }
      )
    }

    // Generate verification code
    const code = generateCode()
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000) // 10 minutes

    // Store verification code in Supabase (optional but recommended)
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    
    const { error: dbError } = await supabase
      .from('sms_verifications')
      .insert({
        phone_number: phoneNumber,
        code: code,
        purpose: purpose,
        expires_at: expiresAt.toISOString(),
        verified: false,
      })

    if (dbError) {
      console.error('Database error:', dbError)
      // Continue anyway - SMS can still be sent
    }

    // Prepare SMS message
    const messages = {
      admission: `Your Armenian College of Nursing verification code is: ${code}. Valid for 10 minutes. Do not share this code.`,
      login: `Your login verification code is: ${code}. Valid for 10 minutes.`,
      'password-reset': `Your password reset code is: ${code}. Valid for 10 minutes. If you didn't request this, ignore this message.`,
    }

    const message = messages[purpose]

    // Send SMS via Twilio
    const params = new URLSearchParams({
      To: phoneNumber,
      From: TWILIO_PHONE_NUMBER,
      Body: message,
    })

    const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json`
    const auth = btoa(`${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}`)

    const response = await fetch(twilioUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: params.toString(),
    })

    const data = await response.json()

    if (!response.ok) {
      console.error('Twilio error:', data)
      return new Response(
        JSON.stringify({
          error: data.message || 'Failed to send verification SMS',
          success: false,
        }),
        {
          status: response.status,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        }
      )
    }

    console.log(`Verification SMS sent to ${phoneNumber}. SID: ${data.sid}`)

    return new Response(
      JSON.stringify({
        success: true,
        messageSid: data.sid,
        expiresAt: expiresAt.toISOString(),
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  } catch (error) {
    console.error('Error sending verification SMS:', error)
    return new Response(
      JSON.stringify({
        error: error.message,
        success: false,
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    )
  }
})
