-- Shared internal notes for Export.html (Document Package Builder)
-- Run this once in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS export_session_notes (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  student_name text        NOT NULL,
  student_key  text        NOT NULL,
  note_text    text        NOT NULL,
  author_email text,
  author_name  text,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- Backward-compatible columns for older table versions
ALTER TABLE export_session_notes
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- Ensure student_key is populated for existing records
UPDATE export_session_notes
SET student_key = lower(regexp_replace(trim(student_name), '\\s+', ' ', 'g'))
WHERE student_key IS NULL OR btrim(student_key) = '';

-- Keep one row per student key (latest wins)
DELETE FROM export_session_notes t
USING (
  SELECT id FROM (
    SELECT
      id,
      row_number() OVER (
        PARTITION BY student_key
        ORDER BY coalesce(updated_at, created_at) DESC, created_at DESC, id DESC
      ) AS rn
    FROM export_session_notes
  ) ranked
  WHERE rn > 1
) dupes
WHERE t.id = dupes.id;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'export_session_notes_student_key_unique'
  ) THEN
    ALTER TABLE export_session_notes
      ADD CONSTRAINT export_session_notes_student_key_unique UNIQUE (student_key);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_export_session_notes_student_key
  ON export_session_notes(student_key);

CREATE INDEX IF NOT EXISTS idx_export_session_notes_updated_at_desc
  ON export_session_notes(updated_at DESC);

-- Allow anonymous reads and writes (same pattern as this project's admin pages)
ALTER TABLE export_session_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "export_session_notes_anon_all" ON export_session_notes;

CREATE POLICY "export_session_notes_anon_all"
  ON export_session_notes FOR ALL TO anon
  USING (true) WITH CHECK (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON export_session_notes TO anon;