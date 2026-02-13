-- Add payment_receipts column to invoices table
-- This column stores uploaded payment receipt files as JSONB array

ALTER TABLE invoices 
ADD COLUMN IF NOT EXISTS payment_receipts JSONB DEFAULT '[]'::jsonb;

-- Add comment explaining the structure
COMMENT ON COLUMN invoices.payment_receipts IS 'Array of payment receipt objects with filename, public_url, uploaded_at, and size fields';

-- Example structure:
-- [
--   {
--     "filename": "payment_receipt.pdf",
--     "public_url": "https://storage.supabase.co/...",
--     "uploaded_at": "2026-02-14T10:30:00Z",
--     "size": 524288
--   }
-- ]
