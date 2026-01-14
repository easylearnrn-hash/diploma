-- COMPREHENSIVE UNIQUE IDENTIFIER VERIFICATION
-- Run this in Supabase SQL Editor to triple-check all identifiers

-- ========================================
-- STEP 1: Check for duplicate control_numbers
-- ========================================
SELECT 'CONTROL NUMBER DUPLICATES' as check_type, control_number, COUNT(*) as count
FROM public.applications
WHERE control_number IS NOT NULL
GROUP BY control_number
HAVING COUNT(*) > 1;

-- ========================================
-- STEP 2: Check for duplicate document_ids
-- ========================================
SELECT 'DOCUMENT ID DUPLICATES' as check_type, document_id, COUNT(*) as count
FROM public.applications
WHERE document_id IS NOT NULL
GROUP BY document_id
HAVING COUNT(*) > 1;

-- ========================================
-- STEP 3: Check for duplicate verification hashes
-- ========================================
SELECT 'VERIFICATION HASH DUPLICATES' as check_type, verification_hash, COUNT(*) as count
FROM public.applications
WHERE verification_hash IS NOT NULL
GROUP BY verification_hash
HAVING COUNT(*) > 1;

-- ========================================
-- STEP 4: Check for duplicate reference_numbers
-- ========================================
SELECT 'REFERENCE NUMBER DUPLICATES' as check_type, reference_number, COUNT(*) as count
FROM public.applications
WHERE reference_number IS NOT NULL
GROUP BY reference_number
HAVING COUNT(*) > 1;

-- ========================================
-- STEP 5: Check for duplicate barcodes
-- ========================================
SELECT 'BARCODE DUPLICATES' as check_type, barcode, COUNT(*) as count
FROM public.applications
WHERE barcode IS NOT NULL
GROUP BY barcode
HAVING COUNT(*) > 1;

-- ========================================
-- STEP 6: Check for NULL identifiers (should all be populated)
-- ========================================
SELECT 
    COUNT(*) FILTER (WHERE control_number IS NULL) as null_control_numbers,
    COUNT(*) FILTER (WHERE document_id IS NULL) as null_document_ids,
    COUNT(*) FILTER (WHERE verification_hash IS NULL) as null_verification_hashes,
    COUNT(*) FILTER (WHERE reference_number IS NULL) as null_reference_numbers,
    COUNT(*) FILTER (WHERE barcode IS NULL) as null_barcodes,
    COUNT(*) as total_applications
FROM public.applications;

-- ========================================
-- STEP 7: Verify UNIQUE constraints exist
-- ========================================
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    a.attname as column_name
FROM pg_constraint c
JOIN pg_attribute a ON a.attnum = ANY(c.conkey) AND a.attrelid = c.conrelid
WHERE c.conrelid = 'public.applications'::regclass
    AND c.contype = 'u'  -- unique constraints
ORDER BY conname;

-- ========================================
-- STEP 8: Sample recent applications with all identifiers
-- ========================================
SELECT 
    reference_number,
    control_number,
    document_id,
    verification_hash,
    barcode,
    applicant_name,
    submission_date
FROM public.applications
ORDER BY submission_date DESC
LIMIT 10;
