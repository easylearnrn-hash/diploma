-- ============================================
-- ADD PSYCHO-SOCIAL ASPECTS SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Psycho-Social Aspects subject (display_order = 20)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000020',
  'Psycho-Social Aspects',
  'Abuse, aging, end-of-life care, and the psychosocial dimensions of nursing practice',
  '🤝',
  20,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 3 topics
--    IDs continue from Musculoskeletal (which used ...0307–...0314)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000315', '10000000-0000-0000-0000-000000000020', 'Abuse and Violence',                           'Child, elder, and intimate partner abuse — mandatory reporting, safety planning, and trauma-informed care', 1, true, 'published'),
  ('20000000-0000-0000-0000-000000000316', '10000000-0000-0000-0000-000000000020', 'Aging: Physiological and Psychosocial Changes', 'Normal vs abnormal aging, polypharmacy risks, sensory changes, and promoting independence in older adults',  2, true, 'published'),
  ('20000000-0000-0000-0000-000000000317', '10000000-0000-0000-0000-000000000020', 'End-of-Life Care',                             'Palliative vs hospice care, Kübler-Ross stages, comfort measures, advance directives, and family support',  3, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Psycho-Social Aspects
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000020',
  '10000000-0000-0000-0000-000000000020',
  'Psycho-Social Aspects – NCLEX Comprehensive Assessment',
  'Abuse, aging, end-of-life care, and the psychosocial dimensions of nursing practice for NCLEX preparation',
  60,
  75,
  true,
  true,
  true,
  true,
  true
)
ON CONFLICT (id) DO UPDATE SET
  subject_id            = EXCLUDED.subject_id,
  title                 = EXCLUDED.title,
  description           = EXCLUDED.description,
  duration_minutes      = EXCLUDED.duration_minutes,
  passing_score_percent = EXCLUDED.passing_score_percent;

-- ============================================
-- VERIFICATION — should show all twenty subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
