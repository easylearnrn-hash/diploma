// Supabase Edge Function: admin-data
// Deploy: supabase functions deploy admin-data --project-ref eyhksbiceueoiamwnqpr
// Setup:  see DATA-LOCKDOWN-SETUP.md in the project root

import { handleAdminData } from './handler.ts'

Deno.serve((req) =>
  handleAdminData(req, {
    env: (name) => Deno.env.get(name),
    fetchFn: fetch,
  })
)
