-- Invoice Line Item Templates Table
-- Run this in Supabase SQL Editor to create the table

CREATE TABLE IF NOT EXISTS invoice_templates (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  items JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable Row Level Security
ALTER TABLE invoice_templates ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous users to read all templates
CREATE POLICY "Allow anonymous read access"
  ON invoice_templates
  FOR SELECT
  TO anon
  USING (true);

-- Policy: Allow anonymous users to insert templates
CREATE POLICY "Allow anonymous insert access"
  ON invoice_templates
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy: Allow anonymous users to update templates
CREATE POLICY "Allow anonymous update access"
  ON invoice_templates
  FOR UPDATE
  TO anon
  USING (true);

-- Policy: Allow anonymous users to delete templates
CREATE POLICY "Allow anonymous delete access"
  ON invoice_templates
  FOR DELETE
  TO anon
  USING (true);

-- Index for faster lookups by name
CREATE INDEX IF NOT EXISTS idx_invoice_templates_name ON invoice_templates(name);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_invoice_templates_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_invoice_templates_timestamp ON invoice_templates;
CREATE TRIGGER update_invoice_templates_timestamp
  BEFORE UPDATE ON invoice_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_invoice_templates_updated_at();

-- Verify table creation
SELECT 'invoice_templates table created successfully' AS status;
