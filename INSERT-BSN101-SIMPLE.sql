-- Check if BSN 101 group exists
SELECT * FROM student_groups;

-- Check what columns exist in student_groups table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'student_groups'
ORDER BY ordinal_position;

-- Try inserting BSN 101 again with proper conflict handling
INSERT INTO student_groups (id, name, semester, student_ids)
VALUES (
  'bsn-101-2026',
  'BSN 101',
  'Spring 2026',
  ARRAY[]::TEXT[]
)
ON CONFLICT (id) DO UPDATE 
SET 
  name = EXCLUDED.name,
  semester = EXCLUDED.semester,
  updated_at = NOW();

-- Verify insert
SELECT 
  id,
  name,
  semester,
  student_ids,
  created_at
FROM student_groups;
