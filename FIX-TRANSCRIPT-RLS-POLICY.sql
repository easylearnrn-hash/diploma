-- ==========================================
-- FIX TRANSCRIPT TABLE RLS POLICY
-- Allows anonymous inserts for student portal
-- Safe version - drops ALL existing policies first
-- ==========================================

-- Drop ALL existing policies first (safe - won't error if they don't exist)
DROP POLICY IF EXISTS "Allow authenticated insert" ON public.transcripts;
DROP POLICY IF EXISTS "Allow authenticated select" ON public.transcripts;
DROP POLICY IF EXISTS "Allow authenticated update" ON public.transcripts;
DROP POLICY IF EXISTS "Allow anonymous insert transcripts" ON public.transcripts;
DROP POLICY IF EXISTS "Allow anonymous select transcripts" ON public.transcripts;
DROP POLICY IF EXISTS "Allow anonymous update transcripts" ON public.transcripts;
DROP POLICY IF EXISTS "Allow authenticated insert transcripts" ON public.transcripts;
DROP POLICY IF EXISTS "Allow authenticated select transcripts" ON public.transcripts;
DROP POLICY IF EXISTS "Allow authenticated update transcripts" ON public.transcripts;

-- Create permissive policies for student portal (anonymous users)
CREATE POLICY "Allow anonymous insert transcripts"
ON public.transcripts
FOR INSERT
TO anon
WITH CHECK (true);

CREATE POLICY "Allow anonymous select transcripts"
ON public.transcripts
FOR SELECT
TO anon
USING (true);

CREATE POLICY "Allow anonymous update transcripts"
ON public.transcripts
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

-- Also allow authenticated users
CREATE POLICY "Allow authenticated insert transcripts"
ON public.transcripts
FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow authenticated select transcripts"
ON public.transcripts
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow authenticated update transcripts"
ON public.transcripts
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Transcript RLS policies updated successfully!';
END $$;
