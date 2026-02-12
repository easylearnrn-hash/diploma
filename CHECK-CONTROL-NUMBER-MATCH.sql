-- Check if control_numbers match between applications and questionnaires
-- Run in Supabase SQL Editor

-- 1. Show applications with control numbers
SELECT 
  id,
  control_number,
  applicant_name,
  status
FROM applications
WHERE control_number IS NOT NULL
LIMIT 10;

-- 2. Check if ACN-2026-811551 exists in applications table
SELECT 
  id,
  control_number,
  applicant_name,
  email,
  status
FROM applications
WHERE control_number = 'ACN-2026-811551';

-- 3. Check questionnaire for this control number
SELECT 
  id,
  control_number,
  created_at,
  questionnaire_data->'personal_info'->>'full_name' as name
FROM enrollment_questionnaires
WHERE control_number = 'ACN-2026-811551'
ORDER BY created_at DESC
LIMIT 1;
