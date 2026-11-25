// Supabase Edge Function: render-pdf
// Deploy: supabase functions deploy render-pdf --project-ref eyhksbiceueoiamwnqpr
// Setup:  see RENDER-PDF-SETUP.md in the project root

import { handleRender } from './handler.ts'

Deno.serve((req) =>
  handleRender(req, {
    env: (name) => Deno.env.get(name),
    fetchFn: fetch,
  })
)
