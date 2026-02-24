-- ============================================
-- ADD PEDIATRICS SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Pediatrics subject (display_order = 14)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000014',
  'Pediatrics',
  'Child development, newborn care, pediatric disorders, and age-specific nursing interventions',
  '👶',
  14,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 25 topics
--    IDs continue from Maternal Health (which used ...0199–...0224)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000225', '10000000-0000-0000-0000-000000000014', 'Pediatric Developmental Stages',                      'Erikson, Piaget, and Freud milestones; growth and developmental red flags',                  1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000226', '10000000-0000-0000-0000-000000000014', 'Care of the Newborn',                                  'Newborn assessment, thermoregulation, feeding, jaundice, and safe sleep positioning',       2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000227', '10000000-0000-0000-0000-000000000014', 'Pediatric Medication Administration',                  'Weight-based dosing, rights of medication, age-appropriate routes and pain scales',         3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000228', '10000000-0000-0000-0000-000000000014', 'Pediatric Medications',                                'Common pediatric drugs, acetaminophen/ibuprofen dosing, and aspirin avoidance (Reye''s)',   4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000229', '10000000-0000-0000-0000-000000000014', 'Pediatric Fever and Dehydration',                     'Fever management, dehydration assessment (mild/moderate/severe), oral rehydration therapy',  5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000230', '10000000-0000-0000-0000-000000000014', 'Pediatric Infectious and Communicable Diseases',       'Chickenpox, measles, mumps, rubella, RSV, pertussis — isolation and immunization',          6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000231', '10000000-0000-0000-0000-000000000014', 'Pediatric Respiratory Disorders',                     'Croup, bronchiolitis, RSV, asthma exacerbations, and respiratory distress recognition',     7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000232', '10000000-0000-0000-0000-000000000014', 'Pediatric Cardiovascular Nursing',                    'Congenital heart defects (acyanotic vs cyanotic), heart failure, and cardiac catheterization', 8, true, 'published'),
  ('20000000-0000-0000-0000-000000000233', '10000000-0000-0000-0000-000000000014', 'Pediatric Neurologic and Psychosocial Disorders',     'Febrile seizures, meningitis, hydrocephalus, autism spectrum, ADHD, and abuse assessment',  9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000234', '10000000-0000-0000-0000-000000000014', 'Pediatric Diabetes Mellitus',                         'Type 1 DM in children, insulin pump management, hypoglycemia recognition, and school care', 10, true, 'published'),
  ('20000000-0000-0000-0000-000000000235', '10000000-0000-0000-0000-000000000014', 'Pediatric Gastrointestinal Disorders',                'Pyloric stenosis, intussusception, Hirschsprung, GERD, celiac, and failure to thrive',      11, true, 'published'),
  ('20000000-0000-0000-0000-000000000236', '10000000-0000-0000-0000-000000000014', 'Pediatric Hematological and Oncological Disorders',   'Sickle cell, hemophilia, leukemia, Wilms tumor, neuroblastoma, and transfusion care',       12, true, 'published'),
  ('20000000-0000-0000-0000-000000000237', '10000000-0000-0000-0000-000000000014', 'Pediatric Renal, Urinary, and Genitourinary Disorders','Nephrotic syndrome, HUS, cryptorchidism, hypospadias, and vesicoureteral reflux',          13, true, 'published'),
  ('20000000-0000-0000-0000-000000000238', '10000000-0000-0000-0000-000000000014', 'Pediatric Musculoskeletal Disorders',                 'Developmental dysplasia of hip, clubfoot, scoliosis, Legg-Calvé-Perthes, and fracture care', 14, true, 'published'),
  ('20000000-0000-0000-0000-000000000239', '10000000-0000-0000-0000-000000000014', 'Pediatric Integumentary Dysfunction',                 'Impetigo, eczema, diaper rash, scabies, and wound care in pediatric patients',              15, true, 'published'),
  ('20000000-0000-0000-0000-000000000240', '10000000-0000-0000-0000-000000000014', 'Pediatric Eye, Ear, and Throat Disorders',            'Otitis media, tonsillitis, adenoiditis, foreign bodies, and hearing screening',             16, true, 'published'),
  ('20000000-0000-0000-0000-000000000241', '10000000-0000-0000-0000-000000000014', 'Pediatric Cognitive, Neurologic, and Psychosocial Nursing', 'Intellectual disability, Down syndrome, cerebral palsy, anxiety, and depression in children', 17, true, 'published'),
  ('20000000-0000-0000-0000-000000000242', '10000000-0000-0000-0000-000000000014', 'Kawasaki Disease',                                    'Mucocutaneous lymph node syndrome, fever criteria, IVIG, aspirin therapy, coronary monitoring', 18, true, 'published'),
  ('20000000-0000-0000-0000-000000000243', '10000000-0000-0000-0000-000000000014', 'Amblyopia',                                           'Lazy eye, patching therapy, corrective lenses, and critical treatment window in childhood',  19, true, 'published'),
  ('20000000-0000-0000-0000-000000000244', '10000000-0000-0000-0000-000000000014', 'Congenital Cataracts',                                'Early detection, surgical timing, visual rehabilitation, and amblyopia prevention',          20, true, 'published'),
  ('20000000-0000-0000-0000-000000000245', '10000000-0000-0000-0000-000000000014', 'Pediatric Conjunctivitis',                            'Neonatal vs childhood conjunctivitis, gonococcal prophylaxis, and antibiotic eye drops',     21, true, 'published'),
  ('20000000-0000-0000-0000-000000000246', '10000000-0000-0000-0000-000000000014', 'Retinopathy of Prematurity',                          'O2 toxicity in preterm infants, ROP staging, laser therapy, and ophthalmology screening',   22, true, 'published'),
  ('20000000-0000-0000-0000-000000000247', '10000000-0000-0000-0000-000000000014', 'Strabismus',                                          'Esotropia vs exotropia, Hirschberg test, patching, surgery, and amblyopia risk',            23, true, 'published'),
  ('20000000-0000-0000-0000-000000000248', '10000000-0000-0000-0000-000000000014', 'Rickets (Vitamin D Deficiency)',                      'Bone demineralization, bowlegs, craniotabes, vitamin D and calcium supplementation',        24, true, 'published'),
  ('20000000-0000-0000-0000-000000000249', '10000000-0000-0000-0000-000000000014', 'Omphalocele',                                         'Abdominal wall defect, bowel/organ protrusion, sterile covering, and surgical repair care', 25, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Pediatrics
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000014',
  '10000000-0000-0000-0000-000000000014',
  'Pediatrics – NCLEX Comprehensive Assessment',
  'Child development, newborn care, pediatric disorders, and age-specific nursing interventions for NCLEX preparation',
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
-- VERIFICATION — should show all fourteen subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
