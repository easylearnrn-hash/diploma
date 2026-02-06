-- Check what invoice Narine's student record is pointing to
SELECT 
  student_id,
  full_name,
  invoice_url
FROM students
WHERE student_id = 'ACNHS-7022395';

-- Check all invoices for Narine to see if a new one was created
SELECT 
  invoice_number,
  student_id,
  student_name,
  total,
  status,
  created_at,
  updated_at
FROM invoices
WHERE student_id = 'ACNHS-7022395'
ORDER BY created_at DESC;

-- The invoice_url should match an existing invoice_number
-- If they don't match, we need to update the student record
