-- Create user_activity_log table to track all user actions
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS user_activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES admin_users(id) ON DELETE CASCADE,
  user_email TEXT NOT NULL,
  user_name TEXT NOT NULL,
  action_type TEXT NOT NULL, -- 'create', 'update', 'delete', 'view', 'send', 'export', etc.
  action_category TEXT NOT NULL, -- 'application', 'student', 'email', 'user', 'document', etc.
  action_description TEXT NOT NULL, -- Human-readable description
  target_type TEXT, -- 'application', 'student', 'email', 'user', etc.
  target_id TEXT, -- ID of the affected record
  target_name TEXT, -- Name/identifier of the target
  old_value JSONB, -- Previous state (for updates)
  new_value JSONB, -- New state (for updates/creates)
  ip_address TEXT,
  user_agent TEXT,
  session_id TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
  metadata JSONB DEFAULT '{}'::jsonb -- Additional context data
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_activity_user_id ON user_activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_user_email ON user_activity_log(user_email);
CREATE INDEX IF NOT EXISTS idx_activity_created_at ON user_activity_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activity_action_type ON user_activity_log(action_type);
CREATE INDEX IF NOT EXISTS idx_activity_action_category ON user_activity_log(action_category);
CREATE INDEX IF NOT EXISTS idx_activity_target_id ON user_activity_log(target_id);

-- Add RLS policies
ALTER TABLE user_activity_log ENABLE ROW LEVEL SECURITY;

-- Allow anonymous users to insert (for logging from frontend)
CREATE POLICY "Allow insert for authenticated users" ON user_activity_log
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Allow anonymous users to read their own logs or admins to read all
CREATE POLICY "Allow read for users" ON user_activity_log
  FOR SELECT
  TO anon
  USING (true);

-- Comment on table
COMMENT ON TABLE user_activity_log IS 'Comprehensive activity log for all user actions in the admin system';
COMMENT ON COLUMN user_activity_log.action_type IS 'Type of action: create, update, delete, view, send, export, login, logout';
COMMENT ON COLUMN user_activity_log.action_category IS 'Category: application, student, email, user, document, system';
COMMENT ON COLUMN user_activity_log.old_value IS 'JSON snapshot of data before change (for updates/deletes)';
COMMENT ON COLUMN user_activity_log.new_value IS 'JSON snapshot of data after change (for creates/updates)';
