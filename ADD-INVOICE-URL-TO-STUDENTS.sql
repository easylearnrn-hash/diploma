-- Add invoice_url column to students table
-- This allows linking invoices directly to student profiles

ALTER TABLE students 
ADD COLUMN IF NOT EXISTS invoice_url TEXT;

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_students_invoice_url 
ON students(invoice_url) 
WHERE invoice_url IS NOT NULL;

-- Add comment
COMMENT ON COLUMN students.invoice_url IS 'Direct link to student invoice with non-refundable disclaimer (invoice-view.html?id=uuid)';
