-- VERIFY TRANSFER CREDITS ARE IN DATABASE
-- Check if Narine's transfer credits exist and can be queried

-- 1. Direct query - show all transfer credits for Narine
SELECT 
    tc.id,
    tc.student_id,
    tc.course_code,
    tc.course_name,
    tc.credits,
    tc.grade,
    tc.grade_points,
    tc.status
FROM transfer_credits tc
WHERE tc.student_id = 'ACNHS-7022395'
ORDER BY tc.course_code;

-- 2. Count transfer credits
SELECT 
    COUNT(*) as total_credits,
    student_id
FROM transfer_credits
WHERE student_id = 'ACNHS-7022395'
GROUP BY student_id;

-- 3. Check what the JavaScript will query (by student UUID)
SELECT 
    tc.*
FROM transfer_credits tc
WHERE tc.student_id IN (
    SELECT student_id FROM students WHERE id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
);
