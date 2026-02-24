-- ============================================
-- ADD MUSCULOSKELETAL DISORDERS SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Musculoskeletal Disorders subject (display_order = 19)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000019',
  'Musculoskeletal Disorders',
  'Bone and joint conditions, fractures, mobility aids, connective tissue disorders, and orthopedic nursing care',
  '🦴',
  19,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 8 topics
--    IDs continue from Cancer (which used ...0297–...0306)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000307', '10000000-0000-0000-0000-000000000019', 'Musculoskeletal Conditions Overview',              'Anatomy, bone remodeling, joint types, and general musculoskeletal assessment techniques',      1, true, 'published'),
  ('20000000-0000-0000-0000-000000000308', '10000000-0000-0000-0000-000000000019', 'Fractures',                                        'Fracture types, 5 P''s of neurovascular assessment, casting, traction, and fat embolism',      2, true, 'published'),
  ('20000000-0000-0000-0000-000000000309', '10000000-0000-0000-0000-000000000019', 'Sprains, Strains, and Dislocations',               'RICE method, ligament vs muscle injury, joint reduction, and return-to-activity guidelines',    3, true, 'published'),
  ('20000000-0000-0000-0000-000000000310', '10000000-0000-0000-0000-000000000019', 'Osteomyelitis',                                    'Hematogenous vs contiguous spread, bone biopsy, IV antibiotics, and wound care',               4, true, 'published'),
  ('20000000-0000-0000-0000-000000000311', '10000000-0000-0000-0000-000000000019', 'Connective Tissue Disorders',                      'Osteoporosis, osteoarthritis, gout, ankylosing spondylitis, and fibromyalgia management',       5, true, 'published'),
  ('20000000-0000-0000-0000-000000000312', '10000000-0000-0000-0000-000000000019', 'Mobility and Assistive Devices',                   'Crutch gaits, walker use, cane placement, wheelchair safety, and fall prevention strategies',   6, true, 'published'),
  ('20000000-0000-0000-0000-000000000313', '10000000-0000-0000-0000-000000000019', 'Intercostal Spaces',                               'Rib anatomy, thoracic landmarks, chest tube insertion sites, and thoracentesis positioning',    7, true, 'published'),
  ('20000000-0000-0000-0000-000000000314', '10000000-0000-0000-0000-000000000019', 'Clinical Prioritization in Musculoskeletal Care',  'NCLEX priority interventions, compartment syndrome, neurovascular checks, and delegation',      8, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Musculoskeletal Disorders
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000019',
  '10000000-0000-0000-0000-000000000019',
  'Musculoskeletal Disorders – NCLEX Comprehensive Assessment',
  'Bone and joint conditions, fractures, mobility aids, connective tissue disorders, and orthopedic nursing care for NCLEX preparation',
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
-- VERIFICATION — should show all nineteen subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
