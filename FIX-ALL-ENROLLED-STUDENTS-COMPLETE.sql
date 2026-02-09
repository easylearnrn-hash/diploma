-- =====================================================
-- COMPLETE FIX FOR ALL ENROLLED STUDENTS
-- =====================================================
-- This script fixes EVERYTHING for all enrolled students:
-- 1. Campus email format (a.lastname@acnhs.am)
-- 2. Username synced to campus email
-- 3. Password set to Welcome2026! (hash: a5ebdb42...)
-- 4. Institutional email fields
-- 5. Payload data
-- =====================================================

-- The correct password hash for "Welcome2026!"
-- Verified: echo -n 'Welcome2026!' | shasum -a 256
-- Result: a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213

-- Step 1: Show what will be fixed
SELECT 
  s.student_id,
  s.full_name,
  s.email AS current_campus_email,
  a.username AS current_username,
  a.password_hash AS current_password_hash,
  CASE 
    WHEN a.password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213' THEN '✅ CORRECT'
    ELSE '❌ WRONG PASSWORD'
  END AS password_status,
  CASE 
    WHEN s.email LIKE '%@acnhs.am' AND a.username = s.email THEN '✅ SYNCED'
    ELSE '❌ NOT SYNCED'
  END AS sync_status
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.status = 'ENROLLED'
ORDER BY s.full_name;

-- Step 2: Fix campus emails (use function from previous script)
-- First create the function if it doesn't exist
CREATE OR REPLACE FUNCTION generate_campus_email(full_name TEXT)
RETURNS TEXT AS $$
DECLARE
  first_initial TEXT;
  last_clean TEXT;
  name_parts TEXT[];
BEGIN
  IF full_name IS NOT NULL AND full_name != '' THEN
    name_parts := REGEXP_SPLIT_TO_ARRAY(TRIM(full_name), '\s+');
    
    IF ARRAY_LENGTH(name_parts, 1) >= 2 THEN
      first_initial := LOWER(SUBSTRING(REGEXP_REPLACE(name_parts[1], '[^a-zA-Z]', '', 'g'), 1, 1));
      last_clean := LOWER(REGEXP_REPLACE(name_parts[ARRAY_LENGTH(name_parts, 1)], '[^a-zA-Z]', '', 'g'));
      
      IF first_initial != '' AND last_clean != '' THEN
        RETURN first_initial || '.' || last_clean || '@acnhs.am';
      END IF;
    END IF;
  END IF;
  
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Update students table with correct campus emails
UPDATE students s
SET email = generate_campus_email(s.full_name)
FROM applications a
WHERE s.application_id = a.id
  AND a.status = 'ENROLLED'
  AND generate_campus_email(s.full_name) IS NOT NULL
  AND (
    s.email NOT LIKE '%@acnhs.am' 
    OR s.email = a.email
    OR s.email != generate_campus_email(s.full_name)
  );

-- Step 4: Update applications table - username, password, and institutional email
UPDATE applications a
SET 
  username = s.email,
  password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213',
  plain_password = 'Welcome2026!',
  institutional_email = s.email,
  payload = jsonb_set(
    jsonb_set(
      jsonb_set(
        COALESCE(a.payload, '{}'::jsonb),
        '{studentPortal,username}',
        to_jsonb(s.email::text),
        true
      ),
      '{studentPortal,institutionalEmail}',
      to_jsonb(s.email::text),
      true
    ),
    '{studentPortal,password}',
    to_jsonb('Welcome2026!'::text),
    true
  )
FROM students s
WHERE a.id = s.application_id
  AND a.status = 'ENROLLED'
  AND s.email LIKE '%@acnhs.am';

-- Step 5: Verify EVERYTHING is now correct
SELECT 
  s.student_id,
  s.full_name,
  s.email AS campus_email,
  a.username AS application_username,
  a.password_hash,
  a.plain_password,
  a.institutional_email,
  a.email AS personal_email,
  CASE 
    WHEN s.email LIKE '%@acnhs.am' 
     AND a.username = s.email
     AND a.institutional_email = s.email
     AND a.password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213'
     AND a.plain_password = 'Welcome2026!'
     AND s.email != a.email
    THEN '✅ PERFECT - CAN LOGIN'
    WHEN a.password_hash != 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213' 
    THEN '❌ WRONG PASSWORD HASH'
    WHEN a.username != s.email THEN '❌ USERNAME MISMATCH'
    WHEN s.email NOT LIKE '%@acnhs.am' THEN '❌ NOT CAMPUS EMAIL'
    WHEN s.email = a.email THEN '❌ SAME AS PERSONAL'
    ELSE '⚠️ CHECK MANUALLY'
  END AS final_status
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.status = 'ENROLLED'
ORDER BY final_status DESC, s.full_name;

-- Step 6: Summary count
SELECT 
  COUNT(*) AS total_enrolled,
  SUM(CASE 
    WHEN s.email LIKE '%@acnhs.am' 
     AND a.username = s.email 
     AND a.password_hash = 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213'
    THEN 1 ELSE 0 
  END) AS ready_to_login,
  SUM(CASE 
    WHEN s.email NOT LIKE '%@acnhs.am' 
     OR a.username != s.email 
     OR a.password_hash != 'a5ebdb42521ba5a49a0021b4d3173f061c19a9efc484f4e81eb15db85c970213'
    THEN 1 ELSE 0 
  END) AS still_broken
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.status = 'ENROLLED';

-- If ready_to_login = total_enrolled, then ALL students can now login!
