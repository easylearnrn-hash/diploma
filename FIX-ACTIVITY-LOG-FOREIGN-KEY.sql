-- Fix user_activity_log foreign key constraint issue
-- The system uses email-based auth, not the admin_users table
-- So user_id should be nullable and not have foreign key constraint

-- Drop the foreign key constraint
ALTER TABLE user_activity_log 
  DROP CONSTRAINT IF EXISTS user_activity_log_user_id_fkey;

-- Make user_id nullable (it already is, but this ensures it)
ALTER TABLE user_activity_log 
  ALTER COLUMN user_id DROP NOT NULL;

-- Add comment explaining the change
COMMENT ON COLUMN user_activity_log.user_id IS 'Optional UUID - nullable since system uses email-based auth instead of admin_users table';

-- Verification: Check the constraint is removed
SELECT 
  conname AS constraint_name,
  contype AS constraint_type
FROM pg_constraint
WHERE conrelid = 'user_activity_log'::regclass
  AND conname LIKE '%user_id%';
