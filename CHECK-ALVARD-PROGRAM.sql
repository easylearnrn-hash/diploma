-- Check Alvard's current program across all tables

-- Check application
SELECT id, applicant_name, program, payload->>'programChoice' as payload_program
FROM applications
WHERE applicant_name ILIKE '%Alvard%' OR email = 'alvard85@yahoo.com';

-- Check student
SELECT id, student_id, full_name, program, application_id
FROM students
WHERE full_name ILIKE '%Alvard%' OR email = 'alvard85@yahoo.com';

-- Check invoices
SELECT id, invoice_number, student_name, student_id, program
FROM invoices
WHERE student_name ILIKE '%Alvard%' OR student_id IN (
  SELECT student_id FROM students WHERE full_name ILIKE '%Alvard%'
);
