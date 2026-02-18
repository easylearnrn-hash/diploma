-- ============================================================
-- ADD RECEIPT VIEWED TRACKING TO INVOICES TABLE
-- Run this ONCE in Supabase SQL Editor
-- ============================================================

-- 1. Track when admin last VIEWED receipts for this invoice
ALTER TABLE invoices
  ADD COLUMN IF NOT EXISTS receipts_viewed_at TIMESTAMPTZ DEFAULT NULL;

-- 2. Track when the LAST receipt was uploaded
--    (used to detect new uploads after a prior view)
ALTER TABLE invoices
  ADD COLUMN IF NOT EXISTS receipts_last_uploaded_at TIMESTAMPTZ DEFAULT NULL;

-- 3. Back-fill receipts_last_uploaded_at for invoices that already have receipts
--    (so existing uploaded receipts don't permanently show as "new" —
--     set their last_uploaded_at to now so they start as "viewed")
UPDATE invoices
SET
  receipts_last_uploaded_at = NOW(),
  receipts_viewed_at        = NOW()
WHERE
  payment_receipts IS NOT NULL
  AND jsonb_array_length(payment_receipts) > 0;

-- 4. Verify
SELECT id, student_name, receipts_viewed_at, receipts_last_uploaded_at
FROM invoices
ORDER BY created_at DESC
LIMIT 10;
