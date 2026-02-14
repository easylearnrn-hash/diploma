-- RESTORE NUR101 Course
-- Copy and paste this into Supabase SQL Editor and click RUN

INSERT INTO courses (code, name, semester, credits, course_type, description, status, created_by, created_at, updated_at)
VALUES (
  'NUR101',
  'Fundamentals of Nursing',
  'Semester 1',
  4,
  'theory',
  'Introduction to fundamental nursing concepts and principles',
  'active',
  'admin',
  NOW(),
  NOW()
)
ON CONFLICT (code, semester) DO UPDATE
SET 
  status = 'active',
  updated_at = NOW();

-- Verify it was created
SELECT * FROM courses WHERE code = 'NUR101';
