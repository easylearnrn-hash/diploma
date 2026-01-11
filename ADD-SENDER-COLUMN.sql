-- Add sender column to email_history table
-- This allows tracking who sent the email

ALTER TABLE email_history 
ADD COLUMN IF NOT EXISTS sender TEXT;

-- Add index for better performance when filtering by sender
CREATE INDEX IF NOT EXISTS idx_email_history_sender ON email_history(sender);

-- Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'email_history';
