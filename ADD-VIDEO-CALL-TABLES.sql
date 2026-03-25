-- ============================================================
-- ADD-VIDEO-CALL-TABLES.sql
-- Master migration for ALL video call tables.
-- Creates: video_call_sessions, video_call_participants,
--          video_call_lobby, video_call_activity_log,
--          video_call_chat
--
-- Run once in: Supabase Dashboard → SQL Editor
-- Safe to re-run (uses IF NOT EXISTS / DO $$ blocks).
-- ============================================================


-- ┌──────────────────────────────────────────────────────────────┐
-- │ 1. video_call_sessions                                       │
-- │    One row per meeting started by a host.                    │
-- └──────────────────────────────────────────────────────────────┘
CREATE TABLE IF NOT EXISTS public.video_call_sessions (
  id            bigint       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  session_id    text         NOT NULL UNIQUE,
  room_name     text,
  room_code     text         NOT NULL,
  host_user_id  text         NOT NULL,
  host_name     text,
  host_role     text         DEFAULT 'Admin',
  status        text         DEFAULT 'live'
                             CHECK (status IN ('live', 'ended')),
  created_at    timestamptz  DEFAULT now(),
  started_at    timestamptz,
  ended_at      timestamptz
);

CREATE INDEX IF NOT EXISTS idx_vcs_room_code   ON public.video_call_sessions (room_code);
CREATE INDEX IF NOT EXISTS idx_vcs_host        ON public.video_call_sessions (host_user_id);
CREATE INDEX IF NOT EXISTS idx_vcs_status      ON public.video_call_sessions (status);
CREATE INDEX IF NOT EXISTS idx_vcs_created      ON public.video_call_sessions (created_at DESC);

ALTER TABLE public.video_call_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS vcs_anon_insert ON public.video_call_sessions;
CREATE POLICY vcs_anon_insert ON public.video_call_sessions
  FOR INSERT TO anon WITH CHECK (true);

DROP POLICY IF EXISTS vcs_anon_select ON public.video_call_sessions;
CREATE POLICY vcs_anon_select ON public.video_call_sessions
  FOR SELECT TO anon USING (true);

DROP POLICY IF EXISTS vcs_anon_update ON public.video_call_sessions;
CREATE POLICY vcs_anon_update ON public.video_call_sessions
  FOR UPDATE TO anon USING (true) WITH CHECK (true);


