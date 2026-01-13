-- ACNHS Grade Calculator - Database Migration
-- Creates student_grades table for end-of-semester grade calculation system
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard

-- ============================================================================
-- CRITICAL: This table implements HARD GRADING GATES with NO ROUNDING
-- Used by: admin/GradeCalculator.html
-- ============================================================================

-- Drop existing table if recreating (CAUTION: Only in development!)
-- DROP TABLE IF EXISTS public.student_grades_calculator CASCADE;

CREATE TABLE IF NOT EXISTS public.student_grades_calculator (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Student & Course identification
  student_id TEXT NOT NULL, -- ACNHS-xxxxxxx format or UUID
  course_id TEXT NOT NULL, -- Course code (e.g., MED101, NURS201)
  semester TEXT NOT NULL, -- e.g., Fall2026, Spring2027
  
  -- ========================================================================
  -- INPUT SCORES (0-100 scale, decimals allowed, NO ROUNDING)
  -- ========================================================================
  unit_exams JSONB NOT NULL DEFAULT '[]'::jsonb, -- [{name: "Exam 1", score: 82.50}, ...]
  final_exam NUMERIC(5,2), -- e.g., 84.50
  quiz_avg NUMERIC(5,2), -- Quizzes/Assignments average
  standardized_avg NUMERIC(5,2), -- Standardized/OSCE score
  
  -- Clinical status
  clinical_status TEXT CHECK (clinical_status IN ('PASS', 'FAIL')),
  
  -- Attendance tracking (for administrative gates)
  attendance_theory INTEGER DEFAULT 0, -- Unexcused theory absences
  attendance_clinical INTEGER DEFAULT 0, -- Unexcused clinical absences
  
  -- ========================================================================
  -- CALCULATED RESULTS (NO ROUNDING - deterministic)
  -- ========================================================================
  exam_avg NUMERIC(5,2), -- Average of unit_exams
  theory_final NUMERIC(5,2), -- Weighted final percentage
  letter_grade TEXT, -- A, A-, B+, B, B-, C+, C, F
  course_outcome TEXT CHECK (course_outcome IN ('PASS', 'FAIL')),
  progression_eligible BOOLEAN DEFAULT FALSE, -- Can progress to next semester?
  
  -- ========================================================================
  -- GATE RESULTS (Hard thresholds - no exceptions)
  -- ========================================================================
  gate_exam_passed BOOLEAN DEFAULT FALSE, -- Gate A: ExamAvg >= 78.00
  gate_final_passed BOOLEAN DEFAULT FALSE, -- Gate B: Final >= 75.00
  gate_clinical_passed BOOLEAN DEFAULT FALSE, -- Gate C: Clinical PASS
  gate_attendance_passed BOOLEAN DEFAULT TRUE, -- Admin: Attendance rules
  
  -- ========================================================================
  -- AUDIT TRAIL (Immutable once finalized)
  -- ========================================================================
  audit_log JSONB DEFAULT '[]'::jsonb, -- ["Gate A: Passed", "Gate B: Failed", ...]
  
  -- ========================================================================
  -- FINALIZATION (Locks record - no edits allowed)
  -- ========================================================================
  is_finalized BOOLEAN DEFAULT FALSE,
  finalized_at TIMESTAMPTZ,
  finalized_by TEXT, -- Admin email/ID who finalized
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure one grade record per student/course/semester
  UNIQUE (student_id, course_id, semester)
);

-- ============================================================================
-- INDEXES for performance
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_student_grades_calc_student ON student_grades_calculator(student_id);
CREATE INDEX IF NOT EXISTS idx_student_grades_calc_course ON student_grades_calculator(course_id);
CREATE INDEX IF NOT EXISTS idx_student_grades_calc_semester ON student_grades_calculator(semester);
CREATE INDEX IF NOT EXISTS idx_student_grades_calc_finalized ON student_grades_calculator(is_finalized);
CREATE INDEX IF NOT EXISTS idx_student_grades_calc_outcome ON student_grades_calculator(course_outcome);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================
ALTER TABLE student_grades_calculator ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous read (for testing - LOCK DOWN IN PRODUCTION)
DROP POLICY IF EXISTS "Allow anon read student_grades_calculator" ON student_grades_calculator;
CREATE POLICY "Allow anon read student_grades_calculator"
  ON student_grades_calculator
  FOR SELECT
  TO anon
  USING (true);

