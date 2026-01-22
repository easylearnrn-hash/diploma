-- Run each query ONE AT A TIME and copy the result

-- Query 1: APPLICATIONS
SELECT STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as applications_columns
FROM information_schema.columns
WHERE table_name = 'applications';

-- Query 2: REGISTRATIONS  
SELECT STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as registrations_columns
FROM information_schema.columns
WHERE table_name = 'registrations';

-- Query 3: STUDENTS
SELECT STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as students_columns
FROM information_schema.columns
WHERE table_name = 'students';

-- Query 4: EMAIL_HISTORY
SELECT STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as email_history_columns
FROM information_schema.columns
WHERE table_name = 'email_history';

-- Query 5: ADMIN_USERS
SELECT STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as admin_users_columns
FROM information_schema.columns
WHERE table_name = 'admin_users';

-- Query 6: USER_TASKS
SELECT STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as user_tasks_columns
FROM information_schema.columns
WHERE table_name = 'user_tasks';

-- Query 7: TRANSCRIPTS
SELECT STRING_AGG(column_name, ', ' ORDER BY ordinal_position) as transcripts_columns
FROM information_schema.columns
WHERE table_name = 'transcripts';
