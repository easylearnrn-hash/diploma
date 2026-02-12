-- Allow VID to read enrollment questionnaires
-- Run in Supabase SQL Editor: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql/new

-- Drop existing VID policy if any
DROP POLICY IF EXISTS "VID: hrachfilm can read questionnaires" ON enrollment_questionnaires;

-- Create policy for hrachfilm to read questionnaires
CREATE POLICY "VID: hrachfilm can read questionnaires"
ON enrollment_questionnaires FOR SELECT TO authenticated
USING (LOWER(auth.jwt() ->> 'email') = 'hrachfilm@gmail.com');

-- Verify policy was created
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'enrollment_questionnaires'
ORDER BY policyname;
