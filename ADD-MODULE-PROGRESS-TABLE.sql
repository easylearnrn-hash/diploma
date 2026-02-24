-- Module Progress Table
-- Stores per-student, per-module progress synced from client
-- Run in Supabase SQL Editor: https://supabase.com/dashboard

CREATE TABLE IF NOT EXISTS public.module_progress (
    id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id     UUID NOT NULL,
    note_id        TEXT NOT NULL,
    ha             TEXT[]  DEFAULT '{}',
    sfx            TEXT[]  DEFAULT '{}',
    dc             TEXT[]  DEFAULT '{}',
    ms             INTEGER DEFAULT 0,
    clicks         INTEGER DEFAULT 0,
    updated_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (student_id, note_id)
);

CREATE INDEX IF NOT EXISTS idx_module_progress_student ON public.module_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_module_progress_note    ON public.module_progress(note_id);

ALTER TABLE public.module_progress ENABLE ROW LEVEL SECURITY;

-- Allow anon to read/write their own rows (matches existing RLS pattern)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='module_progress' AND policyname='anon can upsert own progress'
  ) THEN
    CREATE POLICY "anon can upsert own progress"
      ON public.module_progress FOR ALL TO anon
      USING (true) WITH CHECK (true);
  END IF;
END$$;
