-- =====================================================
-- ADD MISSING COLUMNS TO profile_update_requests
-- =====================================================
-- Run this if you're getting "column does not exist" errors
-- This adds the new columns to an existing table
-- =====================================================

-- Add update_type column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profile_update_requests' 
    AND column_name = 'update_type'
  ) THEN
    ALTER TABLE profile_update_requests 
    ADD COLUMN update_type TEXT;
    
    -- Add constraint
    ALTER TABLE profile_update_requests 
    ADD CONSTRAINT profile_update_requests_update_type_check 
    CHECK (update_type IN (
      'name_change', 'name_correction', 'contact_info', 'emergency_contact',
      'address', 'citizenship', 'date_of_birth', 'other'
    ));
  END IF;
END $$;

-- Add urgency column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profile_update_requests' 
    AND column_name = 'urgency'
  ) THEN
    ALTER TABLE profile_update_requests 
    ADD COLUMN urgency TEXT DEFAULT 'standard';
    
    -- Add constraint
    ALTER TABLE profile_update_requests 
    ADD CONSTRAINT profile_update_requests_urgency_check 
    CHECK (urgency IN ('standard', 'urgent', 'critical'));
  END IF;
END $$;

-- Add reason column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profile_update_requests' 
    AND column_name = 'reason'
  ) THEN
    ALTER TABLE profile_update_requests 
    ADD COLUMN reason TEXT;
  END IF;
END $$;

-- Add form_data column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profile_update_requests' 
    AND column_name = 'form_data'
  ) THEN
    ALTER TABLE profile_update_requests 
    ADD COLUMN form_data JSONB DEFAULT '{}'::jsonb;
  END IF;
END $$;

-- Add supporting_documents_files column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profile_update_requests' 
    AND column_name = 'supporting_documents_files'
  ) THEN
    ALTER TABLE profile_update_requests 
    ADD COLUMN supporting_documents_files TEXT[];
  END IF;
END $$;

-- Update status constraint to include new statuses
DO $$
BEGIN
  -- Drop old constraint if exists
  ALTER TABLE profile_update_requests 
  DROP CONSTRAINT IF EXISTS profile_update_requests_status_check;
  
  -- Add new constraint
  ALTER TABLE profile_update_requests 
  ADD CONSTRAINT profile_update_requests_status_check 
  CHECK (status IN ('pending', 'in_review', 'approved', 'rejected', 'completed'));
END $$;

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_profile_update_requests_update_type 
  ON profile_update_requests(update_type);

CREATE INDEX IF NOT EXISTS idx_profile_update_requests_urgency 
  ON profile_update_requests(urgency);

CREATE INDEX IF NOT EXISTS idx_profile_update_requests_form_data 
  ON profile_update_requests USING gin(form_data);

-- Verify columns exist
SELECT 
  column_name, 
  data_type, 
  column_default,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'profile_update_requests'
ORDER BY ordinal_position;
