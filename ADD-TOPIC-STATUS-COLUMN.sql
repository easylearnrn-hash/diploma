-- ============================================
-- ADD STATUS COLUMN TO test_topics
-- ============================================
-- Makes Draft/Published explicit for professional UI badges

-- Add status column with CHECK constraint
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='test_topics' AND column_name='status') THEN
    ALTER TABLE test_topics 
    ADD COLUMN status TEXT CHECK (status IN ('draft','published')) DEFAULT 'draft';
  END IF;
END $$;

-- Set all existing topics to 'published' if they're active
UPDATE test_topics 
SET status = CASE 
  WHEN is_active = true THEN 'published'
  ELSE 'draft'
END
WHERE status IS NULL OR status = 'draft';

-- Create index for faster filtering
CREATE INDEX IF NOT EXISTS idx_test_topics_status ON test_topics(status);

-- Update RLS policy to only show published topics to students
DROP POLICY IF EXISTS "Anyone can view active topics" ON test_topics;
DROP POLICY IF EXISTS "Anyone can view published topics" ON test_topics;

CREATE POLICY "Anyone can view published topics"
  ON test_topics FOR SELECT
  USING (status = 'published');

-- Verification
SELECT 
  status,
  COUNT(*) as topic_count
FROM test_topics
GROUP BY status;
