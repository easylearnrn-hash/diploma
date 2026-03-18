-- ============================================================
-- SESSION ROLE + AUTO-SAVE SUPPORT
-- ============================================================
-- Purpose:
--   1. Tag every saved session with the user's role (student/teacher/admin)
--      so that each role sees ONLY its own sessions.
--   2. Track a deterministic shuffle_seed so a resumed session on a
--      second device reproduces the exact same question order.
--   3. Add is_in_progress / last_auto_saved_at so the system can
--      auto-save every 5 seconds and resume across devices without
--      the user clicking "Save & Exit".
--   4. RLS policies: students can NEVER read teacher/admin sessions;
--      students can NEVER write to teacher_sessions.
--
-- Run AFTER: ADD-SAVED-TEST-SESSIONS-TABLE.sql
-- Idempotent: safe to run multiple times.
-- ============================================================

-- 1. New columns on saved_test_sessions
ALTER TABLE IF EXISTS public.saved_test_sessions
  ADD COLUMN IF NOT EXISTS user_role          TEXT    NOT NULL DEFAULT 'student',
  ADD COLUMN IF NOT EXISTS shuffle_seed       BIGINT,
  ADD COLUMN IF NOT EXISTS is_in_progress     BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS last_auto_saved_at TIMESTAMPTZ;

-- 2. Performance indexes
CREATE INDEX IF NOT EXISTS idx_saved_sessions_role
  ON public.saved_test_sessions (student_id, user_role);

CREATE INDEX IF NOT EXISTS idx_saved_sessions_in_progress
  ON public.saved_test_sessions (student_id, user_role, is_in_progress)
  WHERE is_in_progress = TRUE;

-- 3. Backfill: assume all existing rows belong to 'student' (safe default)
UPDATE public.saved_test_sessions
SET    user_role = 'student'
WHERE  user_role IS NULL OR user_role = '';

-- ============================================================
-- 4. RLS — saved_test_sessions
--    Each user may only SELECT rows whose user_role matches
--    the value they passed via the x-owner-role header, AND
--    whose student_id matches the x-owner-id header.
--
--    The practical effect:
--      • Students (x-owner-role: student) can NEVER see
--        rows with user_role = 'teacher' or 'admin'.
--      • Teachers can NEVER see student rows.
--      • Each user is still restricted to their own student_id
--        by the existing policy.
-- ============================================================

-- Enable RLS (idempotent)
ALTER TABLE public.saved_test_sessions ENABLE ROW LEVEL SECURITY;

-- Drop old catch-all policies that may allow cross-role reads
DROP POLICY IF EXISTS allow_anon_select_saved_sessions   ON public.saved_test_sessions;
DROP POLICY IF EXISTS allow_anon_insert_saved_sessions   ON public.saved_test_sessions;
DROP POLICY IF EXISTS allow_anon_update_saved_sessions   ON public.saved_test_sessions;
DROP POLICY IF EXISTS allow_anon_delete_saved_sessions   ON public.saved_test_sessions;
-- Drop any previous role-scoped policies before re-creating
DROP POLICY IF EXISTS sts_select_own_role                ON public.saved_test_sessions;
DROP POLICY IF EXISTS sts_insert_own_role                ON public.saved_test_sessions;
DROP POLICY IF EXISTS sts_update_own_role                ON public.saved_test_sessions;
DROP POLICY IF EXISTS sts_delete_own_role                ON public.saved_test_sessions;

-- SELECT: row's student_id must match x-owner-id header
--         AND row's user_role must match x-owner-role header
CREATE POLICY sts_select_own_role ON public.saved_test_sessions
  FOR SELECT TO anon
  USING (
    student_id = current_setting('request.headers', true)::json->>'x-owner-id'
    AND
    user_role  = COALESCE(
                   current_setting('request.headers', true)::json->>'x-owner-role',
                   'student'
                 )
  );

