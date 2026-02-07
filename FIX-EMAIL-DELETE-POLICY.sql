-- Check and fix DELETE policy for email_history table
-- Run this in Supabase SQL Editor at: 
-- https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/editor

-- 1. Check current RLS status
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename = 'email_history';

-- 2. Check existing DELETE policies
SELECT policyname, cmd, qual, with_check 
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename = 'email_history' 
  AND cmd = 'DELETE';

-- 3. Drop old policy if exists and recreate
DROP POLICY IF EXISTS "Allow public to delete email history" ON email_history;

-- 4. Create new DELETE policy for anonymous users
CREATE POLICY "Allow anon to delete email history"
ON email_history
FOR DELETE
TO anon
USING (true);

-- 5. Create DELETE policy for authenticated users
CREATE POLICY "Allow authenticated to delete email history"
ON email_history
FOR DELETE
TO authenticated
USING (true);

-- 6. Verify policies are created
SELECT policyname, cmd, roles::text
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'email_history'
ORDER BY cmd, policyname;

-- Expected output should show DELETE policies for both 'anon' and 'authenticated' roles
