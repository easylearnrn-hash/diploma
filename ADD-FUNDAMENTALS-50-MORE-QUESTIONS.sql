-- ============================================
-- FUNDAMENTALS OF NURSING - 50 ADDITIONAL QUESTIONS
-- ============================================
-- Run this AFTER ADD-FUNDAMENTALS-50-QUESTIONS.sql and REMAP-EXISTING-QUESTIONS.sql
-- These questions will be added to Topic 1: Fundamentals

-- Insert 50 Additional Fundamentals Questions (display_order 51-100)
INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES

-- Fall Safety & Orthostatic Hypotension (Questions 51-52)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which action violates fall precautions?', '[{"id":"a","text":"Yellow wristband applied"},{"id":"b","text":"Bed in lowest position"},{"id":"c","text":"Four side rails raised"},{"id":"d","text":"Call light within reach"}]'::jsonb, ARRAY['c'], false, 'Four side rails raised is considered a restraint and increases fall risk when patients try to climb over them.', 'Safety', 51),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'A patient reports dizziness upon standing. Which safety assessment is most appropriate?', '[{"id":"a","text":"Oxygen saturation"},{"id":"b","text":"Orthostatic hypotension"},{"id":"c","text":"Heart rate variability"},{"id":"d","text":"Temperature trend"}]'::jsonb, ARRAY['b'], false, 'Dizziness upon standing suggests orthostatic hypotension; assess BP supine and standing.', 'Safety', 52),

-- Airborne & Contact Precautions (Questions 53-55)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which patient requires airborne precautions?', '[{"id":"a","text":"MRSA"},{"id":"b","text":"Influenza"},{"id":"c","text":"Measles"},{"id":"d","text":"C. diff"}]'::jsonb, ARRAY['c'], false, 'Measles requires airborne precautions (N95 + negative pressure room).', 'Infection Control', 53),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which PPE combination is correct for TB?', '[{"id":"a","text":"Gloves + gown"},{"id":"b","text":"Mask within 3 feet"},{"id":"c","text":"N95 + negative pressure room"},{"id":"d","text":"Surgical mask only"}]'::jsonb, ARRAY['c'], false, 'TB requires airborne precautions with N95 respirator and negative pressure room.', 'Infection Control', 54),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Alcohol-based hand rub is inappropriate in which case?', '[{"id":"a","text":"Before patient contact"},{"id":"b","text":"After removing gloves"},{"id":"c","text":"Visible dirt on hands"},{"id":"d","text":"After touching equipment"}]'::jsonb, ARRAY['c'], false, 'When hands are visibly soiled, soap and water must be used instead of alcohol rub.', 'Infection Control', 55),

-- Vital Signs Critical Values (Questions 56-57)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which finding must be reported immediately?', '[{"id":"a","text":"HR 98 bpm"},{"id":"b","text":"BP 110/70"},{"id":"c","text":"Temp 100.6°F"},{"id":"d","text":"RR 18"}]'::jsonb, ARRAY['c'], false, 'Temperature ≥100.4°F indicates fever and possible infection requiring immediate attention.', 'Vital Signs', 56),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which SpO₂ value indicates hypoxemia?', '[{"id":"a","text":"94%"},{"id":"b","text":"92%"},{"id":"c","text":"89%"},{"id":"d","text":"95%"}]'::jsonb, ARRAY['c'], false, 'SpO₂ <90% indicates hypoxemia requiring oxygen intervention.', 'Vital Signs', 57),

-- Physical Assessment Order (Questions 58-60)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'The correct abdominal assessment order is:', '[{"id":"a","text":"I-P-P-A"},{"id":"b","text":"I-A-P-P"},{"id":"c","text":"A-I-P-P"},{"id":"d","text":"P-A-I-P"}]'::jsonb, ARRAY['b'], false, 'Abdomen: Inspect, Auscultate, Percuss, Palpate (I-A-P-P) to avoid altering bowel sounds.', 'Physical Assessment', 58),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Palpating before auscultating the abdomen may cause:', '[{"id":"a","text":"Infection"},{"id":"b","text":"Pain"},{"id":"c","text":"False bowel sounds"},{"id":"d","text":"Hypotension"}]'::jsonb, ARRAY['c'], false, 'Palpation can stimulate peristalsis and create false bowel sounds; auscultate first.', 'Physical Assessment', 59),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Percussion helps differentiate:', '[{"id":"a","text":"Muscle tone"},{"id":"b","text":"Fluid vs air"},{"id":"c","text":"Pulse strength"},{"id":"d","text":"Skin color"}]'::jsonb, ARRAY['b'], false, 'Percussion produces sounds that help distinguish fluid-filled areas from air-filled spaces.', 'Physical Assessment', 60),

