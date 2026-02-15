-- ============================================
-- SCOPE OF PRACTICE - 100 QUESTIONS
-- ============================================
-- Run this AFTER ADD-SUBJECTS-TOPICS-TABLE.sql
-- All 100 questions for Topic 3: Scope of Practice

-- Delete any existing questions for this topic to avoid duplicates
DELETE FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001' 
  AND topic_id = '20000000-0000-0000-0000-000000000003';

-- Insert 100 Scope of Practice Questions (display_order 1-100 for this topic)
INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES

-- Questions 1-10: Scope Definition & Legal Boundaries
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Scope of practice is primarily defined by:', '[{"id":"a","text":"Hospital preference"},{"id":"b","text":"Nurse''s experience alone"},{"id":"c","text":"Legal and professional boundaries"},{"id":"d","text":"Patient acuity"}]'::jsonb, ARRAY['c'], false, 'Scope of practice is primarily defined by legal and professional boundaries set by state law and professional standards.', 'Scope of Practice', 1),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which most directly determines what a nurse can legally perform?', '[{"id":"a","text":"Provider preference"},{"id":"b","text":"State Nurse Practice Act"},{"id":"c","text":"Years of experience"},{"id":"d","text":"Seniority"}]'::jsonb, ARRAY['b'], false, 'The State Nurse Practice Act is the legal document that defines what a nurse can legally perform in that state.', 'Scope of Practice', 2),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Scope is influenced by all EXCEPT:', '[{"id":"a","text":"Education and training"},{"id":"b","text":"Facility policies"},{"id":"c","text":"Personal comfort"},{"id":"d","text":"Licensure level"}]'::jsonb, ARRAY['c'], false, 'Personal comfort does not influence scope of practice. Scope is defined by education, policies, and licensure level.', 'Scope of Practice', 3),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Who is responsible for knowing scope limits?', '[{"id":"a","text":"Facility"},{"id":"b","text":"Provider"},{"id":"c","text":"The nurse"},{"id":"d","text":"Charge nurse only"}]'::jsonb, ARRAY['c'], false, 'Each nurse is individually responsible for knowing and practicing within their own scope of practice limits.', 'Scope of Practice', 4),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which level performs comprehensive assessments?', '[{"id":"a","text":"CNA"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"UAP"}]'::jsonb, ARRAY['c'], false, 'Only RNs perform comprehensive assessments. LPNs can observe and report, but cannot perform full assessments.', 'Scope of Practice', 5),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPNs can:', '[{"id":"a","text":"Perform full assessments"},{"id":"b","text":"Formulate nursing diagnoses"},{"id":"c","text":"Observe and report"},{"id":"d","text":"Create care plans"}]'::jsonb, ARRAY['c'], false, 'LPNs can observe and report findings, but cannot perform full assessments, diagnose, or create care plans.', 'Scope of Practice', 6),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'UAPs can:', '[{"id":"a","text":"Assess patients"},{"id":"b","text":"Plan care"},{"id":"c","text":"Perform ADLs"},{"id":"d","text":"Diagnose"}]'::jsonb, ARRAY['c'], false, 'UAPs can perform Activities of Daily Living (ADLs) but cannot assess, plan care, or diagnose.', 'Scope of Practice', 7),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Who develops the nursing care plan?', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"CNA"},{"id":"d","text":"UAP"}]'::jsonb, ARRAY['a'], false, 'Only RNs can develop nursing care plans. This requires critical thinking and nursing judgment.', 'Scope of Practice', 8),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Who can formulate nursing diagnoses?', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['a'], false, 'Only RNs can formulate nursing diagnoses. This is an RN-only function requiring critical thinking.', 'Scope of Practice', 9),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Initial teaching is done by:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['a'], false, 'Initial patient teaching must be done by an RN. LPNs can reinforce teaching but cannot provide initial instruction.', 'Scope of Practice', 10),