-- Policy: Allow anonymous insert (for testing - LOCK DOWN IN PRODUCTION)
DROP POLICY IF EXISTS "Allow anon insert student_grades_calculator" ON student_grades_calculator;
CREATE POLICY "Allow anon insert student_grades_calculator"
  ON student_grades_calculator
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy: Allow anonymous update ONLY if NOT finalized
DROP POLICY IF EXISTS "Allow anon update student_grades_calculator" ON student_grades_calculator;
CREATE POLICY "Allow anon update student_grades_calculator"
  ON student_grades_calculator
  FOR UPDATE
  TO anon
  USING (NOT is_finalized)
  WITH CHECK (NOT is_finalized); -- CRITICAL: Cannot update finalized grades

-- Policy: Prevent deletion of finalized grades
DROP POLICY IF EXISTS "Prevent delete finalized student_grades_calculator" ON student_grades_calculator;
CREATE POLICY "Prevent delete finalized student_grades_calculator"
  ON student_grades_calculator
  FOR DELETE
  TO anon
  USING (NOT is_finalized); -- Can only delete drafts

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_student_grades_calculator_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS student_grades_calculator_timestamp ON student_grades_calculator;
CREATE TRIGGER student_grades_calculator_timestamp
  BEFORE UPDATE ON student_grades_calculator
  FOR EACH ROW
  EXECUTE FUNCTION update_student_grades_calculator_timestamp();

-- ============================================================================
-- TABLE COMMENTS (Documentation)
-- ============================================================================
COMMENT ON TABLE student_grades_calculator IS 'ACNHS Grade Calculator - End-of-semester grades with hard gate enforcement (NO ROUNDING)';
COMMENT ON COLUMN student_grades_calculator.unit_exams IS 'JSONB: [{name: "Exam 1", score: 82.50}, {name: "Exam 2", score: 78.00}, ...]';
COMMENT ON COLUMN student_grades_calculator.exam_avg IS 'Average of unit_exams (NO ROUNDING)';
COMMENT ON COLUMN student_grades_calculator.theory_final IS 'Weighted final percentage = (exams*60% + final*20% + quiz*10% + std*10%)';
COMMENT ON COLUMN student_grades_calculator.gate_exam_passed IS 'Gate A: ExamAvg >= 78.00 (default threshold)';
COMMENT ON COLUMN student_grades_calculator.gate_final_passed IS 'Gate B: Final >= 75.00 (safety gate)';
COMMENT ON COLUMN student_grades_calculator.gate_clinical_passed IS 'Gate C: Clinical status must be PASS';
COMMENT ON COLUMN student_grades_calculator.gate_attendance_passed IS 'Admin gate: Theory absences < 3 AND Clinical absences < 2';
COMMENT ON COLUMN student_grades_calculator.audit_log IS 'JSONB: ["Gate A: Passed - 82.50 >= 78.00", "Gate B: Failed - 74.00 < 75.00", ...]';
COMMENT ON COLUMN student_grades_calculator.is_finalized IS 'When TRUE, record is LOCKED and cannot be edited (only super-admin override)';
COMMENT ON COLUMN student_grades_calculator.course_outcome IS 'PASS = all gates passed + progression >= 78.00; FAIL = any gate failed';

-- ============================================================================
-- GRANT PERMISSIONS (Adjust for production)
-- ============================================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON student_grades_calculator TO anon;

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================
DO $$
BEGIN
  RAISE NOTICE '✅ student_grades_calculator table created successfully';
  RAISE NOTICE '📋 Features: Hard gates, NO ROUNDING, Audit trails, Finalization locks';
  RAISE NOTICE '⚠️  WARNING: Anonymous policies enabled for TESTING ONLY';
  RAISE NOTICE '🔒 In PRODUCTION, restrict policies to authenticated role with proper checks';
  RAISE NOTICE '';
  RAISE NOTICE '📝 Next steps:';
  RAISE NOTICE '  1. Test in admin/GradeCalculator.html';
  RAISE NOTICE '  2. Verify autosave works';
  RAISE NOTICE '  3. Test finalization lock';
  RAISE NOTICE '  4. Integrate into admin-student-page.html as Grades tab';
END $$;
