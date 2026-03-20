-- ============================================================
-- Add DELETE policy to certificates table
-- Run this in the Supabase SQL Editor:
-- https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql
-- ============================================================

-- Allow anon (admin browser) to delete certificates
DROP POLICY IF EXISTS "Anon delete certificates" ON public.certificates;
CREATE POLICY "Anon delete certificates"
    ON public.certificates FOR DELETE
    TO anon
    USING (true);
