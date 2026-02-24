-- ============================================
-- ADD ENDOCRINE SYSTEM SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Endocrine System subject (display_order = 4)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000004',
  'Endocrine System',
  'Hormonal regulation, diabetes management, and endocrine disorders',
  '⚗️',
  4,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 13 topics for Endocrine System
--    IDs continue from Cardiovascular (which used ...0047–...0069)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000070', '10000000-0000-0000-0000-000000000004', 'Diabetes Mellitus',                                                                    'Type 1 vs Type 2, pathophysiology, complications, and nursing management',            1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000071', '10000000-0000-0000-0000-000000000004', 'Insulin Patch',                                                                        'Transdermal insulin delivery, application sites, and patient education',               2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000072', '10000000-0000-0000-0000-000000000004', 'Insulin Storage and Checking',                                                         'Refrigeration guidelines, expiration, and visual inspection before use',               3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000073', '10000000-0000-0000-0000-000000000004', 'Insulin',                                                                              'Rapid, short, intermediate, long-acting types, onset/peak/duration',                   4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000074', '10000000-0000-0000-0000-000000000004', 'Mixing of Insulin Guidelines',                                                         'Draw clear before cloudy, compatibility rules, and safe mixing technique',             5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000075', '10000000-0000-0000-0000-000000000004', 'Metformin',                                                                            'Mechanism, contraindications (renal/contrast), lactic acidosis risk',                 6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000076', '10000000-0000-0000-0000-000000000004', 'Endocrine Medications',                                                                'Oral antidiabetics, thyroid agents, steroids, and hormonal therapies',                7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000077', '10000000-0000-0000-0000-000000000004', 'Thyroid Gland and Its Hormones',                                                       'T3, T4, TSH regulation, feedback loop, and lab interpretation',                       8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000078', '10000000-0000-0000-0000-000000000004', 'Thyroid Gland',                                                                        'Hypothyroidism vs hyperthyroidism, Hashimoto''s, Graves'' disease, nursing care',    9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000079', '10000000-0000-0000-0000-000000000004', 'Parathyroid Disorders',                                                                'Hypo/hyperparathyroidism, calcium regulation, Chvostek and Trousseau signs',          10, true, 'published'),
  ('20000000-0000-0000-0000-000000000080', '10000000-0000-0000-0000-000000000004', 'Diabetes Insipidus and Syndrome of Inappropriate Antidiuretic Hormone (SIADH)',        'ADH dysregulation, urine/serum osmolality, fluid management',                         11, true, 'published'),
  ('20000000-0000-0000-0000-000000000081', '10000000-0000-0000-0000-000000000004', 'Adrenal Gland – Addison''s Disease and Cushing''s Disease',                           'Cortisol excess vs deficiency, moon face, adrenal crisis, steroid taper',             12, true, 'published'),
  ('20000000-0000-0000-0000-000000000082', '10000000-0000-0000-0000-000000000004', 'Diabetic Ketoacidosis (DKA) and Hyperosmolar Hyperglycemic Nonketotic Syndrome (HHNS)', 'Triggers, lab differences, fluid/insulin protocols, and nursing priorities',           13, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Endocrine System
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000004',
  '10000000-0000-0000-0000-000000000004',
  'Endocrine System – NCLEX Comprehensive Assessment',
  'Hormonal regulation, diabetes management, and endocrine disorders for NCLEX preparation',
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
-- VERIFICATION — should show all four subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
