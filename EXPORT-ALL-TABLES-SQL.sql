-- ====================================================================
-- COMPLETE SQL EXPORT FOR ALL TABLES
-- Run each section in OLD Supabase, copy results, paste in NEW Supabase
-- ====================================================================

-- ====================================================================
-- 1. EXPORT APPLICATIONS
-- ====================================================================
SELECT 
  'INSERT INTO applications (id, reference_number, control_number, document_id, verification_hash, barcode, hash, username, password_hash, applicant_name, email, phone, program, start_term, submission_date, payload, status, status_message, status_history, status_updated_at, rfe_documents_requested, admin_notes, uploaded_documents, credentials_screenshot, armenian_citizen, us_immigration_status, last_time_in_armenia, armenia_exit_date) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || ', ' ||
    quote_nullable(reference_number) || ', ' ||
    quote_nullable(control_number) || ', ' ||
    quote_nullable(document_id) || ', ' ||
    quote_nullable(verification_hash) || ', ' ||
    quote_nullable(barcode) || ', ' ||
    quote_nullable(hash) || ', ' ||
    quote_nullable(username) || ', ' ||
    quote_nullable(password_hash) || ', ' ||
    quote_nullable(applicant_name) || ', ' ||
    quote_nullable(email) || ', ' ||
    quote_nullable(phone) || ', ' ||
    quote_nullable(program) || ', ' ||
    quote_nullable(start_term) || ', ' ||
    quote_nullable(submission_date::text) || '::timestamptz, ' ||
    quote_literal(payload::text) || '::jsonb, ' ||
    quote_nullable(status) || ', ' ||
    quote_nullable(status_message) || ', ' ||
    quote_literal(COALESCE(status_history::text, '[]')) || '::jsonb, ' ||
    quote_nullable(status_updated_at::text) || '::timestamptz, ' ||
    quote_literal(COALESCE(rfe_documents_requested::text, '[]')) || '::jsonb, ' ||
    quote_nullable(admin_notes) || ', ' ||
    quote_literal(COALESCE(uploaded_documents::text, '[]')) || '::jsonb, ' ||
    quote_nullable(credentials_screenshot) || ', ' ||
    quote_nullable(armenian_citizen) || ', ' ||
    quote_nullable(us_immigration_status) || ', ' ||
    quote_nullable(last_time_in_armenia) || ', ' ||
    quote_nullable(armenia_exit_date) ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;' as sql_export
FROM applications;

-- ====================================================================
-- 2. EXPORT REGISTRATIONS
-- ====================================================================
-- Run this separately after applications
/*
SELECT 
  'INSERT INTO registrations (id, full_name, date_of_birth, email, phone, education_level, preferred_start_date, registration_date, status, notes, reminder_date) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || ', ' ||
    quote_nullable(full_name) || ', ' ||
    quote_nullable(date_of_birth) || ', ' ||
    quote_nullable(email) || ', ' ||
    quote_nullable(phone) || ', ' ||
    quote_nullable(education_level) || ', ' ||
    quote_nullable(preferred_start_date) || ', ' ||
    quote_nullable(registration_date::text) || '::timestamptz, ' ||
    quote_nullable(status) || ', ' ||
    quote_nullable(notes) || ', ' ||
    quote_nullable(reminder_date::text) || '::timestamptz' ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;' as sql_export
FROM registrations;
*/

-- ====================================================================
-- 3. EXPORT STUDENTS
-- ====================================================================
-- Run this separately after applications (has FK to applications)
/*
SELECT 
  'INSERT INTO students (id, name, group_name, price_per_class, email, phone, aliases, notes, status, status_changed_date, balance, created_at, show_in_grid, auth_user_id, role, college, student_id, full_name, date_of_birth, program, start_term, application_id, metadata, updated_at) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || ', ' ||
    quote_nullable(name) || ', ' ||
    quote_nullable(group_name) || ', ' ||
    quote_nullable(price_per_class) || ', ' ||
    quote_nullable(email) || ', ' ||
    quote_nullable(phone) || ', ' ||
    quote_nullable(aliases) || ', ' ||
    quote_nullable(notes) || ', ' ||
    quote_nullable(status) || ', ' ||
    quote_nullable(status_changed_date::text) || '::timestamptz, ' ||
    COALESCE(balance::text, '0') || ', ' ||
    quote_nullable(created_at::text) || '::timestamptz, ' ||
    COALESCE(show_in_grid::text, 'false') || ', ' ||
    quote_nullable(auth_user_id::text) || '::uuid, ' ||
    quote_nullable(role) || ', ' ||
    quote_nullable(college) || ', ' ||
    quote_nullable(student_id) || ', ' ||
    quote_nullable(full_name) || ', ' ||
    quote_nullable(date_of_birth) || ', ' ||
    quote_nullable(program) || ', ' ||
    quote_nullable(start_term) || ', ' ||
    quote_nullable(application_id::text) || '::uuid, ' ||
    quote_literal(COALESCE(metadata::text, '{}')) || '::jsonb, ' ||
    quote_nullable(updated_at::text) || '::timestamptz' ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;' as sql_export
FROM students;
*/

