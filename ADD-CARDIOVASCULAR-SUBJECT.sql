-- ============================================
-- ADD CARDIOVASCULAR SYSTEM SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Cardiovascular System subject (display_order = 3)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000003',
  'Cardiovascular System',
  'Cardiac assessment, disorders, medications, and emergency management',
  '❤️',
  3,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 23 topics for Cardiovascular System
--    IDs continue from Neurology (which used ...0030–...0046)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000047', '10000000-0000-0000-0000-000000000003', 'Pacemakers and Implantable Cardioverter-Defibrillators (ICDs)',                   'Indications, settings, and nursing care for pacemakers and ICDs',                    1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000048', '10000000-0000-0000-0000-000000000003', 'Hypertension, Cardiac Output (CO), and Stroke Volume (SV)',                       'BP classification, CO/SV determinants, and antihypertensive management',             2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000049', '10000000-0000-0000-0000-000000000003', 'Pulses',                                                                          'Peripheral pulse assessment, grading scale, and abnormal findings',                  3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000050', '10000000-0000-0000-0000-000000000003', 'Heart Attack and Cardiac Arrest',                                                 'MI recognition, STEMI vs NSTEMI, and cardiac arrest response',                       4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000051', '10000000-0000-0000-0000-000000000003', 'Intravenous Gauges and Their Uses',                                               'IV catheter gauge selection for cardiac and emergency situations',                    5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000052', '10000000-0000-0000-0000-000000000003', 'Anticoagulants',                                                                  'Heparin, warfarin, DOACs, monitoring, reversal agents',                              6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000053', '10000000-0000-0000-0000-000000000003', 'Cardiomyopathy',                                                                  'Dilated, hypertrophic, and restrictive types with nursing management',               7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000054', '10000000-0000-0000-0000-000000000003', 'Infective Endocarditis',                                                          'Pathophysiology, Osler nodes, Janeway lesions, antibiotic therapy',                  8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000055', '10000000-0000-0000-0000-000000000003', 'Peripheral Vascular Disease (PVD), Peripheral Artery Disease (PAD), and DVT',    'Arterial vs venous insufficiency, DVT prophylaxis and management',                   9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000056', '10000000-0000-0000-0000-000000000003', 'Troponin, BNP, CK-MM, CK-MB, CK-BB, and BUN',                                   'Cardiac biomarkers, timing, interpretation, and clinical significance',              10, true, 'published'),
  ('20000000-0000-0000-0000-000000000057', '10000000-0000-0000-0000-000000000003', 'Blood, Vessels, and Lymphatics',                                                  'Vascular anatomy, blood components, and lymphatic function',                         11, true, 'published'),
  ('20000000-0000-0000-0000-000000000058', '10000000-0000-0000-0000-000000000003', 'Buerger''s Disease',                                                              'Thromboangiitis obliterans, risk factors, and nursing care',                         12, true, 'published'),
  ('20000000-0000-0000-0000-000000000059', '10000000-0000-0000-0000-000000000003', 'Coronary Artery Bypass Graft (CABG) and Percutaneous Coronary Intervention (PCI)', 'Pre/post-op care, stent management, and patient education',                         13, true, 'published'),
  ('20000000-0000-0000-0000-000000000060', '10000000-0000-0000-0000-000000000003', 'Cardiopulmonary Resuscitation (CPR)',                                             'BLS/ACLS protocols, compression ratios, and AED use',                               14, true, 'published'),
  ('20000000-0000-0000-0000-000000000061', '10000000-0000-0000-0000-000000000003', 'Pericarditis',                                                                    'Friction rub, pericardial effusion, and anti-inflammatory treatment',                15, true, 'published'),
  ('20000000-0000-0000-0000-000000000062', '10000000-0000-0000-0000-000000000003', 'Cardiovascular Medications',                                                      'Beta-blockers, ACE inhibitors, diuretics, nitrates, and antiarrhythmics',            16, true, 'published'),
  ('20000000-0000-0000-0000-000000000063', '10000000-0000-0000-0000-000000000003', 'Cardiac Tamponade',                                                               'Beck''s triad, pulsus paradoxus, pericardiocentesis nursing care',                   17, true, 'published'),
  ('20000000-0000-0000-0000-000000000064', '10000000-0000-0000-0000-000000000003', 'Shock Management and Emergency Care',                                             'Cardiogenic, hypovolemic, distributive, and obstructive shock interventions',        18, true, 'published'),
  ('20000000-0000-0000-0000-000000000065', '10000000-0000-0000-0000-000000000003', 'Electrocardiogram (EKG)',                                                         'Rhythm interpretation, P-QRS-T waves, common dysrhythmias',                         19, true, 'published'),
  ('20000000-0000-0000-0000-000000000066', '10000000-0000-0000-0000-000000000003', 'Heart Structure and Circulation',                                                 'Cardiac anatomy, conduction system, and coronary blood flow',                        20, true, 'published'),
  ('20000000-0000-0000-0000-000000000067', '10000000-0000-0000-0000-000000000003', 'Ischemic Heart Disease (IHD)',                                                    'Stable vs unstable angina, risk factors, and medical management',                    21, true, 'published'),
  ('20000000-0000-0000-0000-000000000068', '10000000-0000-0000-0000-000000000003', 'Right-Sided and Left-Sided Heart Failure',                                        'S/S differentiation, NYHA classification, and nursing interventions',               22, true, 'published'),
  ('20000000-0000-0000-0000-000000000069', '10000000-0000-0000-0000-000000000003', 'Vital Signs and Organ Prioritization',                                            'Hemodynamic monitoring and prioritization in cardiac emergencies',                   23, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Cardiovascular System
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000003',
  '10000000-0000-0000-0000-000000000003',
  'Cardiovascular System – NCLEX Comprehensive Assessment',
  'Cardiac disorders, medications, and emergency management for NCLEX preparation',
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
-- VERIFICATION — should show all three subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
