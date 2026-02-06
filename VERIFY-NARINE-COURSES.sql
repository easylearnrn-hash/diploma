-- Verify all ACNHS courses for Narine
SELECT 
    course_code,
    course_name,
    credits,
    grade,
    grade_points,
    credits * grade_points as quality_points
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
ORDER BY course_code;

-- Check total credits
SELECT 
    COUNT(*) as total_courses,
    SUM(credits) as total_credits
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3';
