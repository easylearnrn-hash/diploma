-- Add 'received' status to email_history table check constraint
-- Run this SQL in Supabase SQL Editor

-- Drop the existing check constraint
ALTER TABLE email_history 
DROP CONSTRAINT IF EXISTS email_history_status_check;

-- Add new check constraint with 'received' included
ALTER TABLE email_history 
ADD CONSTRAINT email_history_status_check 
CHECK (status IN ('sent', 'failed', 'pending', 'received'));
