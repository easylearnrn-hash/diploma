-- ====================================================================
-- BATCH IMPORT - Import applications in small groups
-- Run each query separately in OLD Supabase to get smaller INSERT statements
-- ====================================================================

-- BATCH 1: First 10 applications
SELECT 
  'INSERT INTO applications (id, reference_number, control_number, document_id, verification_hash, barcode, hash, username, password_hash, applicant_name, email, phone, program, start_term, submission_date, payload, status) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || '::uuid, ' ||
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
    quote_nullable(status) ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;'
FROM applications
LIMIT 10;

-- BATCH 2: Next 10 (run separately after batch 1 succeeds)
/*
SELECT 
  'INSERT INTO applications (id, reference_number, control_number, document_id, verification_hash, barcode, hash, username, password_hash, applicant_name, email, phone, program, start_term, submission_date, payload, status) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || '::uuid, ' ||
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
    quote_nullable(status) ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;'
FROM applications
LIMIT 10 OFFSET 10;
*/

-- BATCH 3: Next 10
/*
SELECT 
  'INSERT INTO applications (id, reference_number, control_number, document_id, verification_hash, barcode, hash, username, password_hash, applicant_name, email, phone, program, start_term, submission_date, payload, status) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || '::uuid, ' ||
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
    quote_nullable(status) ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;'
FROM applications
LIMIT 10 OFFSET 20;
*/

-- BATCH 4: Next 10
/*
SELECT 
  'INSERT INTO applications (id, reference_number, control_number, document_id, verification_hash, barcode, hash, username, password_hash, applicant_name, email, phone, program, start_term, submission_date, payload, status) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || '::uuid, ' ||
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
    quote_nullable(status) ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;'
FROM applications
LIMIT 10 OFFSET 30;
*/

-- BATCH 5: Remaining rows
/*
SELECT 
  'INSERT INTO applications (id, reference_number, control_number, document_id, verification_hash, barcode, hash, username, password_hash, applicant_name, email, phone, program, start_term, submission_date, payload, status) VALUES ' ||
  STRING_AGG(
    '(' || 
    quote_literal(id::text) || '::uuid, ' ||
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
    quote_nullable(status) ||
    ')',
    ', '
  ) || ' ON CONFLICT (id) DO NOTHING;'
FROM applications
OFFSET 40;
*/
