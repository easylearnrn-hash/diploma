-- =====================================================
-- VIDEO LIBRARY TABLE - SAFE IDEMPOTENT VERSION
-- =====================================================
-- This version checks if table/trigger/functions exist before creating
-- Safe to run multiple times without errors

-- =====================================================
-- TABLE STRUCTURE
-- =====================================================

-- Only create table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'video_library') THEN
        CREATE TABLE public.video_library (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            drive_url TEXT NOT NULL,
            embed_url TEXT NOT NULL,
            is_published BOOLEAN DEFAULT false,
            created_at TIMESTAMPTZ DEFAULT now(),
            updated_at TIMESTAMPTZ DEFAULT now(),
            created_by TEXT,
            view_count INTEGER DEFAULT 0,
            duration TEXT,
            thumbnail_url TEXT
        );
        
        COMMENT ON TABLE public.video_library IS 'Educational videos from Google Drive for student access';
    END IF;
END $$;

-- =====================================================
-- INDEXES (create only if they don't exist)
-- =====================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_video_library_category') THEN
        CREATE INDEX idx_video_library_category ON public.video_library(category);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_video_library_published') THEN
        CREATE INDEX idx_video_library_published ON public.video_library(is_published);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_video_library_created_at') THEN
        CREATE INDEX idx_video_library_created_at ON public.video_library(created_at DESC);
    END IF;
END $$;

-- =====================================================
-- TRIGGER (auto-update updated_at)
-- =====================================================

-- Drop trigger if exists, then recreate (ensures latest version)
DROP TRIGGER IF EXISTS video_library_updated_at ON public.video_library;

CREATE TRIGGER video_library_updated_at
    BEFORE UPDATE ON public.video_library
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- RLS POLICIES
-- =====================================================

-- Enable RLS
ALTER TABLE public.video_library ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Students can view published videos" ON public.video_library;
DROP POLICY IF EXISTS "Admin can view all videos" ON public.video_library;
DROP POLICY IF EXISTS "Admin can insert videos" ON public.video_library;
DROP POLICY IF EXISTS "Admin can update videos" ON public.video_library;
DROP POLICY IF EXISTS "Admin can delete videos" ON public.video_library;

-- Recreate policies
CREATE POLICY "Students can view published videos"
    ON public.video_library
    FOR SELECT
    USING (is_published = true);

CREATE POLICY "Admin can view all videos"
    ON public.video_library
    FOR SELECT
    USING (true);

CREATE POLICY "Admin can insert videos"
    ON public.video_library
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Admin can update videos"
    ON public.video_library
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Admin can delete videos"
    ON public.video_library
    FOR DELETE
    USING (true);

-- =====================================================
-- HELPER FUNCTIONS (idempotent with CREATE OR REPLACE)
-- =====================================================

CREATE OR REPLACE FUNCTION extract_drive_file_id(url TEXT)
RETURNS TEXT AS $$
DECLARE
    file_id TEXT;
BEGIN
    -- Extract FILE_ID from various Google Drive URL formats
    -- Format 1: https://drive.google.com/file/d/FILE_ID/view
    file_id := substring(url from 'drive\.google\.com/file/d/([^/]+)');
    
    -- Format 2: https://drive.google.com/open?id=FILE_ID
    IF file_id IS NULL THEN
        file_id := substring(url from 'id=([^&]+)');
    END IF;
    
    -- Format 3: Already just the FILE_ID
    IF file_id IS NULL AND length(url) BETWEEN 20 AND 50 AND url NOT LIKE '%/%' THEN
        file_id := url;
    END IF;
    
    RETURN file_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_drive_embed_url(drive_url TEXT)
RETURNS TEXT AS $$
DECLARE
    file_id TEXT;
BEGIN
    file_id := extract_drive_file_id(drive_url);
    
    IF file_id IS NULL THEN
        RAISE EXCEPTION 'Invalid Google Drive URL format';
    END IF;
    
    RETURN 'https://drive.google.com/file/d/' || file_id || '/preview';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Check table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'video_library'
ORDER BY ordinal_position;

-- Test helper functions
SELECT 
    'https://drive.google.com/file/d/1ABC123XYZ/view' as original_url,
    extract_drive_file_id('https://drive.google.com/file/d/1ABC123XYZ/view') as file_id,
    generate_drive_embed_url('https://drive.google.com/file/d/1ABC123XYZ/view') as embed_url;

-- Check policies
SELECT schemaname, tablename, policyname, permissive, roles, qual, with_check
FROM pg_policies
WHERE tablename = 'video_library'
ORDER BY policyname;

-- Count existing videos
SELECT 
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE is_published = true) as published,
    COUNT(*) FILTER (WHERE is_published = false) as drafts
FROM video_library;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Video Library table is ready!';
    RAISE NOTICE '📹 You can now use admin-video-library.html to add videos';
    RAISE NOTICE '🔗 Paste Google Drive links and they will auto-convert to embed URLs';
END $$;
