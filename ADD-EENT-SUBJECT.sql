-- ============================================
-- ADD EAR, EYE, NOSE, AND THROAT (EENT) SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert EENT subject (display_order = 10)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000010',
  'Ear, Eye, Nose, and Throat (EENT)',
  'Sensory organ assessment, EENT disorders, upper airway conditions, and related medications',
  '👂',
  10,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 6 topics
--    IDs continue from Eye Disorders (which used ...0165–...0174)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000175', '10000000-0000-0000-0000-000000000010', 'Ear',                                                      'Anatomy, hearing assessment, otitis media/externa, cerumen impaction, and hearing aids',   1, true, 'published'),
  ('20000000-0000-0000-0000-000000000176', '10000000-0000-0000-0000-000000000010', 'Nose',                                                     'Nasal anatomy, epistaxis management, sinusitis, and nasal polyps',                        2, true, 'published'),
  ('20000000-0000-0000-0000-000000000177', '10000000-0000-0000-0000-000000000010', 'Throat and Upper Airway',                                  'Pharyngitis, tonsillitis, laryngitis, strep throat, and airway obstruction management',    3, true, 'published'),
  ('20000000-0000-0000-0000-000000000178', '10000000-0000-0000-0000-000000000010', 'Ear, Eye, Nose, and Throat Disorders',                     'Otosclerosis, Ménière''s disease, nasal fractures, and peritonsillar abscess',           4, true, 'published'),
  ('20000000-0000-0000-0000-000000000179', '10000000-0000-0000-0000-000000000010', 'Ear, Eye, Nose, and Throat and Upper Airway Medications',  'Otic drops, decongestants, antihistamines, corticosteroid sprays, and mouthwashes',       5, true, 'published'),
  ('20000000-0000-0000-0000-000000000180', '10000000-0000-0000-0000-000000000010', 'Gingivitis',                                               'Plaque-induced gum inflammation, oral hygiene interventions, and dental referral',        6, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for EENT
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000010',
  '10000000-0000-0000-0000-000000000010',
  'Ear, Eye, Nose, and Throat (EENT) – NCLEX Comprehensive Assessment',
  'Sensory organ assessment, EENT disorders, upper airway conditions, and related medications for NCLEX preparation',
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
-- VERIFICATION — should show all ten subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
