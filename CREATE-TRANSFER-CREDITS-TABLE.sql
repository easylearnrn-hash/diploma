-- Transfer Credits Table for Students
-- Stores academic credits transferred from other institutions

-- Drop existing table if needed (for clean reinstall)
DROP TABLE IF EXISTS transfer_credits CASCADE;

-- Create the transfer_credits table
CREATE TABLE IF NOT EXISTS transfer_credits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES acnhs_students(id) ON DELETE CASCADE,
  
  -- Institution Information
  institution_name TEXT NOT NULL,
  institution_country TEXT,
  institution_city TEXT,
  
  -- Course Information
  course_code TEXT NOT NULL,
  course_name TEXT NOT NULL,
  credits DECIMAL(5,2) NOT NULL CHECK (credits > 0),
  
  -- Grade Information
  grade TEXT NOT NULL,
  grade_points DECIMAL(4,2) CHECK (grade_points >= 0 AND grade_points <= 4.0),
  letter_grade TEXT,
  
  -- Transfer Details
  transfer_date DATE,
  term_completed TEXT, -- e.g., "Fall 2023", "Spring 2024"
  year_completed INTEGER,
  
  -- Equivalency Information
  acnhs_equivalent_course TEXT, -- What ACNHS course this replaces
  evaluated_by TEXT, -- Admin who evaluated/approved the transfer
  evaluation_date TIMESTAMP DEFAULT NOW(),
  
  -- Supporting Documentation
  transcript_document_url TEXT, -- Link to uploaded transcript
  evaluation_notes TEXT,
  
  -- Status
  status TEXT DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by TEXT, -- Admin email who created this record
  
  -- Constraints
  CONSTRAINT valid_credits CHECK (credits BETWEEN 0.5 AND 12.0),
  CONSTRAINT valid_grade_points CHECK (grade_points IS NULL OR (grade_points >= 0 AND grade_points <= 4.0))
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_transfer_credits_student_id ON transfer_credits(student_id);
CREATE INDEX IF NOT EXISTS idx_transfer_credits_status ON transfer_credits(status);
CREATE INDEX IF NOT EXISTS idx_transfer_credits_institution ON transfer_credits(institution_name);

-- Add RLS (Row Level Security) policies
ALTER TABLE transfer_credits ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow anonymous to read transfer credits" ON transfer_credits;
DROP POLICY IF EXISTS "Allow anonymous to insert transfer credits" ON transfer_credits;
DROP POLICY IF EXISTS "Allow anonymous to update transfer credits" ON transfer_credits;
DROP POLICY IF EXISTS "Allow anonymous to delete transfer credits" ON transfer_credits;

-- Allow anonymous access (admin portal uses anon key)
CREATE POLICY "Allow anonymous to read transfer credits"
  ON transfer_credits FOR SELECT
  USING (true);

CREATE POLICY "Allow anonymous to insert transfer credits"
  ON transfer_credits FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow anonymous to update transfer credits"
  ON transfer_credits FOR UPDATE
  USING (true);

CREATE POLICY "Allow anonymous to delete transfer credits"
  ON transfer_credits FOR DELETE
  USING (true);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_transfer_credits_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS transfer_credits_updated_at ON transfer_credits;

CREATE TRIGGER transfer_credits_updated_at
  BEFORE UPDATE ON transfer_credits
  FOR EACH ROW
  EXECUTE FUNCTION update_transfer_credits_updated_at();

-- Sample data for testing (optional - comment out if not needed)
/*
INSERT INTO transfer_credits (student_id, institution_name, institution_country, course_code, course_name, credits, grade, grade_points, letter_grade, term_completed, year_completed, status)
VALUES 
  ('ACNHS-0000151', 'University of California', 'USA', 'BIO101', 'Introduction to Biology', 3.00, '92', 4.00, 'A', 'Fall', 2023, 'approved'),
  ('ACNHS-0000151', 'University of California', 'USA', 'CHEM101', 'General Chemistry', 4.00, '88', 3.67, 'A-', 'Fall', 2023, 'approved');
*/

COMMENT ON TABLE transfer_credits IS 'Stores academic credits transferred from other institutions';
COMMENT ON COLUMN transfer_credits.student_id IS 'References the ACNHS student ID';
COMMENT ON COLUMN transfer_credits.grade_points IS 'Grade points on 4.0 scale for GPA calculation';
COMMENT ON COLUMN transfer_credits.acnhs_equivalent_course IS 'Which ACNHS course this transfer credit satisfies';
COMMENT ON COLUMN transfer_credits.status IS 'pending: awaiting evaluation, approved: counted toward degree, rejected: not accepted';
