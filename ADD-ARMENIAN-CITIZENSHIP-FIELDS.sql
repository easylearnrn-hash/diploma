-- ================================================================
-- ADD ARMENIAN CITIZENSHIP AND IMMIGRATION STATUS FIELDS
-- ================================================================
-- Purpose: Add fields to track Armenian citizenship status, 
--          US immigration status, and Armenia travel/exit dates
-- 
-- Run this in Supabase SQL Editor:
-- https://supabase.com/dashboard → Project → SQL Editor
-- 
-- NOTE: These columns are OPTIONAL for direct querying.
-- The primary data is stored in the 'payload' JSONB column with keys:
--   - armenianCitizen (camelCase in payload)
--   - usImmigrationStatus
--   - lastTimeInArmenia
--   - armeniaExitDate
-- 
-- These top-level columns allow SQL queries like:
-- SELECT * FROM applications WHERE armenian_citizen = 'yes';
-- ================================================================

-- Add armenian_citizen column (YES/NO)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'applications' 
    AND column_name = 'armenian_citizen'
  ) THEN
    ALTER TABLE applications 
    ADD COLUMN armenian_citizen TEXT;
    
    RAISE NOTICE 'Added armenian_citizen column to applications table';
  ELSE
    RAISE NOTICE 'Column armenian_citizen already exists in applications table';
  END IF;
END $$;

-- Add us_immigration_status column
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'applications' 
    AND column_name = 'us_immigration_status'
  ) THEN
    ALTER TABLE applications 
    ADD COLUMN us_immigration_status TEXT;
    
    RAISE NOTICE 'Added us_immigration_status column to applications table';
  ELSE
    RAISE NOTICE 'Column us_immigration_status already exists in applications table';
  END IF;
END $$;

-- Add last_time_in_armenia column
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'applications' 
    AND column_name = 'last_time_in_armenia'
  ) THEN
    ALTER TABLE applications 
    ADD COLUMN last_time_in_armenia TEXT;
    
    RAISE NOTICE 'Added last_time_in_armenia column to applications table';
  ELSE
    RAISE NOTICE 'Column last_time_in_armenia already exists in applications table';
  END IF;
END $$;

-- Add armenia_exit_date column (exact date when applicant left Armenia)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'applications' 
    AND column_name = 'armenia_exit_date'
  ) THEN
    ALTER TABLE applications 
    ADD COLUMN armenia_exit_date TEXT;
    
    RAISE NOTICE 'Added armenia_exit_date column to applications table';
  ELSE
    RAISE NOTICE 'Column armenia_exit_date already exists in applications table';
  END IF;
END $$;

-- ================================================================
-- VERIFICATION QUERY
-- Run this to confirm all columns were added successfully:
-- ================================================================

SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'applications'
  AND column_name IN (
    'armenian_citizen',
    'us_immigration_status',
    'last_time_in_armenia',
    'armenia_exit_date'
  )
ORDER BY column_name;

-- ================================================================
-- SAMPLE TEST QUERY
-- Check if any applications have these new fields populated:
-- ================================================================

-- SELECT 
--   reference_number,
--   applicant_name,
--   armenian_citizen,
--   us_immigration_status,
--   last_time_in_armenia,
--   armenia_exit_date,
--   created_at
-- FROM applications
-- WHERE armenian_citizen IS NOT NULL
--   OR us_immigration_status IS NOT NULL
--   OR last_time_in_armenia IS NOT NULL
--   OR armenia_exit_date IS NOT NULL
-- ORDER BY created_at DESC
-- LIMIT 10;
