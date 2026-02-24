-- ============================================
-- ADD MEDICAL-SURGICAL CARE SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Medical-Surgical Care subject (display_order = 15)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000015',
  'Medical-Surgical Care',
  'Perioperative nursing, surgical complications, shock management, and med-surg pharmacology',
  '🔬',
  15,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 7 topics
--    IDs continue from Pediatrics (which used ...0225–...0249)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000250', '10000000-0000-0000-0000-000000000015', 'Medical-Surgical Pharmacology',                        'Analgesics, anticoagulants, antibiotics, and high-alert medications in med-surg settings',   1, true, 'published'),
  ('20000000-0000-0000-0000-000000000251', '10000000-0000-0000-0000-000000000015', 'Orthopedic Postoperative Care',                        'Hip/knee replacement care, neurovascular checks, positioning, DVT prevention, and PT goals',  2, true, 'published'),
  ('20000000-0000-0000-0000-000000000252', '10000000-0000-0000-0000-000000000015', 'Preoperative and Postoperative Care',                  'Pre-op checklist, informed consent, NPO guidelines, PACU monitoring, and pain management',    3, true, 'published'),
  ('20000000-0000-0000-0000-000000000253', '10000000-0000-0000-0000-000000000015', 'Postoperative Surgical Emergencies and Complications', 'Hemorrhage, wound dehiscence, evisceration, pulmonary embolism, and ileus recognition',       4, true, 'published'),
  ('20000000-0000-0000-0000-000000000254', '10000000-0000-0000-0000-000000000015', 'Emergency, Shock, and Surgical Medications',           'Vasopressors, inotropes, thrombolytics, reversal agents, and rapid-sequence medications',      5, true, 'published'),
  ('20000000-0000-0000-0000-000000000255', '10000000-0000-0000-0000-000000000015', 'Shock Management and Emergency Care',                  'Hypovolemic, cardiogenic, distributive, and obstructive shock — assessment and interventions', 6, true, 'published'),
  ('20000000-0000-0000-0000-000000000256', '10000000-0000-0000-0000-000000000015', 'Medical-Surgical Priorities',                         'NCLEX-style prioritization, delegation, safety, and high-yield med-surg clinical scenarios',   7, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Medical-Surgical Care
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000015',
  '10000000-0000-0000-0000-000000000015',
  'Medical-Surgical Care – NCLEX Comprehensive Assessment',
  'Perioperative nursing, surgical complications, shock management, and med-surg pharmacology for NCLEX preparation',
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
-- VERIFICATION — should show all fifteen subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
