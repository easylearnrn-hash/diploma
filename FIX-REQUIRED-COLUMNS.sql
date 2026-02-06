-- =====================================================
-- FIX REQUIRED COLUMNS - Set NOT NULL Constraints
-- =====================================================
-- update_type and reason should be required fields
-- =====================================================

-- Set update_type as NOT NULL (it's a required field)
DO $$ 
BEGIN
  -- First, update any existing NULL values to a default
  UPDATE profile_update_requests 
  SET update_type = 'other' 
  WHERE update_type IS NULL;
  
  -- Then set NOT NULL constraint
  ALTER TABLE profile_update_requests 
  ALTER COLUMN update_type SET NOT NULL;
  
  RAISE NOTICE 'update_type set to NOT NULL';
END $$;

-- Set reason as NOT NULL (it's a required field)
DO $$ 
BEGIN
  -- First, update any existing NULL values to a default
  UPDATE profile_update_requests 
  SET reason = 'No reason provided' 
  WHERE reason IS NULL;
  
  -- Then set NOT NULL constraint
  ALTER TABLE profile_update_requests 
  ALTER COLUMN reason SET NOT NULL;
  
  RAISE NOTICE 'reason set to NOT NULL';
END $$;

-- Verify the changes
SELECT 
  column_name, 
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'profile_update_requests'
AND column_name IN ('update_type', 'reason', 'description', 'form_data', 'urgency')
ORDER BY column_name;

-- =====================================================
-- EXPECTED RESULT:
-- update_type  | text  | NO  | null
-- reason       | text  | NO  | null
-- description  | text  | NO  | null
-- =====================================================
