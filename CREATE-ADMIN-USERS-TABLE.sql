-- Create admin_users table for employee management
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  permissions JSONB DEFAULT '{}'::jsonb,
  email_permissions TEXT[] DEFAULT ARRAY[]::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

-- Create index on username for faster lookups
CREATE INDEX IF NOT EXISTS idx_admin_users_username ON admin_users(username);

-- Create index on status
CREATE INDEX IF NOT EXISTS idx_admin_users_status ON admin_users(status);

-- Enable RLS
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Create policies for admin_users table
-- Only authenticated users can read
CREATE POLICY "Enable read access for authenticated users" ON admin_users
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Only authenticated users can insert
CREATE POLICY "Enable insert for authenticated users" ON admin_users
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Only authenticated users can update
CREATE POLICY "Enable update for authenticated users" ON admin_users
  FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Only authenticated users can delete
CREATE POLICY "Enable delete for authenticated users" ON admin_users
  FOR DELETE
  USING (auth.role() = 'authenticated');

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_admin_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_admin_users_timestamp
  BEFORE UPDATE ON admin_users
  FOR EACH ROW
  EXECUTE FUNCTION update_admin_users_updated_at();
