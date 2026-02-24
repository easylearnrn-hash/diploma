-- ============================================
-- ADD MEDICAL TERMINOLOGY SUBJECT & TOPICS
-- Subject display_order = 22
-- Topic IDs: ...0337 – ...0352 (16 topics)
-- Run AFTER ADD-PHARMACOLOGY-SUBJECT.sql
-- ============================================

INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000022',
  'Medical Terminology',
  'Word roots, prefixes, suffixes, abbreviations, and body-system terminology used in clinical nursing practice',
  '📖',
  22,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000337', '10000000-0000-0000-0000-000000000022', 'Word Roots, Prefixes, and Suffixes',              'Breaking down medical words: roots (cardi-, hepat-, neur-), prefixes (tachy-, brady-), and suffixes (-itis, -ectomy, -ology)',  1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000338', '10000000-0000-0000-0000-000000000022', 'Body Planes, Directions, and Positions',          'Anatomical position, planes (sagittal, coronal, transverse), directional terms (proximal, distal, medial, lateral)',           2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000339', '10000000-0000-0000-0000-000000000022', 'Integumentary System Terminology',               'Skin lesion terms, wound descriptors, and dermatology vocabulary',                                                         3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000340', '10000000-0000-0000-0000-000000000022', 'Musculoskeletal Terminology',                    'Bone, muscle, and joint terms: fractures, arthro-, osteo-, myopathy, and range-of-motion vocabulary',                      4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000341', '10000000-0000-0000-0000-000000000022', 'Cardiovascular Terminology',                     'Cardio-, angio-, athero-, hemo- terms; arrhythmia names, hemodynamic vocabulary, and diagnostic test terms',                5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000342', '10000000-0000-0000-0000-000000000022', 'Respiratory Terminology',                        'Pulmo-, pneumo-, broncho- terms; breath sounds, ventilation vocabulary, and ABG terminology',                             6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000343', '10000000-0000-0000-0000-000000000022', 'Gastrointestinal Terminology',                   'Gastro-, hepato-, entero-, colono- terms; stool descriptors, surgical suffixes (-ostomy, -scopy)',                        7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000344', '10000000-0000-0000-0000-000000000022', 'Renal and Urinary Terminology',                  'Nephro-, cysto-, uro- terms; urine characteristics, dialysis vocabulary, and renal lab terminology',                      8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000345', '10000000-0000-0000-0000-000000000022', 'Neurological Terminology',                       'Neuro-, encephalo-, myelo- terms; consciousness levels, reflex vocabulary, and neuroimaging terms',                       9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000346', '10000000-0000-0000-0000-000000000022', 'Endocrine Terminology',                          'Endo-, thyro-, adren-, glyco- terms; hormone names, feedback loop vocabulary, and diabetes terminology',                 10, true, 'published'),
  ('20000000-0000-0000-0000-000000000347', '10000000-0000-0000-0000-000000000022', 'Reproductive and Obstetric Terminology',         'Gravida, para, OB terms, gynecological vocabulary, and reproductive anatomy terminology',                                 11, true, 'published'),
  ('20000000-0000-0000-0000-000000000348', '10000000-0000-0000-0000-000000000022', 'Ophthalmic and Otic Terminology',                'Eye (ophthalmo-, ocul-) and ear (oto-, auri-) terms; visual acuity vocabulary, hearing assessment terms',                 12, true, 'published'),
  ('20000000-0000-0000-0000-000000000349', '10000000-0000-0000-0000-000000000022', 'Oncology Terminology',                           'Tumor nomenclature, -oma/-carcinoma/-sarcoma, staging vocabulary, and chemotherapy terms',                                13, true, 'published'),
  ('20000000-0000-0000-0000-000000000350', '10000000-0000-0000-0000-000000000022', 'Immunology and Infectious Disease Terminology',  'Immuno-, path-, septic- terms; isolation precaution vocabulary and microbiology terminology',                              14, true, 'published'),
  ('20000000-0000-0000-0000-000000000351', '10000000-0000-0000-0000-000000000022', 'Clinical Abbreviations and Documentation Terms', 'Common nursing abbreviations (NPO, PRN, STAT, QID), charting terms, and order transcription vocabulary',                  15, true, 'published'),
  ('20000000-0000-0000-0000-000000000352', '10000000-0000-0000-0000-000000000022', 'Pharmacology Terminology',                       'Drug name suffixes (-olol, -pril, -statin, -mycin), pharmacokinetic terms, and medication administration abbreviations',   16, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000022',
  '10000000-0000-0000-0000-000000000022',
  'Medical Terminology – NCLEX Comprehensive Assessment',
  'Word roots, prefixes, suffixes, abbreviations, and body-system terminology used in clinical nursing practice',
  60, 75, true, true, true, true, true
)
ON CONFLICT (id) DO UPDATE SET
  subject_id            = EXCLUDED.subject_id,
  title                 = EXCLUDED.title,
  description           = EXCLUDED.description,
  duration_minutes      = EXCLUDED.duration_minutes,
  passing_score_percent = EXCLUDED.passing_score_percent;

-- VERIFICATION
SELECT s.name, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
WHERE s.id = '10000000-0000-0000-0000-000000000022'
GROUP BY s.name, s.display_order;
