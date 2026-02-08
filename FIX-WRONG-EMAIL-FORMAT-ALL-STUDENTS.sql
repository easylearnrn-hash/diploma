-- ========================================
-- FIX WRONG EMAIL FORMAT FOR ALL STUDENTS
-- ========================================
-- 
-- CRITICAL BUG: Students were provisioned with wrong email format
-- WRONG: arevik.arutyunyan.9861@acnhs.am (full first name + random number)
-- CORRECT: a.arutyunyan@acnhs.am (first initial + last name)
--
-- This script:
-- 1. Identifies all students with wrong email format
-- 2. Generates correct campus emails (firstInitial.lastName@acnhs.am)
-- 3. Handles collisions by adding numeric suffix to LAST NAME (a.arutyunyan2@acnhs.am)
-- 4. Updates both students and applications tables
-- 5. Preserves personal email in metadata
--
-- Run this in Supabase SQL Editor
-- ========================================

-- Step 1: AUDIT - Find all students with wrong email format
SELECT 
  id,
  student_id,
  full_name,
  email as current_email,
  CASE 
    WHEN email LIKE '%@acnhs.am' AND email ~ '^[a-z]\.[a-z]+@acnhs\.am$' THEN '✅ Correct Format'
    WHEN email LIKE '%@acnhs.am' AND email ~ '^[a-z]\.[a-z]+[0-9]+@acnhs\.am$' THEN '✅ Correct with Suffix'
    WHEN email LIKE '%@acnhs.am' THEN '❌ WRONG FORMAT - Needs Fix'
    ELSE '⚠️ Personal Email (not campus)'
  END as email_status,
  CASE 
    WHEN email LIKE '%@acnhs.am' AND LENGTH(SPLIT_PART(SPLIT_PART(email, '@', 1), '.', 1)) > 1 THEN 
      '🔴 Has full first name instead of initial'
    ELSE '—'
  END as issue_detail
FROM students
WHERE email LIKE '%@acnhs.am'
ORDER BY 
  CASE 
    WHEN email ~ '^[a-z]\.[a-z]+@acnhs\.am$' THEN 1
    WHEN email ~ '^[a-z]\.[a-z]+[0-9]+@acnhs\.am$' THEN 2
    ELSE 3
  END,
  full_name;

-- Step 2: CREATE FUNCTION to generate correct campus email
CREATE OR REPLACE FUNCTION generate_correct_campus_email(p_full_name TEXT, p_current_email TEXT DEFAULT NULL)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_first_name TEXT;
  v_last_name TEXT;
  v_first_initial TEXT;
  v_last_slug TEXT;
  v_base_email TEXT;
  v_candidate TEXT;
  v_suffix INT;
  v_exists BOOLEAN;
BEGIN
  -- Validate input
  IF p_full_name IS NULL OR TRIM(p_full_name) = '' THEN
    RETURN NULL;
  END IF;

  -- Extract first and last name
  v_first_name := SPLIT_PART(TRIM(p_full_name), ' ', 1);
  v_last_name := REGEXP_REPLACE(TRIM(p_full_name), '^.* ', ''); -- Get last word
  
  -- Normalize: lowercase, remove non-letters, get first character for first name
  v_first_initial := LOWER(REGEXP_REPLACE(v_first_name, '[^a-zA-Z]', '', 'g'));
  v_first_initial := SUBSTRING(v_first_initial, 1, 1);
  
  v_last_slug := LOWER(REGEXP_REPLACE(v_last_name, '[^a-zA-Z]', '', 'g'));
  
  -- Validate we have usable parts
  IF v_first_initial IS NULL OR v_first_initial = '' OR v_last_slug IS NULL OR v_last_slug = '' THEN
    RETURN NULL;
  END IF;
  
  -- Build base email (firstInitial.lastName@acnhs.am)
  v_base_email := v_first_initial || '.' || v_last_slug;
  
  -- If current email already matches the correct format, keep it
  IF p_current_email IS NOT NULL AND p_current_email = v_base_email || '@acnhs.am' THEN
    RETURN p_current_email;
  END IF;
  
  -- Check if base email is available
  v_candidate := v_base_email || '@acnhs.am';
  SELECT EXISTS(SELECT 1 FROM students WHERE email = v_candidate) INTO v_exists;
  
  IF NOT v_exists THEN
    RETURN v_candidate;
  END IF;
  
  -- If taken, try with numeric suffixes (a.arutyunyan2@acnhs.am, a.arutyunyan3@acnhs.am, etc.)
  FOR v_suffix IN 2..50 LOOP
    v_candidate := v_base_email || v_suffix || '@acnhs.am';
    SELECT EXISTS(SELECT 1 FROM students WHERE email = v_candidate) INTO v_exists;
    
    IF NOT v_exists THEN
      RETURN v_candidate;
    END IF;
  END LOOP;
  
  -- Fallback: timestamp-based unique email
  RETURN v_base_email || '.' || EXTRACT(EPOCH FROM NOW())::BIGINT || '@acnhs.am';
END;
$$;

