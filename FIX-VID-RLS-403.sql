-- FIX 403 RLS ERROR FOR admin_private_notes
-- Run this in Supabase SQL Editor to allow anonymous INSERT/UPDATE/DELETE

-- First, disable RLS temporarily to clean up
ALTER TABLE public.admin_private_notes DISABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies
DROP POLICY IF EXISTS "Allow anon select" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Allow anon insert" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Allow anon update" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Allow anon delete" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Enable insert access for all users" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Enable update access for all users" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Enable delete access for all users" ON public.admin_private_notes;

-- Grant explicit table permissions to anon role
GRANT ALL ON public.admin_private_notes TO anon;
GRANT USAGE ON SEQUENCE admin_private_notes_id_seq TO anon;

-- Re-enable RLS
ALTER TABLE public.admin_private_notes ENABLE ROW LEVEL SECURITY;

-- Create PERMISSIVE policies (default, less restrictive)
CREATE POLICY "Allow all select" 
  ON public.admin_private_notes 
  FOR SELECT 
  TO public
  USING (true);

CREATE POLICY "Allow all insert" 
  ON public.admin_private_notes 
  FOR INSERT 
  TO public
  WITH CHECK (true);

CREATE POLICY "Allow all update" 
  ON public.admin_private_notes 
  FOR UPDATE 
  TO public
  USING (true) 
  WITH CHECK (true);

CREATE POLICY "Allow all delete" 
  ON public.admin_private_notes 
  FOR DELETE 
  TO public
  USING (true);

-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'admin_private_notes';

-- Verify table permissions
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_name = 'admin_private_notes';
