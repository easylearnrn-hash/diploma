-- ADD NARINE'S ACNHS COURSES TO STUDENT_GRADES TABLE
-- Student: Narine Avetisyan
-- Student ID (TEXT): ACNHS-7022395
-- Student UUID: 03f0f55c-1743-421d-a16b-bfe2325815c3

-- First, check the structure of student_grades table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'student_grades'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Insert all ACNHS courses for Narine
-- Using UUID for student_id (not the TEXT ACNHS-7022395)
DO $$
DECLARE
    v_student_uuid UUID := '03f0f55c-1743-421d-a16b-bfe2325815c3';
    v_term TEXT := 'Spring 2026';
BEGIN
    -- Semester 1 Courses
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, letter_grade, grade_points, status)
    VALUES 
        (v_student_uuid, 'MEDT-101', 'Medical Terminology (Healthcare-Specific)', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'PHRM-201', 'Pharmacology', 4, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'PHRM-202', 'Medication Suffixes & Drug Classes', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'NURS-210', 'Fluids, Electrolytes & IV Therapy', 2, v_term, 'IP', 'IP', NULL, 'in_progress');
    
    -- Semester 2 Courses
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, letter_grade, grade_points, status)
    VALUES 
        (v_student_uuid, 'CVN-301', 'Cardiovascular Nursing', 4, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'RESP-302', 'Respiratory Nursing', 4, v_term, 'IP', 'IP', NULL, 'in_progress');
    
    -- Semester 3 Courses
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, letter_grade, grade_points, status)
    VALUES 
        (v_student_uuid, 'REN-303', 'Renal & Urinary Nursing', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'ENDO-304', 'Endocrine Nursing', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'GIH-305', 'Gastrointestinal & Hepatic Nursing', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'MSK-306', 'Musculoskeletal Nursing', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'DERM-307', 'Integumentary / Burns & Wound Care', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'SENS-308', 'Sensory Systems (Eye & ENT)', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'ONC-101', 'Oncology Nursing', 3, v_term, 'IP', 'IP', NULL, 'in_progress');
    
    -- Semester 4 Courses
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, letter_grade, grade_points, status)
    VALUES 
        (v_student_uuid, 'OBN-401', 'Maternal & Newborn Nursing', 2, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'REPR-402', 'Reproductive & Sexual Health (Nursing)', 1, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'PEDS-403', 'Pediatric Nursing', 2, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'PSY-404', 'Mental Health Nursing (Psychiatric Nursing)', 2, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'GERO-405', 'Gerontology (Nursing Focus)', 2, v_term, 'IP', 'IP', NULL, 'in_progress');
    
    -- Embedded/Clinical Courses (0 credits - not counted in GPA)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, letter_grade, grade_points, status)
    VALUES 
        (v_student_uuid, 'PHN-410', 'Community / Public Health Nursing', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'LEAD-420', 'Leadership & Management in Nursing', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'ETHL-430', 'Ethics & Legal Aspects of Nursing', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'EBPQ-440', 'Evidence-Based Practice & Quality Improvement', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'NGN-450', 'Clinical Judgment / NGN Case Studies', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'NCLEX-460', 'Integrated NCLEX Review', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'LAB-470', 'Skills Laboratory', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'SIM-480', 'High-Fidelity Simulation', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'CLIN-490', 'Supervised Clinical Rotations', 0, v_term, 'IP', 'IP', NULL, 'in_progress'),
        (v_student_uuid, 'COMP-495', 'Clinical Competency Evaluation', 0, v_term, 'IP', 'IP', NULL, 'in_progress');
    
    RAISE NOTICE '✅ Successfully inserted % ACNHS courses for Narine', (SELECT COUNT(*) FROM student_grades WHERE student_id = v_student_uuid);
END $$;

-- Verify the inserted courses
SELECT 
    course_code,
    course_name,
    credits,
    grade,
    status
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
ORDER BY course_code;

-- Calculate summary
SELECT 
    COUNT(*) as total_courses,
    SUM(credits) as total_credits_in_progress,
    COUNT(*) FILTER (WHERE credits > 0) as credit_courses
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3';