-- Questions 11-25: Delegation vs Assignment
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Assignment refers to:', '[{"id":"a","text":"Transferring accountability"},{"id":"b","text":"Transferring responsibility"},{"id":"c","text":"Distributing routine workload"},{"id":"d","text":"Clinical judgment transfer"}]'::jsonb, ARRAY['c'], false, 'Assignment is distributing routine workload among staff of similar licensure. Delegation transfers specific tasks while retaining accountability.', 'Scope of Practice', 11),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Delegation transfers:', '[{"id":"a","text":"Accountability"},{"id":"b","text":"Responsibility (not accountability)"},{"id":"c","text":"Licensure"},{"id":"d","text":"Scope"}]'::jsonb, ARRAY['b'], false, 'Delegation transfers responsibility for a task but NOT accountability. The RN remains accountable for outcomes.', 'Scope of Practice', 12),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'After delegation, the RN remains:', '[{"id":"a","text":"Free of responsibility"},{"id":"b","text":"Accountable for outcomes"},{"id":"c","text":"Legally detached"},{"id":"d","text":"Uninvolved"}]'::jsonb, ARRAY['b'], false, 'After delegation, the RN remains accountable for outcomes and must monitor and evaluate the delegated task.', 'Scope of Practice', 13),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which is NOT one of the 5 Rights of Delegation?', '[{"id":"a","text":"Right Task"},{"id":"b","text":"Right Patient Diagnosis"},{"id":"c","text":"Right Person"},{"id":"d","text":"Right Supervision"}]'::jsonb, ARRAY['b'], false, 'The 5 Rights are: Task, Circumstance, Person, Direction, and Supervision. Patient diagnosis is not one of them.', 'Scope of Practice', 14),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Right Circumstance focuses on:', '[{"id":"a","text":"Nurse workload"},{"id":"b","text":"Stability of patient"},{"id":"c","text":"Time of day"},{"id":"d","text":"Policy"}]'::jsonb, ARRAY['b'], false, 'Right Circumstance evaluates patient stability. Unstable patients should not have care delegated to UAP or LPN.', 'Scope of Practice', 15),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Right Person evaluates:', '[{"id":"a","text":"Patient preference"},{"id":"b","text":"Delegatee qualification"},{"id":"c","text":"Documentation"},{"id":"d","text":"Family input"}]'::jsonb, ARRAY['b'], false, 'Right Person evaluates whether the delegatee has the necessary qualifications, training, and competence for the task.', 'Scope of Practice', 16),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Right Direction requires:', '[{"id":"a","text":"Vague instruction"},{"id":"b","text":"Clear communication"},{"id":"c","text":"Silent observation"},{"id":"d","text":"Assumptions"}]'::jsonb, ARRAY['b'], false, 'Right Direction requires clear, specific communication about the task, expected outcomes, and reporting requirements.', 'Scope of Practice', 17),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Right Supervision means:', '[{"id":"a","text":"Delegating and leaving"},{"id":"b","text":"Monitoring and evaluating"},{"id":"c","text":"Charting only"},{"id":"d","text":"Asking charge nurse"}]'::jsonb, ARRAY['b'], false, 'Right Supervision requires the RN to monitor, evaluate, and follow up on delegated tasks to ensure proper completion.', 'Scope of Practice', 18),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Delegation is safest when patient is:', '[{"id":"a","text":"New"},{"id":"b","text":"Unstable"},{"id":"c","text":"Stable"},{"id":"d","text":"Critical"}]'::jsonb, ARRAY['c'], false, 'Delegation is safest with stable patients. Unstable, new, or critical patients require RN-level assessment and judgment.', 'Scope of Practice', 19),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Unstable patients require:', '[{"id":"a","text":"LPN"},{"id":"b","text":"UAP"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Unstable patients require RN-level care due to the need for ongoing assessment and clinical judgment.', 'Scope of Practice', 20),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which is a key difference between assignment and delegation?', '[{"id":"a","text":"Assignment is to similar licensure level"},{"id":"b","text":"Delegation is only to RNs"},{"id":"c","text":"Assignment transfers accountability"},{"id":"d","text":"Delegation is illegal"}]'::jsonb, ARRAY['a'], false, 'Assignment distributes workload to staff of similar licensure, while delegation transfers specific tasks to different levels.', 'Scope of Practice', 21),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'The RN who delegates must ensure:', '[{"id":"a","text":"Patient does all care"},{"id":"b","text":"Task is within delegatee scope"},{"id":"c","text":"No monitoring needed"},{"id":"d","text":"Accountability transfers"}]'::jsonb, ARRAY['b'], false, 'The RN must ensure the delegated task is within the delegatee''s legal scope of practice and competence level.', 'Scope of Practice', 22),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Effective delegation requires:', '[{"id":"a","text":"Minimal communication"},{"id":"b","text":"Assumptions about competence"},{"id":"c","text":"Clear expectations and follow-up"},{"id":"d","text":"Complete task transfer with no oversight"}]'::jsonb, ARRAY['c'], false, 'Effective delegation requires clear expectations, specific instructions, and proper follow-up to ensure safe outcomes.', 'Scope of Practice', 23),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'When delegating, the RN must consider:', '[{"id":"a","text":"Only the task complexity"},{"id":"b","text":"Patient stability, task complexity, and delegatee competence"},{"id":"c","text":"Only delegatee preference"},{"id":"d","text":"Only time constraints"}]'::jsonb, ARRAY['b'], false, 'Safe delegation requires considering patient stability, task complexity, and delegatee competence together.', 'Scope of Practice', 24),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which scenario represents appropriate delegation?', '[{"id":"a","text":"RN delegates assessment to UAP"},{"id":"b","text":"RN delegates vital signs on stable patient to UAP"},{"id":"c","text":"RN delegates care planning to LPN"},{"id":"d","text":"RN delegates IV push to CNA"}]'::jsonb, ARRAY['b'], false, 'Delegating vital signs on a stable patient to UAP is appropriate. Assessment, planning, and IV push cannot be delegated.', 'Scope of Practice', 25),

