-- Check which courses were actually inserted
SELECT 
    course_code,
    course_name,
    credits,
    grade,
    grade_points
FROM student_grades
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
ORDER BY course_code;
