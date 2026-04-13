-- ============================================================
-- ADD YES/NO RESPONSE TRACKING TO WAITING LIST (registrations)
-- Run this in the Supabase SQL Editor
-- Project: eyhksbiceueoiamwnqpr
-- ============================================================

-- 1. Add response column (YES or NO, set by the registrant)
ALTER TABLE public.registrations
  ADD COLUMN IF NOT EXISTS wl_response TEXT
  CHECK (wl_response IN ('YES', 'NO'));

-- 2. Add token column (for secure email link verification)
ALTER TABLE public.registrations
  ADD COLUMN IF NOT EXISTS wl_response_token TEXT;

-- Done.
SELECT 'Migration complete. wl_response and wl_response_token columns added to registrations.' AS result;
