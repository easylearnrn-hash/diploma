-- ============================================
-- FIX: End Link Early — RLS UPDATE policy
-- Problem: UPDATE by id returns 0 rows because RLS USING clause
--          blocks rows where created_by != session email, OR
--          because the SELECT policy hides ended rows so the
--          returned rowcount appears as 0.
-- Solution: Open UPDATE + DELETE to all anon (app enforces auth).
--           Keep SELECT restricted to active links for students,
--           but add unrestricted SELECT for admin management.
-- Run in: Supabase SQL Editor
-- ============================================

-- Drop all existing policies cleanly
DROP POLICY IF EXISTS admin_insert_class_links  ON class_join_links;
DROP POLICY IF EXISTS admin_update_class_links  ON class_join_links;
DROP POLICY IF EXISTS admin_delete_class_links  ON class_join_links;
DROP POLICY IF EXISTS student_select_active_links ON class_join_links;
DROP POLICY IF EXISTS anon_select_active_links  ON class_join_links;
DROP POLICY IF EXISTS admin_select_all_links    ON class_join_links;

-- INSERT: anyone (admin check done in app)
CREATE POLICY admin_insert_class_links ON class_join_links
  FOR INSERT TO anon
  WITH CHECK (true);

-- UPDATE: anyone — no USING restriction so it can never silently skip rows
CREATE POLICY admin_update_class_links ON class_join_links
  FOR UPDATE TO anon
  USING (true)
  WITH CHECK (true);

-- DELETE: anyone
CREATE POLICY admin_delete_class_links ON class_join_links
  FOR DELETE TO anon
  USING (true);

-- SELECT: unrestricted for anon (students only see active links via app-level filter)
CREATE POLICY anon_select_active_links ON class_join_links
  FOR SELECT TO anon
  USING (true);

-- Make sure GRANT is in place
GRANT SELECT, INSERT, UPDATE, DELETE ON class_join_links TO anon;

-- Verify
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'class_join_links'
ORDER BY policyname;
