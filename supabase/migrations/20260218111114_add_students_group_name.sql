-- Add group_name column to students table
-- This column stores which student group the student belongs to
-- (e.g., "2024-2025", "RN Track", "LPN Track")

-- Add the column if it doesn't exist
ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS group_name TEXT;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_students_group_name 
ON public.students(group_name);

-- Verify the column was added
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'students' 
AND column_name = 'group_name';

-- Show current students table structure
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'students'
ORDER BY ordinal_position;
