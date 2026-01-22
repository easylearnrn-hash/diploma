-- ====================================================================
-- DATABASE SETUP VERIFICATION TEST
-- Run this after completing all migrations to verify everything is set up correctly
-- ====================================================================

-- ====================================================================
-- 1. CHECK ALL REQUIRED TABLES EXIST
-- ====================================================================
SELECT 
  'TABLES CHECK' as test_category,
  CASE 
    WHEN COUNT(*) >= 10 THEN '✓ PASS'
    ELSE '✗ FAIL - Missing tables'
  END as status,
  COUNT(*) as tables_found,
  STRING_AGG(table_name, ', ' ORDER BY table_name) as table_list
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
  AND table_name IN (
    'applications',
    'registrations', 
    'students',
    'transcripts',
    'sms_verifications',
    'sms_logs',
    'email_history',
    'admin_users',
    'user_tasks',
    'user_activity_log'
  );

-- ====================================================================
-- 2. CHECK APPLICATIONS TABLE HAS ALL REQUIRED COLUMNS
-- ====================================================================
SELECT 
  'APPLICATIONS COLUMNS' as test_category,
  CASE 
    WHEN COUNT(*) >= 15 THEN '✓ PASS'
    ELSE '✗ FAIL - Missing columns'
  END as status,
  COUNT(*) as columns_found,
  STRING_AGG(column_name, ', ' ORDER BY column_name) as missing_or_present
FROM information_schema.columns 
WHERE table_name = 'applications' 
  AND column_name IN (
    'id',
    'document_id',
    'control_number',
    'verification_hash',
    'username',
    'password_hash',
    'credentials_screenshot',
    'payload',
    'status',
    'created_at',
    'armenian_citizen',
    'us_immigration_status',
    'last_time_in_armenia',
    'armenia_exit_date',
    'acceptance_letter_sent'
  );

-- ====================================================================
-- 3. CHECK REGISTRATIONS TABLE HAS ALL REQUIRED COLUMNS
-- ====================================================================
SELECT 
  'REGISTRATIONS COLUMNS' as test_category,
  CASE 
    WHEN COUNT(*) >= 8 THEN '✓ PASS'
    ELSE '✗ FAIL - Missing columns'
  END as status,
  COUNT(*) as columns_found,
  STRING_AGG(column_name, ', ' ORDER BY column_name) as columns_list
FROM information_schema.columns 
WHERE table_name = 'registrations' 
  AND column_name IN (
    'id',
    'payload',
    'status',
    'reminder_date',
    'created_at',
    'updated_at',
    'phone',
    'email'
  );

-- ====================================================================
-- 4. CHECK EMAIL_HISTORY TABLE HAS ALL REQUIRED COLUMNS
-- ====================================================================
SELECT 
  'EMAIL_HISTORY COLUMNS' as test_category,
  CASE 
    WHEN COUNT(*) >= 12 THEN '✓ PASS'
    ELSE '✗ FAIL - Missing columns'
  END as status,
  COUNT(*) as columns_found,
  STRING_AGG(column_name, ', ' ORDER BY column_name) as columns_list
FROM information_schema.columns 
WHERE table_name = 'email_history' 
  AND column_name IN (
    'id',
    'to_email',
    'from_email',
    'subject',
    'body',
    'html_body',
    'status',
    'sent_at',
    'created_at',
    'application_id',
    'sent_by_admin',
    'archived'
  );

-- ====================================================================
-- 5. CHECK ADMIN_USERS TABLE HAS ALL REQUIRED COLUMNS
-- ====================================================================
SELECT 
  'ADMIN_USERS COLUMNS' as test_category,
  CASE 
    WHEN COUNT(*) >= 10 THEN '✓ PASS'
    ELSE '✗ FAIL - Missing columns'
  END as status,
  COUNT(*) as columns_found,
  STRING_AGG(column_name, ', ' ORDER BY column_name) as columns_list
FROM information_schema.columns 
WHERE table_name = 'admin_users' 
  AND column_name IN (
    'id',
    'name',
    'username',
    'email',
    'title',
    'phone_ext',
    'signature',
    'role',
    'status',
    'created_at'
  );

-- ====================================================================
-- 6. CHECK USER_TASKS TABLE EXISTS AND HAS REQUIRED COLUMNS
-- ====================================================================
SELECT 
  'USER_TASKS COLUMNS' as test_category,
  CASE 
    WHEN COUNT(*) >= 6 THEN '✓ PASS'
    ELSE '✗ FAIL - Missing columns'
  END as status,
  COUNT(*) as columns_found,
  STRING_AGG(column_name, ', ' ORDER BY column_name) as columns_list
