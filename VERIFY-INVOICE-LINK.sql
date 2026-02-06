-- Verify everything is correctly linked

-- Check Narine's student record invoice_url
SELECT 
  student_id,
  full_name,
  invoice_url
FROM students
WHERE student_id = 'ACNHS-7022395';

-- Check if the invoice exists with that number
SELECT 
  invoice_number,
  student_name,
  student_id,
  total,
  status
FROM invoices
WHERE invoice_number = 'ACNHS-20260205-2351-684';

-- The invoice_url should be: invoice-view.html?id=ACNHS-20260205-2351-684
-- And the invoice query should use: .eq('invoice_number', 'ACNHS-20260205-2351-684')
