-- Allow anon role to UPDATE documents (needed for "Save Changes" in documents.html)
-- Run once in: https://supabase.com/dashboard → SQL Editor

DROP POLICY IF EXISTS "Allow anon update documents" ON documents;
CREATE POLICY "Allow anon update documents"
  ON documents FOR UPDATE TO anon USING (true) WITH CHECK (true);
