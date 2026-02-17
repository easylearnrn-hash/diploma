-- Check what groups students have
SELECT 
  student_id,
  full_name,
  email,
  "group",
  enrollment_status
FROM students
WHERE enrollment_status = 'active' OR enrollment_status = 'enrolled'
LIMIT 10;