-- ┌──────────────────────────────────────────────────────────────┐
-- │ 2. video_call_participants                                   │
-- │    Attendance: one row per join (tracks join/leave/duration). │
-- └──────────────────────────────────────────────────────────────┘
CREATE TABLE IF NOT EXISTS public.video_call_participants (
  id                      bigint       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  session_id              text         NOT NULL,
  participant_user_id     text         NOT NULL,
  participant_name        text,
  participant_role        text         DEFAULT 'Student',
  participant_email       text,
  joined_at               timestamptz  DEFAULT now(),
  left_at                 timestamptz,
  is_present              boolean      DEFAULT true,
  total_duration_seconds  integer      DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_vcp_session     ON public.video_call_participants (session_id);
CREATE INDEX IF NOT EXISTS idx_vcp_user        ON public.video_call_participants (participant_user_id);
CREATE INDEX IF NOT EXISTS idx_vcp_present     ON public.video_call_participants (is_present);
CREATE INDEX IF NOT EXISTS idx_vcp_joined      ON public.video_call_participants (joined_at DESC);

ALTER TABLE public.video_call_participants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS vcp_anon_insert ON public.video_call_participants;
CREATE POLICY vcp_anon_insert ON public.video_call_participants
  FOR INSERT TO anon WITH CHECK (true);

DROP POLICY IF EXISTS vcp_anon_select ON public.video_call_participants;
CREATE POLICY vcp_anon_select ON public.video_call_participants
  FOR SELECT TO anon USING (true);

DROP POLICY IF EXISTS vcp_anon_update ON public.video_call_participants;
CREATE POLICY vcp_anon_update ON public.video_call_participants
  FOR UPDATE TO anon USING (true) WITH CHECK (true);


-- ┌──────────────────────────────────────────────────────────────┐
-- │ 3. video_call_lobby                                          │
-- │    Join requests: student requests → host admits/denies.     │
-- └──────────────────────────────────────────────────────────────┘
CREATE TABLE IF NOT EXISTS public.video_call_lobby (
  id            uuid         DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id    text         NOT NULL,
  session_code  text         NOT NULL,
  user_id       text         NOT NULL,
  user_name     text,
  user_role     text         DEFAULT 'Student',
  user_email    text,
  status        text         DEFAULT 'waiting'
                             CHECK (status IN ('waiting', 'admitted', 'denied')),
  requested_at  timestamptz  DEFAULT now(),
  decided_at    timestamptz
);

CREATE INDEX IF NOT EXISTS idx_vcl_session_id   ON public.video_call_lobby (session_id);
CREATE INDEX IF NOT EXISTS idx_vcl_session_code ON public.video_call_lobby (session_code);
CREATE INDEX IF NOT EXISTS idx_vcl_user_id      ON public.video_call_lobby (user_id);
CREATE INDEX IF NOT EXISTS idx_vcl_status       ON public.video_call_lobby (status);

ALTER TABLE public.video_call_lobby ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS vcl_anon_insert ON public.video_call_lobby;
CREATE POLICY vcl_anon_insert ON public.video_call_lobby
  FOR INSERT TO anon WITH CHECK (true);

DROP POLICY IF EXISTS vcl_anon_select ON public.video_call_lobby;
CREATE POLICY vcl_anon_select ON public.video_call_lobby
  FOR SELECT TO anon USING (true);

DROP POLICY IF EXISTS vcl_anon_update ON public.video_call_lobby;
CREATE POLICY vcl_anon_update ON public.video_call_lobby
  FOR UPDATE TO anon USING (true) WITH CHECK (true);


-- ┌──────────────────────────────────────────────────────────────┐
-- │ 4. video_call_activity_log                                   │
-- │    Every action: join/leave/cam/mic/screen/hand/chat/lobby.  │
-- └──────────────────────────────────────────────────────────────┘
CREATE TABLE IF NOT EXISTS public.video_call_activity_log (
  id            bigint       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ts            timestamptz  NOT NULL DEFAULT now(),
  session_id    text,
  session_code  text,
  session_name  text,
  user_id       text,
  user_name     text,
  user_role     text,
  event_type    text         NOT NULL,
  detail        text                        -- optional extra info (e.g. "Admitted John Doe")
);

CREATE INDEX IF NOT EXISTS idx_vcal_session_id ON public.video_call_activity_log (session_id);
CREATE INDEX IF NOT EXISTS idx_vcal_user_id    ON public.video_call_activity_log (user_id);
CREATE INDEX IF NOT EXISTS idx_vcal_ts         ON public.video_call_activity_log (ts DESC);
CREATE INDEX IF NOT EXISTS idx_vcal_event      ON public.video_call_activity_log (event_type);

ALTER TABLE public.video_call_activity_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_anon_insert_activity" ON public.video_call_activity_log;
CREATE POLICY "allow_anon_insert_activity" ON public.video_call_activity_log
  FOR INSERT TO anon WITH CHECK (true);

DROP POLICY IF EXISTS "allow_anon_select_activity" ON public.video_call_activity_log;
CREATE POLICY "allow_anon_select_activity" ON public.video_call_activity_log
  FOR SELECT TO anon USING (true);

-- Add detail column if the table already exists without it
DO $$ BEGIN
  ALTER TABLE public.video_call_activity_log ADD COLUMN detail text;
EXCEPTION WHEN duplicate_column THEN NULL;
END $$;


-- ┌──────────────────────────────────────────────────────────────┐
-- │ 5. video_call_chat                                           │
-- │    Chat messages persisted for review after session ends.    │
-- └──────────────────────────────────────────────────────────────┘
CREATE TABLE IF NOT EXISTS public.video_call_chat (
  id            bigint       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  session_id    text         NOT NULL,
  session_code  text,
  user_id       text         NOT NULL,
  user_name     text,
  user_role     text,
  message       text         NOT NULL,
  sent_at       timestamptz  DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_vcc_session     ON public.video_call_chat (session_id);
CREATE INDEX IF NOT EXISTS idx_vcc_user        ON public.video_call_chat (user_id);
CREATE INDEX IF NOT EXISTS idx_vcc_sent        ON public.video_call_chat (sent_at DESC);

ALTER TABLE public.video_call_chat ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS vcc_anon_insert ON public.video_call_chat;
CREATE POLICY vcc_anon_insert ON public.video_call_chat
  FOR INSERT TO anon WITH CHECK (true);

DROP POLICY IF EXISTS vcc_anon_select ON public.video_call_chat;
CREATE POLICY vcc_anon_select ON public.video_call_chat
  FOR SELECT TO anon USING (true);


-- ════════════════════════════════════════════════════════════════
-- Enable Supabase Realtime on tables that need live subscriptions
-- ════════════════════════════════════════════════════════════════
DO $$
BEGIN
  -- video_call_participants: host subscribes to see join/leave in real time
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.video_call_participants;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;

  -- video_call_lobby: host subscribes to see new join requests
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.video_call_lobby;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
END $$;


-- ════════════════════════════════════════════════════════════════
-- DONE — Summary of all events tracked:
--
-- Activity Log (video_call_activity_log.event_type):
--   session_started, session_ended
--   joined, left
--   camera_on, camera_off
--   mic_on, mic_off
--   screen_on, screen_off
--   hand_raised, hand_lowered
--   chat_message
--   lobby_request
--   lobby_admitted, lobby_denied
--   admitted_student, denied_student  (host actions with detail)
--
-- Attendance (video_call_participants):
--   participant_user_id, joined_at, left_at, total_duration_seconds
--
-- Lobby (video_call_lobby):
--   user join request with status tracking (waiting → admitted/denied)
--
-- Chat (video_call_chat):
--   Full message history per session
-- ════════════════════════════════════════════════════════════════
