-- ============================================
-- DELEGATION - 100 QUESTIONS
-- ============================================
-- Run this AFTER ADD-SUBJECTS-TOPICS-TABLE.sql
-- All 100 questions for Topic 4: Delegation

-- Delete any existing questions for this topic to avoid duplicates
DELETE FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001' 
  AND topic_id = '20000000-0000-0000-0000-000000000004';

-- Insert 100 Delegation Questions (display_order 1-100 for this topic)
INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES

-- Questions 1-10: Core Delegation Principles
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Delegation transfers:', '[{"id":"a","text":"Accountability"},{"id":"b","text":"Nursing judgment"},{"id":"c","text":"Tasks only"},{"id":"d","text":"Licensure"}]'::jsonb, ARRAY['c'], false, 'Delegation transfers tasks only. The RN retains accountability and nursing judgment cannot be delegated.', 'Delegation', 1),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'After delegation, the RN remains:', '[{"id":"a","text":"Legally uninvolved"},{"id":"b","text":"Accountable for outcome"},{"id":"c","text":"Free from supervision"},{"id":"d","text":"Unaware of results"}]'::jsonb, ARRAY['b'], false, 'After delegation, the RN remains accountable for the outcome and must supervise and evaluate the delegated task.', 'Delegation', 2),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Which cannot be delegated?', '[{"id":"a","text":"Bathing"},{"id":"b","text":"Ambulating stable patient"},{"id":"c","text":"Nursing judgment"},{"id":"d","text":"Linen change"}]'::jsonb, ARRAY['c'], false, 'Nursing judgment cannot be delegated. It requires RN-level critical thinking and professional decision-making.', 'Delegation', 3),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Which best defines delegation?', '[{"id":"a","text":"Assigning patients"},{"id":"b","text":"Sharing accountability"},{"id":"c","text":"Assigning tasks while retaining accountability"},{"id":"d","text":"Reassigning licensure"}]'::jsonb, ARRAY['c'], false, 'Delegation is assigning specific tasks to competent individuals while the RN retains accountability for outcomes.', 'Delegation', 4),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Who can delegate?', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Only RNs can delegate tasks. LPNs, UAPs, and CNAs cannot delegate as they work under supervision.', 'Delegation', 5),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Delegation is safest when the patient is:', '[{"id":"a","text":"Unstable"},{"id":"b","text":"Stable"},{"id":"c","text":"New admit"},{"id":"d","text":"Acute"}]'::jsonb, ARRAY['b'], false, 'Delegation is safest with stable patients. Unstable, new admit, or acute patients require RN-level assessment and judgment.', 'Delegation', 6),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Which task requires RN critical thinking?', '[{"id":"a","text":"Linen change"},{"id":"b","text":"Assessing new chest pain"},{"id":"c","text":"Bathing"},{"id":"d","text":"Feeding stable patient"}]'::jsonb, ARRAY['b'], false, 'Assessing new chest pain requires RN critical thinking to identify potential cardiac emergency and initiate interventions.', 'Delegation', 7),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'A patient with complications should:', '[{"id":"a","text":"Be delegated to UAP"},{"id":"b","text":"Be managed by RN"},{"id":"c","text":"Be assigned to LPN only"},{"id":"d","text":"Be transferred"}]'::jsonb, ARRAY['b'], false, 'Patients with complications require RN-level assessment, clinical judgment, and intervention capabilities.', 'Delegation', 8),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Which is true?', '[{"id":"a","text":"Responsibility transfers"},{"id":"b","text":"Accountability transfers"},{"id":"c","text":"RN retains accountability"},{"id":"d","text":"RN loses supervision role"}]'::jsonb, ARRAY['c'], false, 'The RN retains accountability even after delegating tasks. Accountability never transfers in delegation.', 'Delegation', 9),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', '"You can delegate tasks, but not…":', '[{"id":"a","text":"Responsibility"},{"id":"b","text":"Accountability"},{"id":"c","text":"Planning"},{"id":"d","text":"Documentation"}]'::jsonb, ARRAY['b'], false, 'You can delegate tasks but not accountability. The RN remains accountable for patient outcomes after delegation.', 'Delegation', 10),

