-- DEBUG: Find out what's actually in both tables

-- Check applications table structure
SELECT 
  '1. APPLICATIONS - Full Document Array' as step,
  id,
  jsonb_array_length(uploaded_documents) as total_documents,
  jsonb_pretty(uploaded_documents) as all_documents
FROM applications 
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106';

-- Check each document in the array
SELECT 
  '2. APPLICATIONS - Individual Documents' as step,
  ordinality - 1 as array_index,
  doc->>'doc_name' as document_type,
  doc->>'filename' as filename,
  left(doc->>'public_url', 80) as url_preview
FROM applications,
jsonb_array_elements(uploaded_documents) WITH ORDINALITY AS doc
WHERE id = '5afc4def-0dd9-438f-9200-5f9cfee78106'
ORDER BY ordinality;

-- Check invoices table structure
SELECT 
  '3. INVOICES - Full Receipts Array' as step,
  id,
  invoice_number,
  jsonb_array_length(payment_receipts) as total_receipts,
  jsonb_pretty(payment_receipts) as all_receipts
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';

-- Check if payment_receipts has any data at all
SELECT 
  '4. INVOICES - Receipt Details' as step,
  CASE 
    WHEN payment_receipts IS NULL THEN 'NULL'
    WHEN jsonb_array_length(payment_receipts) = 0 THEN 'EMPTY ARRAY'
    ELSE 'HAS DATA: ' || jsonb_array_length(payment_receipts)::text || ' receipt(s)'
  END as status,
  payment_receipts
FROM invoices 
WHERE student_id = 'ACNHS-9656167'
AND status = 'unpaid';
