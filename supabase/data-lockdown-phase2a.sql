-- DATA LOCKDOWN, PHASE 2A. Run ONLY after the pages and the admin-data function are published (see DATA-LOCKDOWN-SETUP.md).
--   supabase db query --linked -f supabase/data-lockdown-phase2a.sql
-- Roll back: supabase db query --linked -f supabase/data-lockdown-phase2a-rollback.sql

-- no page uses these (Edge Functions use the service role)
revoke all on public.institutions            from anon, authenticated;
revoke all on public.course_grade_items      from anon, authenticated;
revoke all on public.sms_logs                from anon, authenticated;
revoke all on public.sms_verifications       from anon, authenticated;
revoke all on public.teacher_password_resets from anon, authenticated;

-- admin pages only (through the admin-data gateway)
revoke all on public.export_sessions         from anon, authenticated;
revoke all on public.export_session_notes    from anon, authenticated;

-- e-mail history: admins, and each student for their own mail, through the gateway
revoke all on public.email_history           from anon, authenticated;

-- the CEO's private notes: only the signed-in owner (VID.html uses a real Supabase login = role authenticated)
revoke all on public.admin_private_notes     from anon;

-- activity log: the site can still add lines, nobody can read, change or delete them with the public key (admins read via the gateway)
revoke select, update, delete on public.user_activity_log from anon, authenticated;

notify pgrst, 'reload schema';
