-- Create table for tracking which notes are published to which students
CREATE TABLE IF NOT EXISTS published_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  note_id TEXT NOT NULL,
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  published_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(note_id, student_id)
);

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_published_notes_student ON published_notes(student_id);
CREATE INDEX IF NOT EXISTS idx_published_notes_note ON published_notes(note_id);

-- Enable RLS
ALTER TABLE published_notes ENABLE ROW LEVEL SECURITY;

-- Allow anonymous to read (students checking their access)
CREATE POLICY "Allow anonymous to read published notes"
  ON published_notes FOR SELECT
  TO anon
  USING (true);

-- Allow anonymous to insert/update/delete (for admin operations)
CREATE POLICY "Allow anonymous to manage published notes"
  ON published_notes FOR ALL
  TO anon
  USING (true);

COMMENT ON TABLE published_notes IS 'Tracks which course notes are published/available to which students';
COMMENT ON COLUMN published_notes.note_id IS 'ID of the note (matches note file identifier)';
COMMENT ON COLUMN published_notes.student_id IS 'Foreign key to students table';
COMMENT ON COLUMN published_notes.published_by IS 'Email of admin who published the note';
