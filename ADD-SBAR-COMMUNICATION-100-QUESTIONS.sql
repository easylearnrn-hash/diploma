-- ============================================
-- SBAR COMMUNICATION - 100 QUESTIONS
-- ============================================
-- Run this AFTER ADD-SUBJECTS-TOPICS-TABLE.sql
-- All 100 questions for Topic 6: SBAR Communication

-- Delete any existing questions for this topic to avoid duplicates
DELETE FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001' 
  AND topic_id = '20000000-0000-0000-0000-000000000006';

-- Insert 100 SBAR Communication Questions (display_order 1-100 for this topic)
INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES

-- Questions 1-10: SBAR Overview & Purpose
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR is primarily designed to:', '[{"id":"a","text":"Replace documentation"},{"id":"b","text":"Standardize communication"},{"id":"c","text":"Transfer accountability"},{"id":"d","text":"Shorten charting time"}]'::jsonb, ARRAY['b'], false, 'SBAR (Situation, Background, Assessment, Recommendation) is primarily designed to standardize communication, ensuring clear and consistent information transfer between healthcare providers.', 'SBAR Communication', 1),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR was originally developed by:', '[{"id":"a","text":"The Joint Commission"},{"id":"b","text":"Kaiser Permanente"},{"id":"c","text":"U.S. Navy"},{"id":"d","text":"Institute for Healthcare Improvement"}]'::jsonb, ARRAY['c'], false, 'SBAR was originally developed by the U.S. Navy as a submarine communication technique to ensure clear, concise communication in high-stakes situations.', 'SBAR Communication', 2),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR was later adapted for healthcare by:', '[{"id":"a","text":"CDC"},{"id":"b","text":"Kaiser Permanente & IHI"},{"id":"c","text":"WHO"},{"id":"d","text":"ANA"}]'::jsonb, ARRAY['b'], false, 'SBAR was adapted for healthcare by Kaiser Permanente and the Institute for Healthcare Improvement (IHI) to improve patient safety.', 'SBAR Communication', 3),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR improves:', '[{"id":"a","text":"Billing"},{"id":"b","text":"Communication clarity"},{"id":"c","text":"Staffing ratios"},{"id":"d","text":"Licensure"}]'::jsonb, ARRAY['b'], false, 'SBAR improves communication clarity by providing a structured framework that ensures critical information is conveyed efficiently.', 'SBAR Communication', 4),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR primarily promotes:', '[{"id":"a","text":"Faster discharges"},{"id":"b","text":"Patient safety"},{"id":"c","text":"Nurse independence"},{"id":"d","text":"Policy enforcement"}]'::jsonb, ARRAY['b'], false, 'SBAR primarily promotes patient safety by reducing communication errors and ensuring critical information is not missed.', 'SBAR Communication', 5),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR ensures information is:', '[{"id":"a","text":"Emotional"},{"id":"b","text":"Detailed storytelling"},{"id":"c","text":"Clear, concise, structured"},{"id":"d","text":"Informal"}]'::jsonb, ARRAY['c'], false, 'SBAR ensures information is clear, concise, and structured, eliminating unnecessary details while capturing essential facts.', 'SBAR Communication', 6),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR empowers nurses to:', '[{"id":"a","text":"Avoid providers"},{"id":"b","text":"Speak with clarity and confidence"},{"id":"c","text":"Delegate assessments"},{"id":"d","text":"Replace providers"}]'::jsonb, ARRAY['b'], false, 'SBAR empowers nurses to speak with clarity and confidence when communicating with providers, improving interprofessional collaboration.', 'SBAR Communication', 7),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR is commonly used during:', '[{"id":"a","text":"Meal breaks"},{"id":"b","text":"Shift handoffs"},{"id":"c","text":"Billing discussions"},{"id":"d","text":"Personal meetings"}]'::jsonb, ARRAY['b'], false, 'SBAR is commonly used during shift handoffs to ensure continuity of care and complete information transfer between nurses.', 'SBAR Communication', 8),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR reduces:', '[{"id":"a","text":"Communication errors"},{"id":"b","text":"Charting requirements"},{"id":"c","text":"Staffing needs"},{"id":"d","text":"Medication costs"}]'::jsonb, ARRAY['a'], false, 'SBAR reduces communication errors by providing a standardized format that ensures critical information is organized and complete.', 'SBAR Communication', 9),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR is part of:', '[{"id":"a","text":"State Nurse Practice Act"},{"id":"b","text":"Joint Commission best practices"},{"id":"c","text":"Federal licensure exam only"},{"id":"d","text":"Insurance policy"}]'::jsonb, ARRAY['b'], false, 'SBAR is part of Joint Commission best practices for improving communication and patient safety in healthcare settings.', 'SBAR Communication', 10),

