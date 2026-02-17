-- ============================================
-- IMMEDIATE CHECK - Run this NOW in Supabase SQL Editor
-- ============================================

-- 1. What active links exist?
SELECT 
  '1. ACTIVE LINKS' as step,
  id,
  url,
  group_id,
  is_active,
  created_at,
  created_by
FROM class_join_links
WHERE is_active = true 
  AND ended_at IS NULL
ORDER BY created_at DESC;

-- 2. What is Ani's group?
SELECT 
  '2. ANI GROUP' as step,
  student_id,
  full_name,
  email,
  "group",
  enrollment_status
FROM students
WHERE email = 'a.abovian@acnhs.am' OR full_name LIKE '%Abovian%';

-- 3. What are ALL student groups?
SELECT 
  '3. ALL STUDENT GROUPS' as step,
  "group",
  COUNT(*) as count
FROM students
GROUP BY "group"
ORDER BY count DESC;

-- ============================================
-- BASED ON RESULTS ABOVE, CHOOSE ONE FIX:
-- ============================================

-- FIX A: If active link has group_id = 'Semester 1' (or any specific group)
--        AND Ani's group is NULL or different:
/*
UPDATE students 
SET "group" = 'Semester 1'  -- CHANGE THIS to match group_id from step 1
WHERE email = 'a.abovian@acnhs.am';
*/

-- FIX B: If you want ALL students to see the button:
/*
UPDATE class_join_links
SET group_id = 'all'
WHERE is_active = true AND ended_at IS NULL;
*/

-- FIX C: If Ani's group is NULL and you want to set default for everyone:
/*
UPDATE students 
SET "group" = 'Semester 1'  -- CHANGE THIS to your default group name
WHERE "group" IS NULL OR "group" = '';
*/

-- 4. After running fix, verify:
SELECT 
  '4. VERIFY FIX' as step,
  s.student_id,
  s.full_name,
  s."group" as student_group,
  c.group_id as link_group,
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
