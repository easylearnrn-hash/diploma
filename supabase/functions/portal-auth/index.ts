// Supabase Edge Function: portal-auth
// Deploy: supabase functions deploy portal-auth --project-ref eyhksbiceueoiamwnqpr
// Setup:  see PORTAL-AUTH-SETUP.md in the project root

import { handlePortalAuth } from './handler.ts'

Deno.serve((req) =>
  handlePortalAuth(req, {
    env: (name) => Deno.env.get(name),
    fetchFn: fetch,
  })
)
