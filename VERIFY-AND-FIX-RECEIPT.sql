-- Complete verification and fix for Ani's receipt
-- This ensures we're using the CORRECT URL from applications table

-- Step 1: Show what's in applications (the source of truth)
SELECT 
  'APPLICATIONS TABLE (Source of Truth)' as table_name,
  id,
  uploaded_documents->0->>'public_url' as actual_uploaded_url
FROM applications 
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106';

-- Step 2: Show what's currently in invoices
SELECT 
  'INVOICES TABLE (Before Fix)' as table_name,
  id,
  invoice_number,
  payment_receipts->0->>'public_url' as current_receipt_url
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';

-- Step 3: Force update to match applications table exactly
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

-- Step 4: Verify the fix
SELECT 
  'INVOICES TABLE (After Fix)' as table_name,
  id,
  invoice_number,
  payment_receipts->0->>'public_url' as fixed_receipt_url
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';

-- Step 5: Test if the URL is accessible
SELECT 
  'URL COMPARISON' as check_type,
  uploaded_documents->0->>'public_url' as applications_url,
  (SELECT payment_receipts->0->>'public_url' 
   FROM invoices 
   WHERE student_id = 'ACNHS-9656167' 
   AND status = 'unpaid') as invoices_url,
  CASE 
    WHEN uploaded_documents->0->>'public_url' = 
         (SELECT payment_receipts->0->>'public_url' 
          FROM invoices 
          WHERE student_id = 'ACNHS-9656167' 
          AND status = 'unpaid')
    THEN '✅ URLS MATCH'
    ELSE '❌ URLS DO NOT MATCH'
  END as status
FROM applications 
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106';
