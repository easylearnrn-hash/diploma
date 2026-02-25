-- =====================================================
-- ARMENIAN LANGUAGE SUPPORT FOR TEST QUESTIONS
-- =====================================================
-- Purpose:  Add Armenian (hy) translations to test questions
--           and a frozen bilingual session snapshot to teacher_sessions.
--
-- Run this in Supabase SQL Editor ONCE.
-- All operations are idempotent (IF NOT EXISTS / DO $$ blocks).
-- =====================================================

-- ─────────────────────────────────────────
-- 1. test_questions — Armenian translation columns
-- ─────────────────────────────────────────

-- Armenian question stem
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'test_questions'
      AND column_name  = 'question_stem_hy'
  ) THEN
    ALTER TABLE public.test_questions
      ADD COLUMN question_stem_hy TEXT DEFAULT NULL;
    COMMENT ON COLUMN public.test_questions.question_stem_hy
      IS 'Armenian translation of the question stem. Same meaning, null if not yet translated.';
  END IF;
END $$;

-- Armenian answer options — same JSONB shape as `options`:
-- [{"id":"a","text":"Ընտրանք Ա"},{"id":"b","text":"Ընտրանք Բ"},…]
-- The `id` values MUST match the English options exactly (same letter keys).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'test_questions'
      AND column_name  = 'options_hy'
  ) THEN
    ALTER TABLE public.test_questions
      ADD COLUMN options_hy JSONB DEFAULT NULL;
    COMMENT ON COLUMN public.test_questions.options_hy
      IS 'Armenian translation of answer options. Must keep identical id values (a/b/c/d) as English options so correct_answers still maps correctly.';
  END IF;
END $$;

-- Armenian rationale / explanation
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'test_questions'
      AND column_name  = 'rationale_hy'
  ) THEN
    ALTER TABLE public.test_questions
      ADD COLUMN rationale_hy TEXT DEFAULT NULL;
    COMMENT ON COLUMN public.test_questions.rationale_hy
      IS 'Armenian translation of the answer rationale/explanation.';
  END IF;
END $$;

-- ─────────────────────────────────────────
-- 2. teacher_sessions — frozen bilingual snapshot columns
-- ─────────────────────────────────────────
-- These store the FINAL shuffled question array (both languages) so every
-- device connected to the same session ALWAYS gets the exact same content
-- and order regardless of when they join or which language they pick.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'teacher_sessions'
      AND column_name  = 'session_snapshot_en'
  ) THEN
    ALTER TABLE public.teacher_sessions
      ADD COLUMN session_snapshot_en JSONB DEFAULT NULL;
    COMMENT ON COLUMN public.teacher_sessions.session_snapshot_en
      IS 'Frozen English question array [{id,stem,options,correct,rationale,multi,points,category}…] generated once at session creation. Never changes.';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'teacher_sessions'
      AND column_name  = 'session_snapshot_hy'
  ) THEN
    ALTER TABLE public.teacher_sessions
      ADD COLUMN session_snapshot_hy JSONB DEFAULT NULL;
    COMMENT ON COLUMN public.teacher_sessions.session_snapshot_hy
      IS 'Frozen Armenian question array — same order and correct-answer IDs as session_snapshot_en, only text fields differ. null if no Armenian translation available.';
  END IF;
END $$;

-- ─────────────────────────────────────────
-- 3. Helpful index so translation queries are fast
-- ─────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_test_questions_has_hy
  ON public.test_questions ((question_stem_hy IS NOT NULL));

-- ─────────────────────────────────────────
-- 4. Quick verification
-- ─────────────────────────────────────────
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'test_questions'
--   AND column_name IN ('question_stem_hy','options_hy','rationale_hy');

-- SELECT column_name FROM information_schema.columns
-- WHERE table_name = 'teacher_sessions'
--   AND column_name IN ('session_snapshot_en','session_snapshot_hy');

-- ─────────────────────────────────────────
-- 5. Example: add an Armenian translation to an existing question
-- ─────────────────────────────────────────
-- UPDATE public.test_questions
-- SET
--   question_stem_hy = 'Ի՞նչ է թթվածնի նորմալ հագեցվածությունը մեծահասակ հիվանդի համար:',
--   options_hy = '[
--     {"id":"a","text":"85-90%"},
--     {"id":"b","text":"94-100%"},
--     {"id":"c","text":"75-85%"},
--     {"id":"d","text":"60-70%"}
--   ]'::jsonb,
--   rationale_hy = 'Թթվածնի նորմալ հագեցվածությունը (SpO2) 94-100% է։ 94%-ից ցածր արժեքը թթվածնային թերապիայի կարիք է ցույց տալիս։'
-- WHERE id = '<question-uuid-here>';
