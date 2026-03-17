-- ADD student_role column to test_grade_history
-- This allows us to filter out teacher/admin rows from the student results view.
-- Run this in the Supabase SQL Editor.

ALTER TABLE IF EXISTS public.test_grade_history
  ADD COLUMN IF NOT EXISTS student_role TEXT DEFAULT 'student';

-- Tag any pre-existing rows that look like they belong to teachers
-- (owner_id that contains '@' and matches known admin emails).
-- Update this list if you add more teacher accounts.
UPDATE public.test_grade_history
SET student_role = 'teacher'
WHERE student_role IS DISTINCT FROM 'student'
  AND LOWER(owner_id) IN (
    'hrachfilm@gmail.com'
    -- Add more teacher emails here as needed:
    -- 'teacher2@example.com'
  );

-- All rows not updated above keep student_role = 'student' (the default).
