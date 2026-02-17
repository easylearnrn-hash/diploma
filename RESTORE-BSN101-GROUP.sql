-- ============================================
-- RESTORE BSN 101 GROUP AND ASSIGN STUDENTS
-- Run this in Supabase SQL Editor
-- ============================================

-- Step 1: Create BSN 101 group in student_groups table (for admin UI)
INSERT INTO student_groups (id, name, semester, student_ids, created_at, updated_at)
VALUES (
  'bsn-101-2026',
  'BSN 101',
  'Spring 2026',
  ARRAY[]::TEXT[],  -- Empty array, will be populated by admin UI
  NOW(),
  NOW()
)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name,
    semester = EXCLUDED.semester,
    updated_at = NOW();

-- Step 2: Assign ALL active students to BSN 101 group (in students.group column)
UPDATE students 
SET "group" = 'BSN 101'
WHERE enrollment_status IN ('active', 'enrolled', 'Active', 'Enrolled');

-- Step 3: Verify the setup
SELECT 
  '=== STUDENT GROUPS TABLE ===' as check,
  id,
  name,
  semester,
  array_length(student_ids, 1) as student_count
FROM student_groups;

SELECT 
  '=== STUDENTS WITH BSN 101 GROUP ===' as check,
  student_id,
  full_name,
  email,
  "group",
  enrollment_status
FROM students
WHERE "group" = 'BSN 101'
ORDER BY created_at DESC;

-- Step 4: Verify Ani can now see the link
SELECT 
  '=== ANI VISIBILITY CHECK ===' as check,
  s.student_id,
  s.full_name,
  s."group" as student_group,
  c.group_id as link_group,
  c.url,
  CASE 
    WHEN c.group_id = 'all' THEN '✅ WILL SEE (all)'
    WHEN s."group" = c.group_id THEN '✅ WILL SEE (match)'
    ELSE '❌ WONT SEE (no match)'
  END as visibility
FROM students s
CROSS JOIN class_join_links c
WHERE s.email = 'a.abovian@acnhs.am'
  AND c.is_active = true 
  AND c.ended_at IS NULL;
