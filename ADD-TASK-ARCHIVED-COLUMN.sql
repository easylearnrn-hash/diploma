-- Add archived column to user_tasks table
-- Run this in Supabase SQL Editor

ALTER TABLE user_tasks 
ADD COLUMN IF NOT EXISTS archived BOOLEAN DEFAULT FALSE;

-- Create index for faster queries on archived tasks
CREATE INDEX IF NOT EXISTS idx_user_tasks_archived ON user_tasks(archived);

-- Comment for documentation
COMMENT ON COLUMN user_tasks.archived IS 'Whether the task has been archived by admin after completion';
