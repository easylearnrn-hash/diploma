-- ADD NARINE'S ACNHS COURSES WITH GRADES (ONLY CREDIT-BEARING COURSES)
-- Student: Narine Avetisyan
-- Student UUID: 03f0f55c-1743-421d-a16b-bfe2325815c3
-- Grades: Mostly A (4.0), some A- (3.7), a few B (3.0)
-- NOTE: Excluding 0-credit embedded courses due to check constraint

DO $$
DECLARE
    v_student_uuid UUID := '03f0f55c-1743-421d-a16b-bfe2325815c3';
    v_term TEXT := 'Spring 2026';
BEGIN
    -- Semester 1 Courses (8 credits)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'MEDT-101', 'Medical Terminology (Healthcare-Specific)', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'PHRM-201', 'Pharmacology', 4, v_term, 'A', 4.0),
        (v_student_uuid, 'PHRM-202', 'Medication Suffixes & Drug Classes', 1, v_term, 'A-', 3.7),
        (v_student_uuid, 'NURS-210', 'Fluids, Electrolytes & IV Therapy', 2, v_term, 'A', 4.0);
    
    -- Semester 2 Courses (8 credits)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'CVN-301', 'Cardiovascular Nursing', 4, v_term, 'A', 4.0),
        (v_student_uuid, 'RESP-302', 'Respiratory Nursing', 4, v_term, 'A-', 3.7);
    
    -- Semester 3 Courses (9 credits)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'REN-303', 'Renal & Urinary Nursing', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'ENDO-304', 'Endocrine Nursing', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'GIH-305', 'Gastrointestinal & Hepatic Nursing', 1, v_term, 'B', 3.0),
        (v_student_uuid, 'MSK-306', 'Musculoskeletal Nursing', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'DERM-307', 'Integumentary / Burns & Wound Care', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'SENS-308', 'Sensory Systems (Eye & ENT)', 1, v_term, 'A-', 3.7),
        (v_student_uuid, 'ONC-101', 'Oncology Nursing', 3, v_term, 'A', 4.0);
    
    -- Semester 4 Courses (11 credits)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, grade, grade_points)
    VALUES 
        (v_student_uuid, 'OBN-401', 'Maternal & Newborn Nursing', 2, v_term, 'A', 4.0),
        (v_student_uuid, 'REPR-402', 'Reproductive & Sexual Health (Nursing)', 1, v_term, 'A', 4.0),
        (v_student_uuid, 'PEDS-403', 'Pediatric Nursing', 2, v_term, 'A-', 3.7),
        (v_student_uuid, 'PSY-404', 'Mental Health Nursing (Psychiatric Nursing)', 2, v_term, 'A', 4.0),
        (v_student_uuid, 'GERO-405', 'Gerontology (Nursing Focus)', 2, v_term, 'B', 3.0),
        (v_student_uuid, 'CAPSTONE-499', 'Capstone Project', 2, v_term, 'A', 4.0);
    
    RAISE NOTICE '✅ Successfully inserted % ACNHS courses for Narine', (SELECT COUNT(*) FROM student_grades WHERE student_id = v_student_uuid);
END $$;

-- Verify the inserted courses
SELECT 
    course_code,
    course_name,
    credits,
    grade,
    grade_points,
    ROUND(credits * grade_points, 2) as quality_points
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
ORDER BY course_code;

-- Calculate ACNHS GPA
SELECT 
    'ACNHS Courses' as source,
    COUNT(*) as courses,
    SUM(credits) as total_credits,
    ROUND(SUM(credits * grade_points) / SUM(credits), 2) as gpa,
    SUM(credits * grade_points) as quality_points
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3';

-- Calculate COMBINED GPA (Transfer + ACNHS)
WITH transfer_data AS (
    SELECT 
        'Transfer Credits' as source,
        COUNT(*) as courses,
        SUM(credits) as credits,
        SUM(credits * grade_points) as quality_points,
        ROUND(SUM(credits * grade_points) / SUM(credits), 2) as gpa
    FROM transfer_credits
    WHERE student_id = 'ACNHS-7022395' AND status = 'approved'
),
acnhs_data AS (
    SELECT 
        'ACNHS Courses' as source,
        COUNT(*) as courses,
        SUM(credits) as credits,
        SUM(credits * grade_points) as quality_points,
        ROUND(SUM(credits * grade_points) / SUM(credits), 2) as gpa
    FROM student_grades
    WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
),
combined_data AS (
    SELECT 
        'COMBINED TOTAL' as source,
        SUM(courses) as courses,
        SUM(credits) as credits,
        SUM(quality_points) as quality_points,
        ROUND(SUM(quality_points) / SUM(credits), 2) as gpa
    FROM (
        SELECT courses, credits, quality_points FROM transfer_data
        UNION ALL
        SELECT courses, credits, quality_points FROM acnhs_data
    ) all_courses
)
SELECT * FROM (
    SELECT source, courses, credits, quality_points, gpa,
        CASE source
            WHEN 'Transfer Credits' THEN 1
            WHEN 'ACNHS Courses' THEN 2
            WHEN 'COMBINED TOTAL' THEN 3
        END as sort_order
    FROM transfer_data
    UNION ALL
    SELECT source, courses, credits, quality_points, gpa,
        CASE source
            WHEN 'Transfer Credits' THEN 1
            WHEN 'ACNHS Courses' THEN 2
            WHEN 'COMBINED TOTAL' THEN 3
        END as sort_order
    FROM acnhs_data
    UNION ALL
    SELECT source, courses, credits, quality_points, gpa,
        CASE source
            WHEN 'Transfer Credits' THEN 1
            WHEN 'ACNHS Courses' THEN 2
            WHEN 'COMBINED TOTAL' THEN 3
        END as sort_order
    FROM combined_data
) results
ORDER BY sort_order;
