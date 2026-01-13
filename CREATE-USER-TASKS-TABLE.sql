-- Create user_tasks table for admin task assignments
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS user_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  assigned_to TEXT NOT NULL, -- Email of user assigned to
  assigned_by TEXT, -- Email of admin who assigned
  priority TEXT CHECK (priority IN ('low', 'medium', 'high')),
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  due_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE user_tasks ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own tasks
CREATE POLICY "Users can view their own tasks"
  ON user_tasks
  FOR SELECT
  USING (assigned_to = current_setting('request.jwt.claims', true)::json->>'email');

-- Policy: Users can update their own tasks (mark complete/incomplete)
CREATE POLICY "Users can update their own tasks"
  ON user_tasks
  FOR UPDATE
  USING (assigned_to = current_setting('request.jwt.claims', true)::json->>'email')
  WITH CHECK (assigned_to = current_setting('request.jwt.claims', true)::json->>'email');

-- Policy: Admins can insert tasks (temporary - allow anon for testing)
CREATE POLICY "Allow task creation"
  ON user_tasks
  FOR INSERT
  WITH CHECK (true);

-- Policy: Allow reading all tasks (temporary for testing)
CREATE POLICY "Allow reading tasks"
  ON user_tasks
  FOR SELECT
  USING (true);

-- Policy: Allow updating tasks (temporary for testing)
CREATE POLICY "Allow updating tasks"
  ON user_tasks
  FOR UPDATE
  USING (true);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_tasks_assigned_to ON user_tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_user_tasks_completed ON user_tasks(completed);

-- Insert sample tasks for testing (replace email with actual user email)
INSERT INTO user_tasks (title, description, assigned_to, assigned_by, priority) VALUES
  ('Review new applications', 'Check and process the latest student applications', 's.gharibyan@acnhs.am', 'admin@acnhs.am', 'high'),
  ('Update student records', 'Ensure all student information is up to date in the system', 's.gharibyan@acnhs.am', 'admin@acnhs.am', 'medium'),
  ('Prepare verification codes', 'Generate QR codes for this month''s transcripts', 's.gharibyan@acnhs.am', 'admin@acnhs.am', 'low');

COMMENT ON TABLE user_tasks IS 'Task assignments for admin users';
