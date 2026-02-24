-- ============================================
-- ADD FLUIDS, ELECTROLYTES, AND NUTRITION SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert subject (display_order = 8)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000008',
  'Fluids, Electrolytes, and Nutrition',
  'IV therapy, electrolyte imbalances, acid-base balance, and ABG interpretation',
  '💧',
  8,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 5 topics
--    IDs continue from Renal (which used ...0141–...0159)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000160', '10000000-0000-0000-0000-000000000008', 'Fluids, Electrolytes, and Acid-Base IV Therapy Medications', 'Isotonic, hypotonic, hypertonic solutions, electrolyte additives, and IV drug compatibility',  1, true, 'published'),
  ('20000000-0000-0000-0000-000000000161', '10000000-0000-0000-0000-000000000008', 'Electrolyte Imbalances Overview',                           'Sodium, potassium, calcium, magnesium, phosphorus — hypo/hyper states and interventions',      2, true, 'published'),
  ('20000000-0000-0000-0000-000000000162', '10000000-0000-0000-0000-000000000008', 'IV Therapy and Complications',                              'Infiltration, phlebitis, extravasation, air embolism, speed shock, and site assessment',       3, true, 'published'),
  ('20000000-0000-0000-0000-000000000163', '10000000-0000-0000-0000-000000000008', 'Acid-Base Balance and IV Therapy Overview',                 'pH, bicarbonate, PaCO2 relationships; respiratory vs metabolic acidosis and alkalosis',        4, true, 'published'),
  ('20000000-0000-0000-0000-000000000164', '10000000-0000-0000-0000-000000000008', 'Arterial Blood Gas (ABG) Compensation',                     'Rome/TICLS method, partial vs full compensation, expected compensatory responses',             5, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000008',
  '10000000-0000-0000-0000-000000000008',
  'Fluids, Electrolytes, and Nutrition – NCLEX Comprehensive Assessment',
  'IV therapy, electrolyte imbalances, acid-base balance, and ABG interpretation for NCLEX preparation',
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
-- VERIFICATION — should show all eight subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
