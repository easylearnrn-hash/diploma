-- ============================================
-- ADD ENGLISH SUBJECT & TOPICS
-- Subject display_order = 25
-- Subject ID: 10000000-0000-0000-0000-000000000025
-- Topic IDs: ...0396 – ...0403 (8 topics)
-- Test Config ID: 00000000-0000-0000-0000-000000000025
-- Run AFTER ADD-DRUG-CLASSES-SUBJECT.sql
-- ============================================

-- Step 1: Insert English subject
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000025',
  'English',
  'Grammar, syntax, clinical application of medical English, and advanced clinical scenario comprehension for nursing practice',
  '📝',
  25,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 8 topics
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000396', '10000000-0000-0000-0000-000000000025', 'Conjunctions and Connectors',         'Coordinating and subordinating conjunctions, conjunctive adverbs, and connectors in clinical sentences',                    1, true, 'published'),
  ('20000000-0000-0000-0000-000000000397', '10000000-0000-0000-0000-000000000025', 'Clauses, Modifiers, and Negation',    'Dependent/independent clauses, dangling modifiers, double negatives, and precise clinical language',                        2, true, 'published'),
  ('20000000-0000-0000-0000-000000000398', '10000000-0000-0000-0000-000000000025', 'Parallel Structure and Voice',        'Parallel grammatical construction and active vs. passive voice in nursing documentation and communication',                3, true, 'published'),
  ('20000000-0000-0000-0000-000000000399', '10000000-0000-0000-0000-000000000025', 'Clinical English Terminology',        'Medical terms in English sentences: febrile, orthostatic hypotension, NPO, PRN, tachycardia, and documentation phrasing',   4, true, 'published'),
  ('20000000-0000-0000-0000-000000000400', '10000000-0000-0000-0000-000000000025', 'Clinical Abbreviations in Context',   'Interpreting STAT, QID, BID, TID, PRN, NPO, and other abbreviations within clinical English sentences',                   5, true, 'published'),
  ('20000000-0000-0000-0000-000000000401', '10000000-0000-0000-0000-000000000025', 'Clinical Scenario Reading I',         'Intermediate comprehension: reading nursing shift notes, patient statements, and clinical orders in English',              6, true, 'published'),
  ('20000000-0000-0000-0000-000000000402', '10000000-0000-0000-0000-000000000025', 'Clinical Scenario Reading II',        'Advanced comprehension: complex conditional statements, implied meaning, and multi-step clinical English scenarios',         7, true, 'published'),
  ('20000000-0000-0000-0000-000000000403', '10000000-0000-0000-0000-000000000025', 'Professional Nursing Communication', 'Therapeutic communication phrases, professional language, patient education wording, and SBAR structure in English',       8, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Insert test config
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000025',
  '10000000-0000-0000-0000-000000000025',
  'English – Clinical Language & Grammar Assessment',
  'Grammar, syntax, clinical application of medical English, and advanced clinical scenario comprehension for nursing practice',
  60, 75, true, true, true, true, true
)
ON CONFLICT (id) DO UPDATE SET
  subject_id            = EXCLUDED.subject_id,
  title                 = EXCLUDED.title,
  description           = EXCLUDED.description,
  duration_minutes      = EXCLUDED.duration_minutes,
  passing_score_percent = EXCLUDED.passing_score_percent;

-- ============================================
-- VERIFICATION
-- ============================================
SELECT s.name, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
WHERE s.id = '10000000-0000-0000-0000-000000000025'
GROUP BY s.name, s.display_order;
