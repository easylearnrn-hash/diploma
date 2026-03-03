-- Allow anonymous inserts into test_questions
DROP POLICY IF EXISTS "Allow anonymous inserts into test_questions" ON test_questions;
CREATE POLICY "Allow anonymous inserts into test_questions"
  ON test_questions FOR INSERT
  WITH CHECK (true);

-- Also allow updates/deletes in case the admin tool needs it
DROP POLICY IF EXISTS "Allow anonymous updates to test_questions" ON test_questions;
CREATE POLICY "Allow anonymous updates to test_questions"
  ON test_questions FOR UPDATE
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anonymous deletes from test_questions" ON test_questions;
CREATE POLICY "Allow anonymous deletes from test_questions"
  ON test_questions FOR DELETE
  USING (true);
