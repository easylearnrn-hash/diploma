-- Fix Narine's invoice totals
-- The items total $9,000 but subtotal/total show $0.00

UPDATE invoices
SET 
  subtotal = 9000.00,
  tax_rate = 0.00,
  tax_amount = 0.00,
  total = 9000.00
WHERE invoice_number = 'ACNHS-20260205-2351-684';

-- Verify the fix
SELECT 
  invoice_number,
  student_name,
  student_id,
  subtotal,
  tax_amount,
  total,
  status,
  items
FROM invoices
WHERE invoice_number = 'ACNHS-20260205-2351-684';
