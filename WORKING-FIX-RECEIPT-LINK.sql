-- FINAL FIX: Link Ani's receipt from applications to invoices
-- This handles NULL payment_receipts and ensures proper linking

-- Step 1: Show what we have in applications
SELECT 
  '1. SOURCE DATA (applications)' as step,
  doc->>'filename' as filename,
  doc->>'public_url' as url,
  doc->>'doc_name' as document_type
FROM applications,
jsonb_array_elements(uploaded_documents) AS doc
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106'
AND doc->>'doc_name' = 'Invoice Payment Receipt';

-- Step 2: Update invoice with receipt (handles NULL case)
UPDATE invoices
SET payment_receipts = COALESCE(payment_receipts, '[]'::jsonb) || 
  (
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
AND status = 'unpaid'
RETURNING 
  '2. UPDATED INVOICE' as step,
  invoice_number,
  jsonb_pretty(payment_receipts) as linked_receipts;

-- Step 3: Verify the link worked
SELECT 
  '3. VERIFICATION' as step,
  invoice_number,
  student_name,
  jsonb_array_length(payment_receipts) as receipt_count,
  payment_receipts->0->>'filename' as first_receipt_filename,
  substring(payment_receipts->0->>'public_url', 1, 100) as first_receipt_url
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';
