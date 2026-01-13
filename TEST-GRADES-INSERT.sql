-- Test Insert for Student Grades
-- This will add sample grades for the first student in your acnhs_students table

-- First, let's see what students we have
SELECT id, student_id, full_name, email 
FROM public.acnhs_students 
LIMIT 5;

-- Insert sample grades for the first student
-- Replace the student_id with an actual ID from the query above
DO $$
DECLARE
  first_student_id UUID;
BEGIN
  -- Get the first student
  SELECT id INTO first_student_id 
  FROM public.acnhs_students 
  LIMIT 1;
  
  -- Only insert if we found a student
  IF first_student_id IS NOT NULL THEN
    -- Insert sample grades
    INSERT INTO public.student_grades (student_id, course_code, course_name, credits, grade, grade_points, term, academic_year)
    VALUES 
      (first_student_id, 'NUR-101', 'Fundamentals of Nursing', 3, 'A', 4.0, 'Fall 2026', '2026-2027'),
      (first_student_id, 'BIO-201', 'Human Anatomy and Physiology', 4, 'B+', 3.3, 'Fall 2026', '2026-2027'),
      (first_student_id, 'PSY-101', 'Introduction to Psychology', 3, 'A-', 3.7, 'Fall 2026', '2026-2027'),
      (first_student_id, 'NUR-102', 'Medical Terminology', 2, 'A', 4.0, 'Fall 2026', '2026-2027'),
      (first_student_id, 'CHM-101', 'General Chemistry', 4, 'B', 3.0, 'Fall 2026', '2026-2027');
    
    RAISE NOTICE 'Sample grades inserted for student ID: %', first_student_id;
  ELSE
    RAISE NOTICE 'No students found in acnhs_students table';
  END IF;
END $$;

-- Verify the insert
SELECT 
  sg.course_code,
  sg.course_name,
  sg.credits,
  sg.grade,
  sg.grade_points,
  sg.term,
  s.student_id,
  s.full_name
FROM public.student_grades sg
JOIN public.acnhs_students s ON sg.student_id = s.id
ORDER BY sg.created_at DESC;

-- Calculate GPA
SELECT 
  s.student_id,
  s.full_name,
  COUNT(sg.id) as total_courses,
  SUM(sg.credits) as total_credits,
  ROUND(SUM(sg.grade_points * sg.credits) / SUM(sg.credits), 2) as calculated_gpa
FROM public.acnhs_students s
LEFT JOIN public.student_grades sg ON s.id = sg.student_id
WHERE sg.id IS NOT NULL
GROUP BY s.id, s.student_id, s.full_name;
