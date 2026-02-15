-- ============================================
-- FUNDAMENTALS OF NURSING - 50 NCLEX QUESTIONS
-- ============================================
-- Run this AFTER ADD-SUBJECTS-TOPICS-TABLE.sql

-- Delete any existing fundamentals questions to avoid duplicates
DELETE FROM test_questions WHERE test_id = '00000000-0000-0000-0000-000000000001';

-- Insert 50 Fundamentals Questions
INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES

-- Infection Control (Questions 1-5)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'What is the #1 way to prevent infection?', '[{"id":"a","text":"Antibiotics"},{"id":"b","text":"Vaccination"},{"id":"c","text":"Hand hygiene"},{"id":"d","text":"Isolation"}]'::jsonb, ARRAY['c'], false, 'Hand hygiene is the single most effective way to prevent healthcare-associated infections.', 'Infection Control', 1),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Which precaution is used for MRSA?', '[{"id":"a","text":"Airborne"},{"id":"b","text":"Droplet"},{"id":"c","text":"Contact"},{"id":"d","text":"Protective"}]'::jsonb, ARRAY['c'], false, 'MRSA requires contact precautions due to skin-to-skin transmission risk.', 'Infection Control', 2),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'What PPE is required for TB?', '[{"id":"a","text":"Surgical mask"},{"id":"b","text":"Gloves only"},{"id":"c","text":"N95 mask"},{"id":"d","text":"Face shield"}]'::jsonb, ARRAY['c'], false, 'Tuberculosis requires airborne precautions with N95 respirator.', 'Infection Control', 3),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'When must soap and water be used instead of alcohol rub?', '[{"id":"a","text":"After every patient"},{"id":"b","text":"Before meals"},{"id":"c","text":"For C. diff or visible dirt"},{"id":"d","text":"After glove removal"}]'::jsonb, ARRAY['c'], false, 'Alcohol-based hand rub does not kill C. diff spores; soap and water required.', 'Infection Control', 4),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'How long should hands be washed?', '[{"id":"a","text":"5–10 seconds"},{"id":"b","text":"10–15 seconds"},{"id":"c","text":"15–30 seconds"},{"id":"d","text":"45 seconds"}]'::jsonb, ARRAY['c'], false, 'Proper handwashing technique requires 15-30 seconds of vigorous scrubbing.', 'Infection Control', 5),

-- Vital Signs (Questions 6-10)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A temperature above what indicates possible infection?', '[{"id":"a","text":"99°F"},{"id":"b","text":"100.4°F"},{"id":"c","text":"101°F"},{"id":"d","text":"102°F"}]'::jsonb, ARRAY['b'], false, 'Fever is defined as temperature ≥100.4°F (38°C).', 'Vital Signs', 6),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'O2 saturation below what indicates hypoxemia?', '[{"id":"a","text":"95%"},{"id":"b","text":"93%"},{"id":"c","text":"92%"},{"id":"d","text":"90%"}]'::jsonb, ARRAY['d'], false, 'Hypoxemia is defined as SpO2 <90%, requiring intervention.', 'Vital Signs', 7),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Normal heart rate range?', '[{"id":"a","text":"50–90 bpm"},{"id":"b","text":"60–100 bpm"},{"id":"c","text":"70–110 bpm"},{"id":"d","text":"80–120 bpm"}]'::jsonb, ARRAY['b'], false, 'Normal adult heart rate is 60-100 beats per minute.', 'Vital Signs', 8),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Normal respiratory rate?', '[{"id":"a","text":"10–18"},{"id":"b","text":"12–20"},{"id":"c","text":"14–24"},{"id":"d","text":"16–22"}]'::jsonb, ARRAY['b'], false, 'Normal adult respiratory rate is 12-20 breaths per minute.', 'Vital Signs', 9),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Normal blood pressure range?', '[{"id":"a","text":"80/50–110/70"},{"id":"b","text":"100/60–130/90"},{"id":"c","text":"90/60–120/80"},{"id":"d","text":"110/70–140/90"}]'::jsonb, ARRAY['c'], false, 'Normal BP is <120/80 mmHg; range 90/60-120/80 is considered normal.', 'Vital Signs', 10),

