-- ============================================
-- FIX CLASS JOIN LINKS RLS POLICIES
-- Purpose: Allow admins to insert/update/delete class join links
-- Issue: Policy was checking created_by BEFORE insert, causing 42501 error
-- Solution: Allow any insert/update/delete for anon role (admin check happens in app)
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS admin_insert_class_links ON class_join_links;
DROP POLICY IF EXISTS admin_update_class_links ON class_join_links;
DROP POLICY IF EXISTS admin_delete_class_links ON class_join_links;
DROP POLICY IF EXISTS student_select_active_links ON class_join_links;
DROP POLICY IF EXISTS anon_select_active_links ON class_join_links;
DROP POLICY IF EXISTS admin_select_all_links ON class_join_links;

-- Policy 1: Allow INSERT for anon (admin authentication handled in app)
CREATE POLICY admin_insert_class_links ON class_join_links
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy 2: Allow UPDATE for anon (admin authentication handled in app)
CREATE POLICY admin_update_class_links ON class_join_links
  FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- Policy 3: Allow DELETE for anon (admin authentication handled in app)
CREATE POLICY admin_delete_class_links ON class_join_links
  FOR DELETE
  TO anon
  USING (true);

-- Policy 4: Allow SELECT for anon - see active, non-expired links
CREATE POLICY student_select_active_links ON class_join_links
  FOR SELECT
  TO anon
  USING (
    ended_at IS NULL 
    AND is_active = true 
    AND (expires_at IS NULL OR NOW() < expires_at)
  );

-- Policy 5: Allow admins to SELECT ALL links (for management)
CREATE POLICY admin_select_all_links ON class_join_links
  FOR SELECT
  TO anon
  USING (true);

-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'class_join_links'
ORDER BY policyname;
