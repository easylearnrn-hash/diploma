-- Speed up the student email inbox query:
--   .or(`sender.eq.X,recipient.eq.X`)  +  .order('sent_at', { ascending: false })
-- Without indexes this is a full table scan (explains the ~50s load time).

CREATE INDEX IF NOT EXISTS idx_email_history_recipient_sent
    ON email_history (recipient, sent_at DESC);

CREATE INDEX IF NOT EXISTS idx_email_history_sender_sent
    ON email_history (sender, sent_at DESC);

-- Run this once in Supabase SQL Editor:
-- Dashboard → SQL Editor → paste → Run