-- Questions 26-40: RN vs LPN vs UAP
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN may administer:', '[{"id":"a","text":"IV push meds"},{"id":"b","text":"Oral, IM, SubQ meds"},{"id":"c","text":"Blood transfusion"},{"id":"d","text":"Care plans"}]'::jsonb, ARRAY['b'], false, 'LPNs can administer oral, IM, and SubQ medications to stable patients. IV push and blood transfusions are typically RN-only.', 'Scope of Practice', 26),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Blood transfusion may be performed by:', '[{"id":"a","text":"LPN"},{"id":"b","text":"UAP"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Blood transfusion administration requires RN-level assessment and monitoring due to potential complications.', 'Scope of Practice', 27),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'IV push meds are:', '[{"id":"a","text":"RN only (unless state exception)"},{"id":"b","text":"LPN always"},{"id":"c","text":"UAP allowed"},{"id":"d","text":"CNA allowed"}]'::jsonb, ARRAY['a'], false, 'IV push medications are typically RN-only unless specific state laws allow specially trained LPNs in certain settings.', 'Scope of Practice', 28),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Who can perform ECG?', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"Both RN and LPN"}]'::jsonb, ARRAY['d'], false, 'Both RNs and LPNs can perform ECGs. This is a technical skill that does not require RN-level judgment.', 'Scope of Practice', 29),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Who can perform sterile procedures?', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN simple only"},{"id":"c","text":"RN only"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'LPNs can perform simple sterile procedures (e.g., dressing changes). Complex sterile procedures may require RN level.', 'Scope of Practice', 30),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'UAP may:', '[{"id":"a","text":"Perform sterile wound care"},{"id":"b","text":"Titrate IV meds"},{"id":"c","text":"Record I&O"},{"id":"d","text":"Create care plan"}]'::jsonb, ARRAY['c'], false, 'UAPs can record intake and output (I&O). Sterile procedures, medication titration, and care planning require higher licensure.', 'Scope of Practice', 31),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'UAP can take vitals on:', '[{"id":"a","text":"Unstable patient"},{"id":"b","text":"Stable patient"},{"id":"c","text":"ICU patient"},{"id":"d","text":"New admit"}]'::jsonb, ARRAY['b'], false, 'UAPs can take vital signs on stable patients. Unstable, ICU, or new admit patients require RN assessment.', 'Scope of Practice', 32),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN can monitor:', '[{"id":"a","text":"Unstable patients"},{"id":"b","text":"Stable patients"},{"id":"c","text":"Critical patients"},{"id":"d","text":"Code patients"}]'::jsonb, ARRAY['b'], false, 'LPNs can monitor stable patients. Unstable, critical, or coding patients require RN-level judgment and intervention.', 'Scope of Practice', 33),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Who performs triage?', '[{"id":"a","text":"LPN"},{"id":"b","text":"RN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Triage requires RN-level critical thinking and assessment skills to prioritize patient care needs.', 'Scope of Practice', 34),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Clinical judgment belongs to:', '[{"id":"a","text":"RN"},{"id":"b","text":"UAP"},{"id":"c","text":"CNA"},{"id":"d","text":"All"}]'::jsonb, ARRAY['a'], false, 'Clinical judgment requiring assessment and decision-making is an RN responsibility and cannot be delegated.', 'Scope of Practice', 35),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN scope includes:', '[{"id":"a","text":"Initial assessment"},{"id":"b","text":"Data collection"},{"id":"c","text":"Nursing diagnosis"},{"id":"d","text":"Care plan creation"}]'::jsonb, ARRAY['b'], false, 'LPNs can collect data and observe, but cannot perform initial assessments, diagnose, or create care plans.', 'Scope of Practice', 36),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'UAP responsibilities include:', '[{"id":"a","text":"Medication administration"},{"id":"b","text":"Wound assessment"},{"id":"c","text":"Basic hygiene care"},{"id":"d","text":"Patient teaching"}]'::jsonb, ARRAY['c'], false, 'UAPs provide basic hygiene and ADL care. Medications, assessments, and teaching require licensed personnel.', 'Scope of Practice', 37),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN-exclusive functions include:', '[{"id":"a","text":"Feeding patients"},{"id":"b","text":"Assessment and diagnosis"},{"id":"c","text":"Ambulation"},{"id":"d","text":"Taking vital signs"}]'::jsonb, ARRAY['b'], false, 'Assessment and nursing diagnosis are RN-exclusive functions requiring professional judgment and education.', 'Scope of Practice', 38),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPNs work under the supervision of:', '[{"id":"a","text":"UAP"},{"id":"b","text":"CNA"},{"id":"c","text":"RN or provider"},{"id":"d","text":"No supervision needed"}]'::jsonb, ARRAY['c'], false, 'LPNs work under the supervision of RNs or providers, practicing within their defined scope.', 'Scope of Practice', 39),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Who evaluates patient response to interventions?', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN data collection"},{"id":"c","text":"RN clinical judgment"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Evaluating patient response requires RN clinical judgment to interpret findings and adjust the care plan accordingly.', 'Scope of Practice', 40),

-- Questions 41-60: Non-Delegable Tasks
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which cannot be delegated?', '[{"id":"a","text":"ADLs"},{"id":"b","text":"Vitals on stable"},{"id":"c","text":"Assessment"},{"id":"d","text":"I&O recording"}]'::jsonb, ARRAY['c'], false, 'Assessment cannot be delegated. It requires RN-level critical thinking and professional judgment.', 'Scope of Practice', 41),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Care plan creation is:', '[{"id":"a","text":"LPN"},{"id":"b","text":"RN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Care plan creation requires RN-level critical thinking, assessment, and nursing diagnosis formulation.', 'Scope of Practice', 42),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Medication titration:', '[{"id":"a","text":"UAP"},{"id":"b","text":"RN"},{"id":"c","text":"CNA"},{"id":"d","text":"LPN unrestricted"}]'::jsonb, ARRAY['b'], false, 'Medication titration requires RN-level assessment and clinical judgment to adjust dosages based on patient response.', 'Scope of Practice', 43),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Teaching new insulin injection:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['a'], false, 'Initial patient teaching must be done by an RN. This includes teaching new skills like insulin injection.', 'Scope of Practice', 44),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Reinforcing prior teaching:', '[{"id":"a","text":"RN only"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'LPNs can reinforce teaching that was initially provided by an RN, but cannot do initial teaching.', 'Scope of Practice', 45),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Unstable patient monitoring:', '[{"id":"a","text":"LPN"},{"id":"b","text":"UAP"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Unstable patients require continuous RN monitoring, assessment, and clinical judgment for intervention decisions.', 'Scope of Practice', 46),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Foley bag emptying:', '[{"id":"a","text":"RN only"},{"id":"b","text":"UAP"},{"id":"c","text":"LPN only"},{"id":"d","text":"Provider"}]'::jsonb, ARRAY['b'], false, 'Emptying a Foley catheter bag is a routine task that can be delegated to UAP for stable patients.', 'Scope of Practice', 47),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Specimen collection (urine):', '[{"id":"a","text":"UAP"},{"id":"b","text":"RN only"},{"id":"c","text":"CNA prohibited"},{"id":"d","text":"LPN prohibited"}]'::jsonb, ARRAY['a'], false, 'Routine specimen collection like urine samples can be delegated to UAP for stable patients.', 'Scope of Practice', 48),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Range of motion exercises:', '[{"id":"a","text":"RN only"},{"id":"b","text":"UAP"},{"id":"c","text":"LPN only"},{"id":"d","text":"Provider"}]'::jsonb, ARRAY['b'], false, 'Range of motion exercises can be delegated to UAP for stable patients after initial RN assessment and instruction.', 'Scope of Practice', 49),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Creating nursing diagnosis:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['a'], false, 'Formulating nursing diagnoses is an RN-only function requiring professional judgment and critical thinking.', 'Scope of Practice', 50),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which task requires RN clinical judgment?', '[{"id":"a","text":"Bathing stable patient"},{"id":"b","text":"Evaluating pain management effectiveness"},{"id":"c","text":"Recording intake"},{"id":"d","text":"Repositioning patient"}]'::jsonb, ARRAY['b'], false, 'Evaluating effectiveness of interventions requires RN clinical judgment to interpret responses and adjust care.', 'Scope of Practice', 51),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Initial pain assessment is performed by:', '[{"id":"a","text":"UAP who reports pain"},{"id":"b","text":"RN"},{"id":"c","text":"LPN"},{"id":"d","text":"Any staff member"}]'::jsonb, ARRAY['b'], false, 'Initial pain assessment requires RN-level assessment skills to evaluate characteristics, quality, and interventions needed.', 'Scope of Practice', 52),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Developing discharge plan:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Discharge planning requires RN-level assessment, coordination, and teaching to ensure safe transition of care.', 'Scope of Practice', 53),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Interpreting lab values:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN collects"},{"id":"c","text":"RN interprets"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Interpreting lab values and determining clinical significance requires RN-level knowledge and judgment.', 'Scope of Practice', 54),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Administering IV medications requires:', '[{"id":"a","text":"RN or specially trained LPN per state law"},{"id":"b","text":"UAP"},{"id":"c","text":"CNA"},{"id":"d","text":"Any licensed personnel"}]'::jsonb, ARRAY['a'], false, 'IV medication administration typically requires RN, though some states allow specially trained LPNs for certain IV meds.', 'Scope of Practice', 55),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Teaching pre-operative instructions:', '[{"id":"a","text":"UAP"},{"id":"b","text":"RN"},{"id":"c","text":"LPN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Initial teaching of pre-operative instructions must be done by RN to ensure comprehension and address questions.', 'Scope of Practice', 56),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Developing patient education materials:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"Administrative staff"}]'::jsonb, ARRAY['c'], false, 'Developing patient education requires RN expertise to ensure accuracy, appropriateness, and evidence-based content.', 'Scope of Practice', 57),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Performing wound assessment:', '[{"id":"a","text":"UAP observes"},{"id":"b","text":"LPN observes"},{"id":"c","text":"RN assesses"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Wound assessment requires RN skills to evaluate healing, identify complications, and adjust treatment plans.', 'Scope of Practice', 58),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Evaluating patient understanding after teaching:', '[{"id":"a","text":"UAP"},{"id":"b","text":"RN"},{"id":"c","text":"LPN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Evaluating patient understanding requires RN judgment to determine if teaching was effective and identify additional needs.', 'Scope of Practice', 59),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which cannot be delegated to LPN?', '[{"id":"a","text":"Simple dressing change"},{"id":"b","text":"Oral medication to stable patient"},{"id":"c","text":"Initial admission assessment"},{"id":"d","text":"Vital signs"}]'::jsonb, ARRAY['c'], false, 'Initial admission assessment cannot be delegated to LPN. It requires comprehensive RN assessment and clinical judgment.', 'Scope of Practice', 60),

-- Questions 61-75: NCLEX Scenario Style
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'UAP reports BP 190/110. RN should:', '[{"id":"a","text":"Notify provider"},{"id":"b","text":"Reassess personally"},{"id":"c","text":"Ignore"},{"id":"d","text":"Delegate back"}]'::jsonb, ARRAY['b'], false, 'RN must personally reassess critical findings reported by UAP to validate accuracy and determine interventions needed.', 'Scope of Practice', 61),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN delegates vitals to UAP for unstable patient. This violates:', '[{"id":"a","text":"Right Person"},{"id":"b","text":"Right Circumstance"},{"id":"c","text":"Right Task"},{"id":"d","text":"Right Direction"}]'::jsonb, ARRAY['b'], false, 'Delegating care of unstable patients to UAP violates Right Circumstance. Unstable patients require RN monitoring.', 'Scope of Practice', 62),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN asked to create care plan. RN should:', '[{"id":"a","text":"Allow"},{"id":"b","text":"Refuse; outside scope"},{"id":"c","text":"Supervise"},{"id":"d","text":"Delegate"}]'::jsonb, ARRAY['b'], false, 'Creating care plans is outside LPN scope. The RN must refuse this as it requires RN-level judgment.', 'Scope of Practice', 63),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'UAP asked to teach wound care. RN should:', '[{"id":"a","text":"Allow"},{"id":"b","text":"Reinforce"},{"id":"c","text":"Refuse; teaching non-delegable"},{"id":"d","text":"Supervise"}]'::jsonb, ARRAY['c'], false, 'Patient teaching cannot be delegated to UAP. The RN must refuse and perform the teaching personally.', 'Scope of Practice', 64),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN delegates ADLs for stable patient. Appropriate?', '[{"id":"a","text":"Yes"},{"id":"b","text":"No"},{"id":"c","text":"Only to LPN"},{"id":"d","text":"Only to provider"}]'::jsonb, ARRAY['a'], false, 'Delegating ADLs to UAP for stable patients is appropriate and within both scopes of practice.', 'Scope of Practice', 65),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which requires RN critical thinking?', '[{"id":"a","text":"Ambulation"},{"id":"b","text":"Assessment"},{"id":"c","text":"Oral care"},{"id":"d","text":"Feeding"}]'::jsonb, ARRAY['b'], false, 'Assessment requires RN critical thinking to collect data, identify problems, and determine appropriate interventions.', 'Scope of Practice', 66),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN can:', '[{"id":"a","text":"Diagnose"},{"id":"b","text":"Plan care"},{"id":"c","text":"Reinforce teaching"},{"id":"d","text":"Titrate IV drip"}]'::jsonb, ARRAY['c'], false, 'LPNs can reinforce teaching that was initially provided by an RN, but cannot diagnose, plan, or titrate medications.', 'Scope of Practice', 67),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN remains accountable means:', '[{"id":"a","text":"Delegatee responsible legally"},{"id":"b","text":"RN legally responsible for outcome"},{"id":"c","text":"CNA accountable"},{"id":"d","text":"No one accountable"}]'::jsonb, ARRAY['b'], false, 'RN accountability means the RN remains legally responsible for patient outcomes even after delegating tasks.', 'Scope of Practice', 68),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'If delegatee lacks skill:', '[{"id":"a","text":"Delegate anyway"},{"id":"b","text":"Evaluate qualification first"},{"id":"c","text":"Assume competence"},{"id":"d","text":"Ignore"}]'::jsonb, ARRAY['b'], false, 'Before delegating, the RN must evaluate whether the delegatee has the necessary competence and qualifications.', 'Scope of Practice', 69),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which fits UAP role?', '[{"id":"a","text":"Medication titration"},{"id":"b","text":"Comprehensive assessment"},{"id":"c","text":"Hygiene care"},{"id":"d","text":"Care plan creation"}]'::jsonb, ARRAY['c'], false, 'Hygiene care and ADLs are within UAP scope. Medications, assessment, and planning require licensure.', 'Scope of Practice', 70),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Patient refuses care from UAP. RN should:', '[{"id":"a","text":"Force compliance"},{"id":"b","text":"Respect patient autonomy and provide care"},{"id":"c","text":"Document and ignore"},{"id":"d","text":"Discharge patient"}]'::jsonb, ARRAY['b'], false, 'RN must respect patient autonomy. If patient refuses UAP care, RN should provide the care personally.', 'Scope of Practice', 71),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'UAP reports patient "looks funny." RN should:', '[{"id":"a","text":"Ignore vague report"},{"id":"b","text":"Assess patient immediately"},{"id":"c","text":"Ask UAP to clarify later"},{"id":"d","text":"Document only"}]'::jsonb, ARRAY['b'], false, 'Even vague reports from UAP require immediate RN assessment to identify potential problems.', 'Scope of Practice', 72),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN gives oral med to stable patient. This is:', '[{"id":"a","text":"Appropriate within LPN scope"},{"id":"b","text":"Inappropriate"},{"id":"c","text":"RN only"},{"id":"d","text":"UAP only"}]'::jsonb, ARRAY['a'], false, 'LPNs can administer oral medications to stable patients. This is within their scope of practice.', 'Scope of Practice', 73),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN must reassess abnormal findings because:', '[{"id":"a","text":"Delegation removes accountability"},{"id":"b","text":"RN retains accountability for outcomes"},{"id":"c","text":"UAP is unreliable"},{"id":"d","text":"Policy requires it only"}]'::jsonb, ARRAY['b'], false, 'RN must validate abnormal findings because RN retains accountability for patient outcomes despite delegation.', 'Scope of Practice', 74),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which scenario violates scope?', '[{"id":"a","text":"UAP bathing stable patient"},{"id":"b","text":"LPN giving IM med to stable patient"},{"id":"c","text":"UAP performing initial assessment"},{"id":"d","text":"RN creating care plan"}]'::jsonb, ARRAY['c'], false, 'UAP performing initial assessment violates scope. Assessment requires RN-level professional judgment.', 'Scope of Practice', 75),

