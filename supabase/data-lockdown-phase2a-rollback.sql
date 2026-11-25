-- DATA LOCKDOWN, PHASE 2A ROLLBACK: gives the public key its previous access back.
--   supabase db query --linked -f supabase/data-lockdown-phase2a-rollback.sql

grant all on public.institutions, public.course_grade_items, public.sms_logs, public.sms_verifications,
             public.teacher_password_resets, public.export_sessions, public.export_session_notes, public.email_history
  to anon, authenticated;
grant all on public.admin_private_notes to anon;
grant select, update, delete on public.user_activity_log to anon, authenticated;

notify pgrst, 'reload schema';
