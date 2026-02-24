-- ============================================
-- ADD EYE DISORDERS SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Eye Disorders subject (display_order = 9)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000009',
  'Eye Disorders',
  'Ocular anatomy, vision disorders, eye infections, and ophthalmic nursing care',
  '👁️',
  9,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 10 topics
--    IDs continue from Fluids/Electrolytes (which used ...0160–...0164)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000165', '10000000-0000-0000-0000-000000000009', 'Eye Anatomy',                                              'Ocular structures, layers of the eye, visual pathway, and intraocular pressure',          1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000166', '10000000-0000-0000-0000-000000000009', 'Vision Disorders',                                         'Myopia, hyperopia, astigmatism, presbyopia, and corrective interventions',               2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000167', '10000000-0000-0000-0000-000000000009', 'Conjunctivitis',                                           'Bacterial, viral, and allergic types; transmission prevention and treatment',            3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000168', '10000000-0000-0000-0000-000000000009', 'Conjunctivitis vs. Keratitis',                             'Differentiating superficial vs corneal infection; pain, photophobia, and urgency',       4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000169', '10000000-0000-0000-0000-000000000009', 'Cataracts',                                                'Lens opacity, risk factors, phacoemulsification, and post-op nursing care',              5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000170', '10000000-0000-0000-0000-000000000009', 'Glaucoma',                                                 'Open-angle vs closed-angle, IOP management, timolol, pilocarpine, and visual field loss', 6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000171', '10000000-0000-0000-0000-000000000009', 'Macular Degeneration (Age-Related Macular Degeneration – AMD)', 'Dry vs wet AMD, Amsler grid, anti-VEGF injections, and low-vision adaptation',        7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000172', '10000000-0000-0000-0000-000000000009', 'Diabetic Retinopathy (DR)',                                'Nonproliferative vs proliferative, laser photocoagulation, and glycemic control',       8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000173', '10000000-0000-0000-0000-000000000009', 'Retinal Detachment',                                      'Flashes/floaters, curtain vision, surgical repair, and post-op positioning',            9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000174', '10000000-0000-0000-0000-000000000009', 'Ophthalmic (Eye) Medication Administration',              'Eye drop technique, conjunctival sac instillation, nasolacrimal occlusion',             10, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Eye Disorders
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000009',
  '10000000-0000-0000-0000-000000000009',
  'Eye Disorders – NCLEX Comprehensive Assessment',
  'Ocular anatomy, vision disorders, eye infections, and ophthalmic nursing care for NCLEX preparation',
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
-- VERIFICATION — should show all nine subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
