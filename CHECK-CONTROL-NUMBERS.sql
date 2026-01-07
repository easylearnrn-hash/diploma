-- Check what control numbers exist in the database
-- Use this to find the actual control numbers for your applications

SELECT 
    id,
    reference_number,
    control_number,
    applicant_name,
    email,
    status,
    submission_date
FROM public.applications
ORDER BY submission_date DESC
LIMIT 20;

-- If you want to find a specific application by name:
-- SELECT reference_number, control_number, applicant_name 
-- FROM public.applications 
-- WHERE applicant_name ILIKE '%name%';

-- If you want to update a specific application to have the control number ACN-2026-136376:
-- UPDATE public.applications
-- SET control_number = 'ACN-2026-136376'
-- WHERE reference_number = 'YOUR-REFERENCE-NUMBER-HERE';
