-- Fix RLS policies for applications table
-- Run this in Supabase SQL Editor to allow anon users to read applications

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable read access for all users" ON public.applications;
DROP POLICY IF EXISTS "Enable insert access for all users" ON public.applications;
DROP POLICY IF EXISTS "Enable update access for all users" ON public.applications;
DROP POLICY IF EXISTS "Enable delete access for all users" ON public.applications;

-- Enable RLS (if not already enabled)
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;

-- Create permissive policies for development
-- ⚠️ IMPORTANT: In production, restrict these to authenticated users only

-- Allow SELECT (read) for anonymous users
CREATE POLICY "Enable read access for all users"
ON public.applications
FOR SELECT
TO anon, authenticated
USING (true);

-- Allow INSERT for anonymous users (for admission form submissions)
CREATE POLICY "Enable insert access for all users"
ON public.applications
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- Allow UPDATE for anonymous users (for admin edits)
CREATE POLICY "Enable update access for all users"
ON public.applications
FOR UPDATE
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Allow DELETE for anonymous users (for admin actions)
CREATE POLICY "Enable delete access for all users"
ON public.applications
FOR DELETE
TO anon, authenticated
USING (true);

-- Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'applications'
ORDER BY policyname;