-- Questions 11-20: The 5 Rights of Delegation
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Right Task asks:', '[{"id":"a","text":"Is patient stable?"},{"id":"b","text":"Is delegatee trained?"},{"id":"c","text":"Is this safe to delegate?"},{"id":"d","text":"Was task documented?"}]'::jsonb, ARRAY['c'], false, 'Right Task evaluates whether the task itself is appropriate and safe to delegate based on its nature and complexity.', 'Delegation', 11),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Right Circumstance evaluates:', '[{"id":"a","text":"Nurse skill"},{"id":"b","text":"Patient stability"},{"id":"c","text":"Time of shift"},{"id":"d","text":"Room assignment"}]'::jsonb, ARRAY['b'], false, 'Right Circumstance focuses on patient stability. Unstable patients should not have care delegated to UAP or LPN.', 'Delegation', 12),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'New onset chest pain violates:', '[{"id":"a","text":"Right Task"},{"id":"b","text":"Right Circumstance"},{"id":"c","text":"Right Person"},{"id":"d","text":"Right Direction"}]'::jsonb, ARRAY['b'], false, 'New onset chest pain indicates patient instability, violating Right Circumstance for delegation to non-RN staff.', 'Delegation', 13),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Right Person ensures:', '[{"id":"a","text":"Correct nurse"},{"id":"b","text":"Qualified delegatee"},{"id":"c","text":"Patient agreement"},{"id":"d","text":"Provider approval"}]'::jsonb, ARRAY['b'], false, 'Right Person ensures the delegatee has the necessary qualifications, training, and competence for the specific task.', 'Delegation', 14),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Right Direction means:', '[{"id":"a","text":"Vague request"},{"id":"b","text":"Clear specific instruction"},{"id":"c","text":"Written only"},{"id":"d","text":"Silent supervision"}]'::jsonb, ARRAY['b'], false, 'Right Direction requires clear, specific instructions about the task, expected outcomes, and when to report findings.', 'Delegation', 15),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', '"Report if over 140" represents:', '[{"id":"a","text":"Right Supervision"},{"id":"b","text":"Right Task"},{"id":"c","text":"Right Direction"},{"id":"d","text":"Assignment"}]'::jsonb, ARRAY['c'], false, 'Providing specific reporting parameters ("report if over 140") is an example of Right Direction with clear communication.', 'Delegation', 16),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Right Supervision means:', '[{"id":"a","text":"Delegating and leaving"},{"id":"b","text":"Evaluating task completion"},{"id":"c","text":"Ignoring results"},{"id":"d","text":"Assuming completion"}]'::jsonb, ARRAY['b'], false, 'Right Supervision requires the RN to monitor, evaluate, and follow up on delegated tasks to ensure proper completion.', 'Delegation', 17),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN fails to follow up after delegation. Violates:', '[{"id":"a","text":"Right Person"},{"id":"b","text":"Right Circumstance"},{"id":"c","text":"Right Supervision"},{"id":"d","text":"Right Task"}]'::jsonb, ARRAY['c'], false, 'Failure to follow up after delegation violates Right Supervision, which requires monitoring and evaluation.', 'Delegation', 18),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Stable vs unstable distinction relates to:', '[{"id":"a","text":"Right Task"},{"id":"b","text":"Right Circumstance"},{"id":"c","text":"Right Direction"},{"id":"d","text":"Right Person"}]'::jsonb, ARRAY['b'], false, 'Patient stability is evaluated under Right Circumstance when determining if delegation is appropriate.', 'Delegation', 19),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'If delegatee lacks skill:', '[{"id":"a","text":"Delegate anyway"},{"id":"b","text":"It violates Right Person"},{"id":"c","text":"It violates Right Direction"},{"id":"d","text":"It violates Assignment"}]'::jsonb, ARRAY['b'], false, 'Delegating to someone who lacks the necessary skill or competence violates Right Person.', 'Delegation', 20),

