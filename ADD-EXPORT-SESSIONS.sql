-- Export Sessions table for Document Package Builder (Export.html)
-- Run this once in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS export_sessions (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  student_name text        NOT NULL UNIQUE,
  left_armenia text,
  entered_us   text,
  files_data   jsonb       NOT NULL DEFAULT '{}',
  saved_at     timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- Allow anonymous reads and writes (same pattern as the rest of this project)
ALTER TABLE export_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "export_sessions_anon_all"
  ON export_sessions FOR ALL TO anon
  USING (true) WITH CHECK (true);
