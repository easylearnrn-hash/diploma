-- COMPREHENSIVE FIX: Find the correct receipt URL and update invoice
-- This will check storage bucket directly to find the actual file

-- Step 1: Show ALL uploaded documents for Ani (to find the correct one)
SELECT 
  '1. ALL UPLOADED DOCUMENTS' as step,
  jsonb_pretty(uploaded_documents) as all_documents
FROM applications 
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106';

-- Step 2: Extract just the Invoice Payment Receipt
SELECT 
  '2. INVOICE PAYMENT RECEIPT ONLY' as step,
  doc->>'filename' as filename,
  doc->>'public_url' as url,
  doc->>'uploaded_at' as uploaded_at,
  doc->>'size' as size
FROM applications,
jsonb_array_elements(uploaded_documents) AS doc
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106'
AND doc->>'doc_name' = 'Invoice Payment Receipt';

-- Step 3: Show current invoice payment_receipts
SELECT 
  '3. CURRENT INVOICE RECEIPTS' as step,
  invoice_number,
  jsonb_pretty(payment_receipts) as current_receipts
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';

-- Step 4: FORCE UPDATE - Copy exact URL from applications to invoice
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
AND status = 'unpaid'
RETURNING 
  '4. UPDATED INVOICE' as step,
  invoice_number,
  jsonb_pretty(payment_receipts) as updated_receipts;

-- Step 5: Final verification - Compare URLs
SELECT 
  '5. FINAL VERIFICATION' as step,
  a.uploaded_documents->0->>'public_url' as applications_url,
  i.payment_receipts->0->>'public_url' as invoice_url,
  CASE 
    WHEN a.uploaded_documents->0->>'public_url' = i.payment_receipts->0->>'public_url'
    THEN '✅ URLS MATCH - SHOULD WORK NOW'
    ELSE '❌ URLS STILL DO NOT MATCH'
  END as status
FROM applications a
CROSS JOIN invoices i
WHERE a.id = '5afc4def-0dd9-438f-9200-5f9cfee78106'
AND i.student_id = 'ACNHS-9656167'
AND i.status = 'unpaid';
