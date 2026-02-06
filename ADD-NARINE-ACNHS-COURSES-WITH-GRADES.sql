-- ADD NARINE'S ACNHS COURSES WITH GRADES
-- Student: Narine Avetisyan
-- Student UUID: 03f0f55c-1743-421d-a16b-bfe2325815c3
-- Grades: Mostly A (4.0), some A- (3.7), a few B (3.0)

DO $$
DECLARE
    v_student_uuid UUID := '03f0f55c-1743-421d-a16b-bfe2325815c3';
    v_term TEXT := 'Spring 2026';
BEGIN
    -- Semester 1 Courses
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'MEDT-101', 'Medical Terminology (Healthcare-Specific)', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'PHRM-201', 'Pharmacology', 4, v_term, 'A', 4.0),
        (v_student_uuid, 'PHRM-202', 'Medication Suffixes & Drug Classes', 1, v_term, 'A-', 3.7),
        (v_student_uuid, 'NURS-210', 'Fluids, Electrolytes & IV Therapy', 2, v_term, 'A', 4.0);
    
    -- Semester 2 Courses
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'CVN-301', 'Cardiovascular Nursing', 4, v_term, 'A', 4.0),
        (v_student_uuid, 'RESP-302', 'Respiratory Nursing', 4, v_term, 'A-', 3.7);
    
    -- Semester 3 Courses
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'REN-303', 'Renal & Urinary Nursing', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'ENDO-304', 'Endocrine Nursing', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'GIH-305', 'Gastrointestinal & Hepatic Nursing', 1, v_term, 'B', 3.0),
        (v_student_uuid, 'MSK-306', 'Musculoskeletal Nursing', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'DERM-307', 'Integumentary / Burns & Wound Care', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'SENS-308', 'Sensory Systems (Eye & ENT)', 1, v_term, 'A-', 3.7),
        (v_student_uuid, 'ONC-101', 'Oncology Nursing', 3, v_term, 'A', 4.0);
    
    -- Semester 4 Courses
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'OBN-401', 'Maternal & Newborn Nursing', 2, v_term, 'A', 4.0),
        (v_student_uuid, 'REPR-402', 'Reproductive & Sexual Health (Nursing)', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'PEDS-403', 'Pediatric Nursing', 2, v_term, 'A-', 3.7),
        (v_student_uuid, 'PSY-404', 'Mental Health Nursing (Psychiatric Nursing)', 2, v_term, 'A', 4.0),
        (v_student_uuid, 'GERO-405', 'Gerontology (Nursing Focus)', 2, v_term, 'B', 3.0);
    
    -- Embedded/Clinical Courses (0 credits - Pass/Fail, not counted in GPA)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'PHN-410', 'Community / Public Health Nursing', 0, v_term, 'P', 0),
        (v_student_uuid, 'LEAD-420', 'Leadership & Management in Nursing', 0, v_term, 'P', 0),
        (v_student_uuid, 'ETHL-430', 'Ethics & Legal Aspects of Nursing', 0, v_term, 'P', 0),
        (v_student_uuid, 'EBPQ-440', 'Evidence-Based Practice & Quality Improvement', 0, v_term, 'P', 0),
        (v_student_uuid, 'NGN-450', 'Clinical Judgment / NGN Case Studies', 0, v_term, 'P', 0),
        (v_student_uuid, 'NCLEX-460', 'Integrated NCLEX Review', 0, v_term, 'P', 0),
        (v_student_uuid, 'LAB-470', 'Skills Laboratory', 0, v_term, 'P', 0),
        (v_student_uuid, 'SIM-480', 'High-Fidelity Simulation', 0, v_term, 'P', 0),
        (v_student_uuid, 'CLIN-490', 'Supervised Clinical Rotations', 0, v_term, 'P', 0),
        (v_student_uuid, 'COMP-495', 'Clinical Competency Evaluation', 0, v_term, 'P', 0);
    
    RAISE NOTICE '✅ Successfully inserted % ACNHS courses for Narine', (SELECT COUNT(*) FROM student_grades WHERE student_id = v_student_uuid);
END $$;

-- Verify the inserted courses
SELECT 
    course_code,
    course_name,
    credits,
    grade,
    grade_points
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
ORDER BY course_code;

-- Calculate ACNHS GPA
SELECT 
    'ACNHS Courses' as source,
    COUNT(*) FILTER (WHERE credits > 0) as graded_courses,
    SUM(credits) FILTER (WHERE credits > 0) as total_credits,
    ROUND(SUM(credits * grade_points) / NULLIF(SUM(credits) FILTER (WHERE credits > 0), 0), 2) as gpa
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3';

-- Calculate COMBINED GPA (Transfer + ACNHS)
SELECT 
    'Transfer Credits' as source,
    COUNT(*) as courses,
    SUM(credits) as credits,
    ROUND(SUM(credits * grade_points) / SUM(credits), 2) as gpa
FROM transfer_credits
WHERE student_id = 'ACNHS-7022395' AND status = 'approved'
UNION ALL
SELECT 
    'ACNHS Courses' as source,
    COUNT(*) FILTER (WHERE credits > 0) as courses,
    SUM(credits) FILTER (WHERE credits > 0) as credits,
    ROUND(SUM(credits * grade_points) / NULLIF(SUM(credits) FILTER (WHERE credits > 0), 0), 2) as gpa
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
UNION ALL
SELECT 
    'COMBINED TOTAL' as source,
    COUNT(*) as courses,
    SUM(credits) as credits,
    ROUND(SUM(credits * grade_points) / NULLIF(SUM(credits), 0), 2) as gpa
FROM (
    SELECT credits, grade_points FROM transfer_credits WHERE student_id = 'ACNHS-7022395' AND status = 'approved'
    UNION ALL
    SELECT credits, grade_points FROM student_grades WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3' AND credits > 0
) combined;
