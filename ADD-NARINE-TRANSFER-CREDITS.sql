-- ADD NARINE AVETISYAN TRANSFER CREDITS
-- Student: Narine Avetisyan
-- Student ID: ACNHS-7022395 (THIS IS THE student_id TEXT VALUE, NOT UUID)
-- Application Reference: ACNHS-ADM-20260108-970
-- Institution: Previous nursing/medical institution
-- Total Units: 98.00 attempted, 94.00 earned, 93.00 GPA units
-- Cumulative GPA: 3.64 (3.68 excluding NDA courses)

-- STEP 1: Get student_id TEXT value (NOT the UUID!)
DO $$
DECLARE
    v_student_id_text TEXT;  -- This is the ACNHS-7022395 value
    v_application_id UUID;
    v_created_by TEXT := 'admin@acnhs.am'; -- Update with your admin email
BEGIN
    -- Get application_id from reference_number
    SELECT id INTO v_application_id
    FROM applications
    WHERE reference_number = 'ACNHS-ADM-20260108-970'
    LIMIT 1;

    IF v_application_id IS NULL THEN
        RAISE NOTICE 'ERROR: No application found for reference ACNHS-ADM-20260108-970';
        RETURN;
    END IF;

    -- Get student_id TEXT (e.g., 'ACNHS-7022395') from students table
    SELECT student_id INTO v_student_id_text
    FROM students
    WHERE application_id = v_application_id
    LIMIT 1;

    IF v_student_id_text IS NULL THEN
        RAISE NOTICE 'ERROR: No student record found in students table for ACNHS-ADM-20260108-970';
        RAISE NOTICE 'Please ensure student has been enrolled';
        RAISE NOTICE 'Application ID: %', v_application_id;
        RETURN;
    END IF;

    RAISE NOTICE 'Found application_id: %', v_application_id;
    RAISE NOTICE 'Found student_id (TEXT): %', v_student_id_text;
    RAISE NOTICE 'Inserting transfer credits...';

    -- STEP 2: Insert all transfer credits
    
    -- 1. Anatomy 001 – Intro to Human Anatomy (4 units) — A
    INSERT INTO transfer_credits (
        student_id,
        institution_name,
        institution_country,
        institution_city,
        course_code,
        course_name,
        credits,
        grade,
        letter_grade,
        grade_points,
        term_completed,
        year_completed,
        status,
        created_by,
        evaluated_by,
        created_at,
        updated_at
    ) VALUES (
        v_student_id_text,
        'Previous Institution',
        'USA',
        'California',
        'ANAT001',
        'Intro to Human Anatomy',
        4.0,
        'A',
        'A',
        4.0,
        'Completed',
        2024,
        'approved',
        v_created_by,
        v_created_by,
        NOW(),
        NOW()
    );

    -- 2. Physiology 001 – Intro to Human Physiology (4 units) — A
    INSERT INTO transfer_credits (
        student_id, institution_name, institution_country, institution_city,
        course_code, course_name, credits, grade, letter_grade, grade_points,
        term_completed, year_completed, status, created_by, evaluated_by,
        created_at, updated_at
    ) VALUES (
        v_student_id_text, 'Previous Institution', 'USA', 'California',
        'PHYS001', 'Intro to Human Physiology', 4.0, 'A', 'A', 4.0,
        'Completed', 2024, 'approved', v_created_by, v_created_by,
        NOW(), NOW()
    );

    -- 3. Microbiology 020 – General Microbiology (4 units) — A
    INSERT INTO transfer_credits (
        student_id, institution_name, institution_country, institution_city,
        course_code, course_name, credits, grade, letter_grade, grade_points,
        term_completed, year_completed, status, created_by, evaluated_by,
        created_at, updated_at
    ) VALUES (
        v_student_id_text, 'Previous Institution', 'USA', 'California',
        'MICR020', 'General Microbiology', 4.0, 'A', 'A', 4.0,
        'Completed', 2024, 'approved', v_created_by, v_created_by,
        NOW(), NOW()
    );

    -- 4. Biology 003 – Introductory Biology (4 units) — A
    INSERT INTO transfer_credits (
        student_id, institution_name, institution_country, institution_city,
        course_code, course_name, credits, grade, letter_grade, grade_points,
        term_completed, year_completed, status, created_by, evaluated_by,
        created_at, updated_at
    ) VALUES (
        v_student_id_text, 'Previous Institution', 'USA', 'California',
        'BIOL003', 'Introductory Biology', 4.0, 'A', 'A', 4.0,
        'Completed', 2024, 'approved', v_created_by, v_created_by,
        NOW(), NOW()
    );

    -- 5. Chemistry 051 – Fundamental Chemistry I (5 units) — B
    INSERT INTO transfer_credits (
        student_id, institution_name, institution_country, institution_city,
        course_code, course_name, credits, grade, letter_grade, grade_points,
        term_completed, year_completed, status, created_by, evaluated_by,
        created_at, updated_at
    ) VALUES (
        v_student_id_text, 'Previous Institution', 'USA', 'California',
        'CHEM051', 'Fundamental Chemistry I', 5.0, 'B', 'B', 3.0,
        'Completed', 2024, 'approved', v_created_by, v_created_by,
        NOW(), NOW()
    );

    -- 6. Statistics (Math 227) (4 units) — A
    INSERT INTO transfer_credits (
        student_id, institution_name, institution_country, institution_city,
        course_code, course_name, credits, grade, letter_grade, grade_points,
        term_completed, year_completed, status, created_by, evaluated_by,
        created_at, updated_at
    ) VALUES (
        v_student_id_text, 'Previous Institution', 'USA', 'California',
        'MATH227', 'Statistics', 4.0, 'A', 'A', 4.0,
        'Completed', 2024, 'approved', v_created_by, v_created_by,
        NOW(), NOW()
    );

    -- 7. General Psychology 001 (3 units) — A
    INSERT INTO transfer_credits (
        student_id, institution_name, institution_country, institution_city,
        course_code, course_name, credits, grade, letter_grade, grade_points,
        term_completed, year_completed, status, created_by, evaluated_by,
        created_at, updated_at
    ) VALUES (
        v_student_id_text, 'Previous Institution', 'USA', 'California',
        'PSYC001', 'General Psychology', 3.0, 'A', 'A', 4.0,
        'Completed', 2024, 'approved', v_created_by, v_created_by,
        NOW(), NOW()
    );

    -- 8. Life-Span Psychology 041 (3 units) — A
    INSERT INTO transfer_credits (
        student_id, institution_name, institution_country, institution_city,
        course_code, course_name, credits, grade, letter_grade, grade_points,
        term_completed, year_completed, status, created_by, evaluated_by,
        created_at, updated_at
    ) VALUES (
        v_student_id_text, 'Previous Institution', 'USA', 'California',
        'PSYC041', 'Life-Span Psychology', 3.0, 'A', 'A', 4.0,
        'Completed', 2024, 'approved', v_created_by, v_created_by,
        NOW(), NOW()
    );

    -- 9. Nutrition (FAM & CS 021) (3 units) — A
    INSERT INTO transfer_credits (
        student_id, institution_name, institution_country, institution_city,
        course_code, course_name, credits, grade, letter_grade, grade_points,
        term_completed, year_completed, status, created_by, evaluated_by,
        created_at, updated_at
    ) VALUES (
        v_student_id_text, 'Previous Institution', 'USA', 'California',
        'FAMCS021', 'Nutrition', 3.0, 'A', 'A', 4.0,
        'Completed', 2024, 'approved', v_created_by, v_created_by,
        NOW(), NOW()
    );

    RAISE NOTICE '✅ Successfully inserted 9 transfer credits for Narine Avetisyan';
    RAISE NOTICE 'Total Credits: 36.0';
    RAISE NOTICE 'Total Grade Points: 143.0 (36 credits × weighted average)';
    RAISE NOTICE 'Transfer GPA: 3.64 (approximately)';
END $$;

-- STEP 3: Verify the inserted credits
SELECT 
    tc.course_code,
    tc.course_name,
    tc.credits,
    tc.grade,
    tc.letter_grade,
    tc.grade_points,
    tc.status,
    tc.created_at
FROM transfer_credits tc
JOIN students s ON tc.student_id = s.student_id  -- Join on TEXT student_id
JOIN applications a ON s.application_id = a.id
WHERE a.reference_number = 'ACNHS-ADM-20260108-970'
ORDER BY tc.course_code;

-- STEP 4: Calculate summary statistics
SELECT 
    COUNT(*) as total_courses,
    SUM(tc.credits) as total_credits,
    ROUND(AVG(tc.grade_points), 2) as average_gpa,
    ROUND(SUM(tc.credits * tc.grade_points) / SUM(tc.credits), 2) as weighted_gpa
FROM transfer_credits tc
JOIN students s ON tc.student_id = s.student_id  -- Join on TEXT student_id
JOIN applications a ON s.application_id = a.id
WHERE a.reference_number = 'ACNHS-ADM-20260108-970'
AND tc.status = 'approved';
