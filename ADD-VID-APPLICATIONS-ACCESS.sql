-- Allow VID to read applications table
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql/new

-- Drop existing policy if any
DROP POLICY IF EXISTS "VID: ONLY hrachfilm can read applications" ON applications;

-- Create new policy for hrachfilm to read applications
CREATE POLICY "VID: ONLY hrachfilm can read applications"
ON applications FOR SELECT TO authenticated
USING (LOWER(auth.jwt() ->> 'email') = 'hrachfilm@gmail.com');

-- Verify policy was created
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'applications'
ORDER BY policyname;
