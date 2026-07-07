-- ════════════════════════════════════════════════════════════════════
-- Migration: Switch export system to UUID-based identity
-- Run this ONCE in Supabase SQL Editor before using the updated Export.html
-- ════════════════════════════════════════════════════════════════════

-- ── 1. Remove UNIQUE constraint on student_name in export_sessions ───
-- The student name is now a display field only. Multiple packages can
-- share the same name (e.g. two intakes for the same student).
DO $$
DECLARE
  cname text;
BEGIN
  SELECT conname INTO cname
  FROM pg_constraint
  WHERE conrelid = 'export_sessions'::regclass
    AND contype = 'u'
    AND conname ILIKE '%student_name%'
  LIMIT 1;
  IF cname IS NOT NULL THEN
    EXECUTE 'ALTER TABLE export_sessions DROP CONSTRAINT ' || quote_ident(cname);
    RAISE NOTICE 'Dropped constraint: %', cname;
  ELSE
    RAISE NOTICE 'No student_name UNIQUE constraint found (already clean).';
  END IF;
END $$;

-- ── 2. Add export_session_id to export_session_notes ─────────────────
-- Links each note directly to a session UUID.
-- NULL is allowed so old name-based notes are not broken.
ALTER TABLE export_session_notes
  ADD COLUMN IF NOT EXISTS export_session_id uuid
    REFERENCES export_sessions(id) ON DELETE CASCADE;

-- ── 3. Remove the old UNIQUE constraint on student_key ───────────────
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'export_session_notes_student_key_unique'
  ) THEN
    ALTER TABLE export_session_notes
      DROP CONSTRAINT export_session_notes_student_key_unique;
    RAISE NOTICE 'Dropped export_session_notes_student_key_unique';
  ELSE
    RAISE NOTICE 'Constraint export_session_notes_student_key_unique not found (already clean).';
  END IF;
END $$;

-- ── 4. Add UNIQUE on export_session_id (one note per package) ────────
-- NULL values are not considered equal in PostgreSQL UNIQUE constraints,
-- so old notes with NULL export_session_id can coexist.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'export_session_notes_session_id_unique'
  ) THEN
    ALTER TABLE export_session_notes
      ADD CONSTRAINT export_session_notes_session_id_unique
      UNIQUE (export_session_id);
    RAISE NOTICE 'Added export_session_notes_session_id_unique';
  ELSE
    RAISE NOTICE 'Constraint export_session_notes_session_id_unique already exists.';
  END IF;
END $$;

-- ── 5. Make student_name / student_key nullable ───────────────────────
-- New notes no longer set these columns; old notes keep their values.
ALTER TABLE export_session_notes
  ALTER COLUMN student_name DROP NOT NULL;

ALTER TABLE export_session_notes
  ALTER COLUMN student_key  DROP NOT NULL;

-- ── 6. Indexes ────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_export_session_notes_session_id
  ON export_session_notes(export_session_id);

-- ── 7. Ensure RLS is still correct ───────────────────────────────────
ALTER TABLE export_session_notes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "export_session_notes_anon_all" ON export_session_notes;
CREATE POLICY "export_session_notes_anon_all"
  ON export_session_notes FOR ALL TO anon
  USING (true) WITH CHECK (true);
GRANT SELECT, INSERT, UPDATE, DELETE ON export_session_notes TO anon;

-- ── 8. Ensure export_sessions has no student_name NOT NULL ────────────
ALTER TABLE export_sessions
  ALTER COLUMN student_name DROP NOT NULL;

-- ── Done ──────────────────────────────────────────────────────────────
-- After running this migration:
--   • student_name in export_sessions is a label, not an identity key
--   • Storage folders are:  export_sessions/{UUID}/filename.ext
--   • Notes are linked by:  export_session_notes.export_session_id
--   • Old name-based notes remain in the table with NULL export_session_id
--     (they won't appear in the UI until re-created through the updated page)
