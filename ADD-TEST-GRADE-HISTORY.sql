-- ============================================================
-- TEST GRADE HISTORY TABLE
-- Stores every test attempt as a permanent grade entry.
-- Records are never deleted or overwritten — only appended.
-- Run this once in Supabase SQL Editor.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.test_grade_history (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Owner identifier: email or studentId from getOwnerId()
  owner_id      TEXT NOT NULL,

  -- Human-readable identity (for teacher lookup)
  student_name  TEXT,
  student_email TEXT,

  -- Test info
  test_title    TEXT NOT NULL,          -- e.g. "Test on Fundamentals"
  topics        TEXT,                   -- comma-joined topic names
  test_id       TEXT,                   -- TEST_CONFIG.testId

  -- Score
  score_percent INTEGER NOT NULL CHECK (score_percent >= 0 AND score_percent <= 100),
  letter_grade  CHAR(1) NOT NULL CHECK (letter_grade IN ('A','B','C','D','F')),
  correct_count INTEGER NOT NULL DEFAULT 0,
  incorrect_count INTEGER NOT NULL DEFAULT 0,
  total_questions INTEGER NOT NULL DEFAULT 0,

  -- Timestamp
  taken_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Indexes ─────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_tgh_owner_id   ON public.test_grade_history(owner_id);
CREATE INDEX IF NOT EXISTS idx_tgh_taken_at   ON public.test_grade_history(taken_at DESC);
CREATE INDEX IF NOT EXISTS idx_tgh_test_id    ON public.test_grade_history(test_id);

-- ── RLS ─────────────────────────────────────────────────────
ALTER TABLE public.test_grade_history ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'test_grade_history' AND policyname = 'anon_all_test_grade_history'
  ) THEN
    CREATE POLICY anon_all_test_grade_history
      ON public.test_grade_history FOR ALL TO anon USING (true) WITH CHECK (true);
  END IF;
END $$;

-- ── Verify ──────────────────────────────────────────────────
SELECT 'test_grade_history' AS table_name, count(*) AS rows
FROM public.test_grade_history;
