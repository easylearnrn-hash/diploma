-- =====================================================
-- FIX ALVARD GHUKASYAN - WRONG CAMPUS EMAIL
-- =====================================================
-- Problem: Campus email is set to personal email (alvard85@yahoo.com)
-- Solution: Change to proper campus email (a.ghukasyan@acnhs.am)
-- Student ID: ACNHS-3394133
-- =====================================================

-- Step 1: Show current state
SELECT 
  s.id,
  s.student_id,
  s.full_name,
  s.first_name,
  s.last_name,
  s.email AS current_campus_email,
  a.email AS personal_email,
  a.username AS application_username
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE s.student_id = 'ACNHS-3394133';

-- Step 2: Generate correct campus email
-- Format: first initial + . + last name + @acnhs.am
-- Alvard Ghukasyan → a.ghukasyan@acnhs.am

-- Update students table with correct campus email
UPDATE students
SET email = 'a.ghukasyan@acnhs.am'
WHERE student_id = 'ACNHS-3394133';

-- Step 3: Update applications table to match
UPDATE applications a
SET 
  username = 'a.ghukasyan@acnhs.am',
  institutional_email = 'a.ghukasyan@acnhs.am',
  payload = jsonb_set(
    COALESCE(a.payload, '{}'::jsonb),
    '{studentPortal,username}',
    to_jsonb('a.ghukasyan@acnhs.am'),
    true
  ),
  payload = jsonb_set(
    payload,
    '{studentPortal,institutionalEmail}',
    to_jsonb('a.ghukasyan@acnhs.am'),
    true
  )
FROM students s
WHERE a.id = s.application_id
  AND s.student_id = 'ACNHS-3394133';

-- Step 4: Verify the fix
SELECT 
  s.student_id,
  s.full_name,
  s.email AS campus_email,
  a.username AS application_username,
  a.institutional_email,
  a.email AS personal_email,
  CASE 
    WHEN s.email = 'a.ghukasyan@acnhs.am' 
     AND a.username = 'a.ghukasyan@acnhs.am'
     AND a.institutional_email = 'a.ghukasyan@acnhs.am'
    THEN '✅ ALL FIXED'
    ELSE '❌ STILL WRONG'
  END AS status
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE s.student_id = 'ACNHS-3394133';

-- Step 5: Check for any other students with wrong campus emails
-- (personal emails instead of @acnhs.am format)
SELECT 
  s.student_id,
  s.full_name,
  s.first_name,
  s.last_name,
  s.email AS current_campus_email,
  a.email AS personal_email,
  CASE 
    WHEN s.email NOT LIKE '%@acnhs.am' THEN '⚠️ NOT CAMPUS EMAIL'
    WHEN s.email = a.email THEN '⚠️ SAME AS PERSONAL EMAIL'
    ELSE '✅ LOOKS GOOD'
  END AS email_status
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.status = 'ENROLLED'
  AND (s.email NOT LIKE '%@acnhs.am' OR s.email = a.email)
ORDER BY s.full_name;