-- Documentation Standards (Questions 61-63)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which is legally acceptable documentation?', '[{"id":"a","text":"\"Patient lazy and noncompliant.\""},{"id":"b","text":"\"Patient states, ''I feel dizzy.''\""},{"id":"c","text":"\"Patient dramatic about pain.\""},{"id":"d","text":"\"Patient exaggerates symptoms.\""}]'::jsonb, ARRAY['b'], false, 'Use objective data and direct patient quotes; avoid judgmental language.', 'Documentation', 61),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which documentation action is prohibited?', '[{"id":"a","text":"Quoting patient"},{"id":"b","text":"EMR charting"},{"id":"c","text":"Leaving blank spaces"},{"id":"d","text":"Recording outcomes"}]'::jsonb, ARRAY['c'], false, 'Blank spaces allow alteration of records; draw line through unused space or use electronic records.', 'Documentation', 62),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'A nurse forgets to chart earlier care. What is required?', '[{"id":"a","text":"Leave it uncharted"},{"id":"b","text":"Backdate entry"},{"id":"c","text":"Late entry with date, time, reason"},{"id":"d","text":"Ask another nurse to chart"}]'::jsonb, ARRAY['c'], false, 'Late entries must be labeled as such with current date/time and explanation.', 'Documentation', 63),

-- Ethics Principles (Questions 64-66)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which ethical principle is violated if a nurse lies to a patient?', '[{"id":"a","text":"Justice"},{"id":"b","text":"Fidelity"},{"id":"c","text":"Veracity"},{"id":"d","text":"Autonomy"}]'::jsonb, ARRAY['c'], false, 'Veracity is truthfulness; lying violates this ethical principle.', 'Ethics', 64),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Keeping promises reflects:', '[{"id":"a","text":"Justice"},{"id":"b","text":"Beneficence"},{"id":"c","text":"Fidelity"},{"id":"d","text":"Nonmaleficence"}]'::jsonb, ARRAY['c'], false, 'Fidelity is faithfulness and loyalty; keeping promises demonstrates fidelity.', 'Ethics', 65),

-- Informed Consent (Questions 66-68)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Informed consent is invalid if patient is:', '[{"id":"a","text":"Alert"},{"id":"b","text":"Voluntary"},{"id":"c","text":"Sedated"},{"id":"d","text":"Competent"}]'::jsonb, ARRAY['c'], false, 'Sedation impairs decision-making capacity; patient must be alert and competent.', 'Informed Consent', 66),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Who explains the procedure risks?', '[{"id":"a","text":"RN"},{"id":"b","text":"CNA"},{"id":"c","text":"Provider"},{"id":"d","text":"Family"}]'::jsonb, ARRAY['c'], false, 'The provider performing the procedure explains risks, benefits, and alternatives.', 'Informed Consent', 67),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'RN role in consent:', '[{"id":"a","text":"Explain risks"},{"id":"b","text":"Decide treatment"},{"id":"c","text":"Witness signature"},{"id":"d","text":"Obtain permission"}]'::jsonb, ARRAY['c'], false, 'The nurse witnesses the signature and ensures patient understanding; provider explains risks.', 'Informed Consent', 68),

