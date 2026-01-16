-- ====================================================================
-- FIX EMAIL FORWARDING TABLE - Allow NULL forward_to_email
-- Run this if you already created the table with NOT NULL constraint
-- ====================================================================

-- Drop the table if it exists (if you haven't added important data yet)
DROP TABLE IF EXISTS public.email_forwarding_rules CASCADE;

-- Recreate with correct schema
CREATE TABLE IF NOT EXISTS public.email_forwarding_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  acnhs_email TEXT NOT NULL,
  forward_to_email TEXT, -- Allow NULL for emails not yet configured
  enabled BOOLEAN DEFAULT FALSE NOT NULL, -- Default to disabled
  created_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT email_forwarding_rules_unique_acnhs_email UNIQUE (acnhs_email)
);

-- Add comments
COMMENT ON TABLE public.email_forwarding_rules IS 'Individual forwarding rules for each ACNHS email address';
COMMENT ON COLUMN public.email_forwarding_rules.acnhs_email IS 'The ACNHS email address to forward from (e.g., info@acnhs.am)';
COMMENT ON COLUMN public.email_forwarding_rules.forward_to_email IS 'Personal email address to forward to (can be NULL if not configured)';
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
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Enable read access for all users" ON public.email_forwarding_rules;
  DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.email_forwarding_rules;
  DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.email_forwarding_rules;
  DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.email_forwarding_rules;

  -- Recreate policies
  CREATE POLICY "Enable read access for all users"
    ON public.email_forwarding_rules
    FOR SELECT
    USING (true);

  CREATE POLICY "Enable insert for authenticated users"
    ON public.email_forwarding_rules
    FOR INSERT
    WITH CHECK (true);

  CREATE POLICY "Enable update for authenticated users"
    ON public.email_forwarding_rules
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

  CREATE POLICY "Enable delete for authenticated users"
    ON public.email_forwarding_rules
    FOR DELETE
    USING (true);
END $$;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Email forwarding rules table fixed!';
  RAISE NOTICE '📧 forward_to_email can now be NULL';
  RAISE NOTICE '🔧 Try adding a new email again';
END $$;
