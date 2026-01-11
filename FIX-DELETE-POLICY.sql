-- The issue: DELETE policy is for 'authenticated' but other policies are for 'public'
-- The anon key gives 'public' role access, not 'authenticated'

-- Add DELETE policy for public role to match other policies
CREATE POLICY "Allow public to delete email history"
ON email_history
FOR DELETE
TO public
USING (true);

-- Verify the new policy
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'email_history'
ORDER BY cmd, policyname;
