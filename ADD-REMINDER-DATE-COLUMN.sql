-- Add reminder_date column to registrations table
-- Run this in Supabase SQL Editor

-- Add the reminder_date column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'registrations'
          AND column_name = 'reminder_date'
    ) THEN
        ALTER TABLE public.registrations
        ADD COLUMN reminder_date DATE;
    END IF;
END$$;

-- Create index for faster reminder queries
CREATE INDEX IF NOT EXISTS idx_registrations_reminder ON public.registrations(reminder_date);

-- Verify the column was added
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'registrations'
ORDER BY ordinal_position;
