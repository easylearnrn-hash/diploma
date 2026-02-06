-- Manual fix: Update Alvard's program everywhere

-- Update student table
UPDATE students 
SET program = 'Bachelor of Science in Nursing'
WHERE full_name ILIKE '%Alvard%' OR email = 'alvard85@yahoo.com';

-- Update invoices table
UPDATE invoices
SET program = 'Bachelor of Science in Nursing'
WHERE student_name ILIKE '%Alvard%';

-- Verify the changes
SELECT 'Application' as table_name, applicant_name as name, program 
FROM applications 
WHERE applicant_name ILIKE '%Alvard%'
UNION ALL
SELECT 'Student' as table_name, full_name as name, program 
FROM students 
WHERE full_name ILIKE '%Alvard%'
UNION ALL
SELECT 'Invoice' as table_name, student_name as name, program 
FROM invoices 
WHERE student_name ILIKE '%Alvard%';
