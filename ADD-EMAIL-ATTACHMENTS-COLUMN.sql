-- Add attachments column to email_history table for storing metadata about inbound/outbound files
-- Run in Supabase SQL editor before deploying code that references this column

DO $$
BEGIN
  -- Add JSONB column if it does not exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'email_history' AND column_name = 'attachments'
  ) THEN
    ALTER TABLE email_history
      ADD COLUMN attachments JSONB;
    COMMENT ON COLUMN email_history.attachments IS 'Array of attachment metadata (filename, type, size, storage path, public URL)';
  END IF;
END $$;

-- Optional helper index for querying emails that contain attachments
CREATE INDEX IF NOT EXISTS idx_email_history_attachments_exists
ON email_history ((attachments IS NOT NULL));