-- Therapeutic Communication (Questions 69-71)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which is therapeutic communication?', '[{"id":"a","text":"\"Why did you wait so long?\""},{"id":"b","text":"\"Tell me more.\""},{"id":"c","text":"\"Calm down.\""},{"id":"d","text":"\"You''ll be fine.\""}]'::jsonb, ARRAY['b'], false, 'Open-ended statements like "Tell me more" encourage patient expression.', 'Communication', 69),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which question style should be avoided?', '[{"id":"a","text":"Open-ended"},{"id":"b","text":"Reflective"},{"id":"c","text":"\"Why\""},{"id":"d","text":"Clarifying"}]'::jsonb, ARRAY['c'], false, '"Why" questions can seem accusatory and put patients on the defensive.', 'Communication', 70),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'For language barriers, use:', '[{"id":"a","text":"Adult child"},{"id":"b","text":"Spouse"},{"id":"c","text":"Interpreter"},{"id":"d","text":"Friend"}]'::jsonb, ARRAY['c'], false, 'Professional interpreters ensure accurate communication and maintain confidentiality.', 'Communication', 71),

-- Patient Teaching (Questions 72-73)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Teaching level should be:', '[{"id":"a","text":"College"},{"id":"b","text":"10th grade"},{"id":"c","text":"5th grade"},{"id":"d","text":"Medical level"}]'::jsonb, ARRAY['c'], false, 'Patient teaching materials should be at 5th-grade reading level for accessibility.', 'Patient Teaching', 72),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Teach-back verifies:', '[{"id":"a","text":"Literacy"},{"id":"b","text":"Understanding"},{"id":"c","text":"Compliance"},{"id":"d","text":"Memory"}]'::jsonb, ARRAY['b'], false, 'Teach-back method confirms patient understanding by having them explain in their own words.', 'Patient Teaching', 73),

-- Patient Positioning (Questions 74-77)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Best position for dyspnea?', '[{"id":"a","text":"Supine"},{"id":"b","text":"High Fowler''s"},{"id":"c","text":"Sims''"},{"id":"d","text":"Trendelenburg"}]'::jsonb, ARRAY['b'], false, 'High Fowler''s (sitting upright) maximizes chest expansion and eases breathing.', 'Positioning', 74),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Position for hypotension and shock?', '[{"id":"a","text":"Fowler''s"},{"id":"b","text":"Lithotomy"},{"id":"c","text":"Trendelenburg"},{"id":"d","text":"Supine"}]'::jsonb, ARRAY['c'], false, 'Trendelenburg (legs elevated) promotes venous return to increase blood pressure.', 'Positioning', 75),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Prone position is used for:', '[{"id":"a","text":"NG feeding"},{"id":"b","text":"Pelvic exam"},{"id":"c","text":"ARDS"},{"id":"d","text":"Enema"}]'::jsonb, ARRAY['c'], false, 'Prone positioning (face-down) improves oxygenation in ARDS patients.', 'Positioning', 76),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Sims'' position is used for:', '[{"id":"a","text":"Pelvic exams"},{"id":"b","text":"Enemas"},{"id":"c","text":"Hypotension"},{"id":"d","text":"Eating"}]'::jsonb, ARRAY['b'], false, 'Sims'' position (left side-lying) facilitates rectal exams and enema administration.', 'Positioning', 77),

-- Medication Administration (Questions 78-81)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which is part of the 6 Rights?', '[{"id":"a","text":"Right nurse"},{"id":"b","text":"Right allergy"},{"id":"c","text":"Right documentation"},{"id":"d","text":"Right diagnosis"}]'::jsonb, ARRAY['c'], false, '6 Rights: Right patient, drug, dose, route, time, documentation.', 'Medication Administration', 78),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Right time means:', '[{"id":"a","text":"Within 1 hour"},{"id":"b","text":"At shift change"},{"id":"c","text":"Within 30 minutes"},{"id":"d","text":"Before meals only"}]'::jsonb, ARRAY['c'], false, 'Medications should be given within 30 minutes of scheduled time (unless critical).', 'Medication Administration', 79),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Right patient verification includes:', '[{"id":"a","text":"Room number"},{"id":"b","text":"Asking another nurse"},{"id":"c","text":"ID band + name/DOB"},{"id":"d","text":"Chart only"}]'::jsonb, ARRAY['c'], false, 'Use 2 patient identifiers: ID band with name and date of birth.', 'Medication Administration', 80),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Before giving meds always check:', '[{"id":"a","text":"BP"},{"id":"b","text":"Pulse"},{"id":"c","text":"Allergies"},{"id":"d","text":"Weight"}]'::jsonb, ARRAY['c'], false, 'Always check allergies before medication administration to prevent allergic reactions.', 'Medication Administration', 81),

