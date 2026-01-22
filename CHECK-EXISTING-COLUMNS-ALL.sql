-- ====================================================================
-- CHECK WHAT COLUMNS ACTUALLY EXIST IN YOUR DATABASE
-- Run this FIRST to see what columns you have
-- ====================================================================

-- Check applications table columns
SELECT 
  'APPLICATIONS TABLE' as table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'applications'
ORDER BY ordinal_position;

-- Check registrations table columns
SELECT 
  'REGISTRATIONS TABLE' as table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'registrations'
ORDER BY ordinal_position;

-- Check students table columns
SELECT 
  'STUDENTS TABLE' as table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'students'
ORDER BY ordinal_position;

-- Check email_history table columns
SELECT 
  'EMAIL_HISTORY TABLE' as table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'email_history'
ORDER BY ordinal_position;

-- Check admin_users table columns
SELECT 
  'ADMIN_USERS TABLE' as table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'admin_users'
ORDER BY ordinal_position;

-- Check user_tasks table columns
SELECT 
  'USER_TASKS TABLE' as table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'user_tasks'
ORDER BY ordinal_position;

-- Check transcripts table columns
SELECT 
  'TRANSCRIPTS TABLE' as table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'transcripts'
ORDER BY ordinal_position;

-- Summary of all columns count
SELECT 
  table_name,
  COUNT(*) as column_count
FROM information_schema.columns
WHERE table_name IN ('applications', 'registrations', 'students', 'email_history', 'admin_users', 'user_tasks', 'transcripts')
GROUP BY table_name
ORDER BY table_name;
