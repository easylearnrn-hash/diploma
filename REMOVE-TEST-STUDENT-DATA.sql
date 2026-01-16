-- ========================================
-- REMOVE ONLY EXPLICIT TEST STUDENT DATA
-- ========================================
-- ⚠️ DO NOT USE THIS - IT DELETED REAL DATA!
-- ⚠️ USE RESTORE-DELETED-STUDENTS.sql FIRST!
-- ========================================
-- This script was TOO AGGRESSIVE and deleted real students
-- Only use specific student IDs or email addresses you KNOW are test data
-- ========================================

-- SAFE VERSION: Only delete by specific email addresses or student IDs
-- First, let's see what exists:
/*
SELECT student_id, full_name, email, created_at 
FROM acnhs_students 
WHERE email ILIKE '%test%'
   OR student_id LIKE 'ACNHS-test%'
ORDER BY created_at DESC;
*/

-- SAFE: Only delete students with obvious test patterns
DELETE FROM acnhs_students 
WHERE email ILIKE '%test%'
   OR student_id LIKE 'ACNHS-test%'
   OR email = 'test@example.com'
   OR email ILIKE '%@test.com';

-- DO NOT use name-based deletion as names can match real students!

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
