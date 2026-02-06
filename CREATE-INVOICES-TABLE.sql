-- Create invoices table for storing all generated invoices
CREATE TABLE IF NOT EXISTS invoices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  invoice_number TEXT NOT NULL UNIQUE,
  student_name TEXT NOT NULL,
  student_id TEXT,
  program TEXT,
  invoice_date DATE NOT NULL,
  due_date DATE,
  payment_method TEXT,
  notes TEXT,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  tax_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  status TEXT DEFAULT 'unpaid' CHECK (status IN ('unpaid', 'paid', 'overdue', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on invoice_number for fast lookups
CREATE INDEX IF NOT EXISTS idx_invoices_invoice_number ON invoices(invoice_number);

-- Create index on student_name for searching
CREATE INDEX IF NOT EXISTS idx_invoices_student_name ON invoices(student_name);

-- Create index on invoice_date for sorting
CREATE INDEX IF NOT EXISTS idx_invoices_invoice_date ON invoices(invoice_date DESC);

-- Create index on status for filtering
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);

-- Create index on created_at for recent invoices
CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON invoices(created_at DESC);

-- Enable RLS
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Allow anonymous users to insert invoices (for local invoice generator)
CREATE POLICY "Allow anonymous insert invoices"
ON invoices FOR INSERT
TO anon
WITH CHECK (true);

-- Allow anonymous users to select invoices
CREATE POLICY "Allow anonymous select invoices"
ON invoices FOR SELECT
TO anon
USING (true);

-- Allow anonymous users to update invoices
CREATE POLICY "Allow anonymous update invoices"
ON invoices FOR UPDATE
TO anon
USING (true);

-- Allow anonymous users to delete invoices
CREATE POLICY "Allow anonymous delete invoices"
ON invoices FOR DELETE
TO anon
USING (true);

-- Create trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_invoices_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER invoices_updated_at_trigger
BEFORE UPDATE ON invoices
FOR EACH ROW
EXECUTE FUNCTION update_invoices_updated_at();

-- Add helpful comment
COMMENT ON TABLE invoices IS 'Stores all generated invoices with full details including line items, amounts, and payment status';
