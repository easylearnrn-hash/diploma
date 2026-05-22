-- ══════════════════════════════════════════════════════════════
--  Add final_exam_status column to students table
--  Run in: https://supabase.com/dashboard → SQL Editor
-- ══════════════════════════════════════════════════════════════

ALTER TABLE public.students
  ADD COLUMN IF NOT EXISTS final_exam_status TEXT
    CHECK (final_exam_status IN ('pending', 'pass', 'fail'));
