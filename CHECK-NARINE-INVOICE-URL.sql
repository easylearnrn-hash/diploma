-- Check if Narine's student record has invoice_url

-- First, verify the invoice_url column exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'students' 
AND column_name = 'invoice_url';

-- Check Narine's current record (including invoice_url)
SELECT 
  student_id,
  full_name,
  invoice_url,
  enrollment_date,
  "group",
  start_term,
  program,
  status
FROM students
WHERE student_id = 'ACNHS-7022395';

-- If invoice_url is NULL, run this to add it:
UPDATE students
SET invoice_url = 'invoice-view.html?id=ACNHS-20260205-2351-684'
WHERE student_id = 'ACNHS-7022395'
AND (invoice_url IS NULL OR invoice_url = '');

-- Verify after update
SELECT 
  student_id,
  full_name,
  invoice_url
FROM students
WHERE student_id = 'ACNHS-7022395';
