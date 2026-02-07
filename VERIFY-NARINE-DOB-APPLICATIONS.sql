-- Verify the date of birth in applications table
SELECT 
    control_number,
    applicant_name,
    date_of_birth
FROM applications
WHERE control_number = 'ACNHS-ADM-2026011';
