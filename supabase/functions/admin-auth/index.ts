// Supabase Edge Function: admin-auth
// Deploy: supabase functions deploy admin-auth --project-ref eyhksbiceueoiamwnqpr

import { handleAdminAuth } from './handler.ts'

Deno.serve((req) =>
  handleAdminAuth(req, {
    env: (name) => Deno.env.get(name),
    fetchFn: fetch,
  })
)
