-- Manually update Alvard's program in students table to match applications table
UPDATE students
SET program = 'Bachelor of Science in Nursing'
WHERE application_id = 'ad04c641-feaf-4bb3-8f8e-20efa8846719';

-- Verify the update
SELECT 
  student_id,
  full_name,
  program,
  application_id
FROM students
WHERE application_id = 'ad04c641-feaf-4bb3-8f8e-20efa8846719';
