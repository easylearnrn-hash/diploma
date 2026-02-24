-- ============================================
-- ADD DRUG CLASSES SUBJECT & TOPICS
-- Subject display_order = 24
-- Topic IDs: ...0372 – ...0395 (24 topics)
-- Run AFTER ADD-HUMAN-ANATOMY-SUBJECT.sql
-- ============================================

INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000024',
  'Drug Classes',
  'Classification of medications by mechanism of action, therapeutic use, nursing considerations, and key side effects',
  '🧪',
  24,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000372', '10000000-0000-0000-0000-000000000024', 'Analgesics and Antipyretics',                 'Opioid vs. non-opioid analgesics, NSAIDs, acetaminophen — dosing limits, overdose management, and pain scales',         1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000373', '10000000-0000-0000-0000-000000000024', 'Antibiotics',                                 'Penicillins, cephalosporins, macrolides, fluoroquinolones, aminoglycosides — spectrum, resistance, and allergies',      2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000374', '10000000-0000-0000-0000-000000000024', 'Antivirals',                                  'Acyclovir, oseltamivir, antiretrovirals — mechanism, HIV therapy overview, and nursing monitoring',                    3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000375', '10000000-0000-0000-0000-000000000024', 'Antifungals',                                 'Azoles, polyenes, echinocandins — systemic vs. topical use, hepatotoxicity monitoring, and drug interactions',         4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000376', '10000000-0000-0000-0000-000000000024', 'Anticoagulants and Antiplatelets',            'Heparin, warfarin, DOACs, aspirin, clopidogrel — monitoring (INR/aPTT), reversal agents, and bleeding precautions',   5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000377', '10000000-0000-0000-0000-000000000024', 'Antihypertensives',                           'ACE inhibitors, ARBs, beta blockers, CCBs, diuretics — indications, contraindications, and BP monitoring',             6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000378', '10000000-0000-0000-0000-000000000024', 'Antiarrhythmics',                             'Vaughan Williams classes (I–IV), adenosine, digoxin — rhythm indications, toxicity signs, and nursing implications',  7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000379', '10000000-0000-0000-0000-000000000024', 'Diuretics',                                   'Loop, thiazide, potassium-sparing, osmotic diuretics — electrolyte effects, urine output monitoring, and HF use',     8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000380', '10000000-0000-0000-0000-000000000024', 'Antidiabetics',                               'Insulin types, metformin, sulfonylureas, GLP-1 agonists, SGLT-2 inhibitors — hypoglycemia management and monitoring', 9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000381', '10000000-0000-0000-0000-000000000024', 'Thyroid and Antithyroid Agents',              'Levothyroxine, PTU, methimazole — TSH/T3/T4 monitoring, thyroid storm management, and patient education',              10, true, 'published'),
  ('20000000-0000-0000-0000-000000000382', '10000000-0000-0000-0000-000000000024', 'Corticosteroids',                             'Systemic vs. topical steroids — immunosuppression, adrenal suppression, Cushingoid effects, and taper protocols',      11, true, 'published'),
  ('20000000-0000-0000-0000-000000000383', '10000000-0000-0000-0000-000000000024', 'Bronchodilators and Respiratory Agents',      'SABAs, LABAs, anticholinergics, methylxanthines — rescue vs. maintenance inhalers and spacer use education',           12, true, 'published'),
  ('20000000-0000-0000-0000-000000000384', '10000000-0000-0000-0000-000000000024', 'Antipsychotics',                              'Typical vs. atypical antipsychotics — EPS, NMS, tardive dyskinesia, metabolic syndrome, and AIMS monitoring',         13, true, 'published'),
  ('20000000-0000-0000-0000-000000000385', '10000000-0000-0000-0000-000000000024', 'Antidepressants',                             'SSRIs, SNRIs, TCAs, MAOIs — serotonin syndrome, suicide risk, dietary restrictions (MAOIs), and onset of action',     14, true, 'published'),
  ('20000000-0000-0000-0000-000000000386', '10000000-0000-0000-0000-000000000024', 'Anxiolytics and Sedative-Hypnotics',          'Benzodiazepines, buspirone, barbiturates, z-drugs — dependence, flumazenil reversal, and fall risk',                   15, true, 'published'),
  ('20000000-0000-0000-0000-000000000387', '10000000-0000-0000-0000-000000000024', 'Mood Stabilizers',                            'Lithium, valproate, lamotrigine — therapeutic levels, toxicity signs, and teratogenicity',                             16, true, 'published'),
  ('20000000-0000-0000-0000-000000000388', '10000000-0000-0000-0000-000000000024', 'Anticonvulsants',                             'Phenytoin, carbamazepine, levetiracetam, valproate — seizure classification, drug monitoring levels, and interactions', 17, true, 'published'),
  ('20000000-0000-0000-0000-000000000389', '10000000-0000-0000-0000-000000000024', 'Antiemetics and GI Agents',                   'Ondansetron, metoclopramide, PPIs, H2 blockers, antidiarrheals, laxative classes — indications and nursing use',       18, true, 'published'),
  ('20000000-0000-0000-0000-000000000390', '10000000-0000-0000-0000-000000000024', 'Immunosuppressants and Biologics',            'Cyclosporine, methotrexate, TNF inhibitors — infection risk, organ transplant protocols, and lab monitoring',          19, true, 'published'),
  ('20000000-0000-0000-0000-000000000391', '10000000-0000-0000-0000-000000000024', 'Chemotherapy Drug Classes',                   'Alkylating agents, antimetabolites, vinca alkaloids, taxanes — cell cycle specificity, nadir, and safe handling',      20, true, 'published'),
  ('20000000-0000-0000-0000-000000000392', '10000000-0000-0000-0000-000000000024', 'Neuromuscular and Anesthetic Agents',         'Paralytics, reversal agents, anesthetics, succinylcholine — perioperative nursing and airway management',               21, true, 'published'),
  ('20000000-0000-0000-0000-000000000393', '10000000-0000-0000-0000-000000000024', 'Vasopressors and Inotropes',                  'Dopamine, norepinephrine, epinephrine, dobutamine — shock management, titration, and hemodynamic monitoring',         22, true, 'published'),
  ('20000000-0000-0000-0000-000000000394', '10000000-0000-0000-0000-000000000024', 'Vitamins, Minerals, and Supplements',         'Iron, folic acid, B12, calcium, Vitamin D, zinc — deficiency signs, toxicity, and IV vs. PO administration',         23, true, 'published'),
  ('20000000-0000-0000-0000-000000000395', '10000000-0000-0000-0000-000000000024', 'Drug Interactions and Toxicology',            'Cytochrome P450 interactions, contraindicated combinations, antidotes, and overdose management priorities',            24, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000024',
  '10000000-0000-0000-0000-000000000024',
  'Drug Classes – NCLEX Comprehensive Assessment',
  'Classification of medications by mechanism of action, therapeutic use, nursing considerations, and key side effects',
  60, 75, true, true, true, true, true
)
ON CONFLICT (id) DO UPDATE SET
  subject_id            = EXCLUDED.subject_id,
  title                 = EXCLUDED.title,
  description           = EXCLUDED.description,
  duration_minutes      = EXCLUDED.duration_minutes,
  passing_score_percent = EXCLUDED.passing_score_percent;

-- ============================================
-- VERIFICATION — full subject list
-- ============================================
SELECT s.display_order, s.name, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.display_order, s.name
ORDER BY s.display_order;
