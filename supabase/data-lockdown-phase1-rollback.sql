-- DATA LOCKDOWN, PHASE 1 ROLLBACK: gives the public key its previous access back.
--   supabase db query --linked -f supabase/data-lockdown-phase1-rollback.sql

grant all on public.documents to anon, authenticated;
grant all on public.email_folder_rules to anon, authenticated;
grant all on public.email_folders to anon, authenticated;
grant all on public.email_forwarding_rules to anon, authenticated;
grant all on public.email_spam_blocked to anon, authenticated;
grant all on public.invoice_drafts to anon, authenticated;
grant all on public.invoice_templates to anon, authenticated;
grant all on public.monthly_expenses to anon, authenticated;
grant all on public.portal_alert_templates to anon, authenticated;
grant all on public.user_tasks to anon, authenticated;

notify pgrst, 'reload schema';
