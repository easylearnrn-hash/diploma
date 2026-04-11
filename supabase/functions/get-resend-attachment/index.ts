import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY_DIPLOMA') || Deno.env.get('RESEND_API_KEY') || ''
    
    if (!RESEND_API_KEY) {
      throw new Error('Missing Resend API Key')
    }

    const { emailId, attachmentId } = await req.json()

    if (!emailId || !attachmentId) {
      throw new Error('Missing emailId or attachmentId')
    }

    const response = await fetch(`https://api.resend.com/emails/receiving/${emailId}/attachments/${attachmentId}`, {
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`
      }
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Resend API error: ${response.status} ${errorText}`)
    }

    const data = await response.json()

    return new Response(
      JSON.stringify(data),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
