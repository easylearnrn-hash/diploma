-- Quick check if enrollment_questionnaires table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'enrollment_questionnaires'
);