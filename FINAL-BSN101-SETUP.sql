-- ============================================
-- PERMANENT BSN 101 GROUP SETUP
-- This will create the group and ensure it persists
-- Run this in Supabase SQL Editor
-- ============================================

-- Step 1: Create BSN 101 group in student_groups table (for admin UI)
-- Uses UPSERT so it won't fail if it already exists
INSERT INTO student_groups (id, name, semester, student_ids, created_at, updated_at)
VALUES (
  'bsn-101',
  'BSN 101',
  'Spring 2026',
  '{}',
  NOW(),
  NOW()
)
ON CONFLICT (id) 
DO UPDATE SET
  name = EXCLUDED.name,
  semester = EXCLUDED.semester,
  updated_at = NOW();

-- Step 2: Ensure ALL active students have BSN 101 as their group
-- This updates the students.group column which is what the Join Class feature uses
UPDATE students 
SET "group" = 'BSN 101'
WHERE enrollment_status IN ('active', 'Active', 'enrolled', 'Enrolled')
  OR status IN ('active', 'Active', 'enrolled', 'Enrolled');

-- Step 3: Create a backup group just in case
INSERT INTO student_groups (id, name, semester, student_ids, created_at, updated_at)
VALUES (
  'bsn-101-backup',
  'BSN 101 (Backup)',
  'Spring 2026',
  '{}',
  NOW(),
  NOW()
)
ON CONFLICT (id) 
DO UPDATE SET
  name = EXCLUDED.name,
  semester = EXCLUDED.semester,
  updated_at = NOW();

-- Step 4: Verify everything is set up correctly
SELECT 
  '=== STUDENT GROUPS TABLE ===' as check_type,
  id,
  name,
  semester,
  created_at
FROM student_groups
ORDER BY created_at DESC;

SELECT 
  '=== STUDENTS WITH BSN 101 ===' as check_type,
  COUNT(*) as total_students,
  "group"
FROM students
WHERE "group" = 'BSN 101'
GROUP BY "group";

SELECT 
  '=== ACTIVE CLASS LINKS ===' as check_type,
  group_id,
  url,
  is_active,
  created_by
FROM class_join_links
WHERE is_active = true AND ended_at IS NULL;

SELECT 
  '=== VERIFICATION: Can students see the button? ===' as check_type,
  s.student_id,
  s.full_name,
  s."group" as student_group,
  c.group_id as link_group,
  CASE 
    WHEN c.group_id = 'all' THEN '✅ YES - Link is for ALL'
    WHEN s."group" = c.group_id THEN '✅ YES - Groups match'
    ELSE '❌ NO - Groups dont match'
  END as can_see_button
FROM students s
CROSS JOIN class_join_links c
WHERE c.is_active = true 
  AND c.ended_at IS NULL
  AND s.enrollment_status IN ('active', 'Active', 'enrolled', 'Enrolled')
LIMIT 10;

-- ============================================
-- RESULT: You should see:
-- 1. BSN 101 in student_groups table
-- 2. Count of students assigned to BSN 101
-- 3. Your active Google Meet link
-- 4. "✅ YES" for all students in verification
-- ============================================
