-- ⚠️ URGENT: Remove all insecure anonymous access policies from applications table
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql/new

-- Drop all insecure anonymous policies
DROP POLICY IF EXISTS "Allow anonymous insert applications" ON applications;
DROP POLICY IF EXISTS "Allow anonymous read applications" ON applications;
DROP POLICY IF EXISTS "Allow anonymous update applications" ON applications;
DROP POLICY IF EXISTS "Public can delete applications" ON applications;
DROP POLICY IF EXISTS "Public can read applications" ON applications;
DROP POLICY IF EXISTS "Public can submit applications" ON applications;
DROP POLICY IF EXISTS "Public can update applications" ON applications;
DROP POLICY IF EXISTS "Applicants can view their own application" ON applications;

-- Keep only the secure VID policy
-- (VID: ONLY hrachfilm can read applications - already exists)

-- Verify only secure policy remains
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'applications'
ORDER BY policyname;

-- Should see ONLY 1 policy:
-- VID: ONLY hrachfilm can read applications | {authenticated} | SELECT
