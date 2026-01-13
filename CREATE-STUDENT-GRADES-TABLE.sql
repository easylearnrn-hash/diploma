-- Create Student Grades Table for Grade Tracking and GPA Calculation
-- Run this SQL in Supabase SQL Editor

-- Step 1: Create the student_grades table
CREATE TABLE IF NOT EXISTS public.student_grades (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID NOT NULL REFERENCES public.acnhs_students(id) ON DELETE CASCADE,
  course_code VARCHAR(20) NOT NULL,
  course_name VARCHAR(255) NOT NULL,
  credits INTEGER NOT NULL CHECK (credits > 0),
  grade VARCHAR(5) NOT NULL,
  grade_points DECIMAL(3,2) NOT NULL CHECK (grade_points >= 0 AND grade_points <= 4.0),
  term VARCHAR(50) NOT NULL,
  academic_year VARCHAR(20),
  instructor VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_student_grades_student_id ON public.student_grades(student_id);
CREATE INDEX IF NOT EXISTS idx_student_grades_term ON public.student_grades(term);

-- Step 3: Add RLS policies
ALTER TABLE public.student_grades ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow anon to read grades" ON public.student_grades;
DROP POLICY IF EXISTS "Allow anon to insert grades" ON public.student_grades;
DROP POLICY IF EXISTS "Allow anon to update grades" ON public.student_grades;
DROP POLICY IF EXISTS "Allow anon to delete grades" ON public.student_grades;

-- Create policies
CREATE POLICY "Allow anon to read grades" 
  ON public.student_grades FOR SELECT 
  TO anon 
  USING (true);

CREATE POLICY "Allow anon to insert grades" 
  ON public.student_grades FOR INSERT 
  TO anon 
  WITH CHECK (true);

CREATE POLICY "Allow anon to update grades" 
  ON public.student_grades FOR UPDATE 
  TO anon 
  USING (true);

CREATE POLICY "Allow anon to delete grades" 
  ON public.student_grades FOR DELETE 
  TO anon 
  USING (true);

-- Step 4: Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_student_grades_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_student_grades_updated_at ON public.student_grades;
CREATE TRIGGER update_student_grades_updated_at
  BEFORE UPDATE ON public.student_grades
  FOR EACH ROW
  EXECUTE FUNCTION update_student_grades_updated_at();

-- Step 5: Insert sample data for testing (optional)
-- INSERT INTO public.student_grades (student_id, course_code, course_name, credits, grade, grade_points, term)
-- SELECT 
--   id,
--   'NUR-101',
--   'Fundamentals of Nursing',
--   3,
--   'A',
--   4.0,
--   'Fall 2026'
-- FROM public.acnhs_students
-- LIMIT 1;

-- Verify the table was created
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'student_grades'
ORDER BY ordinal_position;