-- Questions 76-85: Advanced Delegation Analysis
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN delegates sterile dressing change to LPN. Appropriate?', '[{"id":"a","text":"Yes"},{"id":"b","text":"No"},{"id":"c","text":"Only unstable"},{"id":"d","text":"Only UAP"}]'::jsonb, ARRAY['a'], false, 'LPNs can perform simple sterile procedures like dressing changes for stable patients. This is appropriate delegation.', 'Scope of Practice', 76),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN asked to manage unstable ICU patient. Appropriate?', '[{"id":"a","text":"Yes"},{"id":"b","text":"No"},{"id":"c","text":"With UAP"},{"id":"d","text":"Always"}]'::jsonb, ARRAY['b'], false, 'Unstable ICU patients require RN-level continuous assessment and clinical judgment. This is inappropriate for LPN.', 'Scope of Practice', 77),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN delegates triage decision to LPN. Violation?', '[{"id":"a","text":"Right Task"},{"id":"b","text":"Right Person"},{"id":"c","text":"Right Circumstance"},{"id":"d","text":"Right Supervision"}]'::jsonb, ARRAY['b'], false, 'Triage requires RN clinical judgment and cannot be delegated to LPN. This violates Right Person.', 'Scope of Practice', 78),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN fails to monitor delegatee. Violates:', '[{"id":"a","text":"Right Supervision"},{"id":"b","text":"Right Task"},{"id":"c","text":"Assignment"},{"id":"d","text":"Stability"}]'::jsonb, ARRAY['a'], false, 'Failure to monitor and evaluate delegated tasks violates Right Supervision, an essential delegation responsibility.', 'Scope of Practice', 79),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Stable post-op patient needs IM pain med. Delegate to:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"CNA"},{"id":"d","text":"Provider"}]'::jsonb, ARRAY['b'], false, 'LPNs can administer IM medications to stable patients. This is appropriate delegation.', 'Scope of Practice', 80),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which is always RN-only?', '[{"id":"a","text":"ROM"},{"id":"b","text":"ADLs"},{"id":"c","text":"Clinical judgment"},{"id":"d","text":"I&O"}]'::jsonb, ARRAY['c'], false, 'Clinical judgment requiring professional assessment and decision-making is always RN-only and non-delegable.', 'Scope of Practice', 81),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Patient becomes unstable after delegation. RN must:', '[{"id":"a","text":"Ignore"},{"id":"b","text":"Reassume care"},{"id":"c","text":"Leave LPN"},{"id":"d","text":"Blame CNA"}]'::jsonb, ARRAY['b'], false, 'When patient condition changes to unstable, RN must reassume direct care requiring RN-level assessment and intervention.', 'Scope of Practice', 82),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Delegation requires:', '[{"id":"a","text":"Legal compliance"},{"id":"b","text":"Stability"},{"id":"c","text":"Clear instructions"},{"id":"d","text":"All of the above"}]'::jsonb, ARRAY['d'], false, 'Safe delegation requires legal compliance with scope, patient stability assessment, and clear communication.', 'Scope of Practice', 83),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Facility policies influence:', '[{"id":"a","text":"Scope boundaries"},{"id":"b","text":"Licensure"},{"id":"c","text":"NPA"},{"id":"d","text":"Education"}]'::jsonb, ARRAY['a'], false, 'Facility policies can further restrict (but not expand) scope of practice beyond state law requirements.', 'Scope of Practice', 84),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which cannot ever be delegated?', '[{"id":"a","text":"Ambulation"},{"id":"b","text":"Vital signs stable"},{"id":"c","text":"Assessment"},{"id":"d","text":"Hygiene"}]'::jsonb, ARRAY['c'], false, 'Assessment can never be delegated as it requires RN-level professional judgment and critical thinking.', 'Scope of Practice', 85),