-- Questions 11-25: S - Situation
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'The "S" in SBAR stands for:', '[{"id":"a","text":"Summary"},{"id":"b","text":"Status"},{"id":"c","text":"Situation"},{"id":"d","text":"Safety"}]'::jsonb, ARRAY['c'], false, 'The "S" in SBAR stands for Situation, which describes the immediate issue or reason for communication.', 'SBAR Communication', 11),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation includes:', '[{"id":"a","text":"Admission history"},{"id":"b","text":"Immediate issue"},{"id":"c","text":"Lab trends"},{"id":"d","text":"Teaching plan"}]'::jsonb, ARRAY['b'], false, 'Situation includes the immediate issue or problem that requires attention right now, not historical information.', 'SBAR Communication', 12),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation should include:', '[{"id":"a","text":"Nurse''s opinion only"},{"id":"b","text":"Nurse name, role, patient ID, current issue"},{"id":"c","text":"Entire chart"},{"id":"d","text":"Background only"}]'::jsonb, ARRAY['b'], false, 'Situation should include nurse identification, patient identification, and the current issue requiring attention.', 'SBAR Communication', 13),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Vital signs belong in Situation when:', '[{"id":"a","text":"Irrelevant"},{"id":"b","text":"Immediately relevant"},{"id":"c","text":"Stable"},{"id":"d","text":"Chronic"}]'::jsonb, ARRAY['b'], false, 'Vital signs belong in Situation when they are immediately relevant to the current problem or concern being reported.', 'SBAR Communication', 14),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Which belongs in Situation?', '[{"id":"a","text":"BNP level yesterday"},{"id":"b","text":"O₂ sat is 86% on room air"},{"id":"c","text":"Past surgery"},{"id":"d","text":"Admission date"}]'::jsonb, ARRAY['b'], false, 'Current oxygen saturation of 86% on room air belongs in Situation as it describes an immediate problem requiring attention.', 'SBAR Communication', 15),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation must answer:', '[{"id":"a","text":"What happened yesterday?"},{"id":"b","text":"What is happening right now?"},{"id":"c","text":"What might happen later?"},{"id":"d","text":"What labs are pending?"}]'::jsonb, ARRAY['b'], false, 'Situation must answer "What is happening right now?" focusing on the immediate problem or concern.', 'SBAR Communication', 16),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation should avoid:', '[{"id":"a","text":"Concise wording"},{"id":"b","text":"Storytelling"},{"id":"c","text":"Vital signs"},{"id":"d","text":"Identification"}]'::jsonb, ARRAY['b'], false, 'Situation should avoid storytelling or rambling narratives. Keep it concise and focused on the immediate issue.', 'SBAR Communication', 17),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation first statement when calling provider:', '[{"id":"a","text":"Background"},{"id":"b","text":"Recommendation"},{"id":"c","text":"Identify yourself and patient"},{"id":"d","text":"Assessment"}]'::jsonb, ARRAY['c'], false, 'The first statement in Situation should identify yourself (name and role) and the patient (name, room, problem).', 'SBAR Communication', 18),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Early Warning Score belongs in:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Recommendation"},{"id":"c","text":"Admission note"},{"id":"d","text":"Teaching"}]'::jsonb, ARRAY['a'], false, 'Early Warning Score belongs in Situation as it indicates the current severity or urgency of the patient''s condition.', 'SBAR Communication', 19),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation establishes:', '[{"id":"a","text":"Historical data"},{"id":"b","text":"Current urgency"},{"id":"c","text":"Lab trends"},{"id":"d","text":"Discharge plan"}]'::jsonb, ARRAY['b'], false, 'Situation establishes the current urgency and severity of the problem requiring attention or intervention.', 'SBAR Communication', 20),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Best Situation opening statement:', '[{"id":"a","text":"Patient has long history"},{"id":"b","text":"I''m calling about Mr. Smith in room 302 with chest pain"},{"id":"c","text":"Patient was admitted last week"},{"id":"d","text":"I think we should do something"}]'::jsonb, ARRAY['b'], false, 'Best Situation statement identifies yourself, the patient, and states the immediate problem clearly and concisely.', 'SBAR Communication', 21),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation includes time frame when:', '[{"id":"a","text":"Never relevant"},{"id":"b","text":"Symptoms started or changed"},{"id":"c","text":"Patient admitted"},{"id":"d","text":"Always excluded"}]'::jsonb, ARRAY['b'], false, 'Situation includes time frame when describing when symptoms started or changed, providing urgency context.', 'SBAR Communication', 22),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Which statement belongs in Situation?', '[{"id":"a","text":"Patient has diabetes since 1995"},{"id":"b","text":"Patient is experiencing acute shortness of breath"},{"id":"c","text":"Patient had surgery 2 days ago"},{"id":"d","text":"Patient''s family lives nearby"}]'::jsonb, ARRAY['b'], false, 'Acute shortness of breath describes the immediate problem and belongs in Situation. History and procedures go in Background.', 'SBAR Communication', 23),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation should be:', '[{"id":"a","text":"Lengthy and detailed"},{"id":"b","text":"Brief and focused"},{"id":"c","text":"Include entire medical history"},{"id":"d","text":"Opinion-based only"}]'::jsonb, ARRAY['b'], false, 'Situation should be brief and focused on the immediate problem, avoiding unnecessary details or lengthy explanations.', 'SBAR Communication', 24),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Priority information in Situation:', '[{"id":"a","text":"Admission diagnosis"},{"id":"b","text":"Current critical change"},{"id":"c","text":"Past medical history"},{"id":"d","text":"Social history"}]'::jsonb, ARRAY['b'], false, 'Priority information in Situation is the current critical change or problem requiring immediate attention.', 'SBAR Communication', 25),

