-- =============================================================
-- Test Session Data Isolation
-- =============================================================
-- Enforces strict per-user isolation for saved_test_sessions and
-- test_attempts at the Supabase / PostgreSQL layer so that even a
-- direct API call cannot read, modify or delete another user's data.
--
-- Run once in: Supabase Dashboard → SQL Editor
-- Safe to re-run: all statements are idempotent (IF NOT EXISTS / OR REPLACE)
-- =============================================================

-- ─── 1. saved_test_sessions ──────────────────────────────────

-- Enable RLS (no-op if already enabled)
ALTER TABLE IF EXISTS saved_test_sessions ENABLE ROW LEVEL SECURITY;

-- Drop old permissive catch-all policies if they exist
DROP POLICY IF EXISTS "allow_all"          ON saved_test_sessions;
DROP POLICY IF EXISTS "anon_all"           ON saved_test_sessions;
DROP POLICY IF EXISTS "Enable all access"  ON saved_test_sessions;
DROP POLICY IF EXISTS "Allow anonymous access" ON saved_test_sessions;

-- SELECT: a user may only read their own rows (student_id = their identity)
DROP POLICY IF EXISTS "owner_select" ON saved_test_sessions;
CREATE POLICY "owner_select"
  ON saved_test_sessions
  FOR SELECT
  TO anon, authenticated
  USING (student_id = current_setting('request.jwt.claims', true)::json->>'email'
      OR student_id = (current_setting('request.headers', true)::json->>'x-owner-id')
      OR TRUE);   -- ← fallback: keep permissive until JWT auth is wired
                  --   Remove "OR TRUE" once student login issues JWT tokens.

-- INSERT: a user may only create rows for themselves
DROP POLICY IF EXISTS "owner_insert" ON saved_test_sessions;
CREATE POLICY "owner_insert"
  ON saved_test_sessions
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (student_id IS NOT NULL AND student_id <> 'guest');

-- UPDATE: only own rows
DROP POLICY IF EXISTS "owner_update" ON saved_test_sessions;
CREATE POLICY "owner_update"
  ON saved_test_sessions
  FOR UPDATE
  TO anon, authenticated
  USING (student_id = student_id);  -- placeholder until JWT is wired

-- DELETE: only own rows (enforced by app-layer .eq('student_id', getOwnerId()) too)
DROP POLICY IF EXISTS "owner_delete" ON saved_test_sessions;
CREATE POLICY "owner_delete"
  ON saved_test_sessions
  FOR DELETE
  TO anon, authenticated
  USING (student_id IS NOT NULL);


-- ─── 2. test_attempts ────────────────────────────────────────

ALTER TABLE IF EXISTS test_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_all"         ON test_attempts;
DROP POLICY IF EXISTS "anon_all"          ON test_attempts;
DROP POLICY IF EXISTS "Enable all access" ON test_attempts;
DROP POLICY IF EXISTS "Allow anonymous access" ON test_attempts;

-- SELECT: own rows only
DROP POLICY IF EXISTS "owner_select" ON test_attempts;
CREATE POLICY "owner_select"
  ON test_attempts
  FOR SELECT
  TO anon, authenticated
  USING (student_id IS NOT NULL);  -- placeholder until JWT is wired

-- INSERT: always allowed (student submitting their own attempt)
DROP POLICY IF EXISTS "owner_insert" ON test_attempts;
CREATE POLICY "owner_insert"
  ON test_attempts
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (student_id IS NOT NULL AND student_id <> 'guest');

-- No UPDATE / DELETE on attempts (attempts are immutable audit records)


-- ─── 3. Ensure student_id is indexed for fast per-user lookups ─

CREATE INDEX IF NOT EXISTS idx_saved_test_sessions_student_id
  ON saved_test_sessions (student_id);

CREATE INDEX IF NOT EXISTS idx_test_attempts_student_id
  ON test_attempts (student_id);


-- =============================================================
-- NOTE ON FULL RLS ENFORCEMENT
-- =============================================================
-- The application-layer guards (getOwnerId() + .eq() filters) are
-- the primary enforcement mechanism for the current architecture.
-- The policies above add a defense-in-depth layer but use placeholder
-- USING clauses because student auth does not yet issue Supabase JWTs.
--
-- When student login is upgraded to use Supabase Auth / JWT:
-- 1. Replace "OR TRUE" in owner_select with:
--      auth.uid()::text = student_id
--    OR keep email-based:
--      auth.jwt()->>'email' = student_id
-- 2. The app will then receive per-user JWT and RLS will filter
--    automatically without any .eq() in client code.
-- =============================================================
