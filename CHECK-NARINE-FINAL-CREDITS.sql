-- CHECK ACTUAL COURSE LIST TO VERIFY 72 CREDITS
SELECT 
    term,
    course_code,
    course_name,
    credits,
    grade
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
ORDER BY 
    CASE term
        WHEN 'Spring 2025' THEN 1
        WHEN 'Fall 2025' THEN 2
        WHEN 'Spring 2026' THEN 3
    END,
    course_code;

-- Total by term
SELECT 
    term,
    COUNT(*) as courses,
    SUM(credits) as total_credits
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
GROUP BY term
ORDER BY 
    CASE term
        WHEN 'Spring 2025' THEN 1
        WHEN 'Fall 2025' THEN 2
        WHEN 'Spring 2026' THEN 3
    END;
