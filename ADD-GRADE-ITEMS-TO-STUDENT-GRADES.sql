-- Add missing columns for grade items and letter grade to student_grades table

ALTER TABLE public.student_grades
ADD COLUMN IF NOT EXISTS grade_items TEXT,
ADD COLUMN IF NOT EXISTS letter_grade VARCHAR(5);
