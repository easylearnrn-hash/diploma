-- ============================================================
-- ADD ANSWER SNAPSHOT TO TEST GRADE HISTORY
-- Stores answered questions + student answers (JSONB)
-- ============================================================

ALTER TABLE public.test_grade_history
  ADD COLUMN IF NOT EXISTS answered_snapshot JSONB;

COMMENT ON COLUMN public.test_grade_history.answered_snapshot IS
  'Answered questions snapshot: array of {index, id, stem, answers:[{id,text}]}. Only answered questions stored.';
