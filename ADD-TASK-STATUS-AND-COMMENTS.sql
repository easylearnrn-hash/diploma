-- Add status and comments to user_tasks table
-- Run this in Supabase SQL Editor

-- Add status column (replaces the simple completed boolean with more states)
ALTER TABLE user_tasks 
ADD COLUMN IF NOT EXISTS status TEXT CHECK (status IN ('pending', 'in_progress', 'more_info_needed', 'completed')) DEFAULT 'pending';

-- Add comment column for "More Info Needed" feedback
ALTER TABLE user_tasks 
ADD COLUMN IF NOT EXISTS user_comment TEXT;

-- Add comment timestamp
ALTER TABLE user_tasks 
ADD COLUMN IF NOT EXISTS comment_updated_at TIMESTAMPTZ;

-- Add admin reply column
ALTER TABLE user_tasks 
ADD COLUMN IF NOT EXISTS admin_reply TEXT;

-- Add admin reply timestamp
ALTER TABLE user_tasks 
ADD COLUMN IF NOT EXISTS admin_reply_at TIMESTAMPTZ;

-- Update existing tasks to use new status field
-- If completed = true, set status to 'completed', otherwise 'pending'
UPDATE user_tasks 
SET status = CASE 
  WHEN completed = true THEN 'completed'
  ELSE 'pending'
END
WHERE status IS NULL;

-- Optional: You can keep the completed boolean for backward compatibility
-- or remove it if you want to use only the status field
