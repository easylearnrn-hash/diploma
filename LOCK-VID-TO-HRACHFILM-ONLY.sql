-- LOCK DOWN VID TO ONLY HRACHFILM@GMAIL.COM
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql/new

-- ============================================
-- MAXIMUM SECURITY: ONLY hrachfilm can access
-- ============================================

-- 1. Drop all existing policies
DROP POLICY IF EXISTS "VID: Allow all users to read students" ON students;
DROP POLICY IF EXISTS "VID: Only authenticated users can read students" ON students;
DROP POLICY IF EXISTS "VID: Only admin emails can read students" ON students;

-- 2. Create STRICT policy - ONLY your email
CREATE POLICY "VID: ONLY hrachfilm can read students"
ON students
FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' = 'Hrachfilm@gmail.com'
);

-- 3. Secure admin_private_notes - ONLY your email
DROP POLICY IF EXISTS "VID: Allow all users to manage notes" ON admin_private_notes;
DROP POLICY IF EXISTS "VID: Only authenticated users can manage notes" ON admin_private_notes;
DROP POLICY IF EXISTS "VID: Only admin emails can manage notes" ON admin_private_notes;

CREATE POLICY "VID: ONLY hrachfilm can manage notes"
ON admin_private_notes
FOR ALL
TO authenticated
USING (auth.jwt() ->> 'email' = 'Hrachfilm@gmail.com')
WITH CHECK (auth.jwt() ->> 'email' = 'Hrachfilm@gmail.com');

-- 4. Ensure RLS is enabled (critical!)
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_private_notes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Verify Security
-- ============================================

-- Check policies
SELECT 
  tablename,
  policyname,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename IN ('students', 'admin_private_notes')
ORDER BY tablename, policyname;

-- Test access (should work only for hrachfilm@gmail.com)
SELECT COUNT(*) as student_count FROM students;

-- ============================================
-- Security Summary
-- ============================================

-- ✅ MAXIMUM SECURITY ENABLED
-- ✅ ONLY allowed user:
--    • Hrachfilm@gmail.com (YOU)
-- ❌ admin@acnhs.edu = BLOCKED
-- ❌ Other admins = BLOCKED
-- ❌ Students = BLOCKED
-- ❌ Everyone else = BLOCKED

-- 🔒 Even if you create other admin users, they CANNOT access VID!
-- 🔒 ONLY Hrachfilm@gmail.com can see any data!
