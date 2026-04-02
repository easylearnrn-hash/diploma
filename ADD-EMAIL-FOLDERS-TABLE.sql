-- ============================================================
-- Email Folders + Rules
-- PROJECT: eyhksbiceueoiamwnqpr
-- 
-- ▶ Run this in Supabase SQL Editor:
--   https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql/new
-- ============================================================

-- 1. Folders table: each row is a named folder (e.g. "Hub", "Billing")
CREATE TABLE IF NOT EXISTS email_folders (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  icon        text NOT NULL DEFAULT '📁',     -- emoji chosen by admin
  color       text NOT NULL DEFAULT '#c9a84c', -- accent colour (hex)
  sort_order  integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- 2. Rules table: "emails FROM <sender_address> go into folder <folder_id>"
CREATE TABLE IF NOT EXISTS email_folder_rules (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  folder_id     uuid NOT NULL REFERENCES email_folders(id) ON DELETE CASCADE,
  sender_address text NOT NULL,               -- exact match, e.g. hub@acnhs.am
  created_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE(sender_address)                       -- one sender → one folder only
);

-- 3. RLS (anon can do everything — consistent with rest of project)
ALTER TABLE email_folders       ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_folder_rules  ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_all_email_folders"      ON email_folders;
DROP POLICY IF EXISTS "anon_all_email_folder_rules" ON email_folder_rules;

CREATE POLICY "anon_all_email_folders"
  ON email_folders FOR ALL TO anon USING (true) WITH CHECK (true);

CREATE POLICY "anon_all_email_folder_rules"
  ON email_folder_rules FOR ALL TO anon USING (true) WITH CHECK (true);

-- 4. Optional seed: a "Hub" folder pointing at hub@acnhs.am
-- Remove or comment out if you don't want a default folder
-- INSERT INTO email_folders (name, icon, color, sort_order)
-- VALUES ('Hub', '🔵', '#3b82f6', 1)
-- ON CONFLICT DO NOTHING;