-- Questions 26-40: B - Background
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Background includes:', '[{"id":"a","text":"Current issue only"},{"id":"b","text":"Relevant history and context"},{"id":"c","text":"Entire medical chart"},{"id":"d","text":"Teaching plan"}]'::jsonb, ARRAY['b'], false, 'Background includes relevant history and context that helps the provider understand the situation, not exhaustive details.', 'SBAR Communication', 26),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Admission diagnosis belongs in:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Background"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['b'], false, 'Admission diagnosis belongs in Background as it provides context for understanding the current situation.', 'SBAR Communication', 27),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recent procedures belong in:', '[{"id":"a","text":"Assessment"},{"id":"b","text":"Background"},{"id":"c","text":"Situation"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['b'], false, 'Recent procedures belong in Background as they provide relevant context for the current situation.', 'SBAR Communication', 28),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Allergies are included if:', '[{"id":"a","text":"Relevant"},{"id":"b","text":"Always excluded"},{"id":"c","text":"In assessment only"},{"id":"d","text":"In recommendation"}]'::jsonb, ARRAY['a'], false, 'Allergies are included in Background if they are relevant to the current situation or proposed interventions.', 'SBAR Communication', 29),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Background should be:', '[{"id":"a","text":"Brief and relevant"},{"id":"b","text":"Exhaustive"},{"id":"c","text":"Emotional"},{"id":"d","text":"Unstructured"}]'::jsonb, ARRAY['a'], false, 'Background should be brief and include only relevant information that provides context for the current situation.', 'SBAR Communication', 30),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Medication list belongs in:', '[{"id":"a","text":"Background"},{"id":"b","text":"Situation"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['a'], false, 'Current medication list belongs in Background as it provides important context for understanding the situation.', 'SBAR Communication', 31),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '"Admitted yesterday for COPD exacerbation" is:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Background"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['b'], false, 'Admission information and diagnosis belong in Background, providing context for the current situation.', 'SBAR Communication', 32),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Background helps provider:', '[{"id":"a","text":"Judge nurse"},{"id":"b","text":"Understand context"},{"id":"c","text":"Change diagnosis"},{"id":"d","text":"Delegate care"}]'::jsonb, ARRAY['b'], false, 'Background helps the provider understand the context and relevant history needed to make informed clinical decisions.', 'SBAR Communication', 33),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Background excludes:', '[{"id":"a","text":"Relevant labs"},{"id":"b","text":"Admission date"},{"id":"c","text":"Unrelated details"},{"id":"d","text":"Procedures"}]'::jsonb, ARRAY['c'], false, 'Background should exclude unrelated details that do not contribute to understanding the current situation.', 'SBAR Communication', 34),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Background should include:', '[{"id":"a","text":"Everything"},{"id":"b","text":"Pertinent information only"},{"id":"c","text":"Family history always"},{"id":"d","text":"Billing details"}]'::jsonb, ARRAY['b'], false, 'Background should include only pertinent information relevant to understanding and addressing the current situation.', 'SBAR Communication', 35),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Which belongs in Background?', '[{"id":"a","text":"Current chest pain"},{"id":"b","text":"History of MI 2 years ago"},{"id":"c","text":"I think patient is having MI"},{"id":"d","text":"I recommend EKG STAT"}]'::jsonb, ARRAY['b'], false, 'History of previous MI belongs in Background as relevant context. Current pain is Situation, interpretation is Assessment, EKG request is Recommendation.', 'SBAR Communication', 36),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Background provides:', '[{"id":"a","text":"Current vitals only"},{"id":"b","text":"Clinical context"},{"id":"c","text":"Nurse opinion"},{"id":"d","text":"Immediate problem"}]'::jsonb, ARRAY['b'], false, 'Background provides clinical context and relevant history to help the provider understand the situation fully.', 'SBAR Communication', 37),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recent lab results belong in:', '[{"id":"a","text":"Situation if critical"},{"id":"b","text":"Background if contextual"},{"id":"c","text":"Both depending on relevance"},{"id":"d","text":"Neither"}]'::jsonb, ARRAY['c'], false, 'Recent lab results can go in Situation if they represent the immediate problem, or Background if they provide context.', 'SBAR Communication', 38),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Code status belongs in:', '[{"id":"a","text":"Background when relevant"},{"id":"b","text":"Situation always"},{"id":"c","text":"Assessment"},{"id":"d","text":"Never included"}]'::jsonb, ARRAY['a'], false, 'Code status belongs in Background when relevant to decision-making about the current situation.', 'SBAR Communication', 39),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Background answers:', '[{"id":"a","text":"What is the immediate problem?"},{"id":"b","text":"What is the clinical context?"},{"id":"c","text":"What do I think is happening?"},{"id":"d","text":"What do I need?"}]'::jsonb, ARRAY['b'], false, 'Background answers "What is the clinical context?" by providing relevant history and information to understand the situation.', 'SBAR Communication', 40),

