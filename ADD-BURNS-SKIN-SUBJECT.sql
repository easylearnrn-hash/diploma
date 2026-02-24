-- ============================================
-- ADD BURNS AND SKIN SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Burns and Skin subject (display_order = 11)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000011',
  'Burns and Skin',
  'Skin conditions, wound care, pressure ulcers, burn management, and dermatology medications',
  '🩹',
  11,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 8 topics
--    IDs continue from EENT (which used ...0175–...0180)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000181', '10000000-0000-0000-0000-000000000011', 'Skin Conditions Overview',                     'Layers of skin, functions, and general assessment of integumentary disorders',             1, true, 'published'),
  ('20000000-0000-0000-0000-000000000182', '10000000-0000-0000-0000-000000000011', 'Common Skin Disorders',                        'Psoriasis, eczema, rosacea, acne, and fungal infections — presentation and management',     2, true, 'published'),
  ('20000000-0000-0000-0000-000000000183', '10000000-0000-0000-0000-000000000011', 'Dermatitis and Cellulitis',                    'Contact vs atopic dermatitis, bacterial cellulitis, skin barrier management',                3, true, 'published'),
  ('20000000-0000-0000-0000-000000000184', '10000000-0000-0000-0000-000000000011', 'Deep Vein Thrombosis (DVT) vs. Cellulitis',    'Differentiating vascular from infectious causes of limb redness, warmth, and swelling',    4, true, 'published'),
  ('20000000-0000-0000-0000-000000000185', '10000000-0000-0000-0000-000000000011', 'Periorbital Cellulitis',                       'Pre-septal vs orbital cellulitis, IV antibiotics, vision monitoring, and emergent care',    5, true, 'published'),
  ('20000000-0000-0000-0000-000000000186', '10000000-0000-0000-0000-000000000011', 'Pressure Ulcers (Bedsores)',                   'NPUAP staging I–IV, Braden scale, repositioning schedules, and wound dressing selection',   6, true, 'published'),
  ('20000000-0000-0000-0000-000000000187', '10000000-0000-0000-0000-000000000011', 'Burns',                                        'Rule of Nines, burn depth classification, Parkland formula, and fluid resuscitation care',   7, true, 'published'),
  ('20000000-0000-0000-0000-000000000188', '10000000-0000-0000-0000-000000000011', 'Burns and Dermatology Medications',            'Silver sulfadiazine, topical antibiotics, corticosteroids, antihistamines, and retinoids',   8, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Burns and Skin
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000011',
  '10000000-0000-0000-0000-000000000011',
  'Burns and Skin – NCLEX Comprehensive Assessment',
  'Skin conditions, wound care, pressure ulcers, burn management, and dermatology medications for NCLEX preparation',
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
-- VERIFICATION — should show all eleven subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
