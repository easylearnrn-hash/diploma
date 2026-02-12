-- DEFINITIVE FIX FOR 403 RLS ERROR
-- Run this in Supabase SQL Editor for project eyhksbiceueoiamwnqpr
-- This will allow INSERT/UPDATE/DELETE for anonymous users

-- Step 1: Temporarily disable RLS to clean up
ALTER TABLE public.admin_private_notes DISABLE ROW LEVEL SECURITY;

-- Step 2: Drop ALL existing policies (clean slate)
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'admin_private_notes') 
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON public.admin_private_notes';
    END LOOP;
END $$;

-- Step 3: Grant explicit permissions to anon and authenticated roles
GRANT ALL ON public.admin_private_notes TO anon;
GRANT ALL ON public.admin_private_notes TO authenticated;
GRANT ALL ON public.admin_private_notes TO service_role;

-- Note: No sequence exists because we use UUID primary keys (not SERIAL)

-- Step 4: Re-enable RLS
ALTER TABLE public.admin_private_notes ENABLE ROW LEVEL SECURITY;

-- Step 5: Create simple, permissive policies for ALL roles
CREATE POLICY "Public can select notes" 
  ON public.admin_private_notes 
  FOR SELECT 
  USING (true);

CREATE POLICY "Public can insert notes" 
  ON public.admin_private_notes 
  FOR INSERT 
  WITH CHECK (true);

CREATE POLICY "Public can update notes" 
  ON public.admin_private_notes 
  FOR UPDATE 
  USING (true) 
  WITH CHECK (true);

CREATE POLICY "Public can delete notes" 
  ON public.admin_private_notes 
  FOR DELETE 
  USING (true);

-- Step 6: Verify the setup
SELECT 
  'Policies:' as check_type,
  policyname, 
  cmd, 
  permissive,
  roles::text
FROM pg_policies 
WHERE tablename = 'admin_private_notes'
UNION ALL
SELECT 
  'Grants:' as check_type,
  grantee::text, 
  privilege_type, 
  'N/A'::text,
  'N/A'::text
FROM information_schema.role_table_grants 
WHERE table_name = 'admin_private_notes'
ORDER BY check_type, policyname;

-- You should see:
-- 4 policies (select, insert, update, delete) with USING (true)
-- Grants to anon, authenticated, service_role
