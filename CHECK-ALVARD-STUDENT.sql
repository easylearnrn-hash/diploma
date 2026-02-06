-- Check Alvard's program in students table
SELECT 
  id,
  student_id,
  application_id,
  full_name,
  program,
  email
FROM students
WHERE full_name ILIKE '%Alvard%'
  AND full_name ILIKE '%Ghukasyan%';
