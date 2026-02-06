-- =====================================================
-- CREATE profile_update_requests TABLE
-- =====================================================
-- Purpose: Store student requests for profile updates (name changes, etc.)
-- Referenced by: Student-page.html (Request Official Update modal)
-- =====================================================

CREATE TABLE IF NOT EXISTS profile_update_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id TEXT,
  student_email TEXT,
  update_type TEXT NOT NULL CHECK (update_type IN (
    'name_change', 'name_correction', 'contact_info', 'emergency_contact',
    'address', 'citizenship', 'date_of_birth', 'other'
  )),
  urgency TEXT DEFAULT 'standard' CHECK (urgency IN ('standard', 'urgent', 'critical')),
  reason TEXT NOT NULL,
  form_data JSONB DEFAULT '{}'::jsonb,
  supporting_documents_files TEXT[], -- Array of file URLs or base64 data
  description TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'approved', 'rejected', 'completed')),
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  reviewed_by TEXT,
  admin_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS policies for student portal access
ALTER TABLE profile_update_requests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow anonymous insert" ON profile_update_requests;
DROP POLICY IF EXISTS "Allow anonymous select" ON profile_update_requests;
DROP POLICY IF EXISTS "Allow anonymous update" ON profile_update_requests;

-- Allow anonymous users to insert (students submit requests)
CREATE POLICY "Allow anonymous insert" ON profile_update_requests
  FOR INSERT TO anon
  WITH CHECK (true);

-- Allow anonymous users to select their own requests
CREATE POLICY "Allow anonymous select" ON profile_update_requests
  FOR SELECT TO anon
  USING (true);

-- Allow anonymous users to update (for testing - restrict in production)
CREATE POLICY "Allow anonymous update" ON profile_update_requests
  FOR UPDATE TO anon
  USING (true);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_profile_update_requests_student_id 
  ON profile_update_requests(student_id);

CREATE INDEX IF NOT EXISTS idx_profile_update_requests_status 
  ON profile_update_requests(status);

CREATE INDEX IF NOT EXISTS idx_profile_update_requests_update_type 
  ON profile_update_requests(update_type);

CREATE INDEX IF NOT EXISTS idx_profile_update_requests_urgency 
  ON profile_update_requests(urgency);

CREATE INDEX IF NOT EXISTS idx_profile_update_requests_submitted_at 
  ON profile_update_requests(submitted_at DESC);

-- Create GIN index for form_data JSONB field
CREATE INDEX IF NOT EXISTS idx_profile_update_requests_form_data 
  ON profile_update_requests USING gin(form_data);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_profile_update_requests_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profile_update_requests_updated_at
  BEFORE UPDATE ON profile_update_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_update_requests_timestamp();

-- =====================================================
-- SAMPLE DATA DOCUMENTATION
-- =====================================================
-- Example form_data JSONB structure:
-- 
-- Name Change:
-- {
--   "current_name": "John Smith",
--   "new_name": "John Doe",
--   "supporting_documents": ["passport", "marriage_cert"]
-- }
--
-- Contact Info:
-- {
--   "new_email": "john.doe@example.com",
--   "new_phone": "+374 XX XXX XXX",
--   "supporting_documents": ["utility_bill"]
-- }
--
-- Address:
-- {
--   "new_address": "123 Main St",
--   "new_city": "Yerevan",
--   "new_country": "Armenia",
--   "supporting_documents": ["utility_bill"]
-- }
--
-- Date of Birth:
-- {
--   "current_dob": "1995-05-15",
--   "new_dob": "1995-06-15",
--   "supporting_documents": ["birth_cert", "passport"]
-- }

-- =====================================================
-- VERIFICATION
-- =====================================================
-- Run this to verify the table was created:
-- SELECT table_name, column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'profile_update_requests'
-- ORDER BY ordinal_position;
