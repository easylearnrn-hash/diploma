-- ============================================================
-- COLD CALL ANALYTICS TABLES
-- Run this in Supabase SQL Editor once.
-- ============================================================

-- ── 1. Sessions table ─────────────────────────────────────────
-- One row per "End Session" click by a teacher.
CREATE TABLE IF NOT EXISTS cold_call_sessions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_email TEXT NOT NULL,
  group_name    TEXT NOT NULL,
  subject_name  TEXT,
  session_date  DATE NOT NULL DEFAULT CURRENT_DATE,
  started_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  ended_at      TIMESTAMPTZ,
  total_picks   INT NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 2. Responses table ────────────────────────────────────────
-- One row per correct/wrong button press.
CREATE TABLE IF NOT EXISTS cold_call_responses (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id     UUID NOT NULL REFERENCES cold_call_sessions(id) ON DELETE CASCADE,
  student_id     TEXT,          -- students.id (UUID stored as text for safety)
  student_name   TEXT NOT NULL,
  question_stem  TEXT,          -- first 200 chars of the question shown
  question_order INT,           -- testState question index at time of pick
  is_correct     BOOLEAN NOT NULL,
  picked_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 3. Indexes ────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_cc_responses_session
  ON cold_call_responses(session_id);

CREATE INDEX IF NOT EXISTS idx_cc_responses_student
  ON cold_call_responses(student_id);

CREATE INDEX IF NOT EXISTS idx_cc_sessions_date
  ON cold_call_sessions(session_date);

CREATE INDEX IF NOT EXISTS idx_cc_sessions_group
  ON cold_call_sessions(group_name);

-- ── 4. RLS ────────────────────────────────────────────────────
ALTER TABLE cold_call_sessions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE cold_call_responses ENABLE ROW LEVEL SECURITY;

-- Allow anon to insert (teacher uses anon key) and select
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'cold_call_sessions' AND policyname = 'anon_all_cold_call_sessions'
  ) THEN
    CREATE POLICY anon_all_cold_call_sessions
      ON cold_call_sessions FOR ALL TO anon USING (true) WITH CHECK (true);
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'cold_call_responses' AND policyname = 'anon_all_cold_call_responses'
  ) THEN
    CREATE POLICY anon_all_cold_call_responses
      ON cold_call_responses FOR ALL TO anon USING (true) WITH CHECK (true);
  END IF;
END $$;

-- ── 5. Verify ─────────────────────────────────────────────────
SELECT 'cold_call_sessions'  AS table_name, count(*) AS rows FROM cold_call_sessions
UNION ALL
SELECT 'cold_call_responses' AS table_name, count(*) AS rows FROM cold_call_responses;
