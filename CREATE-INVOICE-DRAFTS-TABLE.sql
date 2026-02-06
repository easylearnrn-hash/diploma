-- Invoice Drafts Table
-- Run this in Supabase SQL Editor to create the table

CREATE TABLE IF NOT EXISTS invoice_drafts (
  id BIGSERIAL PRIMARY KEY,
  student_name TEXT,
  student_id TEXT,
  program TEXT,
  invoice_number TEXT,
  invoice_date DATE,
  due_date DATE,
  payment_method TEXT,
  notes TEXT,
  items JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable Row Level Security
ALTER TABLE invoice_drafts ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous users to read all drafts
CREATE POLICY "Allow anonymous read access"
  ON invoice_drafts
  FOR SELECT
  TO anon
  USING (true);

-- Policy: Allow anonymous users to insert drafts
CREATE POLICY "Allow anonymous insert access"
  ON invoice_drafts
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy: Allow anonymous users to update drafts
CREATE POLICY "Allow anonymous update access"
  ON invoice_drafts
  FOR UPDATE
  TO anon
  USING (true);

-- Policy: Allow anonymous users to delete drafts
CREATE POLICY "Allow anonymous delete access"
  ON invoice_drafts
  FOR DELETE
  TO anon
  USING (true);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_invoice_drafts_updated_at ON invoice_drafts(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_invoice_drafts_student_name ON invoice_drafts(student_name);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_invoice_drafts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_invoice_drafts_timestamp ON invoice_drafts;
CREATE TRIGGER update_invoice_drafts_timestamp
  BEFORE UPDATE ON invoice_drafts
  FOR EACH ROW
  EXECUTE FUNCTION update_invoice_drafts_updated_at();

-- Verify table creation
SELECT 'invoice_drafts table created successfully' AS status;