-- Questions 41-55: A - Assessment
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Assessment includes:', '[{"id":"a","text":"Only vitals"},{"id":"b","text":"Nursing judgment"},{"id":"c","text":"Background only"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['b'], false, 'Assessment includes nursing judgment, clinical interpretation, and what the nurse thinks is happening based on data.', 'SBAR Communication', 41),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Assessment answers:', '[{"id":"a","text":"What happened before?"},{"id":"b","text":"What is happening?"},{"id":"c","text":"What do you think is going on?"},{"id":"d","text":"What do you want?"}]'::jsonb, ARRAY['c'], false, 'Assessment answers "What do you think is going on?" reflecting the nurse''s clinical judgment and interpretation.', 'SBAR Communication', 42),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Objective data belongs in:', '[{"id":"a","text":"Assessment"},{"id":"b","text":"Recommendation"},{"id":"c","text":"Admission"},{"id":"d","text":"Discharge"}]'::jsonb, ARRAY['a'], false, 'Objective data (vital signs, lab values, physical findings) belongs in Assessment to support clinical judgment.', 'SBAR Communication', 43),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '"I suspect pulmonary embolism" is:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Background"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['c'], false, 'Clinical suspicion or interpretation ("I suspect...") belongs in Assessment, demonstrating nursing judgment.', 'SBAR Communication', 44),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Mental status belongs in:', '[{"id":"a","text":"Assessment"},{"id":"b","text":"Recommendation"},{"id":"c","text":"Situation only"},{"id":"d","text":"Background only"}]'::jsonb, ARRAY['a'], false, 'Mental status findings belong in Assessment as part of the objective data and clinical evaluation.', 'SBAR Communication', 45),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Assessment demonstrates:', '[{"id":"a","text":"Delegation"},{"id":"b","text":"Critical thinking"},{"id":"c","text":"Documentation only"},{"id":"d","text":"Transfer"}]'::jsonb, ARRAY['b'], false, 'Assessment demonstrates critical thinking and clinical judgment by interpreting data and forming clinical conclusions.', 'SBAR Communication', 46),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Only RNs use SBAR to communicate:', '[{"id":"a","text":"Objective data only"},{"id":"b","text":"Assessments and recommendations"},{"id":"c","text":"Billing"},{"id":"d","text":"ADLs"}]'::jsonb, ARRAY['b'], false, 'Only RNs can provide assessments (clinical judgment) and recommendations. LPNs and UAPs can report objective data only.', 'SBAR Communication', 47),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'LPN/UAP can report:', '[{"id":"a","text":"Clinical judgment"},{"id":"b","text":"Objective data"},{"id":"c","text":"Recommendations"},{"id":"d","text":"Diagnosis"}]'::jsonb, ARRAY['b'], false, 'LPNs and UAPs can report objective data (Situation and Background) but cannot provide Assessment or Recommendation.', 'SBAR Communication', 48),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '"Patient deteriorating" fits:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Assessment"},{"id":"c","text":"Background"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['b'], false, 'Clinical judgment that patient is deteriorating belongs in Assessment, reflecting interpretation of objective findings.', 'SBAR Communication', 49),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Assessment should avoid:', '[{"id":"a","text":"Clinical interpretation"},{"id":"b","text":"Vital signs"},{"id":"c","text":"Irrelevant data"},{"id":"d","text":"Mental status"}]'::jsonb, ARRAY['c'], false, 'Assessment should avoid irrelevant data and focus on pertinent findings and clinical interpretation related to the situation.', 'SBAR Communication', 50),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Assessment includes both:', '[{"id":"a","text":"History and medications"},{"id":"b","text":"Objective data and interpretation"},{"id":"c","text":"Recommendations and orders"},{"id":"d","text":"Family and social history"}]'::jsonb, ARRAY['b'], false, 'Assessment includes both objective data (facts, findings) and interpretation (clinical judgment, what you think is happening).', 'SBAR Communication', 51),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '"I am concerned patient is in respiratory distress" belongs in:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Background"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['c'], false, 'Expressions of concern and clinical judgment about patient status belong in Assessment section.', 'SBAR Communication', 52),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Assessment demonstrates RN:', '[{"id":"a","text":"Administrative skills"},{"id":"b","text":"Professional judgment"},{"id":"c","text":"Delegation ability"},{"id":"d","text":"Documentation speed"}]'::jsonb, ARRAY['b'], false, 'Assessment demonstrates RN professional judgment and ability to synthesize data into clinical conclusions.', 'SBAR Communication', 53),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Physical examination findings belong in:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Background"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['c'], false, 'Physical examination findings (objective data) belong in Assessment to support clinical judgment.', 'SBAR Communication', 54),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Assessment connects:', '[{"id":"a","text":"Past to future"},{"id":"b","text":"Data to clinical judgment"},{"id":"c","text":"Family to patient"},{"id":"d","text":"Documentation to billing"}]'::jsonb, ARRAY['b'], false, 'Assessment connects objective data to clinical judgment, showing how findings support your interpretation.', 'SBAR Communication', 55),

