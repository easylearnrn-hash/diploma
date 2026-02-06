-- Cleanup script to remove students from students table whose application status is not ENROLLED
-- Run this in Supabase SQL Editor

-- First, let's see which students should be removed
SELECT 
  s.id,
  s.student_id,
  s.full_name,
  a.status as application_status
FROM students s
LEFT JOIN applications a ON s.application_id = a.id
WHERE a.status != 'ENROLLED' OR a.status IS NULL;

-- ⚠️ IMPORTANT: Only students with application status = 'ENROLLED' should be in students table
-- All other statuses (APPROVED, ACCEPTANCE LETTER SENT, ON HOLD, etc.) should only be in applications table

-- Delete all non-ENROLLED students (UNCOMMENT TO RUN)
DELETE FROM students
WHERE id IN (
  SELECT s.id
  FROM students s
  LEFT JOIN applications a ON s.application_id = a.id
  WHERE a.status != 'ENROLLED' OR a.status IS NULL
);

-- This will remove all 20 students shown in the query result since none have status = 'ENROLLED'
-- They will remain in the applications table but be removed from students table