-- Physical Assessment (Questions 11-17)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Order of physical assessment?', '[{"id":"a","text":"Palpate → Inspect → Percuss → Auscultate"},{"id":"b","text":"Inspect → Palpate → Percuss → Auscultate"},{"id":"c","text":"Auscultate → Inspect → Percuss → Palpate"},{"id":"d","text":"Inspect → Percuss → Palpate → Auscultate"}]'::jsonb, ARRAY['b'], false, 'Standard physical exam order is Inspect, Palpate, Percuss, Auscultate (I-P-P-A).', 'Physical Assessment', 11),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Abdominal assessment order?', '[{"id":"a","text":"I-P-P-A"},{"id":"b","text":"I-A-P-P"},{"id":"c","text":"A-I-P-P"},{"id":"d","text":"P-I-A-P"}]'::jsonb, ARRAY['b'], false, 'Abdomen: Inspect, Auscultate, Percuss, Palpate (I-A-P-P) to avoid altering bowel sounds.', 'Physical Assessment', 12),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Why auscultate before palpating the abdomen?', '[{"id":"a","text":"Prevent infection"},{"id":"b","text":"Avoid false bowel sounds"},{"id":"c","text":"Reduce pain"},{"id":"d","text":"Save time"}]'::jsonb, ARRAY['b'], false, 'Palpation can stimulate bowel activity and create false bowel sounds.', 'Physical Assessment', 13),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Inspect means:', '[{"id":"a","text":"Feel"},{"id":"b","text":"Tap"},{"id":"c","text":"Listen"},{"id":"d","text":"Look"}]'::jsonb, ARRAY['d'], false, 'Inspection involves visual observation of the patient.', 'Physical Assessment', 14),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Palpate means:', '[{"id":"a","text":"Listen"},{"id":"b","text":"Tap"},{"id":"c","text":"Feel with hands"},{"id":"d","text":"Observe"}]'::jsonb, ARRAY['c'], false, 'Palpation uses hands to feel structures beneath the skin.', 'Physical Assessment', 15),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Percuss means:', '[{"id":"a","text":"Look"},{"id":"b","text":"Tap to hear sound changes"},{"id":"c","text":"Feel pulse"},{"id":"d","text":"Measure BP"}]'::jsonb, ARRAY['b'], false, 'Percussion involves tapping to assess underlying structures by sound.', 'Physical Assessment', 16),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Auscultate means:', '[{"id":"a","text":"Observe"},{"id":"b","text":"Tap"},{"id":"c","text":"Listen with stethoscope"},{"id":"d","text":"Palpate"}]'::jsonb, ARRAY['c'], false, 'Auscultation uses a stethoscope to listen to body sounds.', 'Physical Assessment', 17),

-- Documentation (Questions 18-20)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Which is correct documentation?', '[{"id":"a","text":"Patient seems lazy."},{"id":"b","text":"Patient appears dramatic."},{"id":"c","text":"Wound 2 cm with red edges."},{"id":"d","text":"Patient exaggerates pain."}]'::jsonb, ARRAY['c'], false, 'Documentation must be objective, measurable, and factual without opinions.', 'Documentation', 18),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'What should NOT be used in documentation?', '[{"id":"a","text":"EMR"},{"id":"b","text":"Black ink"},{"id":"c","text":"White-out"},{"id":"d","text":"Direct quotes"}]'::jsonb, ARRAY['c'], false, 'Never use white-out; instead draw single line through error and initial.', 'Documentation', 19),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'What must be labeled for late entry?', '[{"id":"a","text":"Only date"},{"id":"b","text":"Only time"},{"id":"c","text":"Date, time, reason"},{"id":"d","text":"Nurse initials only"}]'::jsonb, ARRAY['c'], false, 'Late entries must be clearly labeled with date, time, and reason for delay.', 'Documentation', 20),

