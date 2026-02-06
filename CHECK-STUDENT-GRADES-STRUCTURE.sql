-- CHECK STUDENT_GRADES TABLE STRUCTURE
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'student_grades'
AND table_schema = 'public'
ORDER BY ordinal_position;