-- Questions 56-70: R - Recommendation
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation answers:', '[{"id":"a","text":"What happened?"},{"id":"b","text":"What do you think?"},{"id":"c","text":"What do you need?"},{"id":"d","text":"Who admitted patient?"}]'::jsonb, ARRAY['c'], false, 'Recommendation answers "What do you need?" by clearly stating what action, order, or intervention is being requested.', 'SBAR Communication', 56),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation should:', '[{"id":"a","text":"Be vague"},{"id":"b","text":"Be specific"},{"id":"c","text":"Avoid urgency"},{"id":"d","text":"Avoid requests"}]'::jsonb, ARRAY['b'], false, 'Recommendation should be specific, clearly stating what intervention, order, or action is needed.', 'SBAR Communication', 57),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '"Come assess patient immediately" is:', '[{"id":"a","text":"Assessment"},{"id":"b","text":"Recommendation"},{"id":"c","text":"Background"},{"id":"d","text":"Situation"}]'::jsonb, ARRAY['b'], false, 'A direct request for provider action ("Come assess patient immediately") belongs in Recommendation.', 'SBAR Communication', 58),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation may include:', '[{"id":"a","text":"Tests"},{"id":"b","text":"Orders"},{"id":"c","text":"Actions"},{"id":"d","text":"All of the above"}]'::jsonb, ARRAY['d'], false, 'Recommendation may include requests for diagnostic tests, medication orders, provider assessment, or other specific actions.', 'SBAR Communication', 59),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'If unsure, nurse should:', '[{"id":"a","text":"Avoid recommendation"},{"id":"b","text":"Ask for guidance"},{"id":"c","text":"Guess"},{"id":"d","text":"Remain silent"}]'::jsonb, ARRAY['b'], false, 'If unsure what to recommend, the nurse should ask for guidance: "What would you like me to do while you''re on your way?"', 'SBAR Communication', 60),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation should include:', '[{"id":"a","text":"Time frame"},{"id":"b","text":"Emotions"},{"id":"c","text":"Opinions only"},{"id":"d","text":"Family history"}]'::jsonb, ARRAY['a'], false, 'Recommendation should include time frame (STAT, within 1 hour, etc.) to convey urgency appropriately.', 'SBAR Communication', 61),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '"Is there anything I need to do meantime?" belongs to:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Background"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['d'], false, 'Asking for interim orders or guidance belongs in Recommendation as it clarifies next steps.', 'SBAR Communication', 62),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'STAT chest CT suggestion is:', '[{"id":"a","text":"Background"},{"id":"b","text":"Recommendation"},{"id":"c","text":"Situation"},{"id":"d","text":"Assessment"}]'::jsonb, ARRAY['b'], false, 'Suggesting a specific diagnostic test (STAT chest CT) is a Recommendation for provider action.', 'SBAR Communication', 63),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation improves:', '[{"id":"a","text":"Clarity"},{"id":"b","text":"Decision-making"},{"id":"c","text":"Efficiency"},{"id":"d","text":"All"}]'::jsonb, ARRAY['d'], false, 'Clear recommendations improve clarity, decision-making efficiency, and reduce delays in patient care.', 'SBAR Communication', 64),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation must:', '[{"id":"a","text":"Avoid direct request"},{"id":"b","text":"Clearly state need"},{"id":"c","text":"Be implied"},{"id":"d","text":"Be optional"}]'::jsonb, ARRAY['b'], false, 'Recommendation must clearly state what is needed, avoiding vague or implied requests that can lead to miscommunication.', 'SBAR Communication', 65),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Effective recommendation is:', '[{"id":"a","text":"Vague and open-ended"},{"id":"b","text":"Specific and actionable"},{"id":"c","text":"Historical"},{"id":"d","text":"Judgmental"}]'::jsonb, ARRAY['b'], false, 'Effective recommendations are specific and actionable, clearly stating what intervention or action is needed.', 'SBAR Communication', 66),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation empowers nurse to:', '[{"id":"a","text":"Make diagnosis"},{"id":"b","text":"Advocate for patient needs"},{"id":"c","text":"Replace provider"},{"id":"d","text":"Delegate assessment"}]'::jsonb, ARRAY['b'], false, 'Recommendation empowers the nurse to advocate for patient needs by clearly stating what interventions are necessary.', 'SBAR Communication', 67),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '"I recommend oxygen and repeat chest x-ray" belongs in:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Background"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['d'], false, 'Specific suggestions for interventions ("I recommend...") belong in the Recommendation section.', 'SBAR Communication', 68),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation without time frame:', '[{"id":"a","text":"Is always appropriate"},{"id":"b","text":"May delay urgent care"},{"id":"c","text":"Improves clarity"},{"id":"d","text":"Is preferred"}]'::jsonb, ARRAY['b'], false, 'Recommendation without time frame may delay urgent care as it doesn''t convey the urgency level needed.', 'SBAR Communication', 69),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Best recommendation format:', '[{"id":"a","text":"I think you should come"},{"id":"b","text":"I need you to assess patient now and consider chest x-ray"},{"id":"c","text":"Something should be done"},{"id":"d","text":"Patient needs help"}]'::jsonb, ARRAY['b'], false, 'Best format is specific, direct, and includes time frame: "I need you to [specific action] [time frame] and consider [specific intervention]."', 'SBAR Communication', 70),

