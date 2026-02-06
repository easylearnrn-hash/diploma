-- One-time fix for Alvard: Update program everywhere

-- Step 1: Update students table
UPDATE students 
SET program = 'Bachelor of Science in Nursing'
WHERE student_id = 'ACNHS-3394133';

-- Step 2: Update invoices table (if any exist)
UPDATE invoices
SET program = 'Bachelor of Science in Nursing'
WHERE student_id = 'ACNHS-3394133';

-- Step 3: Verify all tables now match
SELECT 
  'Application' as source,
  applicant_name as name,
  program
FROM applications 
WHERE id = 'ad04c641-feaf-4bb3-8f8e-20efa8846719'

UNION ALL

SELECT 
  'Student' as source,
  full_name as name,
  program
FROM students 
WHERE student_id = 'ACNHS-3394133'

UNION ALL

SELECT 
  'Invoice' as source,
  student_name as name,
  program
FROM invoices 
WHERE student_id = 'ACNHS-3394133';
