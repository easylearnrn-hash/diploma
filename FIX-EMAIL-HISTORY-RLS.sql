-- Fix RLS policies for email_history table
-- Run this in Supabase SQL Editor to allow anon users to log emails

-- Drop existing policies if any
DROP POLICY IF EXISTS "Enable read access for all users" ON public.email_history;
DROP POLICY IF EXISTS "Enable insert access for all users" ON public.email_history;
DROP POLICY IF EXISTS "Enable update access for all users" ON public.email_history;
DROP POLICY IF EXISTS "Enable delete access for all users" ON public.email_history;

-- Enable RLS (if not already enabled)
ALTER TABLE public.email_history ENABLE ROW LEVEL SECURITY;

-- Create permissive policies for development
-- ⚠️ IMPORTANT: In production, restrict these to authenticated users only

-- Allow SELECT (read) for anonymous users
CREATE POLICY "Enable read access for all users"
ON public.email_history
FOR SELECT
TO anon, authenticated
USING (true);

-- Allow INSERT for anonymous users (for logging emails)
CREATE POLICY "Enable insert access for all users"
ON public.email_history
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- Allow UPDATE for anonymous users (for admin edits)
CREATE POLICY "Enable update access for all users"
ON public.email_history
FOR UPDATE
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Allow DELETE for anonymous users (for admin actions)
CREATE POLICY "Enable delete access for all users"
ON public.email_history
FOR DELETE
TO anon, authenticated
USING (true);

-- Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'email_history'
ORDER BY policyname;
