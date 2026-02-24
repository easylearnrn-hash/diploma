-- ============================================
-- ADD GASTROINTESTINAL AND HEPATIC SYSTEM SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert subject (display_order = 5)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000005',
  'Gastrointestinal and Hepatic System',
  'Digestive tract, liver, nutrition, and GI disorder management',
  '🫁',
  5,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 42 topics
--    IDs continue from Endocrine (which used ...0070–...0082)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000083', '10000000-0000-0000-0000-000000000005', 'Abdominal Quadrants',                                          'RUQ, LUQ, RLQ, LLQ organ locations and clinical significance',                        1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000084', '10000000-0000-0000-0000-000000000005', 'Digestive System',                                             'Anatomy and physiology of the GI tract from mouth to rectum',                         2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000085', '10000000-0000-0000-0000-000000000005', 'Physical Examination and Bowel Sounds',                        'Auscultation sequence, normal vs abnormal bowel sounds',                               3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000086', '10000000-0000-0000-0000-000000000005', 'Physical Examination Sounds',                                  'Tympany, dullness, resonance on percussion; bruit and rub on auscultation',            4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000087', '10000000-0000-0000-0000-000000000005', 'Gastroesophageal Issues',                                      'Overview of esophageal disorders, dysphagia, and motility problems',                   5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000088', '10000000-0000-0000-0000-000000000005', 'Gastroesophageal Reflux Disease (GERD)',                       'Pathophysiology, triggers, lifestyle modifications, and PPI therapy',                  6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000089', '10000000-0000-0000-0000-000000000005', 'Peptic Ulcer Disease (PUD) and Gastritis',                     'H. pylori, NSAIDs, ulcer types, complications, and treatment',                        7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000090', '10000000-0000-0000-0000-000000000005', 'Gastric and Peptic Ulcers',                                    'Duodenal vs gastric ulcer differences, pain patterns, and nursing care',               8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000091', '10000000-0000-0000-0000-000000000005', 'Dumping Syndrome',                                             'Early vs late dumping, dietary modifications post-gastric surgery',                   9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000092', '10000000-0000-0000-0000-000000000005', 'Roux-en-Y Gastric Bypass',                                     'Surgical anatomy, post-op nutrition, and complication monitoring',                    10, true, 'published'),
  ('20000000-0000-0000-0000-000000000093', '10000000-0000-0000-0000-000000000005', 'Gastrointestinal Medications',                                 'Antacids, H2 blockers, PPIs, antiemetics, laxatives, and antidiarrheals',             11, true, 'published'),
  ('20000000-0000-0000-0000-000000000094', '10000000-0000-0000-0000-000000000005', 'NG Tube and Total Parenteral Nutrition (TPN)',                  'Insertion verification, feeding protocols, TPN monitoring, and complications',        12, true, 'published'),
  ('20000000-0000-0000-0000-000000000095', '10000000-0000-0000-0000-000000000005', 'Central Line vs. PICC Line',                                   'Indications, insertion sites, maintenance, and complication prevention',              13, true, 'published'),
  ('20000000-0000-0000-0000-000000000096', '10000000-0000-0000-0000-000000000005', 'Colonoscopy',                                                  'Bowel prep, procedure overview, post-procedure nursing care',                         14, true, 'published'),
  ('20000000-0000-0000-0000-000000000097', '10000000-0000-0000-0000-000000000005', 'Colostomy',                                                    'Types, stoma assessment, pouching, and patient education',                            15, true, 'published'),
  ('20000000-0000-0000-0000-000000000098', '10000000-0000-0000-0000-000000000005', 'Lactose Intolerance',                                          'Lactase deficiency, symptoms, dietary substitutions',                                 16, true, 'published'),
  ('20000000-0000-0000-0000-000000000099', '10000000-0000-0000-0000-000000000005', 'Vegan and Vegetarian Diets',                                   'Nutritional gaps, B12, iron, calcium supplementation in plant-based diets',           17, true, 'published'),
  ('20000000-0000-0000-0000-000000000100', '10000000-0000-0000-0000-000000000005', 'Vitamins and Minerals',                                        'Fat vs water soluble vitamins, deficiency vs toxicity signs',                         18, true, 'published'),
  ('20000000-0000-0000-0000-000000000101', '10000000-0000-0000-0000-000000000005', 'B Vitamins',                                                   'B1–B12 functions, deficiency syndromes (beriberi, pellagra, pernicious anemia)',      19, true, 'published'),
  ('20000000-0000-0000-0000-000000000102', '10000000-0000-0000-0000-000000000005', 'Metabolic Syndrome Overview',                                  'Criteria, cardiovascular risk, insulin resistance, and lifestyle interventions',      20, true, 'published'),
  ('20000000-0000-0000-0000-000000000103', '10000000-0000-0000-0000-000000000005', 'Phenylketonuria (PKU)',                                        'Phenylalanine metabolism defect, newborn screening, low-phe diet',                   21, true, 'published'),
  ('20000000-0000-0000-0000-000000000104', '10000000-0000-0000-0000-000000000005', 'Celiac Disease',                                               'Gluten sensitivity, villous atrophy, gluten-free diet, and malabsorption',            22, true, 'published'),
  ('20000000-0000-0000-0000-000000000105', '10000000-0000-0000-0000-000000000005', 'Cholecystitis and Cholelithiasis',                             'Gallstone formation, Murphy''s sign, low-fat diet, cholecystectomy care',            23, true, 'published'),
  ('20000000-0000-0000-0000-000000000106', '10000000-0000-0000-0000-000000000005', 'Pancreatitis',                                                 'Acute vs chronic, Ranson criteria, NPO management, and pain control',                24, true, 'published'),
  ('20000000-0000-0000-0000-000000000107', '10000000-0000-0000-0000-000000000005', 'Alcoholism',                                                   'CAGE screening, withdrawal timeline, Wernicke-Korsakoff, thiamine replacement',       25, true, 'published'),
  ('20000000-0000-0000-0000-000000000108', '10000000-0000-0000-0000-000000000005', 'Liver Cirrhosis',                                              'Fibrosis stages, portal hypertension, ascites, hepatic encephalopathy',              26, true, 'published'),
  ('20000000-0000-0000-0000-000000000109', '10000000-0000-0000-0000-000000000005', 'Portal Vein',                                                  'Portal circulation, varices, TIPS procedure, and variceal bleeding management',       27, true, 'published'),
  ('20000000-0000-0000-0000-000000000110', '10000000-0000-0000-0000-000000000005', 'Peritonitis and Sepsis',                                       'Rebound tenderness, guarding, sepsis criteria, and emergency interventions',          28, true, 'published'),
  ('20000000-0000-0000-0000-000000000111', '10000000-0000-0000-0000-000000000005', 'Lead Poisoning',                                               'Sources, blood lead levels, chelation therapy, and developmental effects',            29, true, 'published'),
  ('20000000-0000-0000-0000-000000000112', '10000000-0000-0000-0000-000000000005', 'Botulism',                                                     'Toxin mechanism, descending paralysis, antitoxin, and airway priority',               30, true, 'published'),
  ('20000000-0000-0000-0000-000000000113', '10000000-0000-0000-0000-000000000005', 'Pyloric Stenosis',                                             'Projectile vomiting in infants, olive-mass, surgical correction nursing care',        31, true, 'published'),
  ('20000000-0000-0000-0000-000000000114', '10000000-0000-0000-0000-000000000005', 'Intussusception',                                              'Telescoping bowel, currant-jelly stools, hydrostatic reduction',                      32, true, 'published'),
  ('20000000-0000-0000-0000-000000000115', '10000000-0000-0000-0000-000000000005', 'Hirschsprung Disease',                                         'Aganglionic megacolon, ribbon stools, surgical pull-through procedure',               33, true, 'published'),
  ('20000000-0000-0000-0000-000000000116', '10000000-0000-0000-0000-000000000005', 'Ulcerative Colitis',                                           'Continuous mucosal inflammation, bloody diarrhea, sulfasalazine, surgery',            34, true, 'published'),
  ('20000000-0000-0000-0000-000000000117', '10000000-0000-0000-0000-000000000005', 'Crohn''s Disease',                                             'Skip lesions, transmural inflammation, fistulas, and nutritional support',           35, true, 'published'),
  ('20000000-0000-0000-0000-000000000118', '10000000-0000-0000-0000-000000000005', 'Irritable Bowel Syndrome (IBS)',                               'Functional disorder, low-FODMAP diet, stress management, and antispasmodics',        36, true, 'published'),
  ('20000000-0000-0000-0000-000000000119', '10000000-0000-0000-0000-000000000005', 'Diverticulosis and Diverticulitis',                            'Pouch formation, low-fiber vs high-fiber diet phases, and acute care',                37, true, 'published'),
  ('20000000-0000-0000-0000-000000000120', '10000000-0000-0000-0000-000000000005', 'Small Bowel Obstruction vs. Large Bowel Obstruction',          'Mechanical vs functional, early vs late signs, nasogastric decompression',            38, true, 'published'),
  ('20000000-0000-0000-0000-000000000121', '10000000-0000-0000-0000-000000000005', 'Lower Gastrointestinal Obstruction',                           'Volvulus, fecal impaction, colonic pseudo-obstruction, and nursing priorities',       39, true, 'published'),
  ('20000000-0000-0000-0000-000000000122', '10000000-0000-0000-0000-000000000005', 'Appendicitis',                                                 'McBurney''s point, Rovsing''s sign, pre/post-appendectomy nursing care',             40, true, 'published'),
  ('20000000-0000-0000-0000-000000000123', '10000000-0000-0000-0000-000000000005', 'Cystic Fibrosis',                                              'CFTR mutation, thick secretions, pancreatic enzymes, chest physiotherapy',            41, true, 'published'),
  ('20000000-0000-0000-0000-000000000124', '10000000-0000-0000-0000-000000000005', 'Epiglottitis',                                                 'Tripod position, drooling, airway emergency, and do-not-examine-throat rule',         42, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Gastrointestinal and Hepatic System
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000005',
  '10000000-0000-0000-0000-000000000005',
  'Gastrointestinal and Hepatic System – NCLEX Comprehensive Assessment',
  'Digestive tract, liver, nutrition, and GI disorder management for NCLEX preparation',
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
-- VERIFICATION — should show all five subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
