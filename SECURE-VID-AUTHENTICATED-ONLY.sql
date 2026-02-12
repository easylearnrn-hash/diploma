-- Secure VID - Only Authenticated Users Can Access Data
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql/new

-- ============================================
-- SECURE: Only logged-in users can see data
-- ============================================

-- 1. Drop the overly permissive policy
DROP POLICY IF EXISTS "VID: Allow all users to read students" ON students;

-- 2. Create secure policy - ONLY authenticated (logged in) users
CREATE POLICY "VID: Only authenticated users can read students"
ON students
FOR SELECT
TO authenticated  -- ✅ Only logged-in users
USING (true);

-- 3. Secure admin_private_notes too
DROP POLICY IF EXISTS "VID: Allow all users to manage notes" ON admin_private_notes;

CREATE POLICY "VID: Only authenticated users can manage notes"
ON admin_private_notes
FOR ALL
TO authenticated  -- ✅ Only logged-in users
USING (true)
WITH CHECK (true);

-- 4. Ensure RLS is enabled (blocks anonymous access)
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_private_notes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Optional: Even more restrictive - only YOUR email
-- ============================================

-- Uncomment these if you want ONLY hrachfilm@gmail.com to access:

-- DROP POLICY IF EXISTS "VID: Only authenticated users can read students" ON students;
-- 
-- CREATE POLICY "VID: Only hrachfilm can read students"
-- ON students
-- FOR SELECT
-- TO authenticated
-- USING (auth.jwt() ->> 'email' = 'Hrachfilm@gmail.com');

-- DROP POLICY IF EXISTS "VID: Only authenticated users can manage notes" ON admin_private_notes;
-- 
-- CREATE POLICY "VID: Only hrachfilm can manage notes"
-- ON admin_private_notes
-- FOR ALL
-- TO authenticated
-- USING (auth.jwt() ->> 'email' = 'Hrachfilm@gmail.com')
-- WITH CHECK (auth.jwt() ->> 'email' = 'Hrachfilm@gmail.com');

-- ============================================
-- Verify Security
-- ============================================

-- This should show your policies
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename IN ('students', 'admin_private_notes')
ORDER BY tablename, policyname;

-- Test: As authenticated user, you should see students
SELECT COUNT(*) as student_count FROM students;

-- Summary
SELECT 
  'students' as table_name,
  'RLS Enabled' as security_status,
  COUNT(*) as total_records
FROM students
UNION ALL
SELECT 
  'admin_private_notes' as table_name,
  'RLS Enabled' as security_status,
  COUNT(*) as total_records
FROM admin_private_notes;

-- ============================================
-- Security Summary
-- ============================================

-- ✅ SECURED: Only users who log in to VID can see data
-- ✅ Anonymous users (no login) = blocked
-- ✅ Need valid email/password to access
-- ✅ Session required to view any data

-- To make it even more restrictive (only YOUR email):
-- Uncomment the "Optional" section above
