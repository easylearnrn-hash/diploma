-- FIX ADMIN USERS RLS POLICIES - COMPREHENSIVE FIX
-- This allows anonymous access for testing purposes
-- In production, you should use proper authentication

-- First, disable RLS temporarily to ensure we can make changes
ALTER TABLE admin_users DISABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies forcefully
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'admin_users') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON admin_users CASCADE';
    END LOOP;
END $$;

-- Re-enable RLS
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Create NEW policies that allow anonymous access (FOR TESTING ONLY)
CREATE POLICY "anon_read_admin_users" ON admin_users
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "anon_insert_admin_users" ON admin_users
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "anon_update_admin_users" ON admin_users
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "anon_delete_admin_users" ON admin_users
  FOR DELETE
  TO anon, authenticated
  USING (true);

-- Verify policies were created
SELECT schemaname, tablename, policyname, roles, cmd 
FROM pg_policies 
WHERE tablename = 'admin_users';

-- Note: In production, replace 'true' with proper auth checks
