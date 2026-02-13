-- Fix Ani's receipt URL by copying from applications.uploaded_documents to invoices.payment_receipts
-- This ensures we use the correct URL that was actually uploaded

-- First, check what's in applications.uploaded_documents
SELECT 
  id,
  uploaded_documents
FROM applications 
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106';

-- Then update the invoice with the CORRECT receipt from uploaded_documents
UPDATE invoices
SET payment_receipts = (
  SELECT jsonb_agg(
    jsonb_build_object(
      'filename', doc->>'filename',
      'public_url', doc->>'public_url',
      'uploaded_at', doc->>'uploaded_at',
      'size', (doc->>'size')::integer
    )
  )
  FROM applications,
  jsonb_array_elements(uploaded_documents) AS doc
  WHERE applications.id = '5afc4def-0dd9-438f-9200-5f9cfee78106'
  AND doc->>'doc_name' = 'Invoice Payment Receipt'
)
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';

-- Verify the update
SELECT 
  id,
  invoice_number,
  student_name,
  payment_receipts
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';
