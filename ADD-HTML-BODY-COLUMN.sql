-- Add html_body column to store the full HTML content of emails
-- This allows us to display the original formatted email below replies

-- Check if column exists, add if it doesn't
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'email_history' 
    AND column_name = 'html_body'
  ) THEN
    ALTER TABLE email_history ADD COLUMN html_body TEXT;
    COMMENT ON COLUMN email_history.html_body IS 'Full HTML content of the email for display';
  END IF;
END $$;

-- Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'email_history' 
AND column_name IN ('body', 'html_body')
ORDER BY ordinal_position;
