-- Manual Student Provisioning for Hrach Vardan
-- This script creates the missing acnhs_students record that should have been auto-created
-- when the application status was changed to ENROLLED

-- Step 1: Verify the application exists and get its ID
DO $$
DECLARE
  v_app_id UUID;
  v_student_id TEXT;
  v_full_name TEXT;
  v_email TEXT;
  v_phone TEXT;
  v_username TEXT;
  v_password_hash TEXT;
  v_payload JSONB;
BEGIN
  -- Find the application
  SELECT id, applicant_name, email, phone, username, password_hash, payload
  INTO v_app_id, v_full_name, v_email, v_phone, v_username, v_password_hash, v_payload
  FROM applications
  WHERE username = 'hrach.vardan.5789'
  LIMIT 1;

  IF v_app_id IS NULL THEN
    RAISE EXCEPTION 'Application not found for username hrach.vardan.5789';
  END IF;

  RAISE NOTICE 'Found application ID: %', v_app_id;
  RAISE NOTICE 'Full name: %', v_full_name;
  RAISE NOTICE 'Email: %', v_email;

  -- Step 2: Check if student record already exists
  IF EXISTS (SELECT 1 FROM acnhs_students WHERE application_id = v_app_id) THEN
    RAISE NOTICE 'Student record already exists for this application';
    RETURN;
  END IF;

  -- Step 3: Generate student ID (format: ACNHS-YYYYMMDD-XXXX)
  -- Using timestamp + random for uniqueness
  v_student_id := 'ACNHS-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');

  -- Ensure uniqueness
  WHILE EXISTS (SELECT 1 FROM acnhs_students WHERE student_id = v_student_id) LOOP
    v_student_id := 'ACNHS-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
  END LOOP;

  RAISE NOTICE 'Generated student ID: %', v_student_id;

  -- Step 4: Insert student record
  INSERT INTO acnhs_students (
    application_id,
    student_id,
    full_name,
    email,
    phone,
    enrollment_status,
    date_of_birth,
    gender,
    nationality,
    program,
    start_term,
    emergency_contact_name,
    emergency_contact_relation,
    emergency_contact_phone,
    metadata,
    created_at,
    updated_at
  ) VALUES (
    v_app_id,
    v_student_id,
    v_full_name,
    'h.vardan@acnhs.am',  -- Institutional email
    v_phone,
    'active',
    (v_payload->>'dob')::DATE,  -- Extract from payload if exists
    v_payload->>'gender',
    v_payload->>'nationality',
    v_payload->>'programChoice',
    v_payload->>'startTerm',
    v_payload->>'emergencyName',
    v_payload->>'emergencyRelation',
    v_payload->>'emergencyPhone',
    jsonb_build_object(
      'personal_email', v_email,
      'portal', jsonb_build_object(
        'institutional_email', 'h.vardan@acnhs.am',
        'username', v_username,
        'provisioned_at', NOW()::TEXT
      ),
      'credentials', jsonb_build_object(
        'username', v_username,
        'password_hash', v_password_hash
      )
    ),
    NOW(),
    NOW()
  );

  RAISE NOTICE 'Successfully created student record with ID: %', v_student_id;

  -- Step 5: Update application payload with student info
  UPDATE applications
  SET payload = COALESCE(payload, '{}'::JSONB) || jsonb_build_object(
    'studentId', v_student_id,
    'studentRecordId', (SELECT id FROM acnhs_students WHERE student_id = v_student_id),
    'institutionalEmail', 'h.vardan@acnhs.am',
    'studentPortal', jsonb_build_object(
      'institutionalEmail', 'h.vardan@acnhs.am',
      'provisionedAt', NOW()::TEXT,
      'studentId', v_student_id
    ),
    'enrollmentProvisionedAt', NOW()::TEXT
  ),
  updated_at = NOW()
  WHERE id = v_app_id;

  RAISE NOTICE 'Updated application payload with student information';

END $$;

-- Step 6: Verify the creation
SELECT 
  s.id,
  s.student_id,
  s.full_name,
  s.email AS institutional_email,
  s.enrollment_status,
  s.metadata->'portal'->>'username' AS portal_username,
  s.created_at
FROM acnhs_students s
JOIN applications a ON s.application_id = a.id
WHERE a.username = 'hrach.vardan.5789';
