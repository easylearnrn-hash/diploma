-- DATA LOCKDOWN, PHASE 1: tables that only admin pages use. The public (anon) key can no longer read or write them; admin pages
-- reach them through the admin-data Edge Function (signed admin session, see DATA-LOCKDOWN-SETUP.md).
-- Run ONLY after the pages and the admin-data function are published.
--
--   supabase db query --linked -f supabase/data-lockdown-phase1.sql
-- Roll back: supabase db query --linked -f supabase/data-lockdown-phase1-rollback.sql

revoke all on public.documents              from anon, authenticated;
revoke all on public.email_configuration    from anon, authenticated;
revoke all on public.email_folder_rules     from anon, authenticated;
revoke all on public.email_folders          from anon, authenticated;
revoke all on public.email_forwarding_rules from anon, authenticated;
revoke all on public.email_spam_blocked     from anon, authenticated;
revoke all on public.invoice_drafts         from anon, authenticated;
revoke all on public.invoice_templates      from anon, authenticated;
revoke all on public.monthly_expenses       from anon, authenticated;
revoke all on public.portal_alert_templates from anon, authenticated;
revoke all on public.user_tasks             from anon, authenticated;

notify pgrst, 'reload schema';
