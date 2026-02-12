-- Check complete questionnaire data structure
-- Run in Supabase SQL Editor

SELECT 
  id,
  control_number,
  created_at,
  questionnaire_data
FROM enrollment_questionnaires
WHERE control_number = 'ACN-2026-811551'
ORDER BY created_at DESC
LIMIT 1;

-- Check what keys exist in the questionnaire_data JSONB
SELECT 
  control_number,
  jsonb_object_keys(questionnaire_data) as data_keys
FROM enrollment_questionnaires
WHERE control_number = 'ACN-2026-811551'
ORDER BY created_at DESC
LIMIT 1;

-- Show specific sections
SELECT 
  control_number,
  questionnaire_data->'personal_info' as personal_info,
  questionnaire_data->'residency_travel' as residency_travel,
  questionnaire_data->'education_history' as education_history,
  questionnaire_data->'emergency_contact' as emergency_contact
FROM enrollment_questionnaires
WHERE control_number = 'ACN-2026-811551'
ORDER BY created_at DESC
LIMIT 1;
