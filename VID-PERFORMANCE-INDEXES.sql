-- ============================================
-- VID Performance Optimization Indexes
-- ============================================
-- Run this SQL in Supabase SQL Editor to add
-- database indexes for lightning-fast queries
-- ============================================

-- 1. Index on applications table (VID queries this table)
CREATE INDEX IF NOT EXISTS idx_applications_control_number 
ON applications(control_number);

CREATE INDEX IF NOT EXISTS idx_applications_submission_date 
ON applications(submission_date DESC);

CREATE INDEX IF NOT EXISTS idx_applications_status 
ON applications(status);

-- 2. Composite index for pagination queries on applications
CREATE INDEX IF NOT EXISTS idx_applications_submission_status 
ON applications(submission_date DESC, status);

-- 3. Index on admin_private_notes.admin_email (for notes lookup)
CREATE INDEX IF NOT EXISTS idx_admin_notes_email 
ON admin_private_notes(admin_email);

-- 4. Index on admin_private_notes.student_id (VID uses control_numbers here)
CREATE INDEX IF NOT EXISTS idx_admin_notes_student_id 
ON admin_private_notes(student_id);

-- 5. Composite index for fast notes queries (most important for filter speed)
CREATE INDEX IF NOT EXISTS idx_admin_notes_email_student 
ON admin_private_notes(admin_email, student_id);

-- 6. Index on enrollment_questionnaires.control_number
CREATE INDEX IF NOT EXISTS idx_questionnaires_control_number 
ON enrollment_questionnaires(control_number);

-- 7. Index on applicant_name for search
CREATE INDEX IF NOT EXISTS idx_applications_applicant_name 
ON applications(applicant_name);

-- 8. Index on email for search
CREATE INDEX IF NOT EXISTS idx_applications_email 
ON applications(email);

-- ============================================
-- Analyze Tables (Update Statistics)
-- ============================================
ANALYZE applications;
ANALYZE admin_private_notes;
ANALYZE enrollment_questionnaires;

-- ============================================
-- Verification Query
-- ============================================
-- Run this to verify indexes were created:

SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename IN ('applications', 'admin_private_notes', 'enrollment_questionnaires')
ORDER BY tablename, indexname;

-- ============================================
-- Expected Performance Improvements
-- ============================================
-- Before indexes:
--   - 1000 students: ~200-500ms query time
--   - 5000 students: ~1-2s query time
--
-- After indexes:
--   - 1000 students: ~10-30ms query time  (10-20x faster!)
--   - 5000 students: ~50-150ms query time (10-20x faster!)
--   - 10000+ students: Still fast with pagination
--
-- Notes lookup goes from O(n) to O(1) with indexes!
-- ============================================