-- Questions 86-100: Final NCLEX Focus
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN assigning patients is:', '[{"id":"a","text":"Delegation"},{"id":"b","text":"Assignment"},{"id":"c","text":"Accountability transfer"},{"id":"d","text":"Illegal"}]'::jsonb, ARRAY['b'], false, 'Assignment is distributing workload to staff of similar licensure level, different from delegation to lower levels.', 'Scope of Practice', 86),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Delegating wound care to UAP is:', '[{"id":"a","text":"Appropriate"},{"id":"b","text":"Inappropriate"},{"id":"c","text":"Conditional"},{"id":"d","text":"Always allowed"}]'::jsonb, ARRAY['b'], false, 'Wound care requires assessment skills and sterile technique beyond UAP scope. This is inappropriate delegation.', 'Scope of Practice', 87),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN giving oral meds to stable patient is:', '[{"id":"a","text":"Appropriate"},{"id":"b","text":"Illegal"},{"id":"c","text":"RN only"},{"id":"d","text":"UAP only"}]'::jsonb, ARRAY['a'], false, 'LPNs can administer oral medications to stable patients. This is within their scope of practice.', 'Scope of Practice', 88),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN must consider patient:', '[{"id":"a","text":"Age"},{"id":"b","text":"Stability"},{"id":"c","text":"Room number"},{"id":"d","text":"Family"}]'::jsonb, ARRAY['b'], false, 'Patient stability is the most critical factor when deciding whether delegation is appropriate and safe.', 'Scope of Practice', 89),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'UAP performing sterile procedure:', '[{"id":"a","text":"Allowed"},{"id":"b","text":"Not allowed"},{"id":"c","text":"RN only"},{"id":"d","text":"LPN only"}]'::jsonb, ARRAY['b'], false, 'Sterile procedures are outside UAP scope and require licensed personnel (LPN for simple, RN for complex).', 'Scope of Practice', 90),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN delegates but fails to evaluate. This violates:', '[{"id":"a","text":"Accountability"},{"id":"b","text":"Scope"},{"id":"c","text":"Stability"},{"id":"d","text":"Assignment"}]'::jsonb, ARRAY['a'], false, 'Failure to evaluate delegated tasks violates RN accountability for ensuring proper task completion and patient safety.', 'Scope of Practice', 91),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN can document:', '[{"id":"a","text":"Within scope"},{"id":"b","text":"Nothing"},{"id":"c","text":"Only vitals"},{"id":"d","text":"Only meds"}]'::jsonb, ARRAY['a'], false, 'LPNs can document all activities performed within their scope of practice, including observations and interventions.', 'Scope of Practice', 92),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'RN must validate abnormal UAP findings because:', '[{"id":"a","text":"Delegation transfers accountability"},{"id":"b","text":"RN retains accountability"},{"id":"c","text":"CNA responsible"},{"id":"d","text":"Provider decides"}]'::jsonb, ARRAY['b'], false, 'RN retains accountability for patient outcomes and must personally validate abnormal findings before intervening.', 'Scope of Practice', 93),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which requires highest level of licensure?', '[{"id":"a","text":"Hygiene"},{"id":"b","text":"I&O"},{"id":"c","text":"Clinical judgment"},{"id":"d","text":"Feeding"}]'::jsonb, ARRAY['c'], false, 'Clinical judgment requiring assessment, diagnosis, and intervention planning requires RN-level education and licensure.', 'Scope of Practice', 94),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Unstable patient should be assigned to:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Unstable patients require RN-level continuous assessment, clinical judgment, and rapid intervention capabilities.', 'Scope of Practice', 95),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Stable patient ADLs best assigned to:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"Provider"}]'::jsonb, ARRAY['c'], false, 'ADLs for stable patients can be appropriately delegated to UAP, allowing RN to focus on complex care needs.', 'Scope of Practice', 96),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Which always requires RN?', '[{"id":"a","text":"Insulin titration"},{"id":"b","text":"Feeding"},{"id":"c","text":"Bathing"},{"id":"d","text":"Repositioning"}]'::jsonb, ARRAY['a'], false, 'Medication titration requires RN-level assessment and clinical judgment to adjust dosages based on patient response.', 'Scope of Practice', 97),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'LPN reinforcing teaching demonstrates:', '[{"id":"a","text":"Full teaching authority"},{"id":"b","text":"Proper scope"},{"id":"c","text":"Care planning"},{"id":"d","text":"Diagnosis"}]'::jsonb, ARRAY['b'], false, 'LPN reinforcing (not initiating) teaching is working within proper scope. Initial teaching must be done by RN.', 'Scope of Practice', 98),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'Delegating unstable patient monitoring violates:', '[{"id":"a","text":"Right Circumstance"},{"id":"b","text":"Right Person"},{"id":"c","text":"Right Task"},{"id":"d","text":"All"}]'::jsonb, ARRAY['d'], false, 'Delegating unstable patient care violates all delegation rights: wrong circumstance (unstable), wrong person (needs RN), wrong task (requires assessment).', 'Scope of Practice', 99),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', 'The safest rule in delegation:', '[{"id":"a","text":"Delegate everything"},{"id":"b","text":"Never delegate"},{"id":"c","text":"Never delegate assessment, teaching, or clinical judgment"},{"id":"d","text":"Always delegate stable patients"}]'::jsonb, ARRAY['c'], false, 'The golden rule: Never delegate assessment, initial teaching, or clinical judgment. These always require RN-level professional practice.', 'Scope of Practice', 100);

-- ============================================
-- VERIFICATION
-- ============================================

-- Show total question count for Scope of Practice topic
SELECT 
  t.name as topic_name,
  COUNT(q.id) as total_questions
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id 
  AND q.test_id = '00000000-0000-0000-0000-000000000001'
WHERE t.id = '20000000-0000-0000-0000-000000000003'
GROUP BY t.id, t.name;
-- Expected: Scope of Practice with 100 questions

-- Verify display_order range
SELECT 
  MIN(display_order) as first_question,
  MAX(display_order) as last_question,
  COUNT(*) as total_count
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000003';
-- Expected: 1 to 100, count = 100
