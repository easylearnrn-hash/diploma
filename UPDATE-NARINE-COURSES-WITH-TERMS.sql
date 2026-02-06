-- DELETE AND RE-INSERT NARINE'S ACNHS COURSES WITH CORRECT TERMS
-- Student: Narine Avetisyan
-- Student UUID: 03f0f55c-1743-421d-a16b-bfe2325815c3
-- Terms: Spring 2025, Fall 2025 (completed), Spring 2026 (in progress for graduation)

DO $$
DECLARE
    v_student_uuid UUID := '03f0f55c-1743-421d-a16b-bfe2325815c3';
BEGIN
    -- First, delete all existing ACNHS courses
    DELETE FROM student_grades WHERE student_id = v_student_uuid;
    RAISE NOTICE '✅ Deleted existing courses';
    
    -- SPRING 2025 (Semester 1) - Completed courses (8 credits)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, academic_year, grade, grade_points)
    VALUES 
        (v_student_uuid, 'MEDT-101', 'Medical Terminology (Healthcare-Specific)', 1, 'Spring 2025', '2024-2025', 'A', 4.0),
        (v_student_uuid, 'PHRM-201', 'Pharmacology', 4, 'Spring 2025', '2024-2025', 'A', 4.0),
        (v_student_uuid, 'PHRM-202', 'Medication Suffixes & Drug Classes', 1, 'Spring 2025', '2024-2025', 'A-', 3.7),
        (v_student_uuid, 'NURS-210', 'Fluids, Electrolytes & IV Therapy', 2, 'Spring 2025', '2024-2025', 'A', 4.0);
    RAISE NOTICE '✅ Inserted Spring 2025 courses (8 credits)';
    
    -- FALL 2025 (Semesters 2-3) - Completed courses (17 credits)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, academic_year, grade, grade_points)
    VALUES 
        -- Semester 2 courses
        (v_student_uuid, 'CVN-301', 'Cardiovascular Nursing', 4, 'Fall 2025', '2025-2026', 'A', 4.0),
        (v_student_uuid, 'RESP-302', 'Respiratory Nursing', 4, 'Fall 2025', '2025-2026', 'A-', 3.7),
        -- Semester 3 courses
        (v_student_uuid, 'REN-303', 'Renal & Urinary Nursing', 1, 'Fall 2025', '2025-2026', 'A', 4.0),
        (v_student_uuid, 'ENDO-304', 'Endocrine Nursing', 1, 'Fall 2025', '2025-2026', 'A', 4.0),
        (v_student_uuid, 'GIH-305', 'Gastrointestinal & Hepatic Nursing', 1, 'Fall 2025', '2025-2026', 'B', 3.0),
        (v_student_uuid, 'MSK-306', 'Musculoskeletal Nursing', 1, 'Fall 2025', '2025-2026', 'A', 4.0),
        (v_student_uuid, 'DERM-307', 'Integumentary / Burns & Wound Care', 1, 'Fall 2025', '2025-2026', 'A', 4.0),
        (v_student_uuid, 'SENS-308', 'Sensory Systems (Eye & ENT)', 1, 'Fall 2025', '2025-2026', 'A-', 3.7),
        (v_student_uuid, 'ONC-101', 'Oncology Nursing', 3, 'Fall 2025', '2025-2026', 'A', 4.0);
    RAISE NOTICE '✅ Inserted Fall 2025 courses (17 credits)';
    
    -- SPRING 2026 (Semester 4) - Current/In Progress for Graduation (11 credits)
    INSERT INTO student_grades (student_id, course_code, course_name, credits, term, academic_year, grade, grade_points)
    VALUES 
        (v_student_uuid, 'OBN-401', 'Maternal & Newborn Nursing', 2, 'Spring 2026', '2025-2026', 'IP', 0),
        (v_student_uuid, 'REPR-402', 'Reproductive & Sexual Health (Nursing)', 1, 'Spring 2026', '2025-2026', 'IP', 0),
        (v_student_uuid, 'PEDS-403', 'Pediatric Nursing', 2, 'Spring 2026', '2025-2026', 'IP', 0),
        (v_student_uuid, 'PSY-404', 'Mental Health Nursing (Psychiatric Nursing)', 2, 'Spring 2026', '2025-2026', 'IP', 0),
        (v_student_uuid, 'GERO-405', 'Gerontology (Nursing Focus)', 2, 'Spring 2026', '2025-2026', 'IP', 0),
        (v_student_uuid, 'CAPSTONE-499', 'Capstone Project', 2, 'Spring 2026', '2025-2026', 'IP', 0);
    RAISE NOTICE '✅ Inserted Spring 2026 courses (11 credits - In Progress)';
    
    RAISE NOTICE '====================================';
    RAISE NOTICE 'TOTAL: % courses inserted', (SELECT COUNT(*) FROM student_grades WHERE student_id = v_student_uuid);
    RAISE NOTICE 'Spring 2025: 8 credits (Completed)';
    RAISE NOTICE 'Fall 2025: 17 credits (Completed)';
    RAISE NOTICE 'Spring 2026: 11 credits (In Progress)';
    RAISE NOTICE 'TOTAL ACNHS: 36 credits';
    RAISE NOTICE '====================================';
END $$;

-- Verify courses by term
SELECT 
    term,
    COUNT(*) as courses,
    SUM(credits) as total_credits,
    STRING_AGG(course_code, ', ' ORDER BY course_code) as course_codes
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
GROUP BY term
ORDER BY 
    CASE term
        WHEN 'Spring 2025' THEN 1
        WHEN 'Fall 2025' THEN 2
        WHEN 'Spring 2026' THEN 3
    END;

-- Calculate GPA (excluding In Progress courses)
WITH completed_courses AS (
    SELECT 
        'ACNHS Completed' as source,
        COUNT(*) as courses,
        SUM(credits) as credits,
        SUM(credits * grade_points) as quality_points,
        ROUND(SUM(credits * grade_points) / SUM(credits), 2) as gpa
    FROM student_grades
    WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
    AND grade != 'IP'
),
in_progress AS (
    SELECT 
        'Spring 2026 (IP)' as source,
        COUNT(*) as courses,
        SUM(credits) as credits,
        0 as quality_points,
        0.00 as gpa
    FROM student_grades
    WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
    AND grade = 'IP'
),
transfer_courses AS (
    SELECT 
        'Transfer Credits' as source,
        COUNT(*) as courses,
        SUM(credits) as credits,
        SUM(credits * grade_points) as quality_points,
        ROUND(SUM(credits * grade_points) / SUM(credits), 2) as gpa
    FROM transfer_credits
    WHERE student_id = 'ACNHS-7022395' AND status = 'approved'
),
combined_gpa AS (
    SELECT 
        'COMBINED GPA' as source,
        SUM(courses) as courses,
        SUM(credits) as credits,
        SUM(quality_points) as quality_points,
        ROUND(SUM(quality_points) / SUM(credits), 2) as gpa
    FROM (
        SELECT courses, credits, quality_points FROM completed_courses
        UNION ALL
        SELECT courses, credits, quality_points FROM transfer_courses
    ) all_completed
)
SELECT * FROM (
    SELECT source, courses, credits, quality_points, gpa, 1 as sort_order FROM transfer_courses
    UNION ALL
    SELECT source, courses, credits, quality_points, gpa, 2 as sort_order FROM completed_courses
    UNION ALL
    SELECT source, courses, credits, quality_points, gpa, 3 as sort_order FROM in_progress
    UNION ALL
    SELECT source, courses, credits, quality_points, gpa, 4 as sort_order FROM combined_gpa
) results
ORDER BY sort_order;
