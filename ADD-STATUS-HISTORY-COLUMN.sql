-- Add status_history column to applications table
-- This stores the complete history of all status changes with timestamps

ALTER TABLE applications 
ADD COLUMN IF NOT EXISTS status_history JSONB DEFAULT '[]'::jsonb;

-- Add comment to explain the column
COMMENT ON COLUMN applications.status_history IS 'Array of status change history entries with status, message, changed_at, and changed_by fields';

-- Example of what the data looks like:
-- [
--   {
--     "status": "SUBMITTED",
--     "message": "Application received",
--     "changed_at": "2026-01-07T10:30:00Z",
--     "changed_by": "admin"
--   },
--   {
--     "status": "UNDER REVIEW",
--     "message": "Your application is being reviewed",
--     "changed_at": "2026-01-08T14:20:00Z",
--     "changed_by": "admin"
--   }
-- ]