-- Ethics & Legal (Questions 21-29)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Autonomy means:', '[{"id":"a","text":"Do good"},{"id":"b","text":"Fair treatment"},{"id":"c","text":"Right to make decisions"},{"id":"d","text":"Keep promises"}]'::jsonb, ARRAY['c'], false, 'Autonomy is the patient''s right to make their own healthcare decisions.', 'Ethics & Legal', 21),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Beneficence means:', '[{"id":"a","text":"Do good"},{"id":"b","text":"Do no harm"},{"id":"c","text":"Justice"},{"id":"d","text":"Truth"}]'::jsonb, ARRAY['a'], false, 'Beneficence means actions that promote the well-being of others.', 'Ethics & Legal', 22),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nonmaleficence means:', '[{"id":"a","text":"Be fair"},{"id":"b","text":"Do no harm"},{"id":"c","text":"Be honest"},{"id":"d","text":"Be loyal"}]'::jsonb, ARRAY['b'], false, 'Nonmaleficence means to do no harm to the patient.', 'Ethics & Legal', 23),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Justice refers to:', '[{"id":"a","text":"Honesty"},{"id":"b","text":"Fair treatment"},{"id":"c","text":"Promises"},{"id":"d","text":"Freedom"}]'::jsonb, ARRAY['b'], false, 'Justice means fair and equal treatment for all patients.', 'Ethics & Legal', 24),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Fidelity means:', '[{"id":"a","text":"Tell truth"},{"id":"b","text":"Keep promises"},{"id":"c","text":"Do good"},{"id":"d","text":"No harm"}]'::jsonb, ARRAY['b'], false, 'Fidelity means keeping promises and commitments to patients.', 'Ethics & Legal', 25),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Veracity means:', '[{"id":"a","text":"Justice"},{"id":"b","text":"Truth"},{"id":"c","text":"Loyalty"},{"id":"d","text":"Autonomy"}]'::jsonb, ARRAY['b'], false, 'Veracity means telling the truth and being honest with patients.', 'Ethics & Legal', 26),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Who explains procedures for informed consent?', '[{"id":"a","text":"RN"},{"id":"b","text":"CNA"},{"id":"c","text":"Provider"},{"id":"d","text":"Family"}]'::jsonb, ARRAY['c'], false, 'The healthcare provider performing the procedure obtains informed consent.', 'Ethics & Legal', 27),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'The RN''s role in consent:', '[{"id":"a","text":"Explain procedure"},{"id":"b","text":"Witness signature"},{"id":"c","text":"Obtain permission"},{"id":"d","text":"Translate risks"}]'::jsonb, ARRAY['b'], false, 'The nurse witnesses the signature after provider obtains informed consent.', 'Ethics & Legal', 28),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Consent is invalid if patient is:', '[{"id":"a","text":"Alert"},{"id":"b","text":"Competent"},{"id":"c","text":"Sedated"},{"id":"d","text":"Voluntary"}]'::jsonb, ARRAY['c'], false, 'Sedated patients cannot give informed consent as they lack decision-making capacity.', 'Ethics & Legal', 29),

