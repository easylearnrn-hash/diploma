-- Run this in Supabase SQL Editor
ALTER TABLE public.student_grades
ADD COLUMN IF NOT EXISTS grade_items JSONB,
ADD COLUMN IF NOT EXISTS letter_grade VARCHAR(5);

-- Update permissions for new columns
GRANT ALL ON public.student_grades TO anon;
