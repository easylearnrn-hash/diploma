-- ========================================
-- REMOVE ALL TEST STUDENT DATA
-- ========================================
-- Run this in Supabase SQL Editor to clean up test data
-- ⚠️ WARNING: This will delete test student records!
-- ========================================

-- First, let's see what test data exists
-- Uncomment these to check before deleting:
/*
SELECT student_id, full_name, email, created_at 
FROM acnhs_students 
WHERE full_name ILIKE '%hrach%' 
   OR full_name ILIKE '%vardan%'
   OR email ILIKE '%test%'
   OR email ILIKE '%hrach%'
   OR email ILIKE '%vardan%'
ORDER BY created_at DESC;
*/

-- Delete test students from acnhs_students table
-- This includes Hrach Vardan and any other test entries
DELETE FROM acnhs_students 
WHERE full_name ILIKE '%hrach%' 
   OR full_name ILIKE '%vardan%'
   OR email ILIKE '%test%'
   OR email ILIKE '%hrach.vardan%'
   OR student_id LIKE 'ACNHS-test%';

-- Delete corresponding applications if they exist
-- (This assumes test students were created from test applications)
DELETE FROM applications 
WHERE applicant_name ILIKE '%hrach%' 
   OR applicant_name ILIKE '%vardan%'
   OR email ILIKE '%test%'
   OR email ILIKE '%hrach.vardan%'
   OR email ILIKE '%hrach%';

-- Delete test registrations (waiting list entries)
DELETE FROM registrations 
WHERE full_name ILIKE '%hrach%' 
   OR full_name ILIKE '%vardan%'
   OR email ILIKE '%test%'
   OR email ILIKE '%hrach%';

-- Clean up any orphaned transcripts for test students
DELETE FROM transcripts 
WHERE student_name ILIKE '%hrach%' 
   OR student_name ILIKE '%vardan%'
   OR student_name ILIKE '%test%';

-- Clean up test email forwarding rules
DELETE FROM email_forwarding_rules 
WHERE acnhs_email ILIKE '%test%'
   OR acnhs_email ILIKE '%hrach.vardan%';

-- Clean up test SMS verifications
DELETE FROM sms_verifications 
WHERE phone_number LIKE '%test%';

-- Verify deletion - this should return 0 rows
SELECT COUNT(*) as remaining_test_students
FROM acnhs_students 
WHERE full_name ILIKE '%hrach%' 
   OR full_name ILIKE '%vardan%'
   OR email ILIKE '%test%';

-- Show remaining students (should be production data only)
SELECT student_id, full_name, email, enrollment_status, created_at 
FROM acnhs_students 
ORDER BY created_at DESC 
LIMIT 10;
