-- Add plain_password column to applications table for admin viewing
-- This stores the password in plain text so admins can view and reset student credentials

-- Add the column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'applications' 
        AND column_name = 'plain_password'
    ) THEN
        ALTER TABLE public.applications 
        ADD COLUMN plain_password TEXT;
        
        RAISE NOTICE 'Column plain_password added to applications table';
    ELSE
        RAISE NOTICE 'Column plain_password already exists in applications table';
    END IF;
END $$;

-- Update existing records to set plain_password = 'NeedReset' for records with password_hash but no plain_password
UPDATE public.applications
SET plain_password = 'NeedReset'
WHERE password_hash IS NOT NULL 
  AND (plain_password IS NULL OR plain_password = '');

-- Verification query
SELECT 
    COUNT(*) as total_records,
    COUNT(password_hash) as has_password_hash,
    COUNT(plain_password) as has_plain_password,
    COUNT(CASE WHEN password_hash IS NOT NULL AND plain_password IS NULL THEN 1 END) as needs_password
FROM public.applications;
