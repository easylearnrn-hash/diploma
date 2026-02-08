-- =====================================================
-- BULK FIX ALL ENROLLED STUDENTS WITH WRONG EMAILS
-- =====================================================
-- This is a ONE-TIME fix for all students whose campus
-- emails were set incorrectly (personal email format)
-- Generates proper a.lastname@acnhs.am format
-- =====================================================

-- Function to generate campus email from name
CREATE OR REPLACE FUNCTION generate_campus_email(full_name TEXT)
RETURNS TEXT AS $$
DECLARE
  first_initial TEXT;
  last_clean TEXT;
  name_parts TEXT[];
BEGIN
  -- Parse full_name
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
  
  -- No valid name found
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Step 1: Preview what will be changed
SELECT 
  s.student_id,
  s.full_name,
  s.email AS current_campus_email,
  generate_campus_email(s.full_name) AS new_campus_email,
  a.email AS personal_email,
  a.username AS current_username,
  CASE 
    WHEN s.email NOT LIKE '%@acnhs.am' THEN '⚠️ NOT CAMPUS FORMAT'
    WHEN s.email = a.email THEN '⚠️ SAME AS PERSONAL'
    WHEN s.email != generate_campus_email(s.full_name) THEN '⚠️ WRONG CAMPUS EMAIL'
    ELSE '✅ CORRECT'
  END AS status
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.status = 'ENROLLED'
  AND (
    s.email NOT LIKE '%@acnhs.am' 
    OR s.email = a.email
    OR s.email != generate_campus_email(s.full_name)
  )
ORDER BY s.full_name;

-- Step 2: Fix students table - update campus emails
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

-- Step 3: Fix applications table - sync username and institutional_email
UPDATE applications a
SET 
  username = s.email,
  institutional_email = s.email,
  payload = jsonb_set(
    jsonb_set(
      COALESCE(a.payload, '{}'::jsonb),
      '{studentPortal,username}',
      to_jsonb(s.email),
      true
    ),
    '{studentPortal,institutionalEmail}',
    to_jsonb(s.email),
    true
  )
FROM students s
WHERE a.id = s.application_id
  AND a.status = 'ENROLLED'
  AND s.email LIKE '%@acnhs.am'
  AND (a.username IS NULL OR a.username != s.email);

-- Step 4: Verify ALL enrolled students now have correct emails
SELECT 
  s.student_id,
  s.full_name,
  s.email AS campus_email,
  a.username AS application_username,
  a.institutional_email,
  a.email AS personal_email,
  CASE 
    WHEN s.email LIKE '%@acnhs.am' 
     AND a.username = s.email
     AND a.institutional_email = s.email
     AND s.email != a.email
    THEN '✅ PERFECT'
    WHEN s.email NOT LIKE '%@acnhs.am' THEN '❌ NOT CAMPUS EMAIL'
    WHEN a.username != s.email THEN '❌ USERNAME MISMATCH'
    WHEN s.email = a.email THEN '❌ SAME AS PERSONAL'
    ELSE '⚠️ CHECK MANUALLY'
  END AS validation_status
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.status = 'ENROLLED'
ORDER BY validation_status DESC, s.full_name;

-- Step 5: Summary count
SELECT 
  COUNT(*) AS total_enrolled,
  SUM(CASE WHEN s.email LIKE '%@acnhs.am' AND a.username = s.email THEN 1 ELSE 0 END) AS correct_count,
  SUM(CASE WHEN s.email NOT LIKE '%@acnhs.am' OR a.username != s.email THEN 1 ELSE 0 END) AS issue_count
FROM students s
JOIN applications a ON s.application_id = a.id
WHERE a.status = 'ENROLLED';

-- Clean up the function (optional - remove after running)
-- DROP FUNCTION IF EXISTS generate_campus_email(TEXT);
