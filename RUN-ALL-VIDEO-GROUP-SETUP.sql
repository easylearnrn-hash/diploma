-- ============================================================================
-- COMPLETE VIDEO LIBRARY GROUP ACCESS SETUP
-- Run this entire file in Supabase SQL Editor
-- https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql
-- ============================================================================

-- ============================================================================
-- STEP 1: Add group_name column to students table
-- ============================================================================

ALTER TABLE public.students 
ADD COLUMN IF NOT EXISTS group_name TEXT;

CREATE INDEX IF NOT EXISTS idx_students_group_name 
ON public.students(group_name);

-- ============================================================================
-- STEP 2: Add group_access column to video_library and update RLS
-- ============================================================================

-- Add the column
ALTER TABLE public.video_library 
ADD COLUMN IF NOT EXISTS group_access TEXT[] DEFAULT NULL;

-- Drop existing RLS policies
DROP POLICY IF EXISTS "Students can view published videos" ON public.video_library;
DROP POLICY IF EXISTS "Students can view published videos (anon)" ON public.video_library;

-- Create NEW RLS policy - videos must have groups assigned (mandatory)
CREATE POLICY "Students can view published videos (anon)"
    ON public.video_library
    FOR SELECT
    USING (
        is_published = true
        AND group_access IS NOT NULL 
        AND group_access != '{}'
    );

-- Admin full access
DROP POLICY IF EXISTS "Admins can manage videos" ON public.video_library;
CREATE POLICY "Admins can manage videos"
    ON public.video_library
    FOR ALL
    USING (true);

-- ============================================================================
-- STEP 3: Create initial student groups
-- ============================================================================

INSERT INTO student_groups (id, name, semester, student_ids)
VALUES 
  ('2024-2025', '2024-2025', 'Academic Year 2024-2025', ARRAY[]::TEXT[]),
  ('2025-2026', '2025-2026', 'Academic Year 2025-2026', ARRAY[]::TEXT[]),
  ('2026-2027', '2026-2027', 'Academic Year 2026-2027', ARRAY[]::TEXT[]),
  ('RN-Track', 'RN Track', 'All Years', ARRAY[]::TEXT[]),
  ('LPN-Track', 'LPN Track', 'All Years', ARRAY[]::TEXT[]),
  ('BSN-101', 'BSN 101', 'All Years', ARRAY[]::TEXT[])
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check students.group_name column exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'students' 
AND column_name = 'group_name';

-- Check video_library.group_access column exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'video_library' 
AND column_name = 'group_access';

-- Check student groups created
SELECT id, name, semester 
FROM student_groups 
ORDER BY name;

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'video_library';

-- ============================================================================
-- SUCCESS! You can now:
-- 1. Refresh admin-video-library.html (Cmd+Shift+R)
-- 2. Click "Add Video"
-- 3. See 6 group checkboxes
-- 4. Select groups (mandatory - at least 1 required)
-- 5. Save and see group count in table
-- ============================================================================
