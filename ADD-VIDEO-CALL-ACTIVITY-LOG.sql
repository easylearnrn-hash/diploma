-- ============================================================
-- video_call_activity_log
-- Records every participant action in a video call session.
-- Run this in: Supabase Dashboard → SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS public.video_call_activity_log (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ts            timestamptz NOT NULL DEFAULT now(),
  session_id    text,
  session_code  text,
  session_name  text,
  user_id       text,
  user_name     text,
  user_role     text,
  event_type    text NOT NULL   -- 'joined'|'left'|'camera_on'|'camera_off'|'mic_on'|'mic_off'|'screen_on'|'screen_off'|'hand_raised'|'hand_lowered'
);

-- Indexes for fast history queries
CREATE INDEX IF NOT EXISTS idx_vcal_session_id  ON public.video_call_activity_log (session_id);
CREATE INDEX IF NOT EXISTS idx_vcal_user_id     ON public.video_call_activity_log (user_id);
CREATE INDEX IF NOT EXISTS idx_vcal_ts          ON public.video_call_activity_log (ts DESC);

-- RLS: allow anon insert (from the video call page) and select (for history panel)
ALTER TABLE public.video_call_activity_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_anon_insert_activity" ON public.video_call_activity_log;
CREATE POLICY "allow_anon_insert_activity"
  ON public.video_call_activity_log
  FOR INSERT TO anon
  WITH CHECK (true);

DROP POLICY IF EXISTS "allow_anon_select_activity" ON public.video_call_activity_log;
CREATE POLICY "allow_anon_select_activity"
  ON public.video_call_activity_log
  FOR SELECT TO anon
  USING (true);
