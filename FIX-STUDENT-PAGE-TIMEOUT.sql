-- Fix Student-page.html Timeout Issues
-- The acnhs_students query is timing out (57014 error code = statement timeout)
-- This creates indexes to speed up student profile lookups

-- Step 1: Check existing indexes on acnhs_students
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'acnhs_students'
ORDER BY indexname;

-- Step 2: Create missing indexes for fast lookups
-- Index on student_id (primary lookup field)
CREATE INDEX IF NOT EXISTS idx_acnhs_students_student_id 
ON acnhs_students(student_id);

-- Index on email (used for profile queries)
CREATE INDEX IF NOT EXISTS idx_acnhs_students_email 
ON acnhs_students(email);

-- Index on application_id (used for joins)
CREATE INDEX IF NOT EXISTS idx_acnhs_students_application_id 
ON acnhs_students(application_id);

-- Index on enrollment_status (used for filtering)
CREATE INDEX IF NOT EXISTS idx_acnhs_students_enrollment_status 
ON acnhs_students(enrollment_status);

-- Composite index for common query pattern (email + enrollment_status)
CREATE INDEX IF NOT EXISTS idx_acnhs_students_email_status 
ON acnhs_students(email, enrollment_status);

-- Step 3: Verify indexes were created
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'acnhs_students'
ORDER BY indexname;

-- Step 4: Check query performance with EXPLAIN
EXPLAIN ANALYZE
SELECT id, student_id, application_id, full_name, email, phone, 
       date_of_birth, program, start_term, enrollment_status, 
       current_gpa, total_credits_earned, academic_standing, metadata
FROM acnhs_students
WHERE email = 'h.vardan@acnhs.am'
ORDER BY created_at DESC
LIMIT 1;

-- Step 5: Verify the student record can be found quickly
SELECT 
    id,
    student_id,
    full_name,
    email,
    enrollment_status,
    metadata->'portal'->>'username' AS portal_username,
    created_at
FROM acnhs_students
WHERE email = 'h.vardan@acnhs.am'
LIMIT 1;
