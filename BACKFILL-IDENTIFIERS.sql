-- Backfill control numbers for existing applications
-- Run this AFTER running ADD-UNIQUE-IDENTIFIERS.sql

-- This will add control_number, document_id, and hash to applications that don't have them yet

UPDATE public.applications
SET 
    control_number = 'ACN-' || EXTRACT(YEAR FROM submission_date)::text || '-' || LPAD((FLOOR(RANDOM() * 900000) + 100000)::text, 6, '0'),
    document_id = 'ACN-' || EXTRACT(YEAR FROM submission_date)::text || '-' || LPAD((FLOOR(RANDOM() * 900000) + 100000)::text, 6, '0'),
    hash = 'SHA256-' || UPPER(SUBSTRING(MD5(id::text || reference_number) FROM 1 FOR 6))
WHERE 
    control_number IS NULL 
    OR document_id IS NULL 
    OR hash IS NULL;

-- Verify the update
SELECT 
    reference_number,
    control_number,
    document_id,
    hash,
    applicant_name
FROM public.applications
ORDER BY submission_date DESC
LIMIT 10;
