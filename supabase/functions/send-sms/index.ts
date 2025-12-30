// Supabase Edge Function for sending SMS via Twilio
// Deploy: supabase functions deploy send-sms

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const TWILIO_ACCOUNT_SID = Deno.env.get('TWILIO_ACCOUNT_SID')!
const TWILIO_AUTH_TOKEN = Deno.env.get('TWILIO_AUTH_TOKEN')!
const TWILIO_PHONE_NUMBER = Deno.env.get('TWILIO_PHONE_NUMBER')!

interface SMSRequest {
  to: string
  message: string
  type?: 'admission' | 'notification' | 'verification' | 'reminder'
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
    // Parse request body
    const { to, message, type = 'notification' }: SMSRequest = await req.json()

    // Validate phone number (US format)
    const phoneRegex = /^\+1[2-9]\d{9}$/
    if (!phoneRegex.test(to)) {
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

    // Validate message length
    if (!message || message.length > 1600) {
      return new Response(
        JSON.stringify({
          error: 'Message must be between 1 and 1600 characters',
          success: false,
        }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        }
      )
    }

    // Prepare Twilio API request
    const params = new URLSearchParams({
      To: to,
      From: TWILIO_PHONE_NUMBER,
      Body: message,
    })

    // Send SMS via Twilio
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
          error: data.message || 'Failed to send SMS',
          success: false,
          code: data.code,
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

    // Log success (optional: store in Supabase database)
    console.log(`SMS sent successfully to ${to}. SID: ${data.sid}`)

    return new Response(
      JSON.stringify({
        success: true,
        messageSid: data.sid,
        status: data.status,
        to: data.to,
        type,
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
    console.error('Error sending SMS:', error)
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
