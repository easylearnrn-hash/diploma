-- Check if enrollment_questionnaires table exists and has data
-- Run in Supabase SQL Editor

-- 1. Check if table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'enrollment_questionnaires'
) as table_exists;

-- 2. Count records in table
SELECT COUNT(*) as total_records FROM enrollment_questionnaires;

-- 3. Check RLS policies
SELECT 
  schemaname,
  tablename,
  policyname,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'enrollment_questionnaires'
ORDER BY policyname;

-- 4. Show sample data (control numbers)
SELECT 
  id,
  control_number,
  application_id,
  created_at,
  jsonb_object_keys(questionnaire_data) as data_keys
FROM enrollment_questionnaires
LIMIT 5;