-- Sterile vs Clean Technique (Questions 82-83)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Surgical wound care requires:', '[{"id":"a","text":"Clean technique"},{"id":"b","text":"Sterile technique"},{"id":"c","text":"Gloves only"},{"id":"d","text":"Alcohol rub only"}]'::jsonb, ARRAY['b'], false, 'Fresh surgical wounds require sterile technique to prevent infection.', 'Wound Care', 82),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Chronic wound care uses:', '[{"id":"a","text":"Sterile technique"},{"id":"b","text":"Clean technique"},{"id":"c","text":"No gloves"},{"id":"d","text":"Isolation"}]'::jsonb, ARRAY['b'], false, 'Chronic wounds can be managed with clean technique and clean gloves.', 'Wound Care', 83),

-- Tube Management (Questions 84-86)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'NG tube placement is confirmed by:', '[{"id":"a","text":"Air auscultation"},{"id":"b","text":"X-ray only"},{"id":"c","text":"pH or X-ray"},{"id":"d","text":"Observation"}]'::jsonb, ARRAY['c'], false, 'NG tube placement confirmed by pH testing (<5.5) or X-ray; air auscultation is unreliable.', 'Tube Management', 84),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'IV infiltration signs:', '[{"id":"a","text":"Red, warm"},{"id":"b","text":"Cool, swollen"},{"id":"c","text":"Pain only"},{"id":"d","text":"Bleeding"}]'::jsonb, ARRAY['b'], false, 'Infiltration: fluid leaks into tissue causing cool, pale, swollen area.', 'Tube Management', 85),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'IV phlebitis signs:', '[{"id":"a","text":"Cool, pale"},{"id":"b","text":"Red, warm"},{"id":"c","text":"Swollen only"},{"id":"d","text":"Numbness"}]'::jsonb, ARRAY['b'], false, 'Phlebitis: vein inflammation causing red, warm, tender streak along vein.', 'Tube Management', 86),

-- Isolation Precautions (Questions 87-89)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which is Standard Precaution?', '[{"id":"a","text":"N95 for all"},{"id":"b","text":"Gloves for blood"},{"id":"c","text":"Mask within 3 feet"},{"id":"d","text":"Negative pressure room"}]'::jsonb, ARRAY['b'], false, 'Standard Precautions: gloves when contacting blood/body fluids for all patients.', 'Infection Control', 87),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Droplet precautions require:', '[{"id":"a","text":"Gown only"},{"id":"b","text":"N95"},{"id":"c","text":"Mask within 3 feet"},{"id":"d","text":"Gloves only"}]'::jsonb, ARRAY['c'], false, 'Droplet precautions: surgical mask when within 3 feet (influenza, pertussis).', 'Infection Control', 88),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Contact precautions require:', '[{"id":"a","text":"Mask"},{"id":"b","text":"Gloves + gown"},{"id":"c","text":"N95"},{"id":"d","text":"Eye shield"}]'::jsonb, ARRAY['b'], false, 'Contact precautions: gloves and gown before entering room (MRSA, C. diff).', 'Infection Control', 89),

-- Documentation Rules (Question 90)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which violates documentation rules?', '[{"id":"a","text":"EMR"},{"id":"b","text":"Objective wound size"},{"id":"c","text":"White-out"},{"id":"d","text":"Direct quote"}]'::jsonb, ARRAY['c'], false, 'White-out is prohibited; use single line-through or EMR correction methods.', 'Documentation', 90),