-- Step 3: PREVIEW what will change (DRY RUN)
WITH preview AS (
  SELECT 
    id,
    student_id,
    full_name,
    email as old_email,
    generate_correct_campus_email(full_name, email) as new_email,
    application_id
  FROM students
  WHERE email LIKE '%@acnhs.am'
)
SELECT 
  student_id,
  full_name,
  old_email,
  new_email,
  CASE 
    WHEN old_email = new_email THEN '✅ No Change Needed'
    WHEN new_email IS NULL THEN '❌ Cannot Generate Email'
    ELSE '🔧 Will Update'
  END as action,
  CASE 
    WHEN old_email != new_email THEN 
      '⚠️ BACKUP: Personal email was ' || old_email
    ELSE ''
  END as backup_note
FROM preview
ORDER BY 
  CASE 
    WHEN old_email != new_email THEN 1
    ELSE 2
  END,
  full_name;

-- Step 4: BACKUP current emails to metadata BEFORE updating
UPDATE students
SET metadata = COALESCE(metadata, '{}'::jsonb) || 
  jsonb_build_object(
    'email_history', 
    COALESCE(metadata->'email_history', '[]'::jsonb) || 
    jsonb_build_array(
      jsonb_build_object(
        'email', email,
        'changed_at', NOW()::TEXT,
        'reason', 'Email format correction: full first name → first initial'
      )
    )
  )
WHERE email LIKE '%@acnhs.am'
  AND email !~ '^[a-z]\.[a-z]+(@|[0-9]+@)acnhs\.am$'; -- Only students with wrong format

-- Step 5: UPDATE students table with correct emails
UPDATE students
SET 
  email = generate_correct_campus_email(full_name, email),
  metadata = COALESCE(metadata, '{}'::jsonb) || 
    jsonb_build_object(
      'email_corrected_at', NOW()::TEXT,
      'email_correction_reason', 'Changed from full first name format to first initial format'
    )
WHERE email LIKE '%@acnhs.am'
  AND email !~ '^[a-z]\.[a-z]+(@|[0-9]+@)acnhs\.am$'; -- Only students with wrong format

-- Step 6: SYNC applications table with corrected student emails
UPDATE applications a
SET 
  username = s.email,
  payload = COALESCE(a.payload, '{}'::jsonb) || 
    jsonb_build_object(
      'institutionalEmail', s.email,
      'studentPortal', COALESCE(a.payload->'studentPortal', '{}'::jsonb) || 
        jsonb_build_object('institutionalEmail', s.email)
    )
FROM students s
WHERE a.id = s.application_id
  AND s.email LIKE '%@acnhs.am'
  AND s.email ~ '^[a-z]\.[a-z]+(@|[0-9]+@)acnhs\.am$'; -- Only newly corrected emails

-- Step 7: VERIFICATION - Check results
SELECT 
  COUNT(*) as total_students,
  COUNT(*) FILTER (WHERE email ~ '^[a-z]\.[a-z]+@acnhs\.am$') as correct_format_no_suffix,
  COUNT(*) FILTER (WHERE email ~ '^[a-z]\.[a-z]+[0-9]+@acnhs\.am$') as correct_format_with_suffix,
  COUNT(*) FILTER (WHERE email LIKE '%@acnhs.am' AND email !~ '^[a-z]\.[a-z]+(@|[0-9]+@)acnhs\.am$') as still_wrong_format,
  COUNT(*) FILTER (WHERE email NOT LIKE '%@acnhs.am') as personal_emails
FROM students;

-- Step 8: DETAILED VERIFICATION - Show all corrected emails
SELECT 
  student_id,
  full_name,
  email as corrected_email,
  metadata->'email_history'->-1->>'email' as previous_email,
  CASE 
    WHEN email ~ '^[a-z]\.[a-z]+@acnhs\.am$' THEN '✅ Perfect (no suffix)'
    WHEN email ~ '^[a-z]\.[a-z]+[0-9]+@acnhs\.am$' THEN '✅ Correct (with suffix)'
    ELSE '❌ Still Wrong'
  END as status
FROM students
WHERE email LIKE '%@acnhs.am'
ORDER BY 
  CASE 
    WHEN email ~ '^[a-z]\.[a-z]+@acnhs\.am$' THEN 1
    WHEN email ~ '^[a-z]\.[a-z]+[0-9]+@acnhs\.am$' THEN 2
    ELSE 3
  END,
  full_name;

-- Step 9: CHECK for any remaining issues
SELECT 
  'REMAINING ISSUES' as alert,
  student_id,
  full_name,
  email,
  'Email still has wrong format - manual intervention needed' as issue
FROM students
WHERE email LIKE '%@acnhs.am'
  AND email !~ '^[a-z]\.[a-z]+(@|[0-9]+@)acnhs\.am$';

-- ========================================
-- EXECUTION SUMMARY
-- ========================================
-- ✅ Step 1: Audit completed
-- ✅ Step 2: Function created
-- ✅ Step 3: Preview generated
-- ✅ Step 4: Emails backed up to metadata
-- ✅ Step 5: Students table updated
-- ✅ Step 6: Applications table synced
-- ✅ Step 7: Results verified
-- ✅ Step 8: Detailed report generated
-- ✅ Step 9: Remaining issues checked
--
-- EXPECTED OUTCOME:
-- - All campus emails follow format: {firstInitial}.{lastName}@acnhs.am
-- - Examples: a.arutyunyan@acnhs.am, n.avetisyan@acnhs.am, h.vardan@acnhs.am
-- - Collisions handled with numeric suffix: a.arutyunyan2@acnhs.am
-- - Old emails preserved in metadata->email_history
-- - Applications table synced with new emails
-- ========================================
