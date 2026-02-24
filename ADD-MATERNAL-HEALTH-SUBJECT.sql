-- ============================================
-- ADD MATERNAL HEALTH SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Maternal Health subject (display_order = 13)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000013',
  'Maternal Health',
  'Reproductive cycle, pregnancy care, labor, postpartum, and obstetric complications',
  '🤰',
  13,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 26 topics
--    IDs continue from Reproductive (which used ...0189–...0198)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000199', '10000000-0000-0000-0000-000000000013', 'Female Reproductive Cycle',                                                    'Ovarian and uterine cycle phases, hormonal regulation, and feedback mechanisms',              1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000200', '10000000-0000-0000-0000-000000000013', 'Menstrual Cycle Made Easy',                                                    'Simplified follicular, ovulation, and luteal phases with clinical nursing relevance',         2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000201', '10000000-0000-0000-0000-000000000013', 'Hormonal and Menstrual Disorders',                                             'Dysmenorrhea, amenorrhea, menorrhagia, PMDD, and hormonal treatment options',                 3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000202', '10000000-0000-0000-0000-000000000013', 'Fertilization and Implantation',                                               'Sperm-egg fusion, zygote cleavage, blastocyst implantation, and early hCG rise',              4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000203', '10000000-0000-0000-0000-000000000013', 'Pregnancy Assessment Signs',                                                   'Presumptive, probable, and positive signs of pregnancy with nursing assessment',               5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000204', '10000000-0000-0000-0000-000000000013', 'Naegele''s Rule',                                                              'Calculating estimated due date from LMP, clinical application and exceptions',                 6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000205', '10000000-0000-0000-0000-000000000013', 'Antepartum Care',                                                              'Prenatal visits, GTPAL, fundal height, fetal movement counts, and risk screening',            7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000206', '10000000-0000-0000-0000-000000000013', 'Intrapartum Care',                                                             'Stages of labor, fetal monitoring, interventions, and nursing priorities during delivery',     8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000207', '10000000-0000-0000-0000-000000000013', 'Postpartum Care',                                                              'BUBBLE-HE assessment, lochia progression, uterine involution, and postpartum blues vs depression', 9, true, 'published'),
  ('20000000-0000-0000-0000-000000000208', '10000000-0000-0000-0000-000000000013', 'Infant Bonding',                                                               'Attachment theory, skin-to-skin contact, breastfeeding initiation, and rooming-in benefits',  10, true, 'published'),
  ('20000000-0000-0000-0000-000000000209', '10000000-0000-0000-0000-000000000013', 'APGAR Score (Appearance, Pulse, Grimace, Activity, Respiration)',              'Scoring system at 1 and 5 minutes, interpretation, and newborn resuscitation thresholds',     11, true, 'published'),
  ('20000000-0000-0000-0000-000000000210', '10000000-0000-0000-0000-000000000013', 'Leopold Maneuvers',                                                            'Four-step abdominal palpation to determine fetal lie, presentation, and position',             12, true, 'published'),
  ('20000000-0000-0000-0000-000000000211', '10000000-0000-0000-0000-000000000013', 'Maternal Health Medications',                                                  'Oxytocin, magnesium sulfate, terbutaline, methylergonovine, and RhoGAM indications',          13, true, 'published'),
  ('20000000-0000-0000-0000-000000000212', '10000000-0000-0000-0000-000000000013', 'Medications in Pregnancy',                                                     'FDA pregnancy categories, teratogens, safe analgesics, and contraindicated drugs',            14, true, 'published'),
  ('20000000-0000-0000-0000-000000000213', '10000000-0000-0000-0000-000000000013', 'TORCH Infections (Toxoplasmosis, Other Infections, Rubella, CMV, HSV)',        'Vertical transmission, congenital effects, screening, and isolation precautions',             15, true, 'published'),
  ('20000000-0000-0000-0000-000000000214', '10000000-0000-0000-0000-000000000013', 'Gestational Diabetes Mellitus',                                                'GDM screening, insulin management, macrosomia risk, and postpartum glucose monitoring',        16, true, 'published'),
  ('20000000-0000-0000-0000-000000000215', '10000000-0000-0000-0000-000000000013', 'Gestational Hypertension, Preeclampsia, and Eclampsia',                        'BP criteria, proteinuria, magnesium toxicity, seizure precautions, and delivery indications',  17, true, 'published'),
  ('20000000-0000-0000-0000-000000000216', '10000000-0000-0000-0000-000000000013', 'Hyperemesis Gravidarum',                                                       'Severe nausea/vomiting, dehydration, IV fluids, antiemetics, and nutritional support',        18, true, 'published'),
  ('20000000-0000-0000-0000-000000000217', '10000000-0000-0000-0000-000000000013', 'Ectopic Pregnancy',                                                            'Tubal rupture risk, β-hCG trends, methotrexate vs surgery, and hemorrhage management',        19, true, 'published'),
  ('20000000-0000-0000-0000-000000000218', '10000000-0000-0000-0000-000000000013', 'Placenta Previa',                                                              'Painless bright red bleeding, placenta location, pelvic rest, and C-section indications',     20, true, 'published'),
  ('20000000-0000-0000-0000-000000000219', '10000000-0000-0000-0000-000000000013', 'Placental Abruption',                                                          'Painful dark bleeding, rigid abdomen, fetal distress, and emergency management',              21, true, 'published'),
  ('20000000-0000-0000-0000-000000000220', '10000000-0000-0000-0000-000000000013', 'Vasa Previa',                                                                  'Fetal vessel rupture risk at membrane rupture, fetal heart rate changes, and urgent delivery', 22, true, 'published'),
  ('20000000-0000-0000-0000-000000000221', '10000000-0000-0000-0000-000000000013', 'Maternal Infections',                                                          'GBS, chorioamnionitis, mastitis, endometritis — screening, antibiotics, and nursing care',    23, true, 'published'),
  ('20000000-0000-0000-0000-000000000222', '10000000-0000-0000-0000-000000000013', 'Organ Disorders in Pregnancy',                                                 'Cardiac, renal, hepatic, and hematologic adaptations and complications in pregnancy',          24, true, 'published'),
  ('20000000-0000-0000-0000-000000000223', '10000000-0000-0000-0000-000000000013', 'Cancer in Pregnancy',                                                          'Cervical, breast, and hematologic malignancies during pregnancy — diagnosis and management',   25, true, 'published'),
  ('20000000-0000-0000-0000-000000000224', '10000000-0000-0000-0000-000000000013', 'Women''s Health NCLEX Priorities',                                             'High-yield maternal-newborn NCLEX topics, priority interventions, and safety strategies',     26, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Maternal Health
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000013',
  '10000000-0000-0000-0000-000000000013',
  'Maternal Health – NCLEX Comprehensive Assessment',
  'Reproductive cycle, pregnancy care, labor, postpartum, and obstetric complications for NCLEX preparation',
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
-- VERIFICATION — should show all thirteen subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