-- Communication (Questions 30-34)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Which is therapeutic communication?', '[{"id":"a","text":"Why did you do that?"},{"id":"b","text":"Tell me more about how you''re feeling."},{"id":"c","text":"You shouldn''t feel that way."},{"id":"d","text":"Calm down."}]'::jsonb, ARRAY['b'], false, 'Open-ended questions encourage patient expression and exploration of feelings.', 'Communication', 30),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Avoid which type of question?', '[{"id":"a","text":"Open-ended"},{"id":"b","text":"Reflective"},{"id":"c","text":"Why questions"},{"id":"d","text":"Clarifying"}]'::jsonb, ARRAY['c'], false, '"Why" questions can make patients feel defensive or judged.', 'Communication', 31),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'For language barriers use:', '[{"id":"a","text":"Family"},{"id":"b","text":"Friend"},{"id":"c","text":"Interpreter"},{"id":"d","text":"Google Translate"}]'::jsonb, ARRAY['c'], false, 'Professional medical interpreters ensure accurate communication and confidentiality.', 'Communication', 32),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Teach at what level?', '[{"id":"a","text":"College"},{"id":"b","text":"8th grade"},{"id":"c","text":"5th grade"},{"id":"d","text":"High school"}]'::jsonb, ARRAY['c'], false, 'Patient education should be at 5th-6th grade reading level for comprehension.', 'Communication', 33),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'What confirms understanding?', '[{"id":"a","text":"Lecture"},{"id":"b","text":"Teach-back"},{"id":"c","text":"Pamphlet"},{"id":"d","text":"Video"}]'::jsonb, ARRAY['b'], false, 'Teach-back method has patient explain in their own words to confirm understanding.', 'Communication', 34),

-- Positioning & Mobility (Questions 35-39)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000007', 'Fowler''s position degree?', '[{"id":"a","text":"15–30°"},{"id":"b","text":"45–60°"},{"id":"c","text":"90°"},{"id":"d","text":"Flat"}]'::jsonb, ARRAY['b'], false, 'Fowler''s position is 45-60° head elevation; High Fowler''s is 60-90°.', 'Positioning & Mobility', 35),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000007', 'High Fowler''s is used for:', '[{"id":"a","text":"Shock"},{"id":"b","text":"Dyspnea"},{"id":"c","text":"Enemas"},{"id":"d","text":"Pelvic exams"}]'::jsonb, ARRAY['b'], false, 'High Fowler''s position (60-90°) maximizes lung expansion for dyspnea.', 'Positioning & Mobility', 36),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000007', 'Sims'' position is used for:', '[{"id":"a","text":"NG tube"},{"id":"b","text":"Enemas"},{"id":"c","text":"Pelvic exam"},{"id":"d","text":"Hypotension"}]'::jsonb, ARRAY['b'], false, 'Sims'' position (side-lying) is used for rectal exams and enema administration.', 'Positioning & Mobility', 37),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000007', 'Trendelenburg is used for:', '[{"id":"a","text":"Dyspnea"},{"id":"b","text":"Shock"},{"id":"c","text":"Eating"},{"id":"d","text":"Lung expansion"}]'::jsonb, ARRAY['b'], false, 'Trendelenburg (feet elevated) increases venous return in shock/hypotension.', 'Positioning & Mobility', 38),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000007', 'Lithotomy position is for:', '[{"id":"a","text":"Pelvic exams"},{"id":"b","text":"ARDS"},{"id":"c","text":"Eating"},{"id":"d","text":"Hypotension"}]'::jsonb, ARRAY['a'], false, 'Lithotomy position (supine with legs in stirrups) is for pelvic/vaginal exams.', 'Positioning & Mobility', 39),

-- Medication Administration (Questions 40-43)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000008', 'Always check what before giving meds?', '[{"id":"a","text":"Weight"},{"id":"b","text":"Allergies"},{"id":"c","text":"Pulse"},{"id":"d","text":"Temperature"}]'::jsonb, ARRAY['b'], false, 'Always verify allergies before medication administration to prevent reactions.', 'Medication Administration', 40),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000008', 'Right patient means:', '[{"id":"a","text":"Ask room number"},{"id":"b","text":"Check ID band"},{"id":"c","text":"Ask nurse"},{"id":"d","text":"Look at chart"}]'::jsonb, ARRAY['b'], false, 'Use two patient identifiers: check ID band and ask patient to state name and DOB.', 'Medication Administration', 41),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000008', 'Right time means:', '[{"id":"a","text":"Anytime in shift"},{"id":"b","text":"Within 30 min of scheduled"},{"id":"c","text":"Before meal"},{"id":"d","text":"After meal"}]'::jsonb, ARRAY['b'], false, 'Medications should be given within 30 minutes of scheduled time (±30 min).', 'Medication Administration', 42),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000008', 'Right documentation occurs:', '[{"id":"a","text":"Before giving"},{"id":"b","text":"After shift"},{"id":"c","text":"Immediately after giving"},{"id":"d","text":"Next day"}]'::jsonb, ARRAY['c'], false, 'Document medications immediately after administration to ensure accuracy.', 'Medication Administration', 43),

