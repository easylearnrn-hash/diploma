-- Update existing TMP student IDs to ACNHS format
UPDATE public.acnhs_students
SET student_id = REPLACE(student_id, 'TMP-', 'ACNHS-')
WHERE student_id LIKE 'TMP-%';

-- Verify the update
SELECT student_id, full_name, email FROM public.acnhs_students;
