-- ====================================================================
-- IMPORT ALL DATA INTO NEW SUPABASE ACCOUNT
-- Run this AFTER setting up schema in new account
-- ====================================================================
-- IMPORTANT: Replace the INSERT VALUES below with your exported data
-- ====================================================================

-- ====================================================================
-- STEP 1: DISABLE TRIGGERS TEMPORARILY (for faster import)
-- ====================================================================
ALTER TABLE applications DISABLE TRIGGER ALL;
ALTER TABLE registrations DISABLE TRIGGER ALL;
ALTER TABLE students DISABLE TRIGGER ALL;
ALTER TABLE email_history DISABLE TRIGGER ALL;

-- ====================================================================
-- STEP 2: IMPORT APPLICATIONS
-- ====================================================================
-- Format: Copy rows from export and paste here
-- Example:
/*
INSERT INTO applications (
  id,
  reference_number,
  control_number,
  document_id,
  verification_hash,
  barcode,
  hash,
  username,
  password_hash,
  applicant_name,
  email,
  phone,
  institutional_email,
  program,
  start_term,
  submission_date,
  payload,
  status,
  status_message,
  status_history,
  status_updated_at,
  rfe_documents_requested,
  admin_notes,
  uploaded_documents,
  credentials_screenshot,
  armenian_citizen,
  us_immigration_status,
  last_time_in_armenia,
  armenia_exit_date,
  acceptance_letter_sent
) VALUES
  ('uuid-here', 'REF-001', 'CTRL-001', 'DOC-001', 'hash', 'barcode', 'hash2', 'user1', 'pass', 'John Doe', 'email@test.com', '+1234', 'inst@test.com', 'Nursing', 'Fall 2026', NOW(), '{}', 'SUBMITTED', NULL, '[]', NOW(), '[]', NULL, '[]', NULL, 'Yes', 'US Citizen', '2024-01-01', '2010-05-15', false),
  -- Add more rows...
ON CONFLICT (id) DO NOTHING;
*/

-- ====================================================================
-- STEP 3: IMPORT REGISTRATIONS
-- ====================================================================
/*
INSERT INTO registrations (
  id,
  payload,
  phone,
  email,
  status,
  reminder_date,
  created_at,
  updated_at
) VALUES
  ('uuid-here', '{}', '+1234', 'test@test.com', 'pending', NULL, NOW(), NOW()),
  -- Add more rows...
ON CONFLICT (id) DO NOTHING;
*/

-- ====================================================================
-- STEP 4: IMPORT STUDENTS
-- ====================================================================
/*
INSERT INTO students (
  id,
  student_id,
  full_name,
  email,
  phone,
  date_of_birth,
  program,
  start_term,
  status,
  application_id,
  metadata,
  created_at,
  updated_at
) VALUES
  ('uuid-here', 'ACNHS-123456789', 'John Doe', 'student@test.com', '+1234', '2000-01-01', 'Nursing', 'Fall 2026', 'active', 'app-uuid-here', '{}', NOW(), NOW()),
  -- Add more rows...
ON CONFLICT (id) DO NOTHING;
*/

-- ====================================================================
-- STEP 5: IMPORT EMAIL HISTORY
-- ====================================================================
/*
INSERT INTO email_history (
  id,
  to_email,
  from_email,
  subject,
  body,
  html_body,
  status,
  sent_at,
  created_at,
  application_id,
  sent_by_admin,
  archived,
  sender,
  direction,
  attachments
) VALUES
  ('uuid-here', 'to@test.com', 'from@test.com', 'Subject', 'Body', '<p>HTML</p>', 'sent', NOW(), NOW(), 'app-uuid', 'Admin Name', false, 'admin@test.com', 'outbound', '[]'),
  -- Add more rows...
ON CONFLICT (id) DO NOTHING;
*/

-- ====================================================================
-- STEP 6: IMPORT ADMIN USERS
-- ====================================================================
/*
INSERT INTO admin_users (
  id,
  name,
  username,
  password_hash,
  role,
  title,
  phone_ext,
  email,
  signature,
  status,
  permissions,
  email_permissions,
  created_at,
  updated_at,
  last_login,
  forward_enabled,
  forward_to_email
) VALUES
  ('uuid-here', 'Admin Name', 'admin', 'hash', 'admin', 'Director', '100', 'admin@acnhs.am', 'Signature', 'active', '{}', ARRAY[]::TEXT[], NOW(), NOW(), NULL, false, NULL),
  -- Add more rows...
ON CONFLICT (id) DO NOTHING;
*/

-- ====================================================================
-- STEP 7: IMPORT USER TASKS
-- ====================================================================
/*
INSERT INTO user_tasks (
  id,
  user_id,
  task,
  status,
  archived,
  completed_at,
  created_at,
  comments
) VALUES
  ('uuid-here', 'user-uuid', 'Task description', 'pending', false, NULL, NOW(), NULL),
  -- Add more rows...
ON CONFLICT (id) DO NOTHING;
*/

-- ====================================================================
-- STEP 8: IMPORT TRANSCRIPTS
-- ====================================================================
/*
INSERT INTO transcripts (
  id,
  verification_code,
  student_id,
  student_name,
  date_of_birth,
  degree_program,
  transcript_type,
  issue_date,
  status,
  cumulative_gpa,
  total_credits,
  metadata
) VALUES
  ('uuid-here', 'TR-001', 'ACNHS-123', 'Student Name', '2000-01-01', 'Nursing', 'official', '2026-01-01', 'valid', 3.75, 120, '{}'),
  -- Add more rows...
ON CONFLICT (id) DO NOTHING;
*/

-- ====================================================================
-- STEP 9: RE-ENABLE TRIGGERS
-- ====================================================================
ALTER TABLE applications ENABLE TRIGGER ALL;
ALTER TABLE registrations ENABLE TRIGGER ALL;
ALTER TABLE students ENABLE TRIGGER ALL;
ALTER TABLE email_history ENABLE TRIGGER ALL;

-- ====================================================================
-- STEP 10: VERIFY IMPORT COUNTS
-- ====================================================================
SELECT 
  'applications' as table_name,
  COUNT(*) as imported_count
FROM applications
UNION ALL
SELECT 
  'registrations' as table_name,
  COUNT(*) as imported_count
FROM registrations
UNION ALL
SELECT 
  'students' as table_name,
  COUNT(*) as imported_count
FROM students
UNION ALL
SELECT 
  'email_history' as table_name,
  COUNT(*) as imported_count
FROM email_history
UNION ALL
SELECT 
  'admin_users' as table_name,
  COUNT(*) as imported_count
FROM admin_users
UNION ALL
SELECT 
  'user_tasks' as table_name,
  COUNT(*) as imported_count
FROM user_tasks
UNION ALL
SELECT 
  'transcripts' as table_name,
  COUNT(*) as imported_count
FROM transcripts
ORDER BY imported_count DESC;

-- Compare these counts with EXPORT-ALL-DATA.sql results
