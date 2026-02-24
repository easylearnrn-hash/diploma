-- ============================================
-- ADD RENAL SYSTEM SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Renal System subject (display_order = 7)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000007',
  'Renal System',
  'Kidney anatomy, urinary disorders, dialysis, and renal medication management',
  '🫘',
  7,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 19 topics
--    IDs continue from Respiratory (which used ...0125–...0140)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000141', '10000000-0000-0000-0000-000000000007', 'Kidney Anatomy',                                             'Nephron structure, glomerular filtration, tubular reabsorption and secretion',         1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000142', '10000000-0000-0000-0000-000000000007', 'Urinary Sample Collection',                                  'Clean-catch midstream, catheter specimen, 24-hour urine collection technique',        2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000143', '10000000-0000-0000-0000-000000000007', 'Urinary Catheters and Clean Intermittent Catheterization (CIC)', 'Indwelling vs intermittent, insertion technique, CAUTI prevention',                 3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000144', '10000000-0000-0000-0000-000000000007', 'Urinary Tract Infections (UTI)',                             'Causative organisms, risk factors, antibiotic selection, and prevention education',   4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000145', '10000000-0000-0000-0000-000000000007', 'Cystitis',                                                   'Bladder infection presentation, urinalysis findings, and nursing interventions',      5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000146', '10000000-0000-0000-0000-000000000007', 'Pyelonephritis',                                             'CVA tenderness, systemic symptoms, IV antibiotics, and hospitalization criteria',     6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000147', '10000000-0000-0000-0000-000000000007', 'Nephrotic Syndrome and Glomerulonephritis',                  'Proteinuria, edema, hypoalbuminemia vs hematuria, RBC casts, immune pathology',       7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000148', '10000000-0000-0000-0000-000000000007', 'Glomerulonephritis',                                         'Post-streptococcal, immune complex deposition, oliguria, and steroid therapy',        8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000149', '10000000-0000-0000-0000-000000000007', 'Hemolytic Uremic Syndrome (HUS)',                            'E. coli O157:H7, triad of AKI/hemolytic anemia/thrombocytopenia, supportive care',    9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000150', '10000000-0000-0000-0000-000000000007', 'Polycystic Kidney Disease (PKD)',                            'Autosomal dominant vs recessive, cyst management, hypertension control',             10, true, 'published'),
  ('20000000-0000-0000-0000-000000000151', '10000000-0000-0000-0000-000000000007', 'Renal Calculi (Kidney Stones)',                              'Stone types, dietary modifications, strain urine, lithotripsy, and pain management', 11, true, 'published'),
  ('20000000-0000-0000-0000-000000000152', '10000000-0000-0000-0000-000000000007', 'Urinary Incontinence',                                       'Stress, urge, overflow, and functional types; Kegel exercises and bladder training',  12, true, 'published'),
  ('20000000-0000-0000-0000-000000000153', '10000000-0000-0000-0000-000000000007', 'Acute Renal Failure / Acute Kidney Injury (AKI)',            'Pre-renal, intrinsic, post-renal causes; oliguric vs anuric phases; fluid management',13, true, 'published'),
  ('20000000-0000-0000-0000-000000000154', '10000000-0000-0000-0000-000000000007', 'Chronic Kidney Disease (CKD)',                               'GFR staging, uremia, dietary phosphorus/potassium/protein restrictions',             14, true, 'published'),
  ('20000000-0000-0000-0000-000000000155', '10000000-0000-0000-0000-000000000007', 'Dialysis',                                                   'Hemodialysis vs peritoneal dialysis, access care, fluid/electrolyte monitoring',      15, true, 'published'),
  ('20000000-0000-0000-0000-000000000156', '10000000-0000-0000-0000-000000000007', 'Dialysis Disequilibrium Syndrome (DDS)',                     'Rapid urea removal, cerebral edema, prevention with slow initial dialysis sessions',  16, true, 'published'),
  ('20000000-0000-0000-0000-000000000157', '10000000-0000-0000-0000-000000000007', 'Renal and Urinary Medications',                              'Diuretics, ACE inhibitors, phosphate binders, erythropoietin, and sodium bicarb',    17, true, 'published'),
  ('20000000-0000-0000-0000-000000000158', '10000000-0000-0000-0000-000000000007', 'Wilms Tumor',                                                'Pediatric renal tumor, do-not-palpate-abdomen rule, nephrectomy, and chemo care',     18, true, 'published'),
  ('20000000-0000-0000-0000-000000000159', '10000000-0000-0000-0000-000000000007', 'Pheochromocytoma',                                           'Catecholamine-secreting adrenal tumor, hypertensive crisis, surgical prep',          19, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Renal System
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000007',
  '10000000-0000-0000-0000-000000000007',
  'Renal System – NCLEX Comprehensive Assessment',
  'Kidney anatomy, urinary disorders, dialysis, and renal medication management for NCLEX preparation',
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
-- VERIFICATION — should show all seven subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