-- Questions 21-40: RN vs LPN vs UAP Roles
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'UAP cannot:', '[{"id":"a","text":"Ambulate stable patient"},{"id":"b","text":"Collect I&O"},{"id":"c","text":"Assess surgical site"},{"id":"d","text":"Feed stable patient"}]'::jsonb, ARRAY['c'], false, 'UAPs cannot assess. Assessment requires RN-level critical thinking and professional judgment.', 'Delegation', 21),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'LPN cannot:', '[{"id":"a","text":"Give oral meds"},{"id":"b","text":"Perform sterile dressing"},{"id":"c","text":"Do initial assessment"},{"id":"d","text":"Insert foley"}]'::jsonb, ARRAY['c'], false, 'LPNs cannot perform initial assessments. This requires comprehensive RN-level assessment and clinical judgment.', 'Delegation', 22),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN performs:', '[{"id":"a","text":"Basic ADLs"},{"id":"b","text":"Initial assessments"},{"id":"c","text":"Linen changes only"},{"id":"d","text":"Stable vitals only"}]'::jsonb, ARRAY['b'], false, 'RNs perform initial assessments requiring comprehensive evaluation, clinical judgment, and care planning.', 'Delegation', 23),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'UAP role is:', '[{"id":"a","text":"Complex decision-making"},{"id":"b","text":"Routine, repetitive, low-risk"},{"id":"c","text":"Unstable monitoring"},{"id":"d","text":"Teaching"}]'::jsonb, ARRAY['b'], false, 'UAP role focuses on routine, repetitive, low-risk tasks that do not require professional nursing judgment.', 'Delegation', 24),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'LPN can care for:', '[{"id":"a","text":"Unstable patients"},{"id":"b","text":"Stable patients"},{"id":"c","text":"Acute new chest pain"},{"id":"d","text":"Complex triage"}]'::jsonb, ARRAY['b'], false, 'LPNs can care for stable patients. Unstable, acute, or complex situations require RN-level judgment.', 'Delegation', 25),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'LPN can administer:', '[{"id":"a","text":"IV morphine"},{"id":"b","text":"Blood transfusion"},{"id":"c","text":"Oral meds"},{"id":"d","text":"IV push meds"}]'::jsonb, ARRAY['c'], false, 'LPNs can administer oral medications to stable patients. IV push and blood transfusions typically require RN.', 'Delegation', 26),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN only task:', '[{"id":"a","text":"Feeding"},{"id":"b","text":"Bathing"},{"id":"c","text":"Triage"},{"id":"d","text":"Ambulation"}]'::jsonb, ARRAY['c'], false, 'Triage requires RN-level critical thinking to prioritize patient care based on acuity and available resources.', 'Delegation', 27),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'UAP may collect:', '[{"id":"a","text":"Nursing diagnosis"},{"id":"b","text":"I&O data"},{"id":"c","text":"Medication doses"},{"id":"d","text":"Care plans"}]'::jsonb, ARRAY['b'], false, 'UAPs can collect intake and output (I&O) data. Diagnosis, medication, and planning require licensure.', 'Delegation', 28),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'UAP must NOT:', '[{"id":"a","text":"Reposition"},{"id":"b","text":"Turn"},{"id":"c","text":"Interpret I&O"},{"id":"d","text":"Record vitals"}]'::jsonb, ARRAY['c'], false, 'UAPs can collect and record data but cannot interpret findings. Interpretation requires professional judgment.', 'Delegation', 29),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'LPN can reinforce teaching but not:', '[{"id":"a","text":"Assess"},{"id":"b","text":"Administer meds"},{"id":"c","text":"Collect specimens"},{"id":"d","text":"Perform sterile dressing"}]'::jsonb, ARRAY['a'], false, 'LPNs can reinforce teaching but cannot assess. Assessment requires RN-level comprehensive evaluation and judgment.', 'Delegation', 30),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Which task can be delegated to UAP?', '[{"id":"a","text":"Evaluating pain relief"},{"id":"b","text":"Taking vital signs on stable patient"},{"id":"c","text":"Developing care plan"},{"id":"d","text":"Teaching wound care"}]'::jsonb, ARRAY['b'], false, 'Taking vital signs on stable patients can be delegated to UAP. Evaluation, planning, and teaching require RN level.', 'Delegation', 31),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'LPN scope includes:', '[{"id":"a","text":"Initial nursing diagnosis"},{"id":"b","text":"Data collection and observation"},{"id":"c","text":"Creating care plans"},{"id":"d","text":"Performing triage"}]'::jsonb, ARRAY['b'], false, 'LPNs can collect data and observe but cannot diagnose, create care plans, or perform triage.', 'Delegation', 32),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Complex wound assessment requires:', '[{"id":"a","text":"UAP observation"},{"id":"b","text":"LPN data collection"},{"id":"c","text":"RN clinical judgment"},{"id":"d","text":"CNA reporting"}]'::jsonb, ARRAY['c'], false, 'Complex wound assessment requires RN clinical judgment to evaluate healing and identify complications.', 'Delegation', 33),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'UAP reports abnormal finding. RN must:', '[{"id":"a","text":"Ignore if UAP trained"},{"id":"b","text":"Validate finding personally"},{"id":"c","text":"Delegate to LPN"},{"id":"d","text":"Document only"}]'::jsonb, ARRAY['b'], false, 'RN must personally validate abnormal findings reported by UAP before taking action, as RN retains accountability.', 'Delegation', 34),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Delegating medication administration to UAP:', '[{"id":"a","text":"Appropriate"},{"id":"b","text":"Inappropriate"},{"id":"c","text":"Depends on medication"},{"id":"d","text":"Allowed with training"}]'::jsonb, ARRAY['b'], false, 'Medication administration cannot be delegated to UAP regardless of training. This requires licensure.', 'Delegation', 35),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN delegates feeding to UAP for patient with dysphagia. This is:', '[{"id":"a","text":"Appropriate"},{"id":"b","text":"Inappropriate - requires RN assessment"},{"id":"c","text":"Appropriate with supervision"},{"id":"d","text":"Always safe"}]'::jsonb, ARRAY['b'], false, 'Patients with dysphagia are at high risk for aspiration and require RN-level assessment and monitoring during feeding.', 'Delegation', 36),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'LPN can perform which procedure?', '[{"id":"a","text":"Initial patient teaching"},{"id":"b","text":"Simple sterile dressing change"},{"id":"c","text":"IV push medication"},{"id":"d","text":"Nursing diagnosis"}]'::jsonb, ARRAY['b'], false, 'LPNs can perform simple sterile procedures like dressing changes. Teaching, IV push, and diagnosis require RN level.', 'Delegation', 37),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Which demonstrates proper delegation?', '[{"id":"a","text":"RN delegates assessment to LPN"},{"id":"b","text":"RN delegates stable patient bathing to UAP"},{"id":"c","text":"RN delegates IV medications to UAP"},{"id":"d","text":"RN delegates triage to LPN"}]'::jsonb, ARRAY['b'], false, 'Delegating bathing of stable patients to UAP is appropriate. Assessment, IV meds, and triage cannot be delegated.', 'Delegation', 38),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'UAP scope is limited to:', '[{"id":"a","text":"Assessment and intervention"},{"id":"b","text":"Basic care and observation"},{"id":"c","text":"Medication administration"},{"id":"d","text":"Care plan development"}]'::jsonb, ARRAY['b'], false, 'UAP scope is limited to basic care activities and observation, not assessment, medications, or planning.', 'Delegation', 39),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN can delegate which to LPN?', '[{"id":"a","text":"Blood transfusion"},{"id":"b","text":"Oral medication to stable patient"},{"id":"c","text":"Initial assessment"},{"id":"d","text":"Discharge planning"}]'::jsonb, ARRAY['b'], false, 'LPNs can administer oral medications to stable patients. Blood products, initial assessment, and discharge planning require RN.', 'Delegation', 40),

