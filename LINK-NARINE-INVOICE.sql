-- Link Narine's invoice to her student record
-- Invoice ID: ACNHS-20260205-2351-684

-- Update student record with invoice URL
UPDATE students
SET invoice_url = 'invoice-view.html?id=ACNHS-20260205-2351-684'
WHERE student_id = 'ACNHS-7022395';

-- Verify the update
SELECT 
  student_id,
  full_name,
  invoice_url,
  status
FROM students
WHERE student_id = 'ACNHS-7022395';

-- This will allow Narine to see her invoice in the Financial tab of Student-page.html
