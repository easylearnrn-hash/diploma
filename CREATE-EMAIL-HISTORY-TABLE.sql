-- Create email_history table for Email System
-- Run this in Supabase SQL Editor

-- Drop table if exists (to recreate with correct policies)
DROP TABLE IF EXISTS email_history CASCADE;

-- Create email_history table
CREATE TABLE email_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  recipient TEXT NOT NULL,
  subject TEXT NOT NULL,
  body TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('sent', 'failed', 'pending')),
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resend_id TEXT,
  error TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better performance
CREATE INDEX idx_email_history_recipient ON email_history(recipient);
CREATE INDEX idx_email_history_status ON email_history(status);
CREATE INDEX idx_email_history_sent_at ON email_history(sent_at DESC);

-- Enable Row Level Security
ALTER TABLE email_history ENABLE ROW LEVEL SECURITY;

-- Create policy to allow anyone to read email history (for admin panel)
CREATE POLICY "Allow public to read email history"
  ON email_history
  FOR SELECT
  TO public
  USING (true);

-- Create policy to allow anyone to insert email history
CREATE POLICY "Allow public to insert email history"
  ON email_history
  FOR INSERT
  TO public
  WITH CHECK (true);

-- Create policy to allow anyone to update email history
CREATE POLICY "Allow public to update email history"
  ON email_history
  FOR UPDATE
  TO public
  USING (true);

-- Grant permissions
GRANT ALL ON email_history TO anon;
GRANT ALL ON email_history TO authenticated;
GRANT ALL ON email_history TO service_role;

-- Verify table creation
SELECT 'Email history table created successfully!' AS message;
SELECT * FROM email_history LIMIT 1;
