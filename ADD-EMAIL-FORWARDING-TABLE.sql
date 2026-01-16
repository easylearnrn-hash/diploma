-- ====================================================================
-- CREATE EMAIL FORWARDING RULES TABLE
-- Individual forwarding rules for each ACNHS email address
-- ====================================================================

-- Create email_forwarding_rules table
CREATE TABLE IF NOT EXISTS public.email_forwarding_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acnhs_email TEXT NOT NULL,
  forward_to_email TEXT, -- Allow NULL for emails not yet configured
  enabled BOOLEAN DEFAULT FALSE NOT NULL, -- Default to disabled
  created_by TEXT, -- admin user who created the rule
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT email_forwarding_rules_unique_acnhs_email UNIQUE (acnhs_email)
);

-- Add comments
COMMENT ON TABLE public.email_forwarding_rules IS 'Individual forwarding rules for each ACNHS email address';
COMMENT ON COLUMN public.email_forwarding_rules.acnhs_email IS 'The ACNHS email address to forward from (e.g., info@acnhs.am)';
COMMENT ON COLUMN public.email_forwarding_rules.forward_to_email IS 'Personal email address to forward to';
COMMENT ON COLUMN public.email_forwarding_rules.enabled IS 'Whether this forwarding rule is active';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_email_forwarding_rules_acnhs_email 
ON public.email_forwarding_rules(acnhs_email);

CREATE INDEX IF NOT EXISTS idx_email_forwarding_rules_enabled 
ON public.email_forwarding_rules(enabled) 
WHERE enabled = TRUE;

-- Enable RLS
ALTER TABLE public.email_forwarding_rules ENABLE ROW LEVEL SECURITY;

-- Create policies
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'email_forwarding_rules'
      AND policyname = 'Enable read access for all users'
  ) THEN
    CREATE POLICY "Enable read access for all users"
      ON public.email_forwarding_rules
      FOR SELECT
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'email_forwarding_rules'
      AND policyname = 'Enable insert for authenticated users'
  ) THEN
    CREATE POLICY "Enable insert for authenticated users"
      ON public.email_forwarding_rules
      FOR INSERT
      WITH CHECK (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'email_forwarding_rules'
      AND policyname = 'Enable update for authenticated users'
  ) THEN
    CREATE POLICY "Enable update for authenticated users"
      ON public.email_forwarding_rules
      FOR UPDATE
      USING (true)
      WITH CHECK (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'email_forwarding_rules'
      AND policyname = 'Enable delete for authenticated users'
  ) THEN
    CREATE POLICY "Enable delete for authenticated users"
      ON public.email_forwarding_rules
      FOR DELETE
      USING (true);
  END IF;
END $$;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Email forwarding rules table created successfully!';
  RAISE NOTICE '📧 Each ACNHS email can now have its own forwarding destination';
  RAISE NOTICE '🔧 Next step: Update email-system.html UI for per-email forwarding';
END $$;
