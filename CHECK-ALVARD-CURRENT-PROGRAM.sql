-- Check Alvard's current program in applications table
SELECT 
  id,
  applicant_name,
  program,
  email
FROM applications
WHERE applicant_name ILIKE '%Alvard%'
  AND applicant_name ILIKE '%Ghukasyan%';