FROM information_schema.columns 
WHERE table_name = 'user_tasks' 
  AND column_name IN (
    'id',
    'user_id',
    'task',
    'status',
    'archived',
    'created_at'
  );

-- ====================================================================
-- 7. CHECK STUDENTS TABLE HAS STUDENT_ID COLUMN
-- ====================================================================
SELECT 
  'STUDENTS TABLE' as test_category,
  CASE 
    WHEN COUNT(*) >= 4 THEN '✓ PASS'
    ELSE '✗ FAIL - Missing columns'
  END as status,
  COUNT(*) as columns_found,
  STRING_AGG(column_name, ', ' ORDER BY column_name) as columns_list
FROM information_schema.columns 
WHERE table_name = 'students' 
  AND column_name IN (
    'id',
    'student_id',
    'application_id',
    'created_at'
  );

-- ====================================================================
-- 8. CHECK RLS (ROW LEVEL SECURITY) IS ENABLED
-- ====================================================================
SELECT 
  'RLS SECURITY' as test_category,
  CASE 
    WHEN COUNT(*) >= 5 THEN '✓ PASS'
    ELSE '✗ FAIL - RLS not enabled on all tables'
  END as status,
  COUNT(*) as tables_with_rls,
  STRING_AGG(tablename, ', ' ORDER BY tablename) as secured_tables
FROM pg_tables 
WHERE schemaname = 'public' 
  AND rowsecurity = true
  AND tablename IN (
    'applications',
    'registrations',
    'students',
    'email_history',
    'admin_users'
  );

-- ====================================================================
-- 9. CHECK STORAGE BUCKETS EXIST
-- ====================================================================
SELECT 
  'STORAGE BUCKETS' as test_category,
  CASE 
    WHEN COUNT(*) >= 2 THEN '✓ PASS'
    ELSE '✗ FAIL - Missing storage buckets'
  END as status,
  COUNT(*) as buckets_found,
  STRING_AGG(name, ', ' ORDER BY name) as bucket_list
FROM storage.buckets 
WHERE name IN ('application-documents', 'email-attachments');

-- ====================================================================
-- 10. SUMMARY - COUNT ALL TESTS
-- ====================================================================
SELECT 
  '========================================' as separator,
  'FINAL SUMMARY' as report,
  '========================================' as separator2;

-- Show which tables are missing (if any)
SELECT 
  'MISSING TABLES' as check_type,
  expected_table as table_name,
  'NOT FOUND' as status
FROM (
  VALUES 
    ('applications'),
    ('registrations'),
    ('students'),
    ('transcripts'),
    ('email_history'),
    ('admin_users'),
    ('user_tasks'),
    ('sms_verifications'),
    ('sms_logs')
) AS expected(expected_table)
WHERE NOT EXISTS (
  SELECT 1 FROM information_schema.tables 
  WHERE table_schema = 'public' 
    AND table_name = expected_table
)
ORDER BY expected_table;

-- Show critical missing columns in applications table
SELECT 
  'MISSING APPLICATIONS COLUMNS' as check_type,
  expected_column as column_name,
  'NOT FOUND IN applications TABLE' as status
FROM (
  VALUES 
    ('armenian_citizen'),
    ('us_immigration_status'),
    ('last_time_in_armenia'),
    ('armenia_exit_date'),
    ('credentials_screenshot'),
    ('acceptance_letter_sent')
) AS expected(expected_column)
WHERE NOT EXISTS (
  SELECT 1 FROM information_schema.columns 
  WHERE table_name = 'applications' 
    AND column_name = expected_column
)
ORDER BY expected_column;

-- Final verdict
SELECT 
  '========================================' as separator,
  CASE 
    WHEN (
      SELECT COUNT(*) FROM information_schema.tables 
      WHERE table_schema = 'public' 
        AND table_name IN ('applications', 'registrations', 'students', 'email_history', 'admin_users')
    ) >= 5 
    AND (
      SELECT COUNT(*) FROM information_schema.columns 
      WHERE table_name = 'applications' 
        AND column_name IN ('armenian_citizen', 'credentials_screenshot')
    ) >= 2
    THEN '✓✓✓ DATABASE READY ✓✓✓'
    ELSE '✗✗✗ SETUP INCOMPLETE ✗✗✗'
  END as final_verdict,
  '========================================' as separator2;