-- Questions 71-85: SBAR Use & NCLEX Application
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR used during:', '[{"id":"a","text":"Rapid response"},{"id":"b","text":"Shift change"},{"id":"c","text":"Physician notification"},{"id":"d","text":"All"}]'::jsonb, ARRAY['d'], false, 'SBAR is used during all critical communications: rapid response, shift handoffs, physician notifications, and transfers.', 'SBAR Communication', 71),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR promotes:', '[{"id":"a","text":"Safety"},{"id":"b","text":"Clarity"},{"id":"c","text":"Continuity"},{"id":"d","text":"All"}]'::jsonb, ARRAY['d'], false, 'SBAR promotes patient safety, communication clarity, and continuity of care through standardized reporting.', 'SBAR Communication', 72),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'In delegation, SBAR is primarily used by:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Complete SBAR (including Assessment and Recommendation) is primarily used by RNs as it requires clinical judgment.', 'SBAR Communication', 73),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Documentation after SBAR should include:', '[{"id":"a","text":"Who was contacted"},{"id":"b","text":"What discussed"},{"id":"c","text":"Actions taken"},{"id":"d","text":"All"}]'::jsonb, ARRAY['d'], false, 'Documentation should include who was contacted, what was discussed, provider response, and actions taken.', 'SBAR Communication', 74),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Before calling provider:', '[{"id":"a","text":"Guess"},{"id":"b","text":"Prepare vitals and chart"},{"id":"c","text":"Call immediately"},{"id":"d","text":"Delegate"}]'::jsonb, ARRAY['b'], false, 'Before calling provider, prepare by gathering vital signs, recent labs, and reviewing the chart for complete SBAR.', 'SBAR Communication', 75),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR avoids:', '[{"id":"a","text":"Structure"},{"id":"b","text":"Facts"},{"id":"c","text":"Storytelling"},{"id":"d","text":"Clarity"}]'::jsonb, ARRAY['c'], false, 'SBAR avoids storytelling or rambling narratives, focusing on concise, structured communication of essential facts.', 'SBAR Communication', 76),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR in priority questions helps:', '[{"id":"a","text":"Delegate ADLs"},{"id":"b","text":"Report critical changes"},{"id":"c","text":"Avoid charting"},{"id":"d","text":"Replace assessment"}]'::jsonb, ARRAY['b'], false, 'SBAR in NCLEX priority questions helps identify when to report critical changes to providers immediately.', 'SBAR Communication', 77),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'First statement when calling physician:', '[{"id":"a","text":"Background"},{"id":"b","text":"Situation"},{"id":"c","text":"Recommendation"},{"id":"d","text":"Assessment"}]'::jsonb, ARRAY['b'], false, 'Always begin with Situation: identify yourself, identify patient, and state the immediate problem.', 'SBAR Communication', 78),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Critical labs reported using:', '[{"id":"a","text":"Background only"},{"id":"b","text":"SBAR format"},{"id":"c","text":"Teaching"},{"id":"d","text":"Discharge"}]'::jsonb, ARRAY['b'], false, 'Critical lab values should be reported using SBAR format to ensure complete, structured communication.', 'SBAR Communication', 79),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR supports:', '[{"id":"a","text":"Clinical decision-making"},{"id":"b","text":"Insurance"},{"id":"c","text":"Billing"},{"id":"d","text":"Staffing"}]'::jsonb, ARRAY['a'], false, 'SBAR supports clinical decision-making by providing providers with complete, organized information efficiently.', 'SBAR Communication', 80),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR during transfer ensures:', '[{"id":"a","text":"Complete handoff"},{"id":"b","text":"Faster discharge"},{"id":"c","text":"Reduced staffing"},{"id":"d","text":"Billing accuracy"}]'::jsonb, ARRAY['a'], false, 'SBAR during transfer ensures complete handoff with all critical information communicated to receiving staff.', 'SBAR Communication', 81),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Incomplete SBAR may result in:', '[{"id":"a","text":"Better outcomes"},{"id":"b","text":"Missed critical information"},{"id":"c","text":"Faster care"},{"id":"d","text":"Improved safety"}]'::jsonb, ARRAY['b'], false, 'Incomplete SBAR may result in missed critical information, leading to delays, errors, or inappropriate care.', 'SBAR Communication', 82),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR is most effective when:', '[{"id":"a","text":"Memorized only"},{"id":"b","text":"Practiced and prepared"},{"id":"c","text":"Avoided"},{"id":"d","text":"Used occasionally"}]'::jsonb, ARRAY['b'], false, 'SBAR is most effective when nurses practice the format and prepare information before communicating.', 'SBAR Communication', 83),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Provider says "I''ll be there in 5 minutes." Nurse should:', '[{"id":"a","text":"Hang up immediately"},{"id":"b","text":"Document and prepare"},{"id":"c","text":"Leave patient"},{"id":"d","text":"Ignore"}]'::jsonb, ARRAY['b'], false, 'After provider response, document the communication and prepare for provider arrival by continuing assessment.', 'SBAR Communication', 84),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR reduces liability by:', '[{"id":"a","text":"Replacing documentation"},{"id":"b","text":"Ensuring clear communication"},{"id":"c","text":"Avoiding providers"},{"id":"d","text":"Delegating assessment"}]'::jsonb, ARRAY['b'], false, 'SBAR reduces liability by ensuring clear, complete communication that is documented, showing appropriate notification.', 'SBAR Communication', 85),

