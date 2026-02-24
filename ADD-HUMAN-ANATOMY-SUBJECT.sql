-- ============================================
-- ADD HUMAN ANATOMY SUBJECT & TOPICS
-- Subject display_order = 23
-- Topic IDs: ...0353 – ...0371 (19 topics)
-- Run AFTER ADD-MEDICAL-TERMINOLOGY-SUBJECT.sql
-- ============================================

INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000023',
  'Human Anatomy',
  'Structure and organization of the human body by system, with clinical correlations for nursing practice',
  '🫀',
  23,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000353', '10000000-0000-0000-0000-000000000023', 'Organization of the Human Body',             'Cell, tissue, organ, and system levels; body cavities, membranes, and anatomical regions',                           1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000354', '10000000-0000-0000-0000-000000000023', 'Integumentary System',                       'Layers of skin (epidermis, dermis, hypodermis), appendages, and clinical significance in wound care',               2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000355', '10000000-0000-0000-0000-000000000023', 'Skeletal System',                            'Bone classification, axial vs. appendicular skeleton, joints, and fracture types relevant to nursing',              3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000356', '10000000-0000-0000-0000-000000000023', 'Muscular System',                            'Skeletal, smooth, and cardiac muscle; major muscle groups, movement terminology, and immobility complications',    4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000357', '10000000-0000-0000-0000-000000000023', 'Nervous System',                             'CNS vs. PNS, brain regions and functions, spinal cord, cranial nerves, and autonomic nervous system',               5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000358', '10000000-0000-0000-0000-000000000023', 'Sensory Organs: Eye and Ear',                'Anatomy of the eye (cornea, lens, retina) and ear (outer, middle, inner); clinical correlations for assessment',    6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000359', '10000000-0000-0000-0000-000000000023', 'Endocrine System',                           'Glands (pituitary, thyroid, adrenal, pancreas), hormone targets, and feedback mechanisms',                         7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000360', '10000000-0000-0000-0000-000000000023', 'Cardiovascular System',                      'Heart chambers, valves, conduction system, coronary arteries, and systemic vs. pulmonary circulation',            8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000361', '10000000-0000-0000-0000-000000000023', 'Lymphatic and Immune System',                'Lymph nodes, spleen, thymus, lymphatic vessels, and immune cell origins',                                          9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000362', '10000000-0000-0000-0000-000000000023', 'Respiratory System',                         'Upper and lower airways, lung lobes and segments, alveolar gas exchange, and pleural anatomy',                    10, true, 'published'),
  ('20000000-0000-0000-0000-000000000363', '10000000-0000-0000-0000-000000000023', 'Digestive System',                           'GI tract from mouth to anus, accessory organs (liver, pancreas, gallbladder), and nutrient absorption sites',     11, true, 'published'),
  ('20000000-0000-0000-0000-000000000364', '10000000-0000-0000-0000-000000000023', 'Urinary System',                             'Kidney anatomy (cortex, medulla, nephron), ureters, bladder, urethra, and urine formation',                       12, true, 'published'),
  ('20000000-0000-0000-0000-000000000365', '10000000-0000-0000-0000-000000000023', 'Male Reproductive System',                   'Testes, epididymis, vas deferens, prostate, and accessory glands with clinical correlations',                      13, true, 'published'),
  ('20000000-0000-0000-0000-000000000366', '10000000-0000-0000-0000-000000000023', 'Female Reproductive System',                 'Ovaries, fallopian tubes, uterus, cervix, vagina, and breast anatomy with clinical correlations',                  14, true, 'published'),
  ('20000000-0000-0000-0000-000000000367', '10000000-0000-0000-0000-000000000023', 'Fetal and Placental Anatomy',                'Fetal circulation, placental structure, umbilical cord, amniotic sac, and developmental milestones',                15, true, 'published'),
  ('20000000-0000-0000-0000-000000000368', '10000000-0000-0000-0000-000000000023', 'Head, Neck, and Cranial Structures',         'Skull bones, meninges, cranial nerves, sinuses, and cervical lymph node locations',                               16, true, 'published'),
  ('20000000-0000-0000-0000-000000000369', '10000000-0000-0000-0000-000000000023', 'Thoracic and Abdominal Cavity Anatomy',      'Mediastinum, diaphragm, peritoneum, retroperitoneal organs, and abdominal quadrant mapping',                       17, true, 'published'),
  ('20000000-0000-0000-0000-000000000370', '10000000-0000-0000-0000-000000000023', 'Vascular Anatomy and Peripheral Circulation','Major arteries and veins, pulse point locations, venipuncture sites, and IV access anatomy',                      18, true, 'published'),
  ('20000000-0000-0000-0000-000000000371', '10000000-0000-0000-0000-000000000023', 'Cellular and Tissue Biology',                'Cell organelles, membrane transport, tissue types (epithelial, connective, muscle, nervous), and mitosis/meiosis', 19, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000023',
  '10000000-0000-0000-0000-000000000023',
  'Human Anatomy – NCLEX Comprehensive Assessment',
  'Structure and organization of the human body by system, with clinical correlations for nursing practice',
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
WHERE s.id = '10000000-0000-0000-0000-000000000023'
GROUP BY s.name, s.display_order;
