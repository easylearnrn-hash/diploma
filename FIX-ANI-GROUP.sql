-- ============================================
-- QUICK FIX: Set Ani Abovian's group so she can see the class link
-- Run this in Supabase SQL Editor
-- ============================================

-- First, check what group the active link is posted for
SELECT 
  'Active link is for group:' as info,
  group_id
FROM class_join_links
WHERE is_active = true 
  AND ended_at IS NULL
ORDER BY created_at DESC
LIMIT 1;

-- Check Ani's current group value
SELECT 
  'Ani current group:' as info,
  student_id,
  full_name,
  email,
  "group"
FROM students
WHERE email LIKE '%abovian%' OR full_name LIKE '%Abovian%';

-- FIX: Update Ani's group to match the active link
-- OPTION 1: If the admin posted link for "Semester 1"
UPDATE students 
SET "group" = 'Semester 1'
WHERE email LIKE '%abovian%' OR full_name LIKE '%Abovian%';

-- OPTION 2: If the admin posted link for "all"
-- Then the student's group can be anything and it should work
-- But let's set it anyway:
-- UPDATE students 
-- SET "group" = 'Semester 1'
-- WHERE email LIKE '%abovian%';

-- Verify the update
SELECT 
  'Ani after update:' as info,
  student_id,
  full_name,
  email,
  "group"
FROM students
WHERE email LIKE '%abovian%' OR full_name LIKE '%Abovian%';

-- AFTER RUNNING THIS, have the student:
-- 1. Refresh the Student Portal page
-- 2. Open browser console (F12) and type: testClassLinkChecker()
-- 3. Check for green button below "Current Semester"
