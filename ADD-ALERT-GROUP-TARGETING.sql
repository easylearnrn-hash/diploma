-- ==========================================
-- ADD GROUP TARGETING TO PORTAL ALERTS
-- ==========================================
-- Run this in Supabase SQL Editor to add group targeting support
-- Date: 2026-02-13

-- Step 1: Drop the old CHECK constraint on target_type
ALTER TABLE public.portal_alerts 
  DROP CONSTRAINT IF EXISTS portal_alerts_target_type_check;

-- Step 2: Add the new CHECK constraint with 'group' option
ALTER TABLE public.portal_alerts 
  ADD CONSTRAINT portal_alerts_target_type_check 
  CHECK (target_type IN ('all', 'group', 'individual'));

-- Step 3: Add target_group column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'portal_alerts' 
    AND column_name = 'target_group'
  ) THEN
    ALTER TABLE public.portal_alerts 
      ADD COLUMN target_group TEXT;
    
    COMMENT ON COLUMN public.portal_alerts.target_group IS 
      'Group identifier when target_type is "group". Options: group_a, group_b, group_c, enrolled, pending, accepted';
  END IF;
END $$;

-- Verification query
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'portal_alerts'
  AND column_name IN ('target_type', 'target_group')
ORDER BY ordinal_position;

-- Success message
DO $$ 
BEGIN
  RAISE NOTICE '✅ Portal alerts group targeting added successfully!';
  RAISE NOTICE 'Available groups: group_a, group_b, group_c, enrolled, pending, accepted';
END $$;
