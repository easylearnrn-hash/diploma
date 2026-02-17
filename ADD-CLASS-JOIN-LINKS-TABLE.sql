-- ============================================
-- CLASS JOIN LINKS TABLE
-- Purpose: 1-hour expiring links for students to join live classes
-- Created: 2026-02-17
-- ============================================

-- Drop existing table if needed (for clean reinstall)
DROP TABLE IF EXISTS class_join_links CASCADE;

-- Create class_join_links table
CREATE TABLE IF NOT EXISTS class_join_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  url TEXT NOT NULL,
  group_id TEXT NOT NULL, -- Required: 'all', 'Group A', 'Group B', etc.
  created_by TEXT NOT NULL, -- Admin email
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ, -- Optional expiration (can be null for permanent links)
  ended_at TIMESTAMPTZ, -- Manual early termination by admin
  is_active BOOLEAN DEFAULT TRUE,
  
  -- Constraints
  CONSTRAINT valid_url CHECK (url ~* '^https?://')
);

-- Create index for fast active link lookup
CREATE INDEX IF NOT EXISTS idx_class_join_links_active 
ON class_join_links(expires_at, ended_at, is_active) 
WHERE ended_at IS NULL AND is_active = true;

-- Create index for admin management
CREATE INDEX IF NOT EXISTS idx_class_join_links_created_by 
ON class_join_links(created_by, created_at DESC);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE class_join_links ENABLE ROW LEVEL SECURITY;

-- Admin emails (same as your system)
DO $$
BEGIN
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS admin_insert_class_links ON class_join_links;
  DROP POLICY IF EXISTS admin_update_class_links ON class_join_links;
  DROP POLICY IF EXISTS admin_delete_class_links ON class_join_links;
  DROP POLICY IF EXISTS student_select_active_links ON class_join_links;
  DROP POLICY IF EXISTS anon_select_active_links ON class_join_links;
END $$;

-- Policy 1: Only admins can INSERT links
CREATE POLICY admin_insert_class_links ON class_join_links
  FOR INSERT
  TO anon
  WITH CHECK (
    created_by IN (
      'Hrachfilm@gmail.com',
      'hrachfilm@gmail.com',
      'admin@acnhs.edu',
      'simonamikayelyan83@gmail.com'
    )
  );

-- Policy 2: Only admins can UPDATE links (for ending early)
CREATE POLICY admin_update_class_links ON class_join_links
  FOR UPDATE
  TO anon
  USING (
    created_by IN (
      'Hrachfilm@gmail.com',
      'hrachfilm@gmail.com',
      'admin@acnhs.edu',
      'simonamikayelyan83@gmail.com'
    )
  );

-- Policy 3: Only admins can DELETE links
CREATE POLICY admin_delete_class_links ON class_join_links
  FOR DELETE
  TO anon
  USING (
    created_by IN (
      'Hrachfilm@gmail.com',
      'hrachfilm@gmail.com',
      'admin@acnhs.edu',
      'simonamikayelyan83@gmail.com'
    )
  );

-- Policy 4: Students can only SELECT active, non-expired links
CREATE POLICY student_select_active_links ON class_join_links
  FOR SELECT
  TO anon
  USING (
    ended_at IS NULL 
    AND is_active = true 
    AND (expires_at IS NULL OR NOW() < expires_at)
  );

-- Policy 5: Allow anonymous access for testing (same as students)
CREATE POLICY anon_select_active_links ON class_join_links
  FOR SELECT
  TO anon
  USING (
    ended_at IS NULL 
    AND is_active = true 
    AND (expires_at IS NULL OR NOW() < expires_at)
  );

-- ============================================
-- HELPER FUNCTION: Get Active Link
-- ============================================

CREATE OR REPLACE FUNCTION get_active_class_link(p_group_id TEXT DEFAULT 'all')
RETURNS TABLE (
  id UUID,
  url TEXT,
  expires_at TIMESTAMPTZ,
  minutes_remaining INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.url,
    l.expires_at,
    CASE 
      WHEN l.expires_at IS NULL THEN NULL
      ELSE EXTRACT(EPOCH FROM (l.expires_at - NOW()))::INTEGER / 60
    END AS minutes_remaining
  FROM class_join_links l
  WHERE l.ended_at IS NULL
    AND l.is_active = true
    AND (l.expires_at IS NULL OR NOW() < l.expires_at)
    AND (l.group_id = p_group_id OR l.group_id = 'all' OR p_group_id IS NULL)
  ORDER BY l.created_at DESC
  LIMIT 1;
END;
$$;

-- ============================================
-- CLEANUP FUNCTION: Auto-expire old links
-- ============================================

CREATE OR REPLACE FUNCTION cleanup_expired_class_links()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE class_join_links
  SET is_active = false
  WHERE ended_at IS NULL
    AND is_active = true
    AND expires_at IS NOT NULL
    AND NOW() >= expires_at;
END;
$$;

-- ============================================
-- ENABLE REALTIME (Optional but recommended)
-- ============================================

-- Enable realtime updates so students see link appear/disappear instantly
ALTER PUBLICATION supabase_realtime ADD TABLE class_join_links;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Test 1: Insert a test link (run as admin)
-- INSERT INTO class_join_links (url, created_by, expires_at, group_id)
-- VALUES (
--   'https://zoom.us/j/123456789',
--   'hrachfilm@gmail.com',
--   NOW() + INTERVAL '1 hour',
--   'all'
-- );

-- Test 2: Get active link
-- SELECT * FROM get_active_class_link('all');

-- Test 3: End link early
-- UPDATE class_join_links SET ended_at = NOW() WHERE id = 'your-uuid-here';

-- Test 4: View all links (admin only)
-- SELECT id, url, created_at, expires_at, ended_at, 
--        EXTRACT(EPOCH FROM (expires_at - NOW()))::INTEGER / 60 as minutes_remaining
-- FROM class_join_links 
-- ORDER BY created_at DESC;

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

GRANT SELECT ON class_join_links TO anon;
GRANT INSERT ON class_join_links TO anon;
GRANT UPDATE ON class_join_links TO anon;
GRANT DELETE ON class_join_links TO anon;

GRANT EXECUTE ON FUNCTION get_active_class_link(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION cleanup_expired_class_links() TO anon;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '✅ class_join_links table created successfully!';
  RAISE NOTICE '📋 Next steps:';
  RAISE NOTICE '   1. Run this SQL in Supabase SQL Editor';
  RAISE NOTICE '   2. Enable Realtime in Dashboard > Database > Replication';
  RAISE NOTICE '   3. Test with: SELECT * FROM get_active_class_link(''all'');';
END $$;