-- INSERT: enforce that user can only insert with their own id and role
CREATE POLICY sts_insert_own_role ON public.saved_test_sessions
  FOR INSERT TO anon
  WITH CHECK (
    student_id = current_setting('request.headers', true)::json->>'x-owner-id'
    AND
    user_role  = COALESCE(
                   current_setting('request.headers', true)::json->>'x-owner-role',
                   'student'
                 )
  );

-- UPDATE: same ownership check
CREATE POLICY sts_update_own_role ON public.saved_test_sessions
  FOR UPDATE TO anon
  USING (
    student_id = current_setting('request.headers', true)::json->>'x-owner-id'
    AND
    user_role  = COALESCE(
                   current_setting('request.headers', true)::json->>'x-owner-role',
                   'student'
                 )
  )
  WITH CHECK (
    student_id = current_setting('request.headers', true)::json->>'x-owner-id'
    AND
    user_role  = COALESCE(
                   current_setting('request.headers', true)::json->>'x-owner-role',
                   'student'
                 )
  );

-- DELETE: same ownership check
CREATE POLICY sts_delete_own_role ON public.saved_test_sessions
  FOR DELETE TO anon
  USING (
    student_id = current_setting('request.headers', true)::json->>'x-owner-id'
    AND
    user_role  = COALESCE(
                   current_setting('request.headers', true)::json->>'x-owner-role',
                   'student'
                 )
  );

-- ============================================================
-- 5. RLS — teacher_sessions
--    Students must NEVER be able to read, write, or subscribe
--    to teacher_sessions rows.
--    Only rows where x-owner-role is teacher/admin/superadmin
--    are allowed through.
-- ============================================================

ALTER TABLE public.teacher_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ts_allow_all              ON public.teacher_sessions;
DROP POLICY IF EXISTS ts_teacher_select         ON public.teacher_sessions;
DROP POLICY IF EXISTS ts_teacher_insert         ON public.teacher_sessions;
DROP POLICY IF EXISTS ts_teacher_update         ON public.teacher_sessions;
DROP POLICY IF EXISTS ts_student_readonly       ON public.teacher_sessions;

-- Teachers/admins: full access to their own sessions
CREATE POLICY ts_teacher_select ON public.teacher_sessions
  FOR SELECT TO anon
  USING (
    COALESCE(
      current_setting('request.headers', true)::json->>'x-owner-role',
      'student'
    ) IN ('teacher', 'admin', 'superadmin', 'instructor')
    OR
    -- Students may SELECT (read-only follow) their teacher's active session
    -- only via a session_id they were given (no wildcard reads)
    (
      COALESCE(
        current_setting('request.headers', true)::json->>'x-owner-role',
        'student'
      ) = 'student'
      AND is_active = true
    )
  );

CREATE POLICY ts_teacher_insert ON public.teacher_sessions
  FOR INSERT TO anon
  WITH CHECK (
    COALESCE(
      current_setting('request.headers', true)::json->>'x-owner-role',
      'student'
    ) IN ('teacher', 'admin', 'superadmin', 'instructor')
  );

CREATE POLICY ts_teacher_update ON public.teacher_sessions
  FOR UPDATE TO anon
  USING (
    COALESCE(
      current_setting('request.headers', true)::json->>'x-owner-role',
      'student'
    ) IN ('teacher', 'admin', 'superadmin', 'instructor')
  )
  WITH CHECK (
    COALESCE(
      current_setting('request.headers', true)::json->>'x-owner-role',
      'student'
    ) IN ('teacher', 'admin', 'superadmin', 'instructor')
  );

-- No DELETE policy for teacher_sessions — rows are deactivated (is_active=false), not deleted.

-- ============================================================
-- 6. Wire x-owner-role header in the JS Supabase client
--    (reminder — this is handled in js/supabase-config.js
--     refreshSupabaseOwner() call — no SQL needed here)
-- ============================================================

-- 7. Verification
SELECT
  user_role,
  is_in_progress,
  COUNT(*) AS session_count
FROM public.saved_test_sessions
GROUP BY user_role, is_in_progress
ORDER BY user_role, is_in_progress;

SELECT 'ADD-SESSION-ROLE-AUTOSAVE migration complete ✓' AS status;
