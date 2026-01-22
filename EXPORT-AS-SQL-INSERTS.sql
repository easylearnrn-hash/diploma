-- ====================================================================
-- EXPORT DATA AS SQL INSERT STATEMENTS
-- Run this in OLD Supabase to generate INSERT statements
-- Copy the results and run in NEW Supabase
-- ====================================================================

-- EXPORT APPLICATIONS AS INSERT STATEMENTS
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
  ) || ' ON CONFLICT (id) DO NOTHING;' as insert_statement
FROM applications;
