# Data lockdown (admin data behind the admin session)

The public (anon) key is in every page, so any table it can read or write is public. Tables are being closed in phases.

## How admin pages keep working
`js/supabase-config.js` wraps the Supabase client's `fetch`. A request for a table listed in `PROXIED_TABLES` is sent to the
**`admin-data` Edge Function** instead of `/rest/v1`, with the signed admin token (`adminToken`, from admin-auth). The function checks
the token and that the admin is still active, then replays the identical request (method, query, body, `Prefer`, `Range`, `Accept`)
against PostgREST with the service role and returns the answer unchanged. Page code did not change.
- Only tables in `ADMIN_TABLES` (`supabase/functions/admin-data/handler.ts`) can be reached; `admin_users`, `application_secrets`,
  `teachers`, `applications`, RPC functions, etc. never can. Keep `PROXIED_TABLES` (browser) and `ADMIN_TABLES` (server) identical.
- A session opened before the update has no token: the page asks the admin to sign in again.

## Phase 1 (admin-only tables)
`documents`, (`email_configuration` is routed too but the table does not exist), `email_folder_rules`, `email_folders`, `email_forwarding_rules`, `email_spam_blocked`,
`invoice_drafts`, `invoice_templates`, `monthly_expenses`, `portal_alert_templates`, `user_tasks`.

```bash
supabase functions deploy admin-data --project-ref eyhksbiceueoiamwnqpr
# publish the pages, wait ~15 minutes (browser cache is 10 min), then
supabase db query --linked -f supabase/data-lockdown-phase1.sql
# rollback: supabase db query --linked -f supabase/data-lockdown-phase1-rollback.sql
```
Local testing (file:// or localhost) needs `http://localhost:8000,null` added to the `ADMIN_AUTH_ORIGINS` secret.

## Not locked yet
Tables that students, teachers or the public also use (`students`, `applications`, `email_history`, `transcripts`, `invoices`,
grades, video-call tables, ...). They need student/teacher session tokens first.

## send-email is no longer open
`send-email` used to send for anyone on the internet, as any @acnhs.am address. It now decides by who is asking
(`supabase/functions/_shared/send-policy.ts`):

| Caller | Proof | May send |
|---|---|---|
| admin | `x-admin-token` | any sender and recipient (600/hour) |
| teacher | `x-portal-token` (from `teacher-verify`) | from `hub@acnhs.am` only (class notices) |
| student | `x-portal-token` (from `student-verify`) | only from their own campus address (30/hour, no attachments) |
| test viewer | `x-portal-token` (from `viewer-login`) | from any @acnhs.am address |
| website forms (no login) | none | from `admissions@`, `student-services@`, `documents@`, `do-not-reply@`; to `student-services@acnhs.am`, `acnhs.2026@gmail.com`, or the applicant who applied in the last 3 hours (3 per address/hour, 10 per IP/hour, no attachments) |

`js/supabase-config.js` attaches the tokens to every request to `/functions/v1/send-email`; `PortalAuth` / `AdminAuth.viewerLogin`
store the portal token on a successful sign-in. Sessions opened before the update have no token: the page asks to sign in again.
Portal tokens are signed with a key derived from `ADMIN_TOKEN_SECRET` and cannot be used as admin tokens.

## receive-email (inbound mail webhook)
Anyone could post a forged "received e-mail" (which also triggers forwarding rules). `receive-email` now verifies the Resend (Svix)
signature as soon as the secret `RESEND_WEBHOOK_SECRET` is set (Resend dashboard → Webhooks → the endpoint → Signing secret, `whsec_...`):
```bash
supabase secrets set RESEND_WEBHOOK_SECRET='whsec_...' --project-ref eyhksbiceueoiamwnqpr
```
Until it is set the function behaves as before and logs a warning. Verbose logging of headers/payload was removed.
