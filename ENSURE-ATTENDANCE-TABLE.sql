-- ============================================================================
-- ENSURE ATTENDANCE RECORDS TABLE EXISTS
-- Run this in Supabase SQL Editor to guarantee attendance tracking works
-- ============================================================================

-- Create attendance_records table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.attendance_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id TEXT NOT NULL, -- UUID or ACNHS-xxxxxxx format
  course_code TEXT NOT NULL,
  semester TEXT NOT NULL,
  session_date DATE NOT NULL,
  session_type TEXT NOT NULL DEFAULT 'lecture' CHECK (session_type IN ('theory', 'clinical', 'lab', 'lecture')),
  status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
  notes TEXT,
  recorded_by TEXT, -- Admin email who recorded attendance
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure one record per student per session
  -- This allows updates when attendance is changed
  UNIQUE (student_id, course_code, session_date, session_type)
);

-- Create indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_attendance_student_id 
  ON public.attendance_records(student_id);

CREATE INDEX IF NOT EXISTS idx_attendance_course_code 
  ON public.attendance_records(course_code);

CREATE INDEX IF NOT EXISTS idx_attendance_semester 
  ON public.attendance_records(semester);

CREATE INDEX IF NOT EXISTS idx_attendance_session_date 
  ON public.attendance_records(session_date DESC);

CREATE INDEX IF NOT EXISTS idx_attendance_status 
  ON public.attendance_records(status);

-- Composite index for common query pattern
CREATE INDEX IF NOT EXISTS idx_attendance_course_date 
  ON public.attendance_records(course_code, session_date);

-- Enable Row Level Security
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Allow anon read attendance_records" ON public.attendance_records;
DROP POLICY IF EXISTS "Allow anon insert attendance_records" ON public.attendance_records;
DROP POLICY IF EXISTS "Allow anon update attendance_records" ON public.attendance_records;
DROP POLICY IF EXISTS "Allow anon delete attendance_records" ON public.attendance_records;

-- Create permissive RLS policies for anon role (development mode)
-- IMPORTANT: In production, restrict these to authenticated users only

CREATE POLICY "Allow anon read attendance_records" 
  ON public.attendance_records FOR SELECT 
  TO anon 
  USING (true);

CREATE POLICY "Allow anon insert attendance_records" 
  ON public.attendance_records FOR INSERT 
  TO anon 
  WITH CHECK (true);

CREATE POLICY "Allow anon update attendance_records" 
  ON public.attendance_records FOR UPDATE 
  TO anon 
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow anon delete attendance_records" 
  ON public.attendance_records FOR DELETE 
  TO anon 
  USING (true);

-- Grant permissions
GRANT ALL ON public.attendance_records TO anon;
GRANT ALL ON public.attendance_records TO authenticated;

-- Verification queries
DO $$ 
BEGIN
  RAISE NOTICE '✅ Attendance records table is ready!';
  RAISE NOTICE 'Table: attendance_records';
  RAISE NOTICE 'Indexes: 6 created for performance';
  RAISE NOTICE 'RLS Policies: 4 policies (SELECT, INSERT, UPDATE, DELETE)';
  RAISE NOTICE 'Unique constraint: student_id + course_code + session_date + session_type';
END $$;

-- Check if table exists and show structure
SELECT 
  'attendance_records' as table_name,
  COUNT(*) as current_record_count
FROM public.attendance_records;

-- Show all columns
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'attendance_records'
ORDER BY ordinal_position;
