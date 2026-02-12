-- ================================================================
-- VID SYSTEM - PRIVATE ADMIN NOTES TABLE
-- ================================================================
-- This SQL creates a secure table for private notes visible only
-- to hrachfilm@gmail.com via Row Level Security (RLS).
-- 
-- SECURITY FEATURES:
-- - RLS enabled to enforce access control at database level
-- - Only hrachfilm@gmail.com can SELECT/INSERT/UPDATE/DELETE
-- - Notes are linked to students via student_id
-- - Automatic timestamps for audit trail
-- 
-- USAGE:
-- 1. Copy this entire SQL block
-- 2. Go to Supabase SQL Editor: 
--    https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql
-- 3. Paste and click "Run"
-- 4. Verify success message
-- ================================================================

-- Create the admin_private_notes table
CREATE TABLE IF NOT EXISTS public.admin_private_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_email TEXT NOT NULL,
    student_id TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    
    -- Ensure one note record per admin per student
    CONSTRAINT unique_admin_student UNIQUE (admin_email, student_id),
    
    -- Foreign key to students table
    CONSTRAINT fk_student FOREIGN KEY (student_id) 
        REFERENCES public.students(student_id) 
        ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_admin_notes_admin_email 
    ON public.admin_private_notes(admin_email);

CREATE INDEX IF NOT EXISTS idx_admin_notes_student_id 
    ON public.admin_private_notes(student_id);

CREATE INDEX IF NOT EXISTS idx_admin_notes_updated 
    ON public.admin_private_notes(updated_at DESC);

-- ================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ================================================================
-- These policies ensure ONLY hrachfilm@gmail.com can access notes

-- Enable RLS on the table
ALTER TABLE public.admin_private_notes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (for re-running this script)
DROP POLICY IF EXISTS "hrachfilm_only_select" ON public.admin_private_notes;
DROP POLICY IF EXISTS "hrachfilm_only_insert" ON public.admin_private_notes;
DROP POLICY IF EXISTS "hrachfilm_only_update" ON public.admin_private_notes;
DROP POLICY IF EXISTS "hrachfilm_only_delete" ON public.admin_private_notes;

-- POLICY 1: Allow hrachfilm@gmail.com to SELECT their notes
CREATE POLICY "hrachfilm_only_select" 
    ON public.admin_private_notes
    FOR SELECT
    USING (admin_email = 'hrachfilm@gmail.com');

-- POLICY 2: Allow hrachfilm@gmail.com to INSERT notes
CREATE POLICY "hrachfilm_only_insert" 
    ON public.admin_private_notes
    FOR INSERT
    WITH CHECK (admin_email = 'hrachfilm@gmail.com');

-- POLICY 3: Allow hrachfilm@gmail.com to UPDATE their notes
CREATE POLICY "hrachfilm_only_update" 
    ON public.admin_private_notes
    FOR UPDATE
    USING (admin_email = 'hrachfilm@gmail.com')
    WITH CHECK (admin_email = 'hrachfilm@gmail.com');

-- POLICY 4: Allow hrachfilm@gmail.com to DELETE their notes
CREATE POLICY "hrachfilm_only_delete" 
    ON public.admin_private_notes
    FOR DELETE
    USING (admin_email = 'hrachfilm@gmail.com');

-- ================================================================
-- VERIFICATION QUERIES
-- ================================================================
-- Run these to verify the setup:

-- Check table structure
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'admin_private_notes';

-- Check RLS is enabled
-- SELECT tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE tablename = 'admin_private_notes';

-- Check policies
-- SELECT policyname, cmd, qual, with_check 
-- FROM pg_policies 
-- WHERE tablename = 'admin_private_notes';

-- ================================================================
-- GRANT PERMISSIONS
-- ================================================================
-- Ensure anon role can access (VID.html uses anon key)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.admin_private_notes TO anon;
GRANT USAGE ON SCHEMA public TO anon;

-- ================================================================
-- SUCCESS MESSAGE
-- ================================================================
DO $$
BEGIN
    RAISE NOTICE '✅ VID System Setup Complete!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 Table created: admin_private_notes';
    RAISE NOTICE '🔒 RLS enabled: Only hrachfilm@gmail.com can access';
    RAISE NOTICE '🔑 Policies created: SELECT, INSERT, UPDATE, DELETE';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  IMPORTANT: Keep VID.html in .gitignore!';
    RAISE NOTICE '⚠️  IMPORTANT: Never link VID.html in public UI!';
END $$;
