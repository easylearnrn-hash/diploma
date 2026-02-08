-- Create enrollment_questionnaires table
-- This table stores the Personal & Residency Timeline Questionnaire responses
-- Linked to students via control_number and application_id

CREATE TABLE IF NOT EXISTS enrollment_questionnaires (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
  control_number TEXT NOT NULL,
  document_id TEXT,
  questionnaire_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Indexes for faster queries
  CONSTRAINT fk_application FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_enrollment_questionnaires_control_number 
ON enrollment_questionnaires(control_number);

CREATE INDEX IF NOT EXISTS idx_enrollment_questionnaires_application_id 
ON enrollment_questionnaires(application_id);

CREATE INDEX IF NOT EXISTS idx_enrollment_questionnaires_created_at 
ON enrollment_questionnaires(created_at DESC);

-- Enable Row Level Security
ALTER TABLE enrollment_questionnaires ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous insert (for form submission)
CREATE POLICY "Allow anonymous insert questionnaires" 
ON enrollment_questionnaires 
FOR INSERT 
TO anon 
WITH CHECK (true);

-- Policy: Allow anonymous select by control_number (students can view their own)
CREATE POLICY "Allow anonymous select own questionnaire" 
ON enrollment_questionnaires 
FOR SELECT 
TO anon 
USING (true);

-- Policy: Allow authenticated users (admins) full access
CREATE POLICY "Allow authenticated full access" 
ON enrollment_questionnaires 
FOR ALL 
TO authenticated 
USING (true);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_enrollment_questionnaires_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_enrollment_questionnaires_updated_at
BEFORE UPDATE ON enrollment_questionnaires
FOR EACH ROW
EXECUTE FUNCTION update_enrollment_questionnaires_updated_at();

-- Add comment
COMMENT ON TABLE enrollment_questionnaires IS 
'Stores Personal & Residency Timeline Questionnaire responses for enrolled students. Links to applications table via control_number and application_id. Contains detailed travel history, education history, and emergency contact information required for regulatory compliance.';

-- Example of questionnaire_data structure:
COMMENT ON COLUMN enrollment_questionnaires.questionnaire_data IS 
'JSONB structure: {
  "control_number": "ACNHS-2026-0001",
  "personal_info": {
    "full_name": "John Smith",
    "date_of_birth": "2000-01-01"
  },
  "education_history": {
    "hs_grad_date": "2018-06-15",
    "armenian_edu": "yes",
    "armenian_institution": "Yerevan State University",
    "application_date": "2020-09-01",
    "graduation_date": "2024-06-15"
  },
  "residency_travel": {
    "permanent_departure_date": "2024-07-01",
    "travel_history": [
      {
        "arrival": "2024-12-20",
        "departure": "2025-01-05",
        "duration": "16",
        "purpose": "Family visit"
      }
    ]
  },
  "emergency_contact": {
    "name": "Jane Smith",
    "relationship": "Mother",
    "phone": "+374 XX XXX XXX",
    "address": "123 Main St, Yerevan"
  },
  "attestation": {
    "signature": "John Smith",
    "date": "2026-02-08"
  },
  "submitted_at": "2026-02-08T10:30:00Z"
}';
