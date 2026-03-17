-- ADD is_flagged COLUMN TO test_questions
-- Run this in the Supabase SQL Editor for project zlvnxvrzotamhpezqedr

ALTER TABLE test_questions
  ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN NOT NULL DEFAULT FALSE;

-- Allow anon role to update the flag column (consistent with existing RLS posture)
-- If you have stricter RLS, restrict this to authenticated role only.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'test_questions'
      AND policyname = 'allow anon update is_flagged'
  ) THEN
    CREATE POLICY "allow anon update is_flagged"
      ON test_questions
      FOR UPDATE
      TO anon
      USING (true)
      WITH CHECK (true);
  END IF;
END $$;
