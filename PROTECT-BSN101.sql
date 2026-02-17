-- ============================================
-- PROTECT BSN 101 GROUP FROM ACCIDENTAL DELETION
-- Creates a database trigger that prevents deletion
-- ============================================

-- Create a function that prevents deletion of BSN 101
CREATE OR REPLACE FUNCTION prevent_bsn101_deletion()
RETURNS TRIGGER AS $$
BEGIN
  -- Prevent deletion of the main BSN 101 group
  IF OLD.id = 'bsn-101' THEN
    RAISE EXCEPTION 'Cannot delete BSN 101 group - it is protected. Contact system administrator.';
  END IF;
  
  -- Allow all other deletions
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create trigger that runs before any DELETE on student_groups
DROP TRIGGER IF EXISTS protect_bsn101_group ON student_groups;
CREATE TRIGGER protect_bsn101_group
  BEFORE DELETE ON student_groups
  FOR EACH ROW
  EXECUTE FUNCTION prevent_bsn101_deletion();

-- Test: Try to delete BSN 101 (this should fail with an error)
-- DELETE FROM student_groups WHERE id = 'bsn-101';
-- You should see: ERROR: Cannot delete BSN 101 group - it is protected

-- Verify trigger exists
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'protect_bsn101_group';
