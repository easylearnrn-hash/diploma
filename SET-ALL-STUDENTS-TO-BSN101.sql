-- ============================================
-- SET ALL ACTIVE STUDENTS TO BSN 101 GROUP
-- Run this to assign all current students to BSN 101
-- ============================================

-- Option 1: Set ALL students to BSN 101
UPDATE students 
SET "group" = 'BSN 101'
WHERE enrollment_status IN ('active', 'enrolled', 'Active', 'Enrolled');

-- Option 2: Set only students with NULL group to BSN 101
UPDATE students 
SET "group" = 'BSN 101'
WHERE "group" IS NULL 
  AND enrollment_status IN ('active', 'enrolled', 'Active', 'Enrolled');

-- Verify the update
SELECT 
  student_id,
  full_name,
  email,
  "group",
  enrollment_status
FROM students
WHERE enrollment_status IN ('active', 'enrolled', 'Active', 'Enrolled')
ORDER BY created_at DESC;

-- ============================================
-- FUTURE: When admitting new students, remember to set their group
-- You can do this in the admin panel when approving applications
-- ============================================
