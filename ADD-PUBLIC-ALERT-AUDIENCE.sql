-- ==========================================
-- ADD PUBLIC (ANYONE) TARGET TYPE
-- ==========================================
-- Run this in Supabase SQL Editor to allow public alerts
-- Date: 2026-02-27

-- Step 1: Drop the old CHECK constraint on target_type
ALTER TABLE public.portal_alerts 
  DROP CONSTRAINT IF EXISTS portal_alerts_target_type_check;

-- Step 2: Add the new CHECK constraint with 'public' option
ALTER TABLE public.portal_alerts 
  ADD CONSTRAINT portal_alerts_target_type_check 
  CHECK (target_type IN ('all', 'group', 'individual', 'public'));

-- Success message
DO $$ 
BEGIN
  RAISE NOTICE '✅ Portal alerts public targeting added successfully!';
END $$;
