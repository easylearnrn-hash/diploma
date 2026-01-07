-- Set a specific control number for an application
-- Use this if you want to assign ACN-2026-136376 to a specific application

-- STEP 1: Find the application you want to update
-- Run this first to see your applications:
SELECT 
    reference_number,
    control_number,
    applicant_name,
    email,
    program,
    submission_date
FROM public.applications
ORDER BY submission_date DESC
LIMIT 10;

-- STEP 2: Update the application with the desired control number
-- Replace 'ACNHS-ADM-20260106-960' with your actual reference number

-- Example: Set control number for Valentina Sookassians's application
UPDATE public.applications
SET 
    control_number = 'ACN-2026-136376',
    document_id = 'ACN-2026-392908',
    hash = 'SHA256-D82025'
WHERE reference_number = 'ACNHS-ADM-20260106-960';  -- Replace with actual reference number

-- STEP 3: Verify the update
SELECT 
    reference_number,
    control_number,
    document_id,
    hash,
    applicant_name
FROM public.applications
WHERE control_number = 'ACN-2026-136376';

-- NOTE: Change the WHERE clause to match YOUR application:
-- WHERE applicant_name = 'Your Name Here'
-- OR
-- WHERE email = 'your@email.com'
-- OR
-- WHERE reference_number = 'ACNHS-ADM-XXXXXXXX-XXX'