-- ====================================================================
-- 4. EXPORT EMAIL_HISTORY
-- ====================================================================
/*
SELECT 
  'INSERT INTO email_history (id, recipient, subject, body, status, sent_at, resend_id, error, created_at, sender, html_body, attachments) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || ', ' ||
    quote_nullable(recipient) || ', ' ||
    quote_nullable(subject) || ', ' ||
    quote_nullable(body) || ', ' ||
    quote_nullable(status) || ', ' ||
    quote_nullable(sent_at::text) || '::timestamptz, ' ||
    quote_nullable(resend_id) || ', ' ||
    quote_nullable(error) || ', ' ||
    quote_nullable(created_at::text) || '::timestamptz, ' ||
    quote_nullable(sender) || ', ' ||
    quote_nullable(html_body) || ', ' ||
    quote_literal(COALESCE(attachments::text, '[]')) || '::jsonb' ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;' as sql_export
FROM email_history;
*/

-- ====================================================================
-- 5. EXPORT ADMIN_USERS
-- ====================================================================
/*
SELECT 
  'INSERT INTO admin_users (id, name, username, password_hash, role, status, permissions, email_permissions, created_at, updated_at, last_login, title, phone_ext, email, signature, forward_enabled, forward_to_email) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || ', ' ||
    quote_nullable(name) || ', ' ||
    quote_nullable(username) || ', ' ||
    quote_nullable(password_hash) || ', ' ||
    quote_nullable(role) || ', ' ||
    quote_nullable(status) || ', ' ||
    quote_literal(COALESCE(permissions::text, '{}')) || '::jsonb, ' ||
    'ARRAY[' || COALESCE((SELECT STRING_AGG(quote_literal(e), ',') FROM unnest(email_permissions) AS e), '') || ']::text[], ' ||
    quote_nullable(created_at::text) || '::timestamptz, ' ||
    quote_nullable(updated_at::text) || '::timestamptz, ' ||
    quote_nullable(last_login::text) || '::timestamptz, ' ||
    quote_nullable(title) || ', ' ||
    quote_nullable(phone_ext) || ', ' ||
    quote_nullable(email) || ', ' ||
    quote_nullable(signature) || ', ' ||
    COALESCE(forward_enabled::text, 'false') || ', ' ||
    quote_nullable(forward_to_email) ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;' as sql_export
FROM admin_users;
*/

-- ====================================================================
-- 6. EXPORT USER_TASKS
-- ====================================================================
/*
SELECT 
  'INSERT INTO user_tasks (id, title, description, assigned_to, assigned_by, priority, completed, completed_at, due_date, created_at, updated_at, status, user_comment, comment_updated_at, admin_reply, admin_reply_at, archived) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || ', ' ||
    quote_nullable(title) || ', ' ||
    quote_nullable(description) || ', ' ||
    quote_nullable(assigned_to) || ', ' ||
    quote_nullable(assigned_by) || ', ' ||
    quote_nullable(priority) || ', ' ||
    COALESCE(completed::text, 'false') || ', ' ||
    quote_nullable(completed_at::text) || '::timestamptz, ' ||
    quote_nullable(due_date::text) || '::timestamptz, ' ||
    quote_nullable(created_at::text) || '::timestamptz, ' ||
    quote_nullable(updated_at::text) || '::timestamptz, ' ||
    quote_nullable(status) || ', ' ||
    quote_nullable(user_comment) || ', ' ||
    quote_nullable(comment_updated_at::text) || '::timestamptz, ' ||
    quote_nullable(admin_reply) || ', ' ||
    quote_nullable(admin_reply_at::text) || '::timestamptz, ' ||
    COALESCE(archived::text, 'false') ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;' as sql_export
FROM user_tasks;
*/

-- ====================================================================
-- 7. EXPORT TRANSCRIPTS
-- ====================================================================
/*
SELECT 
  'INSERT INTO transcripts (id, verification_code, student_id, student_name, date_of_birth, program, issue_date, transcript_type, status, cumulative_gpa, total_credits, created_at, updated_at, metadata) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || ', ' ||
    quote_nullable(verification_code) || ', ' ||
    quote_nullable(student_id) || ', ' ||
    quote_nullable(student_name) || ', ' ||
    quote_nullable(date_of_birth) || ', ' ||
    quote_nullable(program) || ', ' ||
    quote_nullable(issue_date) || ', ' ||
    quote_nullable(transcript_type) || ', ' ||
    quote_nullable(status) || ', ' ||
    COALESCE(cumulative_gpa::text, '0') || ', ' ||
    COALESCE(total_credits::text, '0') || ', ' ||
    quote_nullable(created_at::text) || '::timestamptz, ' ||
    quote_nullable(updated_at::text) || '::timestamptz, ' ||
    quote_literal(COALESCE(metadata::text, '{}')) || '::jsonb' ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;' as sql_export
FROM transcripts;
*/
