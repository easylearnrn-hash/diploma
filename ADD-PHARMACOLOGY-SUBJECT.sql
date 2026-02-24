-- ============================================
-- ADD PHARMACOLOGY SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Pharmacology subject (display_order = 21)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000021',
  'Pharmacology',
  'Drug calculations, medication safety, system-based pharmacology, and high-alert medication management',
  '💊',
  21,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 19 topics
--    IDs continue from Psycho-Social (which used ...0315–...0317)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000318', '10000000-0000-0000-0000-000000000021', 'General Pharmacology',                                     'Pharmacokinetics, pharmacodynamics, drug interactions, half-life, and therapeutic index',          1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000319', '10000000-0000-0000-0000-000000000021', 'Medication Calculation and Administration',                 'Rights of medication administration, routes, injection techniques, and safe handling',            2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000320', '10000000-0000-0000-0000-000000000021', 'Nursing Drug Dosage Mathematics',                          'Dimensional analysis, drip rate calculations, weight-based dosing, and unit conversions',         3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000321', '10000000-0000-0000-0000-000000000021', 'High-Alert Medications and Safety Protocols',              'Insulin, heparin, opioids, chemotherapy — ISMP list, double-check systems, and error prevention',  4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000322', '10000000-0000-0000-0000-000000000021', 'Respiratory Medications',                                  'Bronchodilators, corticosteroids, mucolytics, oxygen therapy, and inhaler technique education',    5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000323', '10000000-0000-0000-0000-000000000021', 'Gastrointestinal Medications',                             'Antacids, H2 blockers, PPIs, antiemetics, laxatives, antidiarrheals, and prokinetics',            6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000324', '10000000-0000-0000-0000-000000000021', 'Ear, Nose, Throat, and Upper Airway Medications',          'Otic drops, decongestants, antihistamines, nasal corticosteroids, and throat lozenges',           7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000325', '10000000-0000-0000-0000-000000000021', 'Cardiovascular Medications',                               'Beta blockers, calcium channel blockers, ACE inhibitors, ARBs, nitrates, and antiarrhythmics',    8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000326', '10000000-0000-0000-0000-000000000021', 'Endocrine Medications',                                    'Insulin types, oral antidiabetics, thyroid agents, corticosteroids, and hormonal therapies',      9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000327', '10000000-0000-0000-0000-000000000021', 'Renal and Urinary Medications',                            'Diuretics, ACE inhibitors, phosphate binders, erythropoietin, and urinary antispasmodics',        10, true, 'published'),
  ('20000000-0000-0000-0000-000000000328', '10000000-0000-0000-0000-000000000021', 'Infectious Disease Medications',                           'Antibiotics (classes, spectra, resistance), antivirals, antifungals, and antiparasitic agents',   11, true, 'published'),
  ('20000000-0000-0000-0000-000000000329', '10000000-0000-0000-0000-000000000021', 'Autoimmune and Inflammatory Disorder Medications',         'DMARDs, biologics, NSAIDs, corticosteroids, and immunosuppressant monitoring',                   12, true, 'published'),
  ('20000000-0000-0000-0000-000000000330', '10000000-0000-0000-0000-000000000021', 'Mental Health Medications',                                'Antipsychotics, antidepressants, mood stabilizers, anxiolytics, EPS, and lithium toxicity',       13, true, 'published'),
  ('20000000-0000-0000-0000-000000000331', '10000000-0000-0000-0000-000000000021', 'Pediatric Medications',                                    'Weight-based dosing, acetaminophen/ibuprofen limits, aspirin avoidance, and liquid conversions',   14, true, 'published'),
  ('20000000-0000-0000-0000-000000000332', '10000000-0000-0000-0000-000000000021', 'Maternal Health Medications',                              'Oxytocin, magnesium sulfate, terbutaline, RhoGAM, tocolytics, and teratogen classification',      15, true, 'published'),
  ('20000000-0000-0000-0000-000000000333', '10000000-0000-0000-0000-000000000021', 'Emergency, Shock, and Surgical Medications',               'Vasopressors, inotropes, thrombolytics, reversal agents, and rapid-sequence intubation drugs',    16, true, 'published'),
  ('20000000-0000-0000-0000-000000000334', '10000000-0000-0000-0000-000000000021', 'Burn and Dermatology Medications',                         'Silver sulfadiazine, topical antibiotics, corticosteroids, antihistamines, and retinoids',        17, true, 'published'),
  ('20000000-0000-0000-0000-000000000335', '10000000-0000-0000-0000-000000000021', 'Fluids, Electrolytes, and Intravenous Therapy Medications','Isotonic/hypotonic/hypertonic solutions, electrolyte replacements, and TPN components',           18, true, 'published'),
  ('20000000-0000-0000-0000-000000000336', '10000000-0000-0000-0000-000000000021', 'Nursing Overview of Common Medications',                   'High-yield NCLEX drug classes, common side effects, priority nursing assessments, and patient education', 19, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Pharmacology
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000021',
  '10000000-0000-0000-0000-000000000021',
  'Pharmacology – NCLEX Comprehensive Assessment',
  'Drug calculations, medication safety, system-based pharmacology, and high-alert medication management for NCLEX preparation',
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
-- VERIFICATION — should show all twenty-one subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
