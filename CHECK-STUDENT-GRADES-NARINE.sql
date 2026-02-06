-- CHECK STUDENT_GRADES TABLE FOR NARINE

-- 1. Check structure of student_grades table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'student_grades'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. Check if Narine has any grades (using UUID from students table)
SELECT sg.*
FROM student_grades sg
JOIN students s ON sg.student_id = s.id
WHERE s.student_id = 'ACNHS-7022395';

-- 3. Check all grades for any student (to understand the structure)
SELECT *
FROM student_grades
LIMIT 5;

-- 4. Calculate combined GPA (transfer credits + ACNHS grades)
SELECT 
    'Transfer Credits' as source,
    COUNT(*) as course_count,
    SUM(tc.credits) as total_credits,
    ROUND(SUM(tc.credits * tc.grade_points) / NULLIF(SUM(tc.credits), 0), 2) as gpa
FROM transfer_credits tc
WHERE tc.student_id = 'ACNHS-7022395'
AND tc.status = 'approved'
UNION ALL
SELECT 
    'ACNHS Courses' as source,
    COUNT(*) as course_count,
    SUM(sg.credits) as total_credits,
    ROUND(SUM(sg.credits * sg.grade_points) / NULLIF(SUM(sg.credits), 0), 2) as gpa
FROM student_grades sg
JOIN students s ON sg.student_id = s.id
WHERE s.student_id = 'ACNHS-7022395'
UNION ALL
SELECT 
    'COMBINED TOTAL' as source,
    COUNT(*) as course_count,
    SUM(credits) as total_credits,
    ROUND(SUM(credits * grade_points) / NULLIF(SUM(credits), 0), 2) as gpa
FROM (
    SELECT credits, grade_points FROM transfer_credits WHERE student_id = 'ACNHS-7022395' AND status = 'approved'
    UNION ALL
    SELECT sg.credits, sg.grade_points 
    FROM student_grades sg
    JOIN students s ON sg.student_id = s.id
    WHERE s.student_id = 'ACNHS-7022395'
) combined;
