-- ============================================================
-- Spam Blocked Senders Table
-- PROJECT: eyhksbiceueoiamwnqpr
--
-- ▶ Run this in Supabase SQL Editor:
--   https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql/new
-- ============================================================

-- 1. Table: one row per blocked sender address
CREATE TABLE IF NOT EXISTS email_spam_blocked (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_address  text NOT NULL UNIQUE,    -- exact address, e.g. scammer@example.com
  blocked_at      timestamptz NOT NULL DEFAULT now()
);

-- 2. RLS — consistent with rest of project (anon can do everything)
ALTER TABLE email_spam_blocked ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_all_email_spam_blocked" ON email_spam_blocked;

CREATE POLICY "anon_all_email_spam_blocked"
  ON email_spam_blocked FOR ALL TO anon USING (true) WITH CHECK (true);
