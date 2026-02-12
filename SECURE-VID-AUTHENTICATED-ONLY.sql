-- Secure VID - Only Authenticated Users Can Access Data
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql/new

-- ============================================
-- SECURE: Only ADMIN users can see data
-- Students CANNOT access VID even if authenticated
-- ============================================

-- 1. Drop the overly permissive policy
DROP POLICY IF EXISTS "VID: Allow all users to read students" ON students;
DROP POLICY IF EXISTS "VID: Only authenticated users can read students" ON students;

-- 2. Create secure policy - ONLY specific admin emails
CREATE POLICY "VID: Only admin emails can read students"
ON students
FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'Hrachfilm@gmail.com',
    'hrachfilm@gmail.com',
    'admin@acnhs.edu'
  )
);

-- 3. Secure admin_private_notes too - ONLY admin emails
DROP POLICY IF EXISTS "VID: Allow all users to manage notes" ON admin_private_notes;
DROP POLICY IF EXISTS "VID: Only authenticated users can manage notes" ON admin_private_notes;

CREATE POLICY "VID: Only admin emails can manage notes"
ON admin_private_notes
FOR ALL
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'Hrachfilm@gmail.com',
    'hrachfilm@gmail.com',
    'admin@acnhs.edu'
  )
)
WITH CHECK (
  auth.jwt() ->> 'email' IN (
    'Hrachfilm@gmail.com',
    'hrachfilm@gmail.com',
    'admin@acnhs.edu'
  )
);

-- 4. Ensure RLS is enabled (blocks anonymous access)
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_private_notes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Optional: Even more restrictive - only YOUR email
-- ============================================

-- This section is now INCLUDED by default above!
-- The policy already restricts to specific admin emails.

-- To add more admin users, edit the email list in the policy above:
-- Example:
-- UPDATE the policy to add 'newadmin@acnhs.edu':
/*
DROP POLICY IF EXISTS "VID: Only admin emails can read students" ON students;

CREATE POLICY "VID: Only admin emails can read students"
ON students
FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'email' IN (
    'Hrachfilm@gmail.com',
    'hrachfilm@gmail.com',
    'admin@acnhs.edu',
    'newadmin@acnhs.edu'  -- Add more admins here
  )
);
*/

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

-- ✅ SECURED: Only SPECIFIC ADMIN EMAILS can see data
-- ✅ Allowed admins:
--    • Hrachfilm@gmail.com
--    • hrachfilm@gmail.com
--    • admin@acnhs.edu
-- ❌ Students (even if authenticated) = BLOCKED
-- ❌ Other authenticated users = BLOCKED
-- ❌ Anonymous users (no login) = BLOCKED
-- ❌ Anyone without whitelisted email = BLOCKED

-- 🔒 Students CANNOT access VID even if they have login credentials!
