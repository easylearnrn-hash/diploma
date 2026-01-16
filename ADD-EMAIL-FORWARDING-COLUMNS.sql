-- ====================================================================
-- ADD EMAIL FORWARDING COLUMNS TO ADMIN_USERS
-- Run this in Supabase SQL Editor to enable email auto-forwarding
-- ====================================================================

DO $$ 
BEGIN
  -- Add forward_enabled column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='admin_users' AND column_name='forward_enabled') THEN
    ALTER TABLE admin_users ADD COLUMN forward_enabled BOOLEAN DEFAULT FALSE NOT NULL;
    COMMENT ON COLUMN admin_users.forward_enabled IS 'Whether to automatically forward emails to another address';
  END IF;

  -- Add forward_to_email column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='admin_users' AND column_name='forward_to_email') THEN
    ALTER TABLE admin_users ADD COLUMN forward_to_email TEXT;
    COMMENT ON COLUMN admin_users.forward_to_email IS 'Email address to forward incoming emails to';
  END IF;

  -- Add constraint to ensure forward_to_email is set when forward_enabled is true
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'admin_users_forward_email_required'
  ) THEN
    ALTER TABLE admin_users 
    ADD CONSTRAINT admin_users_forward_email_required 
    CHECK (
      (forward_enabled = FALSE) OR 
      (forward_enabled = TRUE AND forward_to_email IS NOT NULL AND forward_to_email != '')
    );
  END IF;
END $$;

-- Create index for faster lookups of users with forwarding enabled
CREATE INDEX IF NOT EXISTS idx_admin_users_forward_enabled 
ON admin_users(forward_enabled) 
WHERE forward_enabled = TRUE;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Email forwarding columns added successfully!';
  RAISE NOTICE '📧 Users can now enable auto-forwarding of incoming emails';
  RAISE NOTICE '🔧 Next step: Update email-system.html UI with forwarding toggle';
END $$;