-- Questions 41-60: RN-Only Tasks
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Never delegate:', '[{"id":"a","text":"Stable ambulation"},{"id":"b","text":"Initial assessment"},{"id":"c","text":"Linen change"},{"id":"d","text":"Feeding"}]'::jsonb, ARRAY['b'], false, 'Initial assessment can never be delegated. It requires comprehensive RN-level evaluation and clinical judgment.', 'Delegation', 41),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Care plan development:', '[{"id":"a","text":"LPN"},{"id":"b","text":"RN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Care plan development is an RN-only function requiring assessment, diagnosis, and clinical judgment.', 'Delegation', 42),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'IV meds:', '[{"id":"a","text":"LPN"},{"id":"b","text":"RN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'IV medications typically require RN administration due to rapid onset and potential complications requiring assessment.', 'Delegation', 43),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Blood products:', '[{"id":"a","text":"LPN"},{"id":"b","text":"RN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Blood product administration requires RN-level monitoring and assessment for transfusion reactions.', 'Delegation', 44),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Teaching new insulin:', '[{"id":"a","text":"LPN"},{"id":"b","text":"RN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Initial patient teaching of new skills like insulin injection must be done by RN to ensure comprehension.', 'Delegation', 45),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Discharge education:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Discharge education requires RN-level teaching to ensure patient understands medications, care, and follow-up.', 'Delegation', 46),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Unstable patient care:', '[{"id":"a","text":"LPN"},{"id":"b","text":"RN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Unstable patients require RN-level continuous assessment, clinical judgment, and rapid intervention.', 'Delegation', 47),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Critical thinking tasks:', '[{"id":"a","text":"RN"},{"id":"b","text":"UAP"},{"id":"c","text":"CNA"},{"id":"d","text":"LPN only"}]'::jsonb, ARRAY['a'], false, 'Tasks requiring critical thinking, clinical judgment, and decision-making are RN-only responsibilities.', 'Delegation', 48),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Admission assessment:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['a'], false, 'Admission assessment is an RN-only function requiring comprehensive evaluation and care planning.', 'Delegation', 49),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Evaluation of task after delegation:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'The RN must evaluate delegated tasks to ensure proper completion and patient safety, maintaining accountability.', 'Delegation', 50),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Interpreting lab results:', '[{"id":"a","text":"UAP collects"},{"id":"b","text":"LPN reports"},{"id":"c","text":"RN interprets"},{"id":"d","text":"Any licensed staff"}]'::jsonb, ARRAY['c'], false, 'Interpreting lab results and determining clinical significance requires RN-level knowledge and judgment.', 'Delegation', 51),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Developing discharge plan:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"Social worker only"}]'::jsonb, ARRAY['c'], false, 'Developing discharge plans requires RN-level assessment, coordination, and teaching to ensure safe transitions.', 'Delegation', 52),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Medication titration based on assessment:', '[{"id":"a","text":"LPN with training"},{"id":"b","text":"RN"},{"id":"c","text":"UAP"},{"id":"d","text":"Any nurse"}]'::jsonb, ARRAY['b'], false, 'Medication titration requires RN-level assessment and clinical judgment to adjust dosages based on patient response.', 'Delegation', 53),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Creating nursing diagnosis:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"Collaborative"}]'::jsonb, ARRAY['a'], false, 'Formulating nursing diagnoses is an RN-only function requiring professional judgment and critical analysis.', 'Delegation', 54),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Evaluating patient response to interventions:', '[{"id":"a","text":"UAP observes"},{"id":"b","text":"LPN reports"},{"id":"c","text":"RN evaluates"},{"id":"d","text":"Provider only"}]'::jsonb, ARRAY['c'], false, 'Evaluating patient response requires RN clinical judgment to interpret findings and adjust care accordingly.', 'Delegation', 55),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Teaching post-operative complications to watch for:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"Provider only"}]'::jsonb, ARRAY['c'], false, 'Initial teaching about complications requires RN-level knowledge to ensure patient understanding and safety.', 'Delegation', 56),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Performing focused assessment on unstable patient:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"Any available staff"}]'::jsonb, ARRAY['c'], false, 'Focused assessment on unstable patients requires RN-level skills to identify changes and initiate interventions.', 'Delegation', 57),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Coordinating care across disciplines:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"Unit clerk"}]'::jsonb, ARRAY['c'], false, 'Care coordination requires RN-level communication and clinical judgment to manage complex patient needs.', 'Delegation', 58),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Analyzing trends in vital signs:', '[{"id":"a","text":"UAP records"},{"id":"b","text":"LPN monitors"},{"id":"c","text":"RN analyzes"},{"id":"d","text":"All can analyze"}]'::jsonb, ARRAY['c'], false, 'Analyzing trends requires RN-level clinical judgment to identify patterns and determine interventions needed.', 'Delegation', 59),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Priority setting for multiple patients:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"Charge nurse only"}]'::jsonb, ARRAY['c'], false, 'Priority setting requires RN-level clinical judgment to assess acuity and allocate resources appropriately.', 'Delegation', 60),

