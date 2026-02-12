-- Check departure dates in questionnaires
-- Run in Supabase SQL Editor

-- 1. Count questionnaires with and without departure dates
SELECT 
  COUNT(*) as total_questionnaires,
  COUNT(questionnaire_data->'residency_travel'->>'permanent_departure_date') as with_departure_date,
  COUNT(*) - COUNT(questionnaire_data->'residency_travel'->>'permanent_departure_date') as without_departure_date
FROM enrollment_questionnaires;

-- 2. Show all questionnaires with their departure date status
SELECT 
  control_number,
  questionnaire_data->'personal_info'->>'full_name' as name,
  questionnaire_data->'residency_travel'->>'permanent_departure_date' as departure_date,
  CASE 
    WHEN questionnaire_data->'residency_travel'->>'permanent_departure_date' IS NOT NULL 
    THEN '✅ HAS DATE'
    ELSE '❌ MISSING'
  END as status,
  created_at
FROM enrollment_questionnaires
ORDER BY created_at DESC;

-- 3. Check if the field exists but is empty string
SELECT 
  control_number,
  questionnaire_data->'residency_travel'->>'permanent_departure_date' as raw_value,
  LENGTH(questionnaire_data->'residency_travel'->>'permanent_departure_date') as value_length
FROM enrollment_questionnaires
WHERE questionnaire_data->'residency_travel' IS NOT NULL;

-- 4. Show complete residency_travel object for analysis
SELECT 
  control_number,
  questionnaire_data->'residency_travel' as residency_travel_data
FROM enrollment_questionnaires
LIMIT 5;
