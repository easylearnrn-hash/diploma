-- Add enrollment_date, group, and start_term columns to students table
-- Run this in Supabase SQL Editor

-- Add enrollment_date column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'students' 
    AND column_name = 'enrollment_date'
  ) THEN
    ALTER TABLE students 
    ADD COLUMN enrollment_date DATE;
    
    RAISE NOTICE 'Column enrollment_date added successfully';
  ELSE
    RAISE NOTICE 'Column enrollment_date already exists';
  END IF;
END $$;

-- Add group column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'students' 
    AND column_name = 'group'
  ) THEN
    ALTER TABLE students 
    ADD COLUMN "group" TEXT;
    
    RAISE NOTICE 'Column group added successfully';
  ELSE
    RAISE NOTICE 'Column group already exists';
  END IF;
END $$;

-- Add start_term column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'students' 
    AND column_name = 'start_term'
  ) THEN
    ALTER TABLE students 
    ADD COLUMN start_term TEXT;
    
    RAISE NOTICE 'Column start_term added successfully';
  ELSE
    RAISE NOTICE 'Column start_term already exists';
  END IF;
END $$;

-- Now update Narine's record with enrollment date, group, and start term
UPDATE students 
SET 
  enrollment_date = '2026-01-15',
  "group" = 'BSN 101',
  start_term = 'Spring Semester 2026'
WHERE student_id = 'ACNHS-7022395';

-- Verify the update
SELECT 
  student_id, 
  full_name, 
  enrollment_date, 
  "group",
  start_term,
  program,
  status
FROM students 
WHERE student_id = 'ACNHS-7022395';
