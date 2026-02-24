-- ============================================
-- ADD REPRODUCTIVE AND SEXUAL HEALTH SYSTEM SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert subject (display_order = 12)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000012',
  'Reproductive and Sexual Health System',
  'Reproductive anatomy, sexual health, contraception, STIs, and urological conditions',
  '🩺',
  12,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 10 topics
--    IDs continue from Burns and Skin (which used ...0181–...0188)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000189', '10000000-0000-0000-0000-000000000012', 'Reproductive Anatomy',                                         'Male and female reproductive structures, hormonal regulation, and menstrual cycle',       1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000190', '10000000-0000-0000-0000-000000000012', 'Female Reproductive System: Fertilization and Implantation',   'Ovulation, fertilization process, implantation, and early embryonic development',        2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000191', '10000000-0000-0000-0000-000000000012', 'Sexual Health in Nursing',                                     'Therapeutic communication, LGBTQ+ inclusive care, and sexual health assessment',        3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000192', '10000000-0000-0000-0000-000000000012', 'Contraception and Family Planning',                            'Hormonal, barrier, IUD, emergency contraception, and natural family planning methods',   4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000193', '10000000-0000-0000-0000-000000000012', 'Sexually Transmitted Infections (STIs) and STDs',              'Chlamydia, gonorrhea, syphilis, herpes, HPV — transmission, screening, and treatment',   5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000194', '10000000-0000-0000-0000-000000000012', 'Infertility',                                                  'Male and female causes, diagnostic workup, ART options, and emotional support',         6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000195', '10000000-0000-0000-0000-000000000012', 'Reproductive Complications',                                   'Endometriosis, PCOS, fibroids, ovarian cysts, and ectopic pregnancy management',        7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000196', '10000000-0000-0000-0000-000000000012', 'Priapism',                                                     'Prolonged erection, ischemic vs non-ischemic types, aspiration, and emergency care',    8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000197', '10000000-0000-0000-0000-000000000012', 'Benign Prostatic Hyperplasia (BPH)',                           'Urinary obstruction, alpha-blockers, 5-alpha reductase inhibitors, and post-void residual', 9, true, 'published'),
  ('20000000-0000-0000-0000-000000000198', '10000000-0000-0000-0000-000000000012', 'Transurethral Resection of the Prostate (TURP)',               'Pre/post-op care, continuous bladder irrigation, TURP syndrome, and catheter management', 10, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000012',
  '10000000-0000-0000-0000-000000000012',
  'Reproductive and Sexual Health System – NCLEX Comprehensive Assessment',
  'Reproductive anatomy, sexual health, contraception, STIs, and urological conditions for NCLEX preparation',
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
-- VERIFICATION — should show all twelve subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
