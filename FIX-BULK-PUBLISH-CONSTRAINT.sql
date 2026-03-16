-- Fix bulk publish: ensure the unique constraint on published_notes has a proper name
-- so Supabase upsert can target it. Also adds it if somehow missing.
--
-- Run this once in the Supabase SQL Editor.

DO $$
BEGIN
  -- Add the unique constraint if it doesn't already exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'published_notes'::regclass
      AND contype = 'u'
      AND conname = 'published_notes_note_id_student_id_key'
  ) THEN
    -- Try to add it (will fail gracefully if data has dupes — clean those first)
    ALTER TABLE published_notes
      ADD CONSTRAINT published_notes_note_id_student_id_key
      UNIQUE (note_id, student_id);
    RAISE NOTICE 'Unique constraint added.';
  ELSE
    RAISE NOTICE 'Unique constraint already exists — no changes made.';
  END IF;
END $$;

-- Optional: remove any duplicate rows that snuck in before the constraint existed
-- (keeps the earliest published_at for each pair)
DELETE FROM published_notes
WHERE id NOT IN (
  SELECT DISTINCT ON (note_id, student_id) id
  FROM published_notes
  ORDER BY note_id, student_id, published_at ASC
);
