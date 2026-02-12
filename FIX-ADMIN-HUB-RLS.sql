-- Fix RLS policies for admin-hub.html to display student data
-- This allows anonymous/anon role to SELECT from students table

-- Check current policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd 
FROM pg_policies 
WHERE tablename = 'students';

-- Drop existing restrictive policies if any
DROP POLICY IF EXISTS "Enable read access for authenticated users only" ON public.students;
DROP POLICY IF EXISTS "Restrict access to students" ON public.students;

-- Grant SELECT permission to anon role
GRANT SELECT ON public.students TO anon;
GRANT SELECT ON public.students TO authenticated;

-- Create permissive SELECT policy for all users
CREATE POLICY "Public can view students" 
  ON public.students 
  FOR SELECT 
  USING (true);

-- Verify the new policy
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'students';

-- Check if there are any enrolled students
SELECT COUNT(*) as total_students,
       COUNT(*) FILTER (WHERE enrollment_status = 'active') as active_students
FROM public.students;
