-- Link Ani Ezabela Abovian's uploaded receipt to her invoice
-- The receipt was uploaded successfully to storage but couldn't be linked due to missing column

-- First, verify Ani's invoice exists
SELECT 
  id,
  invoice_number,
  student_name,
  student_id,
  status,
  payment_receipts
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid'
ORDER BY created_at DESC
LIMIT 1;

-- Then link the receipt (update the invoice_id if different from query above)
UPDATE invoices
SET payment_receipts = jsonb_build_array(
  jsonb_build_object(
    'filename', 'ACNHS_Seal_Under_30KB_Transparent.png',
    'public_url', 'https://eyhksbiceueoiamwnqpr.supabase.co/storage/v1/object/public/application-documents/documents/5afc4def-0dd9-438f-9200-5f9cfee78106/1771080290470_ACNHS_Seal_Under_30KB_Transparent.png',
    'uploaded_at', '2026-02-13T22:58:10.470Z',
    'size', 29391
  )
)
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';

-- Verify the receipt was linked
SELECT 
  id,
  invoice_number,
  student_name,
  payment_receipts
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';
