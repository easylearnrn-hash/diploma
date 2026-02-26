-- ============================================
-- FIX: English Subject — Ensure everything
--      is in place and active
-- Run this ONE file in Supabase SQL Editor
-- ============================================

-- Step 1: Ensure subject exists and is active
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000025',
  'English',
  'Grammar, syntax, clinical application of medical English, and advanced clinical scenario comprehension for nursing practice',
  '📝',
  25,
  true
)
ON CONFLICT (id) DO UPDATE SET
  is_active     = true,
  display_order = EXCLUDED.display_order;

-- Step 2: Ensure test config exists (required FK for questions)
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000025',
  '10000000-0000-0000-0000-000000000025',
  'English – Clinical Language & Grammar Assessment',
  'Grammar, syntax, clinical application of medical English, and advanced clinical scenario comprehension for nursing practice',
  60, 75, true, true, true, true, true
)
ON CONFLICT (id) DO UPDATE SET
  is_active  = true,
  subject_id = EXCLUDED.subject_id;

-- Step 3: Ensure all 8 topics exist and are published
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000396', '10000000-0000-0000-0000-000000000025', 'Conjunctions and Connectors',        'Coordinating and subordinating conjunctions, conjunctive adverbs', 1, true, 'published'),
  ('20000000-0000-0000-0000-000000000397', '10000000-0000-0000-0000-000000000025', 'Clauses, Modifiers, and Negation',   'Dependent/independent clauses, dangling modifiers, double negatives', 2, true, 'published'),
  ('20000000-0000-0000-0000-000000000398', '10000000-0000-0000-0000-000000000025', 'Parallel Structure and Voice',       'Parallel grammatical construction and active vs. passive voice', 3, true, 'published'),
  ('20000000-0000-0000-0000-000000000399', '10000000-0000-0000-0000-000000000025', 'Clinical English Terminology',       'Medical terms in English: febrile, orthostatic hypotension, NPO, PRN, tachycardia', 4, true, 'published'),
  ('20000000-0000-0000-0000-000000000400', '10000000-0000-0000-0000-000000000025', 'Clinical Abbreviations in Context',  'Interpreting STAT, QID, BID, TID, PRN, NPO in clinical sentences', 5, true, 'published'),
  ('20000000-0000-0000-0000-000000000401', '10000000-0000-0000-0000-000000000025', 'Clinical Scenario Reading I',        'Intermediate comprehension: nursing shift notes and clinical orders in English', 6, true, 'published'),
  ('20000000-0000-0000-0000-000000000402', '10000000-0000-0000-0000-000000000025', 'Clinical Scenario Reading II',       'Advanced comprehension: complex conditionals and multi-step clinical scenarios', 7, true, 'published'),
  ('20000000-0000-0000-0000-000000000403', '10000000-0000-0000-0000-000000000025', 'Professional Nursing Communication', 'Therapeutic communication phrases and SBAR structure in English', 8, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  is_active = true,
  status    = 'published';

-- Step 4: Activate any English questions already in the table
-- (in case they were inserted but defaulted to is_active = false/null)
UPDATE test_questions
SET is_active = true
WHERE test_id = '00000000-0000-0000-0000-000000000025';

-- Step 5: Verify counts
SELECT
  'Questions active'    AS check_name,
  COUNT(*)              AS count
FROM test_questions
WHERE test_id  = '00000000-0000-0000-0000-000000000025'
  AND is_active = true

UNION ALL

SELECT 'Total questions (all)', COUNT(*)
FROM test_questions
WHERE test_id = '00000000-0000-0000-0000-000000000025'

UNION ALL

SELECT 'Topics published', COUNT(*)
FROM test_topics
WHERE subject_id = '10000000-0000-0000-0000-000000000025'
  AND status = 'published'

UNION ALL

SELECT 'Config exists', COUNT(*)
FROM test_configs
WHERE id = '00000000-0000-0000-0000-000000000025';

-- ============================================
-- IF "Total questions (all)" = 0 after running
-- this, it means the question INSERT files
-- failed silently due to the FK. In that case,
-- re-run these files IN ORDER in the SQL Editor:
--   1. ADD-ENGLISH-SUBJECT.sql        (already done above)
--   2. ADD-ENGLISH-100-QUESTIONS.sql
--   3. ADD-ENGLISH-100-QUESTIONS-2.sql
--   4. ADD-ENGLISH-100-QUESTIONS-3.sql
-- ============================================
