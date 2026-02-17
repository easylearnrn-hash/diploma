-- NUCLEAR OPTION: Delete everything and start fresh
-- Run this if nothing else works

-- Step 1: Clear existing data
DELETE FROM student_groups;

-- Step 2: Insert BSN 101
INSERT INTO student_groups (id, name, semester, student_ids, created_at, updated_at)
VALUES (
  'bsn-101',
  'BSN 101',
  'Spring 2026',
  '{}',  -- Empty array as TEXT
  NOW(),
  NOW()
);

-- Step 3: Verify
SELECT * FROM student_groups;

-- Step 4: Also check what students have
SELECT student_id, full_name, "group" 
FROM students 
WHERE enrollment_status IN ('active', 'Active', 'enrolled', 'Enrolled')
LIMIT 10;
