-- ============================================
-- ADD AUTOIMMUNE AND INFECTIOUS DISORDERS SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert subject (display_order = 17)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000017',
  'Autoimmune and Infectious Disorders',
  'Immune system dysfunction, infectious diseases, isolation precautions, and immunologic medications',
  '🦠',
  17,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 19 topics
--    IDs continue from Mental Health (which used ...0257–...0277)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000278', '10000000-0000-0000-0000-000000000017', 'Autoimmune Diseases Overview',                                             'Self-tolerance failure, autoantibodies, organ-specific vs systemic autoimmune conditions',      1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000279', '10000000-0000-0000-0000-000000000017', 'Autoimmune and Infectious Disorder Medications',                           'DMARDs, biologics, immunosuppressants, antivirals, antifungals, and antiparasitics',            2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000280', '10000000-0000-0000-0000-000000000017', 'Immunodeficiency',                                                         'Primary vs secondary immunodeficiency, neutropenia precautions, and protective isolation',      3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000281', '10000000-0000-0000-0000-000000000017', 'Human Immunodeficiency Virus (HIV)',                                       'HIV lifecycle, CD4/viral load, ART regimens, opportunistic infections, and standard precautions', 4, true, 'published'),
  ('20000000-0000-0000-0000-000000000282', '10000000-0000-0000-0000-000000000017', 'Rheumatoid Arthritis (RA)',                                                'Symmetric joint inflammation, morning stiffness, DMARDs, methotrexate, and joint protection',    5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000283', '10000000-0000-0000-0000-000000000017', 'Systemic Lupus Erythematosus (SLE)',                                       'Butterfly rash, ANA, lupus nephritis, photosensitivity, and hydroxychloroquine therapy',        6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000284', '10000000-0000-0000-0000-000000000017', 'Myasthenia Gravis (MG)',                                                   'ACh receptor antibodies, ptosis, myasthenic vs cholinergic crisis, pyridostigmine',            7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000285', '10000000-0000-0000-0000-000000000017', 'Guillain-Barré Syndrome (GBS)',                                            'Ascending paralysis, respiratory failure risk, plasmapheresis, and IVIG therapy',               8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000286', '10000000-0000-0000-0000-000000000017', 'Infections Overview',                                                      'Chain of infection, modes of transmission, standard and transmission-based precautions',        9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000287', '10000000-0000-0000-0000-000000000017', 'Hepatitis',                                                                'Hepatitis A–E transmission routes, serology markers, vaccination, and liver function monitoring', 10, true, 'published'),
  ('20000000-0000-0000-0000-000000000288', '10000000-0000-0000-0000-000000000017', 'Meningitis',                                                               'Bacterial vs viral, Kernig''s and Brudzinski''s signs, lumbar puncture, and droplet precautions', 11, true, 'published'),
  ('20000000-0000-0000-0000-000000000289', '10000000-0000-0000-0000-000000000017', 'Clostridioides difficile Infection',                                       'Antibiotic-associated diarrhea, spore transmission, contact precautions, and vancomycin/fidaxomicin', 12, true, 'published'),
  ('20000000-0000-0000-0000-000000000290', '10000000-0000-0000-0000-000000000017', 'Lyme Disease',                                                             'Ixodes tick bite, bull''s-eye rash, doxycycline, and cardiac/neurologic complications',         13, true, 'published'),
  ('20000000-0000-0000-0000-000000000291', '10000000-0000-0000-0000-000000000017', 'Anthrax',                                                                  'Bacillus anthracis, cutaneous/inhalation/GI forms, bioterrorism preparedness, and ciprofloxacin', 14, true, 'published'),
  ('20000000-0000-0000-0000-000000000292', '10000000-0000-0000-0000-000000000017', 'Severe Acute Respiratory Syndrome (SARS) and Coronavirus Disease (COVID)', 'Airborne/droplet precautions, PPE protocols, cytokine storm, and ventilator management',        15, true, 'published'),
  ('20000000-0000-0000-0000-000000000293', '10000000-0000-0000-0000-000000000017', 'Chickenpox (Varicella)',                                                   'Vesicular rash progression, airborne + contact precautions, acyclovir, and vaccine schedule',    16, true, 'published'),
  ('20000000-0000-0000-0000-000000000294', '10000000-0000-0000-0000-000000000017', 'Mumps',                                                                    'Parotid swelling, droplet precautions, MMR vaccine, orchitis complication',                      17, true, 'published'),
  ('20000000-0000-0000-0000-000000000295', '10000000-0000-0000-0000-000000000017', 'Rubella',                                                                  'German measles, teratogenic risk, droplet precautions, MMR vaccine, and congenital rubella',     18, true, 'published'),
  ('20000000-0000-0000-0000-000000000296', '10000000-0000-0000-0000-000000000017', 'Rubeola (Measles)',                                                        'Koplik spots, maculopapular rash, airborne precautions, vitamin A, and MMR immunization',       19, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000017',
  '10000000-0000-0000-0000-000000000017',
  'Autoimmune and Infectious Disorders – NCLEX Comprehensive Assessment',
  'Immune system dysfunction, infectious diseases, isolation precautions, and immunologic medications for NCLEX preparation',
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
-- VERIFICATION — should show all seventeen subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
