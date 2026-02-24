-- ============================================
-- ADD RESPIRATORY SYSTEM SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Respiratory System subject (display_order = 6)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000006',
  'Respiratory System',
  'Pulmonary physiology, airway management, and respiratory disorder nursing care',
  '🫁',
  6,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 16 topics
--    IDs continue from Gastrointestinal (which used ...0083–...0124)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000125', '10000000-0000-0000-0000-000000000006', 'Physiology of Breathing',                              'Ventilation, perfusion, V/Q ratio, gas exchange, and acid-base balance',              1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000126', '10000000-0000-0000-0000-000000000006', 'Respiratory Medications',                              'Bronchodilators, corticosteroids, mucolytics, and oxygen therapy agents',              2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000127', '10000000-0000-0000-0000-000000000006', 'Incentive Spirometry and Pulmonary Hygiene',           'Post-op atelectasis prevention, deep breathing, chest physiotherapy',                 3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000128', '10000000-0000-0000-0000-000000000006', 'Mask Types and Respiratory System',                    'Nasal cannula, simple mask, Venturi, non-rebreather FiO2 ranges and indications',      4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000129', '10000000-0000-0000-0000-000000000006', 'Pleural Effusion',                                     'Transudative vs exudative, thoracentesis procedure and nursing care',                  5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000130', '10000000-0000-0000-0000-000000000006', 'Hemothorax and Pneumothorax',                          'Open vs tension pneumothorax, chest tube management, and water-seal drainage',         6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000131', '10000000-0000-0000-0000-000000000006', 'Tracheostomy',                                         'Indications, suctioning technique, cuff management, and stoma care',                  7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000132', '10000000-0000-0000-0000-000000000006', 'Sleep Apnea',                                          'Obstructive vs central, CPAP/BiPAP therapy, and pre/post-op precautions',              8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000133', '10000000-0000-0000-0000-000000000006', 'Chronic Obstructive Pulmonary Disease (COPD)',         'Hypoxic drive, barrel chest, pursed-lip breathing, and low-flow O2 management',       9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000134', '10000000-0000-0000-0000-000000000006', 'Chronic Bronchitis',                                   'Blue bloater, productive cough ≥3 months, airway inflammation and nursing care',       10, true, 'published'),
  ('20000000-0000-0000-0000-000000000135', '10000000-0000-0000-0000-000000000006', 'Asthma',                                               'Reversible bronchospasm, peak flow monitoring, rescue vs controller inhalers',         11, true, 'published'),
  ('20000000-0000-0000-0000-000000000136', '10000000-0000-0000-0000-000000000006', 'Emphysema',                                            'Pink puffer, alveolar destruction, pursed-lip breathing, nutrition support',           12, true, 'published'),
  ('20000000-0000-0000-0000-000000000137', '10000000-0000-0000-0000-000000000006', 'Pneumonia',                                            'Lobar vs broncho, community vs hospital-acquired, sputum culture, positioning',        13, true, 'published'),
  ('20000000-0000-0000-0000-000000000138', '10000000-0000-0000-0000-000000000006', 'Tuberculosis',                                         'AFB transmission, PPD/IGRA testing, airborne precautions, RIPE therapy',               14, true, 'published'),
  ('20000000-0000-0000-0000-000000000139', '10000000-0000-0000-0000-000000000006', 'Pulmonary Embolism',                                   'DVT source, Virchow''s triad, Homans'' sign, anticoagulation, and thrombolytics',     15, true, 'published'),
  ('20000000-0000-0000-0000-000000000140', '10000000-0000-0000-0000-000000000006', 'Acute Respiratory Distress Syndrome (ARDS)',           'Diffuse alveolar damage, Berlin criteria, low-tidal-volume ventilation, prone positioning', 16, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Respiratory System
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000006',
  '10000000-0000-0000-0000-000000000006',
  'Respiratory System – NCLEX Comprehensive Assessment',
  'Pulmonary physiology, airway management, and respiratory disorder nursing care for NCLEX preparation',
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
-- VERIFICATION — should show all six subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
