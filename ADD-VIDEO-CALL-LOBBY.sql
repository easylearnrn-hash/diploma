-- ============================================================
-- ADD-VIDEO-CALL-LOBBY.sql
-- Creates the video_call_lobby table used by the lobby /
-- admission system in Videocall.html.
--
-- Run once in Supabase SQL Editor:
--   https://supabase.com/dashboard → Project → SQL Editor
-- ============================================================

-- 1. Create table
CREATE TABLE IF NOT EXISTS public.video_call_lobby (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id    text        NOT NULL,
  session_code  text        NOT NULL,
  user_id       text        NOT NULL,
  user_name     text,
  user_role     text        DEFAULT 'Student',
  user_email    text,
  status        text        DEFAULT 'waiting'
                            CHECK (status IN ('waiting', 'admitted', 'denied')),
  requested_at  timestamptz DEFAULT now(),
  decided_at    timestamptz
);

-- 2. Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_vcl_session_id
  ON public.video_call_lobby (session_id);

CREATE INDEX IF NOT EXISTS idx_vcl_session_code
  ON public.video_call_lobby (session_code);

CREATE INDEX IF NOT EXISTS idx_vcl_user_id
  ON public.video_call_lobby (user_id);

CREATE INDEX IF NOT EXISTS idx_vcl_status
  ON public.video_call_lobby (status);

-- 3. Enable Row Level Security
ALTER TABLE public.video_call_lobby ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies (anon role — matches rest of project)
-- DROP first so this script is safe to re-run
DROP POLICY IF EXISTS vcl_anon_insert ON public.video_call_lobby;
DROP POLICY IF EXISTS vcl_anon_select ON public.video_call_lobby;
DROP POLICY IF EXISTS vcl_anon_update ON public.video_call_lobby;
DROP POLICY IF EXISTS vcl_anon_delete ON public.video_call_lobby;

-- Students can insert their own join request
CREATE POLICY vcl_anon_insert
  ON public.video_call_lobby
  FOR INSERT TO anon
  WITH CHECK (true);

-- Students can read their own row (polling for admit/deny);
-- hosts can read all rows for their session
CREATE POLICY vcl_anon_select
  ON public.video_call_lobby
  FOR SELECT TO anon
  USING (true);

-- Host updates status to 'admitted' or 'denied' via anon client
CREATE POLICY vcl_anon_update
  ON public.video_call_lobby
  FOR UPDATE TO anon
  USING (true)
  WITH CHECK (true);

-- Optional: allow cleanup of old lobby rows (host ends session)
CREATE POLICY vcl_anon_delete
  ON public.video_call_lobby
  FOR DELETE TO anon
  USING (true);

-- 5. Enable Realtime for this table (required for subscribeLobby() in Videocall.html)
-- Run this if the table is not already in the realtime publication:
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND tablename = 'video_call_lobby'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.video_call_lobby;
  END IF;
END $$;

-- ============================================================
-- Verification query — run after applying migration:
-- SELECT table_name, column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'video_call_lobby'
-- ORDER BY ordinal_position;
-- ============================================================
