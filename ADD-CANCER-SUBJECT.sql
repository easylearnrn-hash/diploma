-- ============================================
-- ADD CANCER SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Cancer subject (display_order = 18)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000018',
  'Cancer',
  'Oncology fundamentals, tumor grading, cancer types, risk factors, and oncologic nursing care',
  '🎗️',
  18,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 10 topics
--    IDs continue from Autoimmune/Infectious (which used ...0278–...0296)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000297', '10000000-0000-0000-0000-000000000018', 'Cancer Overview',                                      'Carcinogenesis, benign vs malignant, metastasis, cancer staging, and nursing priorities',       1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000298', '10000000-0000-0000-0000-000000000018', 'Tumor Grading',                                        'Grade I–IV differentiation, histologic grading vs clinical staging, and prognosis implications', 2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000299', '10000000-0000-0000-0000-000000000018', 'All Cancer Overview',                                  'Cancer treatment modalities: surgery, radiation, chemotherapy, immunotherapy, and targeted therapy', 3, true, 'published'),
  ('20000000-0000-0000-0000-000000000300', '10000000-0000-0000-0000-000000000018', 'Hematological (Blood) Cancers and Risk Factors',       'Leukemia, lymphoma, multiple myeloma — bone marrow suppression and transfusion care',           4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000301', '10000000-0000-0000-0000-000000000018', 'Gastrointestinal Cancers and Risk Factors',            'Colorectal, gastric, esophageal, and pancreatic cancer — screening, risk factors, and care',    5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000302', '10000000-0000-0000-0000-000000000018', 'Large Organ Cancers and Risk Factors',                 'Liver, kidney, and lung cancer — hepatocellular carcinoma, renal cell, NSCLC risk factors',     6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000303', '10000000-0000-0000-0000-000000000018', 'Small Cell Lung Cancer (SCLC)',                        'Neuroendocrine origin, paraneoplastic syndromes, SIADH, rapid progression, and chemoradiation',  7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000304', '10000000-0000-0000-0000-000000000018', 'Female Reproductive Cancers',                         'Breast, cervical, ovarian, and uterine cancer — BRCA, Pap smear, and staging-based care',       8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000305', '10000000-0000-0000-0000-000000000018', 'Male Reproductive Cancers and Risk Factors',           'Prostate, testicular, and penile cancer — PSA, self-exam, orchidectomy, and hormone therapy',   9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000306', '10000000-0000-0000-0000-000000000018', 'Skin Cancer',                                         'Basal cell, squamous cell, melanoma — ABCDE rule, Mohs surgery, and sun protection education',  10, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Cancer
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000018',
  '10000000-0000-0000-0000-000000000018',
  'Cancer – NCLEX Comprehensive Assessment',
  'Oncology fundamentals, tumor grading, cancer types, risk factors, and oncologic nursing care for NCLEX preparation',
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
-- VERIFICATION — should show all eighteen subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