-- Sterile Technique (Questions 44-45)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000009', 'Catheter insertion requires:', '[{"id":"a","text":"Clean technique"},{"id":"b","text":"Sterile technique"},{"id":"c","text":"Gloves only"},{"id":"d","text":"Mask"}]'::jsonb, ARRAY['b'], false, 'Urinary catheter insertion requires strict sterile technique to prevent infection.', 'Sterile Technique', 44),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000009', 'Surgical wound care requires:', '[{"id":"a","text":"Clean technique"},{"id":"b","text":"Sterile technique"},{"id":"c","text":"Alcohol rub only"},{"id":"d","text":"No gloves"}]'::jsonb, ARRAY['b'], false, 'Surgical wound care requires sterile technique to prevent surgical site infection.', 'Sterile Technique', 45),

-- IV Therapy & Tubes (Questions 46-48)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000010', 'NG tube placement is confirmed by:', '[{"id":"a","text":"Air bolus"},{"id":"b","text":"Observation"},{"id":"c","text":"pH or X-ray"},{"id":"d","text":"Listening only"}]'::jsonb, ARRAY['c'], false, 'NG tube placement confirmed by pH testing or X-ray (gold standard).', 'IV Therapy & Tubes', 46),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000010', 'IV infiltration signs:', '[{"id":"a","text":"Red, warm"},{"id":"b","text":"Cool, swollen"},{"id":"c","text":"Hot, painful"},{"id":"d","text":"Bleeding"}]'::jsonb, ARRAY['b'], false, 'Infiltration: IV fluid leaks into tissue causing cool, pale, swollen site.', 'IV Therapy & Tubes', 47),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000010', 'Phlebitis signs:', '[{"id":"a","text":"Cool, pale"},{"id":"b","text":"Swollen"},{"id":"c","text":"Red, warm"},{"id":"d","text":"Numb"}]'::jsonb, ARRAY['c'], false, 'Phlebitis: Vein inflammation with red, warm, tender IV site.', 'IV Therapy & Tubes', 48),

-- Safety (Questions 49-50)
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000011', 'Keep how many side rails up to avoid restraint?', '[{"id":"a","text":"1"},{"id":"b","text":"2"},{"id":"c","text":"3"},{"id":"d","text":"4"}]'::jsonb, ARRAY['b'], false, 'Keep 2-3 side rails up for safety; all 4 rails up = physical restraint.', 'Safety', 49),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000011', 'Orthostatic hypotension means:', '[{"id":"a","text":"High BP sitting"},{"id":"b","text":"Drop in BP when standing"},{"id":"c","text":"High HR standing"},{"id":"d","text":"Low pulse lying down"}]'::jsonb, ARRAY['b'], false, 'Orthostatic hypotension: BP drops ≥20 mmHg systolic or ≥10 mmHg diastolic when standing.', 'Safety', 50);

-- ============================================
-- VERIFICATION
-- ============================================

SELECT COUNT(*) as total_questions FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001';

SELECT t.name as topic, COUNT(*) as question_count 
FROM test_questions q
JOIN test_topics t ON q.topic_id = t.id
WHERE q.test_id = '00000000-0000-0000-0000-000000000001'
GROUP BY t.name, t.display_order
ORDER BY t.display_order;