-- Questions 61-80: NCLEX Application Scenarios
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Stable post-op patient ambulation to bathroom → delegate to:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"Provider"}]'::jsonb, ARRAY['c'], false, 'Ambulating stable post-op patients to bathroom can be appropriately delegated to UAP with clear instructions.', 'Delegation', 61),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Assess surgical site:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Assessing surgical sites requires RN-level skills to evaluate healing, identify complications, and adjust care.', 'Delegation', 62),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Administer morphine:', '[{"id":"a","text":"UAP"},{"id":"b","text":"RN"},{"id":"c","text":"LPN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'Morphine administration requires RN-level assessment of pain, respiratory status, and monitoring for side effects.', 'Delegation', 63),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Collect sputum specimen:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"Both"},{"id":"d","text":"RN only"}]'::jsonb, ARRAY['c'], false, 'Collecting routine specimens like sputum can be delegated to both UAP and LPN for stable patients.', 'Delegation', 64),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Patient unstable → delegate?', '[{"id":"a","text":"Yes"},{"id":"b","text":"No"},{"id":"c","text":"Sometimes"},{"id":"d","text":"Only LPN"}]'::jsonb, ARRAY['b'], false, 'Unstable patients should not have care delegated. They require continuous RN-level assessment and intervention.', 'Delegation', 65),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Reinforcing teaching is:', '[{"id":"a","text":"RN only"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'LPNs can reinforce teaching that was initially provided by an RN, but cannot do initial teaching.', 'Delegation', 66),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'New teaching is:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['a'], false, 'New or initial teaching must be done by RN to assess understanding and answer questions appropriately.', 'Delegation', 67),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Suctioning and trach care:', '[{"id":"a","text":"LPN"},{"id":"b","text":"UAP"},{"id":"c","text":"RN only"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['a'], false, 'LPNs can perform suctioning and trach care for stable patients. Complex or unstable situations require RN.', 'Delegation', 68),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Enteral feeds:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN only"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'LPNs can administer enteral feeds for stable patients. Initial placement and unstable patients require RN.', 'Delegation', 69),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Collecting I&O data:', '[{"id":"a","text":"RN only"},{"id":"b","text":"UAP"},{"id":"c","text":"LPN only"},{"id":"d","text":"Provider"}]'::jsonb, ARRAY['b'], false, 'Collecting and recording I&O data can be delegated to UAP for stable patients. Interpretation requires RN.', 'Delegation', 70),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Patient with new confusion. Delegate vital signs?', '[{"id":"a","text":"Yes to UAP"},{"id":"b","text":"No - RN must assess"},{"id":"c","text":"Yes to LPN"},{"id":"d","text":"Either UAP or LPN"}]'::jsonb, ARRAY['b'], false, 'New confusion indicates patient instability requiring RN assessment. Delegation would be inappropriate.', 'Delegation', 71),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Delegating wound dressing change to trained UAP:', '[{"id":"a","text":"Appropriate"},{"id":"b","text":"Inappropriate - requires assessment"},{"id":"c","text":"Appropriate with supervision"},{"id":"d","text":"Depends on wound"}]'::jsonb, ARRAY['b'], false, 'Wound dressing changes require assessment skills beyond UAP scope, even with training. LPN or RN required.', 'Delegation', 72),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Patient with chest tube. Delegate repositioning?', '[{"id":"a","text":"Yes to UAP"},{"id":"b","text":"Yes to LPN"},{"id":"c","text":"RN must assess first, then can delegate to trained staff"},{"id":"d","text":"Never delegate"}]'::jsonb, ARRAY['c'], false, 'RN must assess patient stability first. If stable, repositioning can be delegated with specific instructions about chest tube.', 'Delegation', 73),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'UAP reports patient "not acting right." RN should:', '[{"id":"a","text":"Thank UAP and continue work"},{"id":"b","text":"Assess patient immediately"},{"id":"c","text":"Ask UAP to clarify later"},{"id":"d","text":"Delegate assessment to LPN"}]'::jsonb, ARRAY['b'], false, 'Any report of change in patient condition requires immediate RN assessment to identify potential problems.', 'Delegation', 74),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Diabetic patient with blood sugar 250. Delegate care?', '[{"id":"a","text":"Yes - stable chronic condition"},{"id":"b","text":"No - requires RN assessment and intervention"},{"id":"c","text":"Yes to LPN for insulin"},{"id":"d","text":"Yes to UAP"}]'::jsonb, ARRAY['b'], false, 'Elevated blood sugar requires RN assessment to determine cause and appropriate insulin intervention.', 'Delegation', 75),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Post-op day 2, stable, needs oral pain medication. Delegate to:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"Must be RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'LPN can administer oral pain medication to stable post-op patients. This is within LPN scope.', 'Delegation', 76),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Patient receiving chemotherapy needs vital signs. Delegate?', '[{"id":"a","text":"Yes to UAP if stable"},{"id":"b","text":"No - always requires RN"},{"id":"c","text":"Yes to any staff"},{"id":"d","text":"Provider must do it"}]'::jsonb, ARRAY['a'], false, 'If chemotherapy patient is stable, vital signs can be delegated to UAP with clear instructions about reporting.', 'Delegation', 77),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Evaluating effectiveness of pain medication:', '[{"id":"a","text":"UAP asks patient"},{"id":"b","text":"LPN reports findings"},{"id":"c","text":"RN evaluates response"},{"id":"d","text":"Any staff member"}]'::jsonb, ARRAY['c'], false, 'Evaluating medication effectiveness requires RN clinical judgment to determine if intervention achieved desired outcome.', 'Delegation', 78),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Patient on fall precautions needs bathroom assistance. Delegate to:', '[{"id":"a","text":"No one - RN must do it"},{"id":"b","text":"UAP with clear instructions"},{"id":"c","text":"LPN only"},{"id":"d","text":"Cannot delegate fall risk patients"}]'::jsonb, ARRAY['b'], false, 'Bathroom assistance for stable patients on fall precautions can be delegated to UAP with clear safety instructions.', 'Delegation', 79),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'First-time parents need infant feeding instruction. Delegate to:', '[{"id":"a","text":"UAP who has children"},{"id":"b","text":"LPN to reinforce only if RN taught first"},{"id":"c","text":"RN must do initial teaching"},{"id":"d","text":"Any experienced mother"}]'::jsonb, ARRAY['c'], false, 'Initial teaching to first-time parents must be done by RN to ensure comprehension and answer questions.', 'Delegation', 80),

