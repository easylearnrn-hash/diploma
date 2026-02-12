-- ============================================================================
-- ACNHS COMPLETE DATABASE MIGRATION
-- Migrate ALL data from localStorage to Supabase
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard
-- ============================================================================

-- ============================================================================
-- TABLE 1: STUDENT GROUPS
-- Replaces: localStorage.studentGroups
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.student_groups (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  semester TEXT NOT NULL,
  student_ids TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_student_groups_semester ON public.student_groups(semester);
CREATE INDEX IF NOT EXISTS idx_student_groups_created_at ON public.student_groups(created_at DESC);

-- Enable RLS
ALTER TABLE public.student_groups ENABLE ROW LEVEL SECURITY;

-- RLS Policies (anonymous for testing - lock down in production)
DROP POLICY IF EXISTS "Allow anon read student_groups" ON public.student_groups;
CREATE POLICY "Allow anon read student_groups" 
  ON public.student_groups FOR SELECT 
  TO anon 
  USING (true);

DROP POLICY IF EXISTS "Allow anon insert student_groups" ON public.student_groups;
CREATE POLICY "Allow anon insert student_groups" 
  ON public.student_groups FOR INSERT 
  TO anon 
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anon update student_groups" ON public.student_groups;
CREATE POLICY "Allow anon update student_groups" 
  ON public.student_groups FOR UPDATE 
  TO anon 
  USING (true);

DROP POLICY IF EXISTS "Allow anon delete student_groups" ON public.student_groups;
CREATE POLICY "Allow anon delete student_groups" 
  ON public.student_groups FOR DELETE 
  TO anon 
  USING (true);

-- ============================================================================
-- TABLE 2: COURSE ENROLLMENTS
-- Replaces: localStorage.COURSE_ENROLLMENTS
-- Stores which student groups are enrolled in which courses
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.course_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_key TEXT NOT NULL UNIQUE, -- Format: "Semester 1_NUR101"
  semester TEXT NOT NULL,
  course_code TEXT NOT NULL,
  enrolled_group_ids TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_course_enrollments_semester ON public.course_enrollments(semester);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_course_code ON public.course_enrollments(course_code);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_key ON public.course_enrollments(enrollment_key);

-- Enable RLS
ALTER TABLE public.course_enrollments ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Allow anon read course_enrollments" ON public.course_enrollments;
CREATE POLICY "Allow anon read course_enrollments" 
  ON public.course_enrollments FOR SELECT 
  TO anon 
  USING (true);

DROP POLICY IF EXISTS "Allow anon insert course_enrollments" ON public.course_enrollments;
CREATE POLICY "Allow anon insert course_enrollments" 
  ON public.course_enrollments FOR INSERT 
  TO anon 
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anon update course_enrollments" ON public.course_enrollments;
CREATE POLICY "Allow anon update course_enrollments" 
  ON public.course_enrollments FOR UPDATE 
  TO anon 
  USING (true);

DROP POLICY IF EXISTS "Allow anon delete course_enrollments" ON public.course_enrollments;
CREATE POLICY "Allow anon delete course_enrollments" 
  ON public.course_enrollments FOR DELETE 
  TO anon 
  USING (true);

-- ============================================================================
-- TABLE 3: COURSE GRADES (Individual Grade Items)
-- Replaces: localStorage.COURSE_GRADES
-- Stores individual grade items (assignments, quizzes, etc.) per student
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.course_grade_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id TEXT NOT NULL, -- UUID or ACNHS-xxxxxxx
  enrollment_key TEXT NOT NULL, -- Format: "Semester 1_NUR101"
  semester TEXT NOT NULL,
  course_code TEXT NOT NULL,
  grade_items JSONB NOT NULL DEFAULT '[]', -- Array of {name, weight, score}
  final_percentage DECIMAL(5,2),
  letter_grade TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure one record per student per course enrollment
  UNIQUE (student_id, enrollment_key)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_course_grade_items_student_id ON public.course_grade_items(student_id);
CREATE INDEX IF NOT EXISTS idx_course_grade_items_enrollment_key ON public.course_grade_items(enrollment_key);
CREATE INDEX IF NOT EXISTS idx_course_grade_items_semester ON public.course_grade_items(semester);
CREATE INDEX IF NOT EXISTS idx_course_grade_items_course_code ON public.course_grade_items(course_code);

-- Enable RLS
ALTER TABLE public.course_grade_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Allow anon read course_grade_items" ON public.course_grade_items;
CREATE POLICY "Allow anon read course_grade_items" 
  ON public.course_grade_items FOR SELECT 
  TO anon 
  USING (true);

DROP POLICY IF EXISTS "Allow anon insert course_grade_items" ON public.course_grade_items;
CREATE POLICY "Allow anon insert course_grade_items" 
  ON public.course_grade_items FOR INSERT 
  TO anon 
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anon update course_grade_items" ON public.course_grade_items;
CREATE POLICY "Allow anon update course_grade_items" 
  ON public.course_grade_items FOR UPDATE 
  TO anon 
  USING (true);

DROP POLICY IF EXISTS "Allow anon delete course_grade_items" ON public.course_grade_items;
CREATE POLICY "Allow anon delete course_grade_items" 
  ON public.course_grade_items FOR DELETE 
  TO anon 
  USING (true);

-- ============================================================================
-- TABLE 4: ATTENDANCE RECORDS
-- NEW: Store student attendance per session
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.attendance_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id TEXT NOT NULL, -- UUID or ACNHS-xxxxxxx
  course_code TEXT NOT NULL,
  semester TEXT NOT NULL,
  session_date DATE NOT NULL,
  session_type TEXT NOT NULL CHECK (session_type IN ('theory', 'clinical', 'lab', 'lecture')),
  status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
  notes TEXT,
  recorded_by TEXT, -- Admin email
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure one record per student per session
  UNIQUE (student_id, course_code, session_date, session_type)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON public.attendance_records(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_course_code ON public.attendance_records(course_code);
CREATE INDEX IF NOT EXISTS idx_attendance_semester ON public.attendance_records(semester);
CREATE INDEX IF NOT EXISTS idx_attendance_session_date ON public.attendance_records(session_date DESC);
CREATE INDEX IF NOT EXISTS idx_attendance_status ON public.attendance_records(status);

-- Enable RLS
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Allow anon read attendance_records" ON public.attendance_records;
CREATE POLICY "Allow anon read attendance_records" 
  ON public.attendance_records FOR SELECT 
  TO anon 
  USING (true);

DROP POLICY IF EXISTS "Allow anon insert attendance_records" ON public.attendance_records;
CREATE POLICY "Allow anon insert attendance_records" 
  ON public.attendance_records FOR INSERT 
  TO anon 
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anon update attendance_records" ON public.attendance_records;
CREATE POLICY "Allow anon update attendance_records" 
  ON public.attendance_records FOR UPDATE 
  TO anon 
  USING (true);

DROP POLICY IF EXISTS "Allow anon delete attendance_records" ON public.attendance_records;
CREATE POLICY "Allow anon delete attendance_records" 
  ON public.attendance_records FOR DELETE 
  TO anon 
  USING (true);

-- ============================================================================
-- TRIGGERS: Auto-update updated_at timestamps
-- ============================================================================

-- Student Groups trigger
CREATE OR REPLACE FUNCTION update_student_groups_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS student_groups_timestamp ON public.student_groups;
CREATE TRIGGER student_groups_timestamp
  BEFORE UPDATE ON public.student_groups
  FOR EACH ROW
  EXECUTE FUNCTION update_student_groups_timestamp();

-- Course Enrollments trigger
CREATE OR REPLACE FUNCTION update_course_enrollments_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS course_enrollments_timestamp ON public.course_enrollments;
CREATE TRIGGER course_enrollments_timestamp
  BEFORE UPDATE ON public.course_enrollments
  FOR EACH ROW
  EXECUTE FUNCTION update_course_enrollments_timestamp();

-- Course Grade Items trigger
CREATE OR REPLACE FUNCTION update_course_grade_items_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS course_grade_items_timestamp ON public.course_grade_items;
CREATE TRIGGER course_grade_items_timestamp
  BEFORE UPDATE ON public.course_grade_items
  FOR EACH ROW
  EXECUTE FUNCTION update_course_grade_items_timestamp();

-- Attendance Records trigger
CREATE OR REPLACE FUNCTION update_attendance_records_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS attendance_records_timestamp ON public.attendance_records;
CREATE TRIGGER attendance_records_timestamp
  BEFORE UPDATE ON public.attendance_records
  FOR EACH ROW
  EXECUTE FUNCTION update_attendance_records_timestamp();

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check all tables exist
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE columns.table_name = tables.table_name) as column_count
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('student_groups', 'course_enrollments', 'course_grade_items', 'attendance_records', 'student_grades')
ORDER BY table_name;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ ALL TABLES CREATED SUCCESSFULLY';
  RAISE NOTICE '✅ student_groups - Stores cohorts and their student lists';
  RAISE NOTICE '✅ course_enrollments - Tracks which groups are enrolled in courses';
  RAISE NOTICE '✅ course_grade_items - Individual assignment/quiz grades';
  RAISE NOTICE '✅ attendance_records - Daily attendance tracking';
  RAISE NOTICE '✅ student_grades - Final semester grades (already exists)';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Next Steps:';
  RAISE NOTICE '1. Run this SQL in Supabase SQL Editor';
  RAISE NOTICE '2. Update admin-hub.html to use Supabase instead of localStorage';
  RAISE NOTICE '3. Migrate existing localStorage data (if needed)';
  RAISE NOTICE '4. Test all grade/enrollment/attendance features';
END $$;
