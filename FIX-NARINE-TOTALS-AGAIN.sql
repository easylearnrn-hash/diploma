-- Fix Narine's invoice totals back to $9,000
UPDATE invoices
SET 
  subtotal = 9000.00,
  tax_rate = 0.00,
  tax_amount = 0.00,
  total = 9000.00
WHERE invoice_number = 'ACNHS-20260205-2351-684';

-- Verify
SELECT 
  invoice_number,
  student_name,
  subtotal,
  total,
  status
FROM invoices
WHERE invoice_number = 'ACNHS-20260205-2351-684';
