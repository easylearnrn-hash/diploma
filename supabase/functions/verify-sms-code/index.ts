// Supabase Edge Function for verifying SMS codes
// Deploy: supabase functions deploy verify-sms-code

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface VerifyRequest {
  phoneNumber: string
  code: string
  purpose: 'admission' | 'login' | 'password-reset'
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
    const { phoneNumber, code, purpose }: VerifyRequest = await req.json()

    // Validate inputs
    if (!phoneNumber || !code || !purpose) {
      return new Response(
        JSON.stringify({
          error: 'Missing required fields',
          success: false,
        }),
        {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        }
      )
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Find the verification record
    const { data: verification, error: fetchError } = await supabase
      .from('sms_verifications')
      .select('*')
      .eq('phone_number', phoneNumber)
      .eq('code', code)
      .eq('purpose', purpose)
      .eq('verified', false)
      .single()

    if (fetchError || !verification) {
      return new Response(
        JSON.stringify({
          error: 'Invalid or expired verification code',
          success: false,
        }),
        {
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        }
      )
    }

    // Check if code is expired
    const expiresAt = new Date(verification.expires_at)
    if (expiresAt < new Date()) {
      return new Response(
        JSON.stringify({
          error: 'Verification code has expired',
          success: false,
        }),
        {
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
          },
        }
      )
    }

    // Mark as verified
    const { error: updateError } = await supabase
      .from('sms_verifications')
      .update({
        verified: true,
        verified_at: new Date().toISOString(),
      })
      .eq('id', verification.id)

    if (updateError) {
      console.error('Error updating verification:', updateError)
      return new Response(
        JSON.stringify({
          error: 'Failed to verify code',
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

    console.log(`Phone number ${phoneNumber} verified successfully`)

    return new Response(
      JSON.stringify({
        success: true,
        verified: true,
        phoneNumber: phoneNumber,
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
    console.error('Error verifying code:', error)
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
