-- ============================================
-- DEBUG CLASS JOIN LINKS SYSTEM
-- Run this in Supabase SQL Editor to diagnose why students can't see the button
-- ============================================

-- Step 1: Check what active links exist
SELECT 
  '=== ACTIVE CLASS LINKS ===' as section,
  id,
  url,
  group_id,
  is_active,
  ended_at,
  expires_at,
  created_at,
  created_by
FROM class_join_links
WHERE is_active = true 
  AND ended_at IS NULL
ORDER BY created_at DESC;

-- Step 2: Check student groups (see what values are actually stored)
SELECT 
  '=== STUDENT GROUPS ===' as section,
  student_id,
  full_name,
  email,
  "group" as student_group,
  enrollment_status
FROM students
WHERE enrollment_status IN ('active', 'enrolled', 'Active', 'Enrolled')
ORDER BY created_at DESC
LIMIT 20;

-- Step 3: Count how many students have NULL groups
SELECT 
  '=== NULL GROUP COUNT ===' as section,
  COUNT(*) as students_with_null_group
FROM students
WHERE "group" IS NULL OR "group" = '';

-- Step 4: Show distinct group values
SELECT 
  '=== DISTINCT GROUPS ===' as section,
  "group" as group_value,
  COUNT(*) as student_count
FROM students
WHERE "group" IS NOT NULL AND "group" != ''
GROUP BY "group"
ORDER BY student_count DESC;

-- Step 5: Check RLS policies
SELECT 
  '=== RLS POLICIES ===' as section,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'class_join_links'
ORDER BY policyname;

-- IMPORTANT: If you see that students have NULL groups or group values
-- that don't match what the admin posted (check the group_id in active links),
-- then run the following UPDATE:

-- UNCOMMENT AND MODIFY THIS IF NEEDED:
-- UPDATE students 
-- SET "group" = 'Semester 1'  -- Change this to match the group_id the admin posted
-- WHERE "group" IS NULL OR "group" = '';

-- OR to match a specific student (use their email):
-- UPDATE students 
-- SET "group" = 'Semester 1'  -- Change this to match the admin's posted group_id
-- WHERE email = 'a.abovian@acnhs.am';
