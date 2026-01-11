-- CREATE EMAIL CONFIGURATION TABLE WITH SMTP SETTINGS
-- This table stores email addresses that can be used for sending emails

CREATE TABLE IF NOT EXISTS email_configuration (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  smtp_host TEXT,
  smtp_port INTEGER,
  smtp_user TEXT,
  smtp_pass TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- If table exists but missing columns, add them
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='email_configuration' AND column_name='smtp_host') THEN
    ALTER TABLE email_configuration ADD COLUMN smtp_host TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='email_configuration' AND column_name='smtp_port') THEN
    ALTER TABLE email_configuration ADD COLUMN smtp_port INTEGER;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='email_configuration' AND column_name='smtp_user') THEN
    ALTER TABLE email_configuration ADD COLUMN smtp_user TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='email_configuration' AND column_name='smtp_pass') THEN
    ALTER TABLE email_configuration ADD COLUMN smtp_pass TEXT;
  END IF;
END $$;

-- Disable RLS temporarily
ALTER TABLE email_configuration DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'email_configuration') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON email_configuration CASCADE';
    END LOOP;
END $$;

-- Re-enable RLS
ALTER TABLE email_configuration ENABLE ROW LEVEL SECURITY;

-- Create policies (allow anonymous for testing)
CREATE POLICY "anon_read_email_config" ON email_configuration
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "anon_insert_email_config" ON email_configuration
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "anon_update_email_config" ON email_configuration
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "anon_delete_email_config" ON email_configuration
  FOR DELETE
  TO anon, authenticated
  USING (true);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_email_configuration_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_email_configuration_updated_at_trigger ON email_configuration;
CREATE TRIGGER update_email_configuration_updated_at_trigger
  BEFORE UPDATE ON email_configuration
  FOR EACH ROW
  EXECUTE FUNCTION update_email_configuration_updated_at();

-- Insert default ACNHS email with SMTP settings
INSERT INTO email_configuration (id, email, display_name, smtp_host, smtp_port, smtp_user, is_active)
VALUES ('acnhs-main', 'admissions@acnhs.am', 'ACNHS Admissions', 'smtp.resend.com', 587, 'admissions@acnhs.am', true)
ON CONFLICT (email) DO UPDATE 
SET smtp_host = EXCLUDED.smtp_host,
    smtp_port = EXCLUDED.smtp_port,
    smtp_user = EXCLUDED.smtp_user;

-- Verify the table structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'email_configuration' 
ORDER BY ordinal_position;
