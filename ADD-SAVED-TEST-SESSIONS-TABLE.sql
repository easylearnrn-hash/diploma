-- ============================================
-- SAVED TEST SESSIONS TABLE
-- ============================================
-- This table stores saved test sessions for students to resume later

-- Create saved_test_sessions table (idempotent)
CREATE TABLE IF NOT EXISTS saved_test_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_name TEXT NOT NULL,
  student_id TEXT NOT NULL,
  test_id TEXT NOT NULL,
  
  -- Test State Data
  session_id TEXT NOT NULL,
  current_question_index INTEGER NOT NULL DEFAULT 0,
  answers JSONB NOT NULL DEFAULT '{}'::jsonb,
  answer_status JSONB NOT NULL DEFAULT '{}'::jsonb,
  flagged_questions JSONB NOT NULL DEFAULT '[]'::jsonb,
  questions JSONB NOT NULL,
  test_config JSONB NOT NULL,

  -- Optional bilingual snapshots for perfect resume parity
  session_snapshot_en JSONB,
  session_snapshot_hy JSONB,
  
  -- Timing
  start_time TIMESTAMPTZ NOT NULL,
  saved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Metadata
  total_questions INTEGER NOT NULL,
  answered_questions INTEGER NOT NULL DEFAULT 0,
  progress_percent INTEGER NOT NULL DEFAULT 0,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ensure snapshot columns exist for older deployments
ALTER TABLE IF EXISTS saved_test_sessions
  ADD COLUMN IF NOT EXISTS session_snapshot_en JSONB,
  ADD COLUMN IF NOT EXISTS session_snapshot_hy JSONB;

-- Create indexes for performance (idempotent)
CREATE INDEX IF NOT EXISTS idx_saved_sessions_student ON saved_test_sessions(student_id);
CREATE INDEX IF NOT EXISTS idx_saved_sessions_test ON saved_test_sessions(test_id);
CREATE INDEX IF NOT EXISTS idx_saved_sessions_created ON saved_test_sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_saved_sessions_student_created ON saved_test_sessions(student_id, created_at DESC);

-- RLS Policies
ALTER TABLE saved_test_sessions ENABLE ROW LEVEL SECURITY;

-- Drop permissive policies if they exist
DROP POLICY IF EXISTS "Users can view their own saved sessions" ON saved_test_sessions;
DROP POLICY IF EXISTS "Users can insert their own saved sessions" ON saved_test_sessions;
DROP POLICY IF EXISTS "Users can update their own saved sessions" ON saved_test_sessions;
DROP POLICY IF EXISTS "Users can delete their own saved sessions" ON saved_test_sessions;
DROP POLICY IF EXISTS "allow_all"          ON saved_test_sessions;
DROP POLICY IF EXISTS "anon_all"           ON saved_test_sessions;
DROP POLICY IF EXISTS "Enable all access"  ON saved_test_sessions;
DROP POLICY IF EXISTS "Allow anonymous access" ON saved_test_sessions;
DROP POLICY IF EXISTS "owner_select" ON saved_test_sessions;
DROP POLICY IF EXISTS "owner_insert" ON saved_test_sessions;
DROP POLICY IF EXISTS "owner_update" ON saved_test_sessions;
DROP POLICY IF EXISTS "owner_delete" ON saved_test_sessions;

-- Strict per-user isolation (matches ADD-TEST-SESSION-RLS-ISOLATION.sql)
CREATE POLICY "owner_select"
  ON saved_test_sessions
  FOR SELECT
  TO anon, authenticated
  USING (
    student_id = COALESCE(
      auth.jwt()::json->>'email',
      current_setting('request.headers', true)::json->>'x-owner-id'
    )
  );

CREATE POLICY "owner_insert"
  ON saved_test_sessions
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (
    student_id IS NOT NULL
    AND student_id <> 'guest'
    AND student_id = COALESCE(
      auth.jwt()::json->>'email',
      current_setting('request.headers', true)::json->>'x-owner-id'
    )
  );

CREATE POLICY "owner_update"
  ON saved_test_sessions
  FOR UPDATE
  TO anon, authenticated
  USING (
    student_id = COALESCE(
      auth.jwt()::json->>'email',
      current_setting('request.headers', true)::json->>'x-owner-id'
    )
  );

CREATE POLICY "owner_delete"
  ON saved_test_sessions
  FOR DELETE
  TO anon, authenticated
  USING (
    student_id = COALESCE(
      auth.jwt()::json->>'email',
      current_setting('request.headers', true)::json->>'x-owner-id'
    )
  );

-- Add comment to table
COMMENT ON TABLE saved_test_sessions IS 'Stores saved test sessions for students to resume later';

-- Verification queries
SELECT 'Saved test sessions table created successfully!' AS status;
SELECT COUNT(*) as saved_session_count FROM saved_test_sessions;
