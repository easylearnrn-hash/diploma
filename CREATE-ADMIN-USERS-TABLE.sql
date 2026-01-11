-- ====================================================================
-- MIGRATION: Add new columns if table already exists
-- Run this first if you already have an admin_users table
-- ====================================================================
DO $$ 
BEGIN
  -- Add title column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='admin_users' AND column_name='title') THEN
    ALTER TABLE admin_users ADD COLUMN title TEXT;
    UPDATE admin_users SET title = 'Team Member' WHERE title IS NULL;
    ALTER TABLE admin_users ALTER COLUMN title SET NOT NULL;
  END IF;

  -- Add phone_ext column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='admin_users' AND column_name='phone_ext') THEN
    ALTER TABLE admin_users ADD COLUMN phone_ext TEXT;
    UPDATE admin_users SET phone_ext = '100' WHERE phone_ext IS NULL;
    ALTER TABLE admin_users ALTER COLUMN phone_ext SET NOT NULL;
  END IF;

  -- Add email column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='admin_users' AND column_name='email') THEN
    ALTER TABLE admin_users ADD COLUMN email TEXT;
    UPDATE admin_users SET email = username || '@acnhs.am' WHERE email IS NULL;
    ALTER TABLE admin_users ALTER COLUMN email SET NOT NULL;
  END IF;

  -- Add signature column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='admin_users' AND column_name='signature') THEN
    ALTER TABLE admin_users ADD COLUMN signature TEXT;
    -- Generate signatures for existing users
    UPDATE admin_users 
    SET signature = name || E'\n' || 
                   COALESCE(title, 'Team Member') || E'\n' ||
                   'Armenian College of Nursing & Health Sciences' || E'\n\n' ||
                   '📞 +374 93 798879 ext. ' || COALESCE(phone_ext, '100') || E'\n' ||
                   '📧 ' || COALESCE(email, username || '@acnhs.am') || E'\n' ||
                   '🌐 www.acnhs.am'
    WHERE signature IS NULL;
    ALTER TABLE admin_users ALTER COLUMN signature SET NOT NULL;
  END IF;
END $$;

-- ====================================================================
-- CREATE TABLE: Only runs if table doesn't exist
-- ====================================================================
-- Create admin_users table for employee management
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL,
  title TEXT NOT NULL,
  phone_ext TEXT NOT NULL,
  email TEXT NOT NULL,
  signature TEXT NOT NULL,
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

-- Create index on email
CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);

-- Enable RLS
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON admin_users;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON admin_users;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON admin_users;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON admin_users;

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

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_admin_users_timestamp ON admin_users;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_admin_users_timestamp
  BEFORE UPDATE ON admin_users
  FOR EACH ROW
  EXECUTE FUNCTION update_admin_users_updated_at();
