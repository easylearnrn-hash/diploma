-- =====================================================
-- VIDEO LIBRARY TABLE FOR ACNHS
-- Stores Google Drive video links for student access
-- =====================================================

-- Create video_library table
CREATE TABLE IF NOT EXISTS public.video_library (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT, -- e.g., 'Fundamentals', 'Med-Surg', 'Pharmacology', 'Clinical Skills'
    drive_url TEXT NOT NULL, -- Original Google Drive link admin pastes
    embed_url TEXT NOT NULL, -- Converted preview iframe link
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    created_by TEXT, -- Admin email who created it
    view_count INTEGER DEFAULT 0, -- Track how many times viewed
    duration TEXT, -- Optional: video length (e.g., "15:30")
    thumbnail_url TEXT -- Optional: custom thumbnail URL
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_video_library_category ON public.video_library(category);
CREATE INDEX IF NOT EXISTS idx_video_library_published ON public.video_library(is_published);
CREATE INDEX IF NOT EXISTS idx_video_library_created_at ON public.video_library(created_at DESC);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_video_library_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER video_library_updated_at
    BEFORE UPDATE ON public.video_library
    FOR EACH ROW
    EXECUTE FUNCTION update_video_library_updated_at();

-- =====================================================
-- RLS POLICIES
-- =====================================================

-- Enable RLS
ALTER TABLE public.video_library ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Students can view published videos" ON public.video_library;
DROP POLICY IF EXISTS "Admin can view all videos" ON public.video_library;
DROP POLICY IF EXISTS "Admin can insert videos" ON public.video_library;
DROP POLICY IF EXISTS "Admin can update videos" ON public.video_library;
DROP POLICY IF EXISTS "Admin can delete videos" ON public.video_library;
DROP POLICY IF EXISTS "Public can view published videos" ON public.video_library;

-- Students: Read published videos only
CREATE POLICY "Students can view published videos"
    ON public.video_library
    FOR SELECT
    USING (is_published = true);

-- Admin: Full control (for now using anon key - replace with auth in production)
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
-- HELPER FUNCTION: Convert Drive URL to Embed URL
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
-- SAMPLE DATA (for testing)
-- =====================================================

-- Uncomment to insert sample videos:
/*
INSERT INTO public.video_library (title, description, category, drive_url, embed_url, is_published, created_by) VALUES
('Fundamentals: Vital Signs Assessment', 'Learn proper techniques for measuring blood pressure, temperature, pulse, and respirations', 'Fundamentals', 'https://drive.google.com/file/d/1ABC123XYZ/view', 'https://drive.google.com/file/d/1ABC123XYZ/preview', true, 'admin@acnhs.am'),
('Pharmacology: Medication Administration', 'Safe medication administration procedures and the 5 Rights of medication safety', 'Pharmacology', 'https://drive.google.com/file/d/2DEF456ABC/view', 'https://drive.google.com/file/d/2DEF456ABC/preview', true, 'admin@acnhs.am'),
('Clinical Skills: IV Insertion', 'Step-by-step demonstration of peripheral IV catheter insertion', 'Clinical Skills', 'https://drive.google.com/file/d/3GHI789DEF/view', 'https://drive.google.com/file/d/3GHI789DEF/preview', false, 'admin@acnhs.am');
*/

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'video_library' 
ORDER BY ordinal_position;

-- Test the helper functions
SELECT 
    'https://drive.google.com/file/d/1ABC123XYZ/view' AS original_url,
    extract_drive_file_id('https://drive.google.com/file/d/1ABC123XYZ/view') AS file_id,
    generate_drive_embed_url('https://drive.google.com/file/d/1ABC123XYZ/view') AS embed_url;

-- Count videos
SELECT 
    category,
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE is_published) as published
FROM public.video_library 
GROUP BY category;

COMMENT ON TABLE public.video_library IS 'Stores Google Drive video links for ACNHS student video library with RLS security';
