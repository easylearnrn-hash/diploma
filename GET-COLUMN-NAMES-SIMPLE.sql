-- Get all column names as comma-separated list for easy copying
SELECT 
  'APPLICATIONS COLUMNS:' as info,
  STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_name = 'applications';

SELECT 
  'REGISTRATIONS COLUMNS:' as info,
  STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_name = 'registrations';

SELECT 
  'STUDENTS COLUMNS:' as info,
  STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_name = 'students';

SELECT 
  'EMAIL_HISTORY COLUMNS:' as info,
  STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_name = 'email_history';

SELECT 
  'ADMIN_USERS COLUMNS:' as info,
  STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_name = 'admin_users';

SELECT 
  'USER_TASKS COLUMNS:' as info,
  STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_name = 'user_tasks';

SELECT 
  'TRANSCRIPTS COLUMNS:' as info,
  STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as columns
FROM information_schema.columns
WHERE table_name = 'transcripts';
