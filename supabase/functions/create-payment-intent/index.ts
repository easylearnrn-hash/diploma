// Supabase Edge Function — Create Stripe PaymentIntent
// Deploy: supabase functions deploy create-payment-intent
// Secret:  supabase secrets set STRIPE_SECRET_KEY=sk_live_...

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY')!

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface PaymentIntentRequest {
  amount: number          // in cents, e.g. 5000 = $50.00
  currency: string        // e.g. 'usd'
  payment_method?: string // 'card' | 'us_bank_account' — restricts PaymentIntent to one method
  application_id?: string
  control_number?: string
  applicant_name?: string
  description?: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS })
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    })
  }

  try {
    const body: PaymentIntentRequest = await req.json()
    const { amount, currency, payment_method, application_id, control_number, applicant_name, description } = body

    // Validate required fields
    if (!amount || amount < 50) {
      return new Response(JSON.stringify({ error: 'Invalid amount.' }), {
        status: 400,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      })
    }
    if (!currency || currency.length !== 3) {
      return new Response(JSON.stringify({ error: 'Invalid currency.' }), {
        status: 400,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      })
    }

    // Build Stripe PaymentIntent request
    // Restrict to the method chosen on the client so the fee calculation stays correct
    const allowedMethod = payment_method === 'us_bank_account' ? 'us_bank_account' : 'card'
    const stripeParams = new URLSearchParams({
      amount:      String(amount),
      currency:    currency.toLowerCase(),
      description: description || 'ACNHS Application Filing Fee',
      'payment_method_types[]': allowedMethod,
    })

    // Attach metadata for reconciliation
    if (application_id) stripeParams.append('metadata[application_id]', application_id)
    if (control_number) stripeParams.append('metadata[control_number]', control_number)
    if (applicant_name) stripeParams.append('metadata[applicant_name]', applicant_name)

    // Call Stripe API
    const stripeRes = await fetch('https://api.stripe.com/v1/payment_intents', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
        'Content-Type':  'application/x-www-form-urlencoded',
        'Stripe-Version': '2023-10-16',
      },
      body: stripeParams.toString(),
    })

    const paymentIntent = await stripeRes.json()

    if (!stripeRes.ok) {
      console.error('Stripe error:', paymentIntent)
      return new Response(JSON.stringify({ error: paymentIntent.error?.message || 'Stripe error.' }), {
        status: stripeRes.status,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      })
    }

    return new Response(JSON.stringify({ clientSecret: paymentIntent.client_secret }), {
      status: 200,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    })

  } catch (err) {
    console.error('Unexpected error:', err)
    return new Response(JSON.stringify({ error: 'Internal server error.' }), {
      status: 500,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    })
  }
})
