-- ============================================
-- ADD MENTAL HEALTH SUBJECT & TOPICS
-- Run in Supabase SQL Editor
-- Requires ADD-TOPIC-STATUS-COLUMN.sql already applied
-- ============================================

-- Step 1: Insert Mental Health subject (display_order = 16)
INSERT INTO test_subjects (id, name, description, icon, display_order, is_active)
VALUES (
  '10000000-0000-0000-0000-000000000016',
  'Mental Health',
  'Psychiatric foundations, therapeutic relationships, mental health disorders, and psychopharmacology',
  '🧠',
  16,
  true
)
ON CONFLICT (name) DO UPDATE SET
  description   = EXCLUDED.description,
  icon          = EXCLUDED.icon,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active;

-- Step 2: Insert 21 topics
--    IDs continue from Medical-Surgical (which used ...0250–...0256)
INSERT INTO test_topics (id, subject_id, name, description, display_order, is_active, status) VALUES
  ('20000000-0000-0000-0000-000000000257', '10000000-0000-0000-0000-000000000016', 'Mental Health Foundations',                        'Mental health vs mental illness, continuum of care, psychiatric assessment, and stigma',        1,  true, 'published'),
  ('20000000-0000-0000-0000-000000000258', '10000000-0000-0000-0000-000000000016', 'Mental Health Therapeutic Relationships',          'Trust, rapport, therapeutic vs social communication, and boundaries in psychiatric nursing',    2,  true, 'published'),
  ('20000000-0000-0000-0000-000000000259', '10000000-0000-0000-0000-000000000016', 'Legal, Ethical, and Safety Principles',            'Involuntary commitment, least restrictive environment, confidentiality, and duty to warn',      3,  true, 'published'),
  ('20000000-0000-0000-0000-000000000260', '10000000-0000-0000-0000-000000000016', 'Core Ethical Principles',                          'Autonomy, beneficence, nonmaleficence, justice, fidelity, and veracity in mental health care',  4,  true, 'published'),
  ('20000000-0000-0000-0000-000000000261', '10000000-0000-0000-0000-000000000016', 'Suicide Risk Assessment',                          'SAD PERSONS scale, protective factors, safety planning, and therapeutic limit-setting',         5,  true, 'published'),
  ('20000000-0000-0000-0000-000000000262', '10000000-0000-0000-0000-000000000016', 'Defense Mechanisms',                               'Repression, projection, denial, rationalization, sublimation, and displacement examples',       6,  true, 'published'),
  ('20000000-0000-0000-0000-000000000263', '10000000-0000-0000-0000-000000000016', 'Family Systems Theory',                            'Bowen theory, triangulation, differentiation, and family roles in psychiatric nursing',         7,  true, 'published'),
  ('20000000-0000-0000-0000-000000000264', '10000000-0000-0000-0000-000000000016', 'Four Main Parenting Styles',                       'Authoritative, authoritarian, permissive, and uninvolved styles and mental health outcomes',    8,  true, 'published'),
  ('20000000-0000-0000-0000-000000000265', '10000000-0000-0000-0000-000000000016', 'Guided Imagery',                                   'Mind-body relaxation technique, indications, contraindications, and nursing facilitation',     9,  true, 'published'),
  ('20000000-0000-0000-0000-000000000266', '10000000-0000-0000-0000-000000000016', 'Mental Health Medications',                        'Antipsychotics, antidepressants, mood stabilizers, anxiolytics, and EPS management',           10, true, 'published'),
  ('20000000-0000-0000-0000-000000000267', '10000000-0000-0000-0000-000000000016', 'Serotonin Syndrome',                               'Hyperthermia, clonus, agitation triad, offending drugs, cyproheptadine treatment',             11, true, 'published'),
  ('20000000-0000-0000-0000-000000000268', '10000000-0000-0000-0000-000000000016', 'Electroconvulsive Therapy (ECT)',                  'Indications, pre/post-procedure care, memory side effects, and informed consent',              12, true, 'published'),
  ('20000000-0000-0000-0000-000000000269', '10000000-0000-0000-0000-000000000016', 'Delirium, Depression, and Dementia',               'The 3 Ds — onset differences, reversibility, cognitive features, and nursing interventions',   13, true, 'published'),
  ('20000000-0000-0000-0000-000000000270', '10000000-0000-0000-0000-000000000016', 'Alzheimer''s Disease',                             'Stages, sundowning, safety measures, caregiver burden, and cholinesterase inhibitors',         14, true, 'published'),
  ('20000000-0000-0000-0000-000000000271', '10000000-0000-0000-0000-000000000016', 'Anxiety Disorders',                                'GAD, panic disorder, PTSD, OCD, phobias — CBT, SSRIs, and therapeutic communication',          15, true, 'published'),
  ('20000000-0000-0000-0000-000000000272', '10000000-0000-0000-0000-000000000016', 'Eating Disorders',                                 'Anorexia, bulimia, binge-eating disorder — medical complications, refeeding syndrome',         16, true, 'published'),
  ('20000000-0000-0000-0000-000000000273', '10000000-0000-0000-0000-000000000016', 'Substance Abuse and Addiction',                    'CAGE screening, alcohol/opioid withdrawal timelines, Wernicke''s, naloxone, and methadone',    17, true, 'published'),
  ('20000000-0000-0000-0000-000000000274', '10000000-0000-0000-0000-000000000016', 'Bipolar Disorder',                                 'Manic vs depressive episodes, lithium monitoring, mood stabilizers, and safety planning',      18, true, 'published'),
  ('20000000-0000-0000-0000-000000000275', '10000000-0000-0000-0000-000000000016', 'Personality Disorders',                            'Cluster A/B/C types, borderline, antisocial, narcissistic — milieu and limit-setting care',    19, true, 'published'),
  ('20000000-0000-0000-0000-000000000276', '10000000-0000-0000-0000-000000000016', 'Schizophrenia',                                    'Positive/negative symptoms, antipsychotics, clozapine monitoring, and relapse prevention',     20, true, 'published'),
  ('20000000-0000-0000-0000-000000000277', '10000000-0000-0000-0000-000000000016', 'Cognitive Impairments and Attention Disorders',    'ADHD, intellectual disability, autism spectrum — stimulant medications and behavioral care',   21, true, 'published')
ON CONFLICT (id) DO UPDATE SET
  name          = EXCLUDED.name,
  description   = EXCLUDED.description,
  display_order = EXCLUDED.display_order,
  is_active     = EXCLUDED.is_active,
  status        = EXCLUDED.status;

-- Step 3: Create test config for Mental Health
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES (
  '00000000-0000-0000-0000-000000000016',
  '10000000-0000-0000-0000-000000000016',
  'Mental Health – NCLEX Comprehensive Assessment',
  'Psychiatric foundations, therapeutic relationships, mental health disorders, and psychopharmacology for NCLEX preparation',
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
-- VERIFICATION — should show all sixteen subjects
-- ============================================
SELECT s.name AS subject, s.display_order, COUNT(t.id) AS topic_count
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id AND t.status = 'published'
GROUP BY s.name, s.display_order
ORDER BY s.display_order;