-- Questions 81-100: Advanced Analysis
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Delegating unstable patient violates:', '[{"id":"a","text":"Right Task"},{"id":"b","text":"Right Circumstance"},{"id":"c","text":"Right Person"},{"id":"d","text":"Right Direction"}]'::jsonb, ARRAY['b'], false, 'Delegating care of unstable patients violates Right Circumstance, as instability requires RN-level care.', 'Delegation', 81),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN delegates but gives vague instruction. Violates:', '[{"id":"a","text":"Right Direction"},{"id":"b","text":"Right Task"},{"id":"c","text":"Right Person"},{"id":"d","text":"Right Supervision"}]'::jsonb, ARRAY['a'], false, 'Vague instructions violate Right Direction, which requires clear, specific communication about tasks and expectations.', 'Delegation', 82),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN does not follow up. Violates:', '[{"id":"a","text":"Right Task"},{"id":"b","text":"Right Supervision"},{"id":"c","text":"Right Person"},{"id":"d","text":"Assignment"}]'::jsonb, ARRAY['b'], false, 'Failure to follow up and evaluate delegated tasks violates Right Supervision and RN accountability.', 'Delegation', 83),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Stable chronic patient ADLs best delegated to:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"Provider"}]'::jsonb, ARRAY['c'], false, 'ADLs for stable chronic patients can be appropriately delegated to UAP, freeing RN for complex care.', 'Delegation', 84),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Complex patient with complications:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'Complex patients with complications require RN-level assessment, clinical judgment, and intervention planning.', 'Delegation', 85),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'ADPIE cannot be delegated because:', '[{"id":"a","text":"It requires nursing judgment"},{"id":"b","text":"It is routine"},{"id":"c","text":"It is repetitive"},{"id":"d","text":"It is low risk"}]'::jsonb, ARRAY['a'], false, 'ADPIE (Assessment, Diagnosis, Planning, Implementation, Evaluation) requires nursing judgment and is RN-only.', 'Delegation', 86),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', '"Reinforce" in NCLEX question suggests:', '[{"id":"a","text":"RN"},{"id":"b","text":"LPN"},{"id":"c","text":"UAP"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['b'], false, 'The word "reinforce" in NCLEX questions typically indicates LPN role - reinforcing what RN initially taught.', 'Delegation', 87),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', '"Assess" in NCLEX question suggests:', '[{"id":"a","text":"UAP"},{"id":"b","text":"LPN"},{"id":"c","text":"RN"},{"id":"d","text":"CNA"}]'::jsonb, ARRAY['c'], false, 'The word "assess" in NCLEX questions indicates RN-only responsibility requiring professional judgment.', 'Delegation', 88),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', '"Assist" in NCLEX question suggests:', '[{"id":"a","text":"RN"},{"id":"b","text":"UAP"},{"id":"c","text":"LPN"},{"id":"d","text":"Provider"}]'::jsonb, ARRAY['b'], false, 'The word "assist" with stable patients typically indicates UAP role - helping with basic care activities.', 'Delegation', 89),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN delegating triage violates:', '[{"id":"a","text":"Right Person"},{"id":"b","text":"Right Task"},{"id":"c","text":"Both"},{"id":"d","text":"None"}]'::jsonb, ARRAY['c'], false, 'Triage cannot be delegated (Right Task) and LPN/UAP lack qualifications for triage (Right Person). Violates both.', 'Delegation', 90),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Stable vital signs monitoring:', '[{"id":"a","text":"RN only"},{"id":"b","text":"LPN or UAP"},{"id":"c","text":"Provider"},{"id":"d","text":"CNA prohibited"}]'::jsonb, ARRAY['b'], false, 'Stable patient vital signs can be monitored by LPN or UAP with clear instructions about reporting abnormals.', 'Delegation', 91),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN accountability includes:', '[{"id":"a","text":"Outcome evaluation"},{"id":"b","text":"Task transfer"},{"id":"c","text":"License transfer"},{"id":"d","text":"Chart only"}]'::jsonb, ARRAY['a'], false, 'RN accountability includes evaluating outcomes of delegated tasks to ensure patient safety and proper completion.', 'Delegation', 92),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Delegation inappropriate if:', '[{"id":"a","text":"Stable patient"},{"id":"b","text":"Complex condition"},{"id":"c","text":"Routine task"},{"id":"d","text":"Clear instruction"}]'::jsonb, ARRAY['b'], false, 'Delegation is inappropriate for complex conditions requiring RN-level assessment and clinical judgment.', 'Delegation', 93),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'LPN = "Licensed but…":', '[{"id":"a","text":"Unlimited"},{"id":"b","text":"Limited"},{"id":"c","text":"Advanced"},{"id":"d","text":"Delegator"}]'::jsonb, ARRAY['b'], false, 'LPN means "Licensed but Limited" - licensed to perform certain tasks but with scope restrictions compared to RN.', 'Delegation', 94),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'UAP = "Routine, Repetitive…":', '[{"id":"a","text":"Complex"},{"id":"b","text":"Low-risk"},{"id":"c","text":"High judgment"},{"id":"d","text":"Critical"}]'::jsonb, ARRAY['b'], false, 'UAP performs routine, repetitive, low-risk tasks that do not require professional nursing judgment.', 'Delegation', 95),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Initial vs ongoing assessment difference:', '[{"id":"a","text":"Both RN"},{"id":"b","text":"Initial = RN"},{"id":"c","text":"Ongoing = UAP"},{"id":"d","text":"Both UAP"}]'::jsonb, ARRAY['b'], false, 'Initial assessment must be done by RN. Ongoing data collection can involve LPN, but RN interprets and evaluates.', 'Delegation', 96),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Delegation always requires:', '[{"id":"a","text":"Stability"},{"id":"b","text":"Supervision"},{"id":"c","text":"Clear communication"},{"id":"d","text":"All of the above"}]'::jsonb, ARRAY['d'], false, 'Safe delegation always requires patient stability, ongoing supervision, and clear communication of expectations.', 'Delegation', 97),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'RN may delegate but must:', '[{"id":"a","text":"Transfer accountability"},{"id":"b","text":"Supervise and follow up"},{"id":"c","text":"Leave unit"},{"id":"d","text":"Avoid involvement"}]'::jsonb, ARRAY['b'], false, 'RN must supervise and follow up on delegated tasks, maintaining accountability for patient outcomes.', 'Delegation', 98),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Which is safest rule?', '[{"id":"a","text":"Delegate everything"},{"id":"b","text":"Never delegate"},{"id":"c","text":"Never delegate nursing judgment"},{"id":"d","text":"Always delegate stable patients"}]'::jsonb, ARRAY['c'], false, 'The safest rule: Never delegate nursing judgment, assessment, or critical thinking. These always require RN.', 'Delegation', 99),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', 'Ultimate NCLEX rule:', '[{"id":"a","text":"If it requires critical thinking → RN"},{"id":"b","text":"If stable → RN"},{"id":"c","text":"If simple → RN"},{"id":"d","text":"If repetitive → RN"}]'::jsonb, ARRAY['a'], false, 'Ultimate NCLEX rule: If a task requires critical thinking, assessment, or clinical judgment, it must be performed by RN.', 'Delegation', 100);

-- ============================================
-- VERIFICATION
-- ============================================

-- Show total question count for Delegation topic
SELECT 
  t.name as topic_name,
  COUNT(q.id) as total_questions
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id 
  AND q.test_id = '00000000-0000-0000-0000-000000000001'
WHERE t.id = '20000000-0000-0000-0000-000000000004'
GROUP BY t.id, t.name;
-- Expected: Delegation with 100 questions

-- Verify display_order range
SELECT 
  MIN(display_order) as first_question,
  MAX(display_order) as last_question,
  COUNT(*) as total_count
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000004';
-- Expected: 1 to 100, count = 100
