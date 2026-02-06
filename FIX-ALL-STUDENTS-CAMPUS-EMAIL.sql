-- ============================================================================
-- FIX ALL STUDENTS CAMPUS EMAIL - BULK UPDATE
-- ============================================================================
-- Problem: Personal emails showing as Campus Email for multiple students
-- Solution: Generate proper campus emails (firstInitial.lastName@acnhs.am)
--           Move personal emails to metadata.personal_email
-- 
-- 🔗 Run in NEW Supabase SQL Editor:
-- https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql
-- ============================================================================

-- ============================================================================
-- STEP 1: Preview students that need fixing
-- ============================================================================
SELECT 
  student_id,
  full_name,
  email,
  status,
  CASE 
    WHEN email NOT LIKE '%@acnhs.am' THEN '❌ Personal Email'
    ELSE '✅ Campus Email'
  END as email_status
FROM students
WHERE status IN ('enrolled', 'active')
ORDER BY full_name;

-- ============================================================================
-- STEP 2: Create a function to generate campus email from name
-- ============================================================================
CREATE OR REPLACE FUNCTION generate_campus_email(full_name TEXT)
RETURNS TEXT AS $$
DECLARE
  name_parts TEXT[];
  first_initial TEXT;
  last_name TEXT;
  cleaned_name TEXT;
BEGIN
  -- Normalize whitespace and validate input
  cleaned_name := REGEXP_REPLACE(TRIM(full_name), '\s+', ' ', 'g');
  IF cleaned_name IS NULL OR cleaned_name = '' THEN
    RETURN NULL;
  END IF;

  -- Split name into parts (guards against single-name entries)
  name_parts := string_to_array(cleaned_name, ' ');
  IF array_length(name_parts, 1) IS NULL THEN
    RETURN NULL;
  END IF;
  
  -- Get first initial (lowercase, remove non-letters)
  first_initial := SUBSTRING(REGEXP_REPLACE(name_parts[1], '[^a-zA-Z]', '', 'g'), 1, 1);
  -- Get last name (lowercase, remove non-letters)
  last_name := REGEXP_REPLACE(name_parts[array_length(name_parts, 1)], '[^a-zA-Z]', '', 'g');

  -- Ensure we have valid components
  IF first_initial IS NULL OR first_initial = '' OR last_name IS NULL OR last_name = '' THEN
    RETURN NULL;
  END IF;

  -- Return formatted email
  RETURN LOWER(first_initial) || '.' || LOWER(last_name) || '@acnhs.am';
END;
$$ LANGUAGE plpgsql;

-- Test the function
SELECT 
  full_name,
  email as current_email,
  generate_campus_email(full_name) as new_campus_email
FROM students
WHERE status IN ('enrolled', 'active')
  AND email NOT LIKE '%@acnhs.am'
ORDER BY full_name;

-- =========================================================================
-- STEP 3: Update STUDENTS table - Fix all enrolled/active students
--         Uses CTE to preserve original personal emails before updating
-- =========================================================================
WITH target_students AS (
  SELECT 
    id,
    full_name,
    email AS personal_email,
    metadata,
    generate_campus_email(full_name) AS new_campus_email
  FROM students
  WHERE status IN ('enrolled', 'active')
    AND email NOT LIKE '%@acnhs.am'
)
UPDATE students s
SET 
  email = t.new_campus_email,
  metadata = jsonb_set(
    jsonb_set(
      jsonb_set(
        COALESCE(t.metadata, '{}'::jsonb),
        '{personal_email}',
        to_jsonb(t.personal_email)
      ),
      '{portal,institutional_email}',
      to_jsonb(t.new_campus_email)
    ),
    '{institutional_email}',
    to_jsonb(t.new_campus_email)
  )
FROM target_students t
WHERE s.id = t.id
  AND t.new_campus_email IS NOT NULL;

-- =========================================================================
-- STEP 4: Update APPLICATIONS table - Fix corresponding applications
--         Preserves personal email before updating institutional value
-- =========================================================================
WITH target_applications AS (
  SELECT 
    a.id,
    a.payload,
    a.email AS personal_email,
    generate_campus_email(a.applicant_name) AS new_campus_email
  FROM applications a
  JOIN students s ON s.application_id = a.id
  WHERE s.status IN ('enrolled', 'active')
    AND a.email NOT LIKE '%@acnhs.am'
)
UPDATE applications a
SET 
  email = t.new_campus_email,
  payload = jsonb_set(
    jsonb_set(
      COALESCE(t.payload, '{}'::jsonb),
      '{institutionalEmail}',
      to_jsonb(t.new_campus_email)
    ),
    '{personalEmail}',
    to_jsonb(t.personal_email)
  )
FROM target_applications t
WHERE a.id = t.id
  AND t.new_campus_email IS NOT NULL;

-- ============================================================================
-- STEP 5: Verify the fix - Check all enrolled students
-- ============================================================================
SELECT 
  s.student_id,
  s.full_name,
  s.email as campus_email,
  s.metadata->>'personal_email' as personal_email,
  s.status,
  CASE 
    WHEN s.email LIKE '%@acnhs.am' THEN '✅ Fixed'
    ELSE '❌ Still needs fix'
  END as email_status
FROM students s
WHERE s.status IN ('enrolled', 'active')
ORDER BY s.full_name;

-- ============================================================================
-- STEP 6: Cross-check students and applications tables
-- ============================================================================
SELECT 
  s.student_id,
  s.full_name,
  s.email as student_campus_email,
  a.email as application_campus_email,
  s.metadata->>'personal_email' as student_personal_email,
  a.payload->>'personalEmail' as application_personal_email,
  CASE 
    WHEN s.email = a.email AND s.email LIKE '%@acnhs.am' THEN '✅ SYNCED'
    WHEN s.email LIKE '%@acnhs.am' AND a.email NOT LIKE '%@acnhs.am' THEN '⚠️ App needs update'
    WHEN s.email NOT LIKE '%@acnhs.am' THEN '❌ Student needs update'
    ELSE '❓ Check manually'
  END as sync_status
FROM students s
LEFT JOIN applications a ON a.id = s.application_id
WHERE s.status IN ('enrolled', 'active')
ORDER BY sync_status DESC, s.full_name;

-- ============================================================================
-- STEP 7: Count summary
-- ============================================================================
SELECT 
  COUNT(*) as total_enrolled_students,
  COUNT(*) FILTER (WHERE email LIKE '%@acnhs.am') as with_campus_email,
  COUNT(*) FILTER (WHERE email NOT LIKE '%@acnhs.am') as with_personal_email
FROM students
WHERE status IN ('enrolled', 'active');

-- ============================================================================
-- CLEANUP: Drop the helper function (optional)
-- ============================================================================
-- Uncomment the line below if you want to remove the function after use
-- DROP FUNCTION IF EXISTS generate_campus_email(TEXT);
