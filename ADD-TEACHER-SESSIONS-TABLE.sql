-- =====================================================
-- TEACHER SESSIONS TABLE FOR TWO-LAPTOP SYNC
-- =====================================================
-- Purpose: Enable real-time synchronization between teacher and student laptops
-- Usage: Teacher creates session, student joins with session ID
-- Realtime: Enabled for instant state updates across devices
-- =====================================================

-- Create teacher_sessions table
CREATE TABLE IF NOT EXISTS public.teacher_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id TEXT UNIQUE NOT NULL,
  test_id TEXT NOT NULL,
  question_order JSONB NOT NULL DEFAULT '[]'::jsonb,
  current_index INTEGER NOT NULL DEFAULT 0,
  teacher_email TEXT,
  teacher_name TEXT,
  test_config JSONB DEFAULT '{}'::jsonb,
  total_questions INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_heartbeat TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for fast session lookups
CREATE INDEX IF NOT EXISTS idx_teacher_sessions_session_id 
  ON public.teacher_sessions(session_id);

CREATE INDEX IF NOT EXISTS idx_teacher_sessions_active 
  ON public.teacher_sessions(is_active, last_heartbeat);

-- Enable Row Level Security
ALTER TABLE public.teacher_sessions ENABLE ROW LEVEL SECURITY;

-- Allow anonymous users to read active sessions (for student view)
CREATE POLICY "Allow anonymous read active sessions"
  ON public.teacher_sessions
  FOR SELECT
  TO anon
  USING (is_active = true);

-- Allow anonymous users to insert sessions (for teacher creation)
CREATE POLICY "Allow anonymous create sessions"
  ON public.teacher_sessions
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Allow anonymous users to update sessions (for teacher navigation)
CREATE POLICY "Allow anonymous update sessions"
  ON public.teacher_sessions
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- Allow anonymous users to delete old sessions
CREATE POLICY "Allow anonymous delete sessions"
  ON public.teacher_sessions
  FOR DELETE
  TO anon
  USING (true);

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_teacher_session_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update timestamp on every change
DROP TRIGGER IF EXISTS trigger_update_teacher_session_timestamp ON public.teacher_sessions;
CREATE TRIGGER trigger_update_teacher_session_timestamp
  BEFORE UPDATE ON public.teacher_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_teacher_session_timestamp();

-- =====================================================
-- ENABLE REALTIME FOR INSTANT SYNC
-- =====================================================
-- This allows Supabase Realtime to broadcast changes
ALTER PUBLICATION supabase_realtime ADD TABLE public.teacher_sessions;

-- =====================================================
-- CLEANUP FUNCTION FOR INACTIVE SESSIONS
-- =====================================================
-- Delete sessions older than 24 hours or inactive for 1 hour
CREATE OR REPLACE FUNCTION cleanup_old_teacher_sessions()
RETURNS void AS $$
BEGIN
  DELETE FROM public.teacher_sessions
  WHERE created_at < NOW() - INTERVAL '24 hours'
     OR (is_active = false AND updated_at < NOW() - INTERVAL '1 hour')
     OR last_heartbeat < NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================
-- Run these to verify setup:
-- SELECT * FROM public.teacher_sessions;
-- SELECT COUNT(*) FROM public.teacher_sessions WHERE is_active = true;

COMMENT ON TABLE public.teacher_sessions IS 'Real-time session state for teacher/student laptop synchronization';
COMMENT ON COLUMN public.teacher_sessions.session_id IS 'Unique session identifier shared between teacher and student devices';
COMMENT ON COLUMN public.teacher_sessions.question_order IS 'Array of question IDs in shuffled order to ensure both devices show same sequence';
COMMENT ON COLUMN public.teacher_sessions.current_index IS 'Current question index (0-based) - broadcast to all connected devices';
COMMENT ON COLUMN public.teacher_sessions.last_heartbeat IS 'Last activity timestamp for cleanup of abandoned sessions';
