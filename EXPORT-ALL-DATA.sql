-- ====================================================================
-- EXPORT ALL DATA FROM OLD SUPABASE ACCOUNT
-- Run this in OLD Supabase SQL Editor to get export data
-- ====================================================================

-- ====================================================================
-- STEP 1: COUNT RECORDS (to verify migration later)
-- ====================================================================
SELECT 'RECORD COUNTS' as export_step;

SELECT 
  'applications' as table_name,
  COUNT(*) as record_count
FROM applications
UNION ALL
SELECT 
  'registrations' as table_name,
  COUNT(*) as record_count
FROM registrations
UNION ALL
SELECT 
  'students' as table_name,
  COUNT(*) as record_count
FROM students
UNION ALL
SELECT 
  'email_history' as table_name,
  COUNT(*) as record_count
FROM email_history
UNION ALL
SELECT 
  'admin_users' as table_name,
  COUNT(*) as record_count
FROM admin_users
UNION ALL
SELECT 
  'user_tasks' as table_name,
  COUNT(*) as record_count
FROM user_tasks
UNION ALL
SELECT 
  'transcripts' as table_name,
  COUNT(*) as record_count
FROM transcripts
UNION ALL
SELECT 
  'sms_verifications' as table_name,
  COUNT(*) as record_count
FROM sms_verifications
UNION ALL
SELECT 
  'sms_logs' as table_name,
  COUNT(*) as record_count
FROM sms_logs
ORDER BY record_count DESC;

-- ====================================================================
-- EXPORT EACH TABLE SEPARATELY
-- Comment out tables you don't need
-- ====================================================================

-- APPLICATIONS (run separately)
SELECT * FROM applications;

-- REGISTRATIONS (run separately)
-- SELECT * FROM registrations;

-- STUDENTS (run separately)
-- SELECT * FROM students;

-- EMAIL_HISTORY (run separately)
-- SELECT * FROM email_history;

-- ADMIN_USERS (run separately)
-- SELECT * FROM admin_users;

-- USER_TASKS (run separately)
-- SELECT * FROM user_tasks;

-- TRANSCRIPTS (run separately)
-- SELECT * FROM transcripts;

-- ====================================================================
-- STEP 9: STORAGE BUCKET FILE LIST
-- ====================================================================
SELECT '========== STORAGE FILES ==========' as export_step;

SELECT 
  name as file_name,
  bucket_id,
  created_at,
  updated_at,
  metadata::text as file_metadata
FROM storage.objects
WHERE bucket_id IN ('application-documents', 'email-attachments')
ORDER BY bucket_id, created_at DESC;

-- ====================================================================
-- FINAL SUMMARY
-- ====================================================================
SELECT '========== EXPORT SUMMARY ==========' as export_step;

SELECT 
  'Total records to migrate' as summary,
  (SELECT COUNT(*) FROM applications) + 
  (SELECT COUNT(*) FROM registrations) + 
  (SELECT COUNT(*) FROM students) + 
  (SELECT COUNT(*) FROM email_history) + 
  (SELECT COUNT(*) FROM admin_users) + 
  (SELECT COUNT(*) FROM user_tasks) as total_records;
