-- Allow admin users to manage applications via admin-applications.html
-- Run in Supabase SQL Editor

-- 1. Allow ALL authenticated users to READ applications (for admin dashboard)
CREATE POLICY "Admin: Authenticated users can read applications"
ON applications FOR SELECT TO authenticated
USING (true);

-- 2. Allow ALL authenticated users to UPDATE applications (for status changes, notes, etc.)
CREATE POLICY "Admin: Authenticated users can update applications"
ON applications FOR UPDATE TO authenticated
USING (true)
WITH CHECK (true);

-- 3. Allow ALL authenticated users to DELETE applications (if needed)
CREATE POLICY "Admin: Authenticated users can delete applications"
ON applications FOR DELETE TO authenticated
USING (true);

-- Note: VID will still work because it also matches the SELECT policy above
-- But VID is the ONLY place restricted to just hrachfilm@gmail.com

-- Verify policies
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'applications'
ORDER BY policyname;
