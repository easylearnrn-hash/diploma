-- =====================================================
-- ADD GROUP ACCESS CONTROL TO VIDEO LIBRARY
-- =====================================================
-- Adds ability to restrict videos to specific student groups

-- Add group_access column (stores array of group names)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'video_library' 
        AND column_name = 'group_access'
    ) THEN
        ALTER TABLE public.video_library 
        ADD COLUMN group_access TEXT[] DEFAULT NULL;
        
        COMMENT ON COLUMN public.video_library.group_access IS 
        'Array of student group names that can access this video. NULL = all groups can access';
    END IF;
END $$;

-- Update RLS policy for students to check group access
DROP POLICY IF EXISTS "Students can view published videos" ON public.video_library;

CREATE POLICY "Students can view published videos"
    ON public.video_library
    FOR SELECT
    USING (
        is_published = true AND (
            group_access IS NULL OR 
            group_access = '{}' OR
            EXISTS (
                SELECT 1 FROM students 
                WHERE students.id = auth.uid()::uuid 
                AND students.group_name = ANY(video_library.group_access)
            )
        )
    );

-- For testing with anon key (remove in production with proper auth)
DROP POLICY IF EXISTS "Students can view published videos (anon)" ON public.video_library;

CREATE POLICY "Students can view published videos (anon)"
    ON public.video_library
    FOR SELECT
    USING (
        is_published = true
        AND group_access IS NOT NULL 
        AND group_access != '{}'
    );

-- Verification: Check the new column
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'video_library' 
AND column_name = 'group_access';

-- Example: Set video to be accessible to specific groups (MANDATORY)
-- UPDATE video_library 
-- SET group_access = ARRAY['2024-2025', '2025-2026'] 
-- WHERE id = 'your-video-id';

-- NOTE: If group_access is NULL or empty array, NO ONE can see the video
-- At least one group must be selected for the video to be visible

-- Check current group access settings
SELECT 
    id,
    title,
    category,
    group_access,
    is_published
FROM video_library
ORDER BY created_at DESC;