-- Questions 86-100: Advanced SBAR Analysis
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR ensures:', '[{"id":"a","text":"Facts not missed"},{"id":"b","text":"Random reporting"},{"id":"c","text":"Informal communication"},{"id":"d","text":"Emotional tone"}]'::jsonb, ARRAY['a'], false, 'SBAR ensures critical facts are not missed by providing a systematic framework for complete information transfer.', 'SBAR Communication', 86),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Clear structure reduces:', '[{"id":"a","text":"Errors"},{"id":"b","text":"Safety"},{"id":"c","text":"Communication"},{"id":"d","text":"Urgency"}]'::jsonb, ARRAY['a'], false, 'Clear SBAR structure reduces communication errors by standardizing how critical information is organized and presented.', 'SBAR Communication', 87),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Background must:', '[{"id":"a","text":"Be unrelated"},{"id":"b","text":"Provide context"},{"id":"c","text":"Be emotional"},{"id":"d","text":"Replace assessment"}]'::jsonb, ARRAY['b'], false, 'Background must provide relevant clinical context that helps the provider understand the situation fully.', 'SBAR Communication', 88),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Assessment includes:', '[{"id":"a","text":"Lab only"},{"id":"b","text":"Interpretation + data"},{"id":"c","text":"History"},{"id":"d","text":"Admission"}]'::jsonb, ARRAY['b'], false, 'Assessment includes both clinical interpretation and supporting objective data that led to that conclusion.', 'SBAR Communication', 89),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Recommendation without urgency may:', '[{"id":"a","text":"Delay care"},{"id":"b","text":"Improve clarity"},{"id":"c","text":"Replace assessment"},{"id":"d","text":"Be irrelevant"}]'::jsonb, ARRAY['a'], false, 'Recommendation without stating urgency or time frame may delay needed care if provider doesn''t understand priority.', 'SBAR Communication', 90),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR used during transfer ensures:', '[{"id":"a","text":"Continuity of care"},{"id":"b","text":"Faster discharge"},{"id":"c","text":"Reduced staffing"},{"id":"d","text":"Billing efficiency"}]'::jsonb, ARRAY['a'], false, 'SBAR during transfer ensures continuity of care by providing receiving staff with complete, organized patient information.', 'SBAR Communication', 91),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '"I am worried" belongs in:', '[{"id":"a","text":"Assessment"},{"id":"b","text":"Background"},{"id":"c","text":"Situation"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['a'], false, 'Expressing clinical concern ("I am worried") belongs in Assessment as it reflects nursing judgment about the situation.', 'SBAR Communication', 92),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Early Warning Score reported in:', '[{"id":"a","text":"Situation"},{"id":"b","text":"Background"},{"id":"c","text":"Assessment"},{"id":"d","text":"Recommendation"}]'::jsonb, ARRAY['a'], false, 'Early Warning Score belongs in Situation as it indicates the current severity and urgency of patient status.', 'SBAR Communication', 93),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR is best described as:', '[{"id":"a","text":"Narrative format"},{"id":"b","text":"Structured framework"},{"id":"c","text":"Legal document"},{"id":"d","text":"Assessment tool"}]'::jsonb, ARRAY['b'], false, 'SBAR is best described as a structured framework or communication tool for standardizing information transfer.', 'SBAR Communication', 94),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR improves nurse:', '[{"id":"a","text":"Silence"},{"id":"b","text":"Confidence"},{"id":"c","text":"Delegation"},{"id":"d","text":"Licensure"}]'::jsonb, ARRAY['b'], false, 'SBAR improves nurse confidence by providing a clear structure for communicating effectively with providers.', 'SBAR Communication', 95),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR ensures providers can:', '[{"id":"a","text":"Delay decisions"},{"id":"b","text":"Make decisions quickly"},{"id":"c","text":"Avoid nurses"},{"id":"d","text":"Delegate assessment"}]'::jsonb, ARRAY['b'], false, 'SBAR ensures providers receive organized, complete information enabling them to make clinical decisions quickly and accurately.', 'SBAR Communication', 96),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Situation must be:', '[{"id":"a","text":"Delayed"},{"id":"b","text":"Immediate issue"},{"id":"c","text":"Historical"},{"id":"d","text":"Opinion-based"}]'::jsonb, ARRAY['b'], false, 'Situation must focus on the immediate issue or current problem requiring attention, not historical information.', 'SBAR Communication', 97),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'SBAR template helps:', '[{"id":"a","text":"Disorganization"},{"id":"b","text":"Organization"},{"id":"c","text":"Storytelling"},{"id":"d","text":"Delays"}]'::jsonb, ARRAY['b'], false, 'SBAR template helps organize thoughts and information systematically, ensuring nothing critical is forgotten.', 'SBAR Communication', 98),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Incomplete SBAR risks:', '[{"id":"a","text":"Clear care"},{"id":"b","text":"Missed critical facts"},{"id":"c","text":"Faster treatment"},{"id":"d","text":"Better outcomes"}]'::jsonb, ARRAY['b'], false, 'Incomplete SBAR risks missing critical facts that could lead to delayed or inappropriate treatment decisions.', 'SBAR Communication', 99),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'Ultimate SBAR goal:', '[{"id":"a","text":"Replace assessment"},{"id":"b","text":"Transfer accountability"},{"id":"c","text":"Ensure safe, effective communication"},{"id":"d","text":"Reduce documentation"}]'::jsonb, ARRAY['c'], false, 'Ultimate SBAR goal is ensuring safe, effective communication that promotes patient safety and optimal clinical outcomes.', 'SBAR Communication', 100);

-- ============================================
-- VERIFICATION
-- ============================================

-- Show total question count for SBAR Communication topic
SELECT 
  t.name as topic_name,
  COUNT(q.id) as total_questions
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id 
  AND q.test_id = '00000000-0000-0000-0000-000000000001'
WHERE t.id = '20000000-0000-0000-0000-000000000006'
GROUP BY t.id, t.name;
-- Expected: SBAR Communication with 100 questions

-- Verify display_order range
SELECT 
  MIN(display_order) as first_question,
  MAX(display_order) as last_question,
  COUNT(*) as total_count
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000006';
-- Expected: 1 to 100, count = 100
