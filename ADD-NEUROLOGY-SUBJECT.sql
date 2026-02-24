-- ============================================
-- ADD NEUROLOGY SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- ============================================

-- 1. Insert Neurology subject (display_order = 2, after Fundamentals)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000002',
  'Neurology',
  'Neurological assessment, disorders, and nursing management',
  '🧠',
  2,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- 2. Insert 17 topics for Neurology
--    IDs continue from Fundamentals (which used ...0001–...0029)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000030', '10000000-0000-0000-0000-000000000002', 'Orientation',                                      'Levels of consciousness and orientation assessment',          1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000031', '10000000-0000-0000-0000-000000000002', 'Clonus',                                           'Assessment and significance of clonus reflex',               2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000032', '10000000-0000-0000-0000-000000000002', 'Twelve Cranial Nerves',                            'Functions and assessment of CN I–XII',                       3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000033', '10000000-0000-0000-0000-000000000002', 'Autonomic Nervous System (ANS)',                   'Sympathetic and parasympathetic pathways and effects',       4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000034', '10000000-0000-0000-0000-000000000002', 'Cerebral Palsy (CP)',                              'Types, presentation, and nursing care for CP',               5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000035', '10000000-0000-0000-0000-000000000002', 'Glasgow Coma Scale (GCS)',                         'Scoring eye, verbal, and motor responses',                   6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000036', '10000000-0000-0000-0000-000000000002', 'Neuroimaging and Diagnostics',                     'CT, MRI, EEG, LP interpretations and nursing implications',  7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000037', '10000000-0000-0000-0000-000000000002', 'Spinal Cord Injury (SCI) Syndrome Types',          'Central, anterior, Brown-Séquard, posterior cord syndromes', 8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000038', '10000000-0000-0000-0000-000000000002', 'Stroke',                                           'Ischemic vs hemorrhagic, FAST, tPA, nursing management',     9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000039', '10000000-0000-0000-0000-000000000002', 'Sympathetic vs. Parasympathetic Nervous System',   'Fight-or-flight vs rest-and-digest responses',               10, true, 'published'),
  ('20000000-0000-0000-0000-000000000040', '10000000-0000-0000-0000-000000000002', 'Seizure Disorders',                                'Types of seizures, medications, and safety interventions',    11, true, 'published'),
  ('20000000-0000-0000-0000-000000000041', '10000000-0000-0000-0000-000000000002', 'Increased Intracranial Pressure (ICP)',             'Cushing triad, herniation, ICP monitoring and management',   12, true, 'published'),
  ('20000000-0000-0000-0000-000000000042', '10000000-0000-0000-0000-000000000002', 'Cerebral Aneurysms',                               'Rupture signs, Hunt-Hess scale, aneurysm care',              13, true, 'published'),
  ('20000000-0000-0000-0000-000000000043', '10000000-0000-0000-0000-000000000002', 'Multiple Sclerosis (MS)',                          'Demyelination, relapse triggers, and nursing care',          14, true, 'published'),
  ('20000000-0000-0000-0000-000000000044', '10000000-0000-0000-0000-000000000002', 'Parkinson''s Disease',                             'Dopamine deficiency, TRAP symptoms, levodopa care',          15, true, 'published'),
  ('20000000-0000-0000-0000-000000000045', '10000000-0000-0000-0000-000000000002', 'Spinal Cord Injury (SCI)',                         'Complete vs incomplete, autonomic dysreflexia, rehab',       16, true, 'published'),
  ('20000000-0000-0000-0000-000000000046', '10000000-0000-0000-0000-000000000002', 'Vertigo and Ménière''s Disease',                  'Vestibular dysfunction, Epley maneuver, low-sodium diet',    17, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- 3. Create test config for Neurology
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000002',
  'Neurology – NCLEX Comprehensive Assessment',
  'Neurological disorders, assessment, and nursing management for NCLEX preparation',
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
-- VERIFICATION
-- ============================================
SELECT s.name AS subject, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id
GROUP BY s.name
ORDER BY s.name;
