-- Add final_exam_date column to students table
-- Run this in the Supabase SQL Editor for project eyhksbiceueoiamwnqpr

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'students'
      AND column_name  = 'final_exam_date'
  ) THEN
    ALTER TABLE public.students ADD COLUMN final_exam_date DATE;
    COMMENT ON COLUMN public.students.final_exam_date IS 'Scheduled final examination date for the student';
  END IF;
END $$;
