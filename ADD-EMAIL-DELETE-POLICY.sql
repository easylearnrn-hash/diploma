-- Add DELETE policy to email_history table
-- Run this in Supabase SQL Editor

-- Create policy to allow anyone to delete email history
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'email_history'
      AND policyname = 'Allow public to delete email history'
  ) THEN
    EXECUTE 'CREATE POLICY "Allow public to delete email history"
             ON email_history
             FOR DELETE
             TO public
             USING (true);';
    RAISE NOTICE 'DELETE policy created successfully';
  ELSE
    RAISE NOTICE 'DELETE policy already exists';
  END IF;
END $$ LANGUAGE plpgsql;

-- Verify the policy was created
SELECT policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'email_history'
ORDER BY policyname;