-- Pain & Vital Sign Standards (Questions 91-94)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Pain must always be assessed using:', '[{"id":"a","text":"HR"},{"id":"b","text":"Facial expression only"},{"id":"c","text":"0–10 scale or faces chart"},{"id":"d","text":"BP"}]'::jsonb, ARRAY['c'], false, 'Use standardized pain scale (0-10 numeric or Wong-Baker faces) for consistent assessment.', 'Pain Management', 91),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Normal oxygen saturation range:', '[{"id":"a","text":"90–95%"},{"id":"b","text":"92–98%"},{"id":"c","text":"95–100%"},{"id":"d","text":"94–100%"}]'::jsonb, ARRAY['c'], false, 'Normal SpO₂ is 95-100%; <95% may require intervention.', 'Vital Signs', 92),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Normal temperature range:', '[{"id":"a","text":"96–98°F"},{"id":"b","text":"97.8–99.1°F"},{"id":"c","text":"98–100°F"},{"id":"d","text":"99–101°F"}]'::jsonb, ARRAY['b'], false, 'Normal oral temperature: 97.8-99.1°F (36.5-37.3°C).', 'Vital Signs', 93),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Normal respiratory rate:', '[{"id":"a","text":"10–16"},{"id":"b","text":"12–20"},{"id":"c","text":"14–22"},{"id":"d","text":"16–24"}]'::jsonb, ARRAY['b'], false, 'Normal adult respiratory rate is 12-20 breaths per minute.', 'Vital Signs', 94),

-- Ethics Principles (Questions 95-97)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which principle supports patient choice?', '[{"id":"a","text":"Beneficence"},{"id":"b","text":"Justice"},{"id":"c","text":"Autonomy"},{"id":"d","text":"Fidelity"}]'::jsonb, ARRAY['c'], false, 'Autonomy is the patient''s right to self-determination and make their own decisions.', 'Ethics', 95),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Fair treatment reflects:', '[{"id":"a","text":"Justice"},{"id":"b","text":"Veracity"},{"id":"c","text":"Fidelity"},{"id":"d","text":"Autonomy"}]'::jsonb, ARRAY['a'], false, 'Justice is fairness and equal distribution of resources and treatment.', 'Ethics', 96),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '"Do no harm" refers to:', '[{"id":"a","text":"Beneficence"},{"id":"b","text":"Nonmaleficence"},{"id":"c","text":"Justice"},{"id":"d","text":"Autonomy"}]'::jsonb, ARRAY['b'], false, 'Nonmaleficence is the duty to do no harm to patients.', 'Ethics', 97),

-- Final Documentation & Safety (Questions 98-100)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which is an example of objective documentation?', '[{"id":"a","text":"\"Patient upset.\""},{"id":"b","text":"\"Patient difficult.\""},{"id":"c","text":"\"BP 150/90 mmHg.\""},{"id":"d","text":"\"Patient lazy.\""}]'::jsonb, ARRAY['c'], false, 'Objective data is measurable and observable; avoid subjective interpretations.', 'Documentation', 98),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which action reduces false bowel sounds?', '[{"id":"a","text":"Percuss first"},{"id":"b","text":"Palpate deeply"},{"id":"c","text":"Auscultate before palpation"},{"id":"d","text":"Elevate HOB"}]'::jsonb, ARRAY['c'], false, 'Auscultate abdomen before palpating to avoid stimulating false bowel sounds.', 'Physical Assessment', 99),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which is correct regarding safety priorities?', '[{"id":"a","text":"Documentation first"},{"id":"b","text":"Ethics first"},{"id":"c","text":"Safety protects patient and nurse"},{"id":"d","text":"Teaching first"}]'::jsonb, ARRAY['c'], false, 'Safety is always the priority; protects both patients and healthcare workers.', 'Safety', 100);

-- ============================================
-- VERIFICATION
-- ============================================

-- Show total question count for Fundamentals topic
SELECT 
  t.name as topic_name,
  COUNT(q.id) as total_questions
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id 
  AND q.test_id = '00000000-0000-0000-0000-000000000001'
WHERE t.id = '20000000-0000-0000-0000-000000000001'
GROUP BY t.id, t.name;
-- Expected: Fundamentals with 100 questions (50 original + 50 new)

-- Verify display_order range
SELECT 
  MIN(display_order) as first_question,
  MAX(display_order) as last_question,
  COUNT(*) as total_count
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000001';
-- Expected: 1 to 100, count = 100
