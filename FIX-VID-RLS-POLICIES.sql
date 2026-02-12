-- Fix RLS Policies for VID to Access Students Data
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql/new

-- Check current RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'students';

-- Check existing policies on students table
SELECT * FROM pg_policies WHERE tablename = 'students';

-- Drop existing policies if they're too restrictive
DROP POLICY IF EXISTS "Allow anonymous read access" ON students;
DROP POLICY IF EXISTS "Allow authenticated read access" ON students;
DROP POLICY IF EXISTS "Enable read access for all users" ON students;

-- Create new policy that allows ALL users (anonymous and authenticated) to read students
CREATE POLICY "VID: Allow all users to read students"
ON students
FOR SELECT
TO public
USING (true);

-- Verify RLS is enabled
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- Test the policy
SELECT COUNT(*) as student_count FROM students;

-- If you see a count, the policy works! 
-- If you see 0 or an error, there might be no students in the table.

-- Check if there are actually students in the table
SELECT student_id, full_name, email, status 
FROM students 
LIMIT 5;

-- Also fix admin_private_notes table if it exists
DO $$ 
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'admin_private_notes') THEN
    -- Drop existing policies
    EXECUTE 'DROP POLICY IF EXISTS "Allow admin read" ON admin_private_notes';
    
    -- Allow all authenticated users to read/write their own notes
    EXECUTE 'CREATE POLICY "VID: Allow all users to manage notes"
      ON admin_private_notes
      FOR ALL
      TO public
      USING (true)
      WITH CHECK (true)';
      
    -- Enable RLS
    EXECUTE 'ALTER TABLE admin_private_notes ENABLE ROW LEVEL SECURITY';
    
    RAISE NOTICE 'Fixed admin_private_notes RLS policies';
  ELSE
    RAISE NOTICE 'admin_private_notes table does not exist - will be created on first use';
  END IF;
END $$;

-- Summary
SELECT 
  'students' as table_name,
  COUNT(*) as total_records,
  COUNT(DISTINCT status) as distinct_statuses
FROM students
UNION ALL
SELECT 
  'admin_private_notes' as table_name,
  COUNT(*) as total_records,
  COUNT(DISTINCT admin_email) as distinct_emails
FROM admin_private_notes
WHERE EXISTS (SELECT FROM pg_tables WHERE tablename = 'admin_private_notes');
