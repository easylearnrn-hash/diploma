-- ============================================================
-- Strip Google Gemini citation markers from test_questions
-- Affects: rationale, question_stem
-- Scope:   ALL questions
-- Markers: [cite_start]  [cite_end]  [cite: N]  [cite: N, M, ...]
-- Run in: Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Strip from rationale (all questions) — catches all [cite...] variants
UPDATE public.test_questions
SET rationale = TRIM(
  REGEXP_REPLACE(
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        rationale,
        '\[cite_start\]', '', 'gi'
      ),
      '\[cite_end\]', '', 'gi'
    ),
    '\[cite:[^\]]*\]', '', 'gi'
  )
)
WHERE rationale IS NOT NULL
  AND rationale ~ '\[cite';

-- 2. Strip from question_stem (all questions)
UPDATE public.test_questions
SET question_stem = TRIM(
  REGEXP_REPLACE(
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        question_stem,
        '\[cite_start\]', '', 'gi'
      ),
      '\[cite_end\]', '', 'gi'
    ),
    '\[cite:[^\]]*\]', '', 'gi'
  )
)
WHERE question_stem IS NOT NULL
  AND question_stem ~ '\[cite';

-- 3. Verify — should return 0 rows if all cleaned
SELECT id, display_order, category, question_stem, rationale
FROM public.test_questions
WHERE
  rationale    ~ '\[cite'
  OR question_stem ~ '\[cite'
ORDER BY display_order;
