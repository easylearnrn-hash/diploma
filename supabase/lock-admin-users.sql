-- Locks the admin_users table: only the server-side Edge Functions (service role) can read or change it.
-- The browser (anon / authenticated keys) can no longer see password hashes.
-- Apply:    supabase db query --linked -f supabase/lock-admin-users.sql
-- Roll back (if something unexpected breaks): run the block at the bottom.

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.admin_users FROM anon, authenticated;

-- ROLLBACK (restores the previous, open state):
-- ALTER TABLE public.admin_users DISABLE ROW LEVEL SECURITY;
-- GRANT ALL ON public.admin_users TO anon, authenticated;
