-- ============================================================================
-- CREATE COURSES TABLE IN SUPABASE
-- Run this to store courses permanently in database instead of localStorage
-- ============================================================================

-- Create courses table
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  semester TEXT NOT NULL,
  credits INTEGER NOT NULL DEFAULT 3,
  course_type TEXT CHECK (course_type IN ('theory', 'clinical', 'lab', 'lecture')),
  description TEXT,
  prerequisites TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT,
  
  -- Unique constraint: one course code per semester
  UNIQUE (code, semester)
);

-- Create indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_courses_semester 
  ON public.courses(semester);

CREATE INDEX IF NOT EXISTS idx_courses_code 
  ON public.courses(code);

CREATE INDEX IF NOT EXISTS idx_courses_status 
  ON public.courses(status);

-- Enable Row Level Security
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow anon read courses" ON public.courses;
DROP POLICY IF EXISTS "Allow anon insert courses" ON public.courses;
DROP POLICY IF EXISTS "Allow anon update courses" ON public.courses;
DROP POLICY IF EXISTS "Allow anon delete courses" ON public.courses;

-- Create RLS policies (permissive for development)
CREATE POLICY "Allow anon read courses" 
  ON public.courses FOR SELECT 
  TO anon 
  USING (true);

CREATE POLICY "Allow anon insert courses" 
  ON public.courses FOR INSERT 
  TO anon 
  WITH CHECK (true);

CREATE POLICY "Allow anon update courses" 
  ON public.courses FOR UPDATE 
  TO anon 
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow anon delete courses" 
  ON public.courses FOR DELETE 
  TO anon 
  USING (true);

-- Grant permissions
GRANT ALL ON public.courses TO anon;
GRANT ALL ON public.courses TO authenticated;

-- Success message
DO $$ 
BEGIN
  RAISE NOTICE '✅ Courses table created successfully!';
  RAISE NOTICE 'Table: courses';
  RAISE NOTICE 'Columns: 11';
  RAISE NOTICE 'Unique constraint: code + semester';
END $$;

-- Verify table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'courses' 
  AND table_schema = 'public'
ORDER BY ordinal_position;
