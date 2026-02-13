-- ABSOLUTE FIX: Force set payment_receipts array from applications data
-- Handles NULL by directly setting the array

-- Step 1: Show source data
SELECT 
  '1. SOURCE DATA' as step,
  jsonb_agg(
    jsonb_build_object(
      'filename', doc->>'filename',
      'public_url', doc->>'public_url',
      'uploaded_at', doc->>'uploaded_at',
      'size', (doc->>'size')::integer
    )
  ) as receipt_data
FROM applications,
jsonb_array_elements(uploaded_documents) AS doc
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106'
AND doc->>'doc_name' = 'Invoice Payment Receipt';

-- Step 2: Force update with direct array replacement
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

-- Step 3: Verify it worked
SELECT 
  '3. AFTER UPDATE' as step,
  invoice_number,
  student_name,
  CASE 
    WHEN payment_receipts IS NULL THEN '❌ STILL NULL'
    WHEN jsonb_array_length(payment_receipts) = 0 THEN '⚠️ EMPTY ARRAY'
    ELSE '✅ HAS ' || jsonb_array_length(payment_receipts)::text || ' RECEIPT(S)'
  END as status,
  jsonb_pretty(payment_receipts) as receipts_data
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';

-- Step 4: Test the URL
SELECT 
  '4. URL TEST' as step,
  payment_receipts->0->>'filename' as filename,
  payment_receipts->0->>'public_url' as full_url,
  (payment_receipts->0->>'size')::integer as file_size,
  payment_receipts->0->>'uploaded_at' as upload_time
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';
