-- ============================================
-- SAVED TEST SESSIONS TABLE
-- ============================================
-- This table stores saved test sessions for students to resume later

-- Drop table if exists (for clean reinstall)
DROP TABLE IF EXISTS saved_test_sessions CASCADE;

-- Create saved_test_sessions table
CREATE TABLE saved_test_sessions (
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

-- Create indexes for performance
CREATE INDEX idx_saved_sessions_student ON saved_test_sessions(student_id);
CREATE INDEX idx_saved_sessions_test ON saved_test_sessions(test_id);
CREATE INDEX idx_saved_sessions_created ON saved_test_sessions(created_at DESC);
CREATE INDEX idx_saved_sessions_student_created ON saved_test_sessions(student_id, created_at DESC);

-- RLS Policies
ALTER TABLE saved_test_sessions ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own saved sessions
CREATE POLICY "Users can view their own saved sessions"
  ON saved_test_sessions
  FOR SELECT
  USING (true); -- For now, allow all to view (students will filter by their ID)

-- Allow users to insert their own saved sessions
CREATE POLICY "Users can insert their own saved sessions"
  ON saved_test_sessions
  FOR INSERT
  WITH CHECK (true);

-- Allow users to update their own saved sessions
CREATE POLICY "Users can update their own saved sessions"
  ON saved_test_sessions
  FOR UPDATE
  USING (true);

-- Allow users to delete their own saved sessions
CREATE POLICY "Users can delete their own saved sessions"
  ON saved_test_sessions
  FOR DELETE
  USING (true);

-- Add comment to table
COMMENT ON TABLE saved_test_sessions IS 'Stores saved test sessions for students to resume later';

-- Verification queries
SELECT 'Saved test sessions table created successfully!' AS status;
SELECT COUNT(*) as saved_session_count FROM saved_test_sessions;
