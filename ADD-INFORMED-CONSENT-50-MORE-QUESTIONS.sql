-- ============================================
-- NURSE'S ROLE IN INFORMED CONSENT - 50 MORE QUESTIONS
-- ============================================
-- Run this AFTER ADD-INFORMED-CONSENT-50-QUESTIONS.sql
-- These questions are for Topic 2: Nurse's Role in Informed Consent (display_order 51-100)

-- Insert 50 Additional Informed Consent Questions (display_order 51-100 for this topic)
INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES

-- Questions 51-60: Emotional State & Verification
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient signs consent but appears fearful and tearful. What is the nurse''s priority action?', '[{"id":"a","text":"Proceed because signature is complete"},{"id":"b","text":"Notify provider due to possible coercion or misunderstanding"},{"id":"c","text":"Ask family to reassure patient"},{"id":"d","text":"File consent form"}]'::jsonb, ARRAY['b'], false, 'Fearful and tearful behavior may indicate coercion or misunderstanding. The nurse must notify the provider.', 'Informed Consent', 51),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The nurse witnesses a signature but did not see the provider explain the procedure. The nurse should:', '[{"id":"a","text":"Assume explanation occurred"},{"id":"b","text":"Witness anyway"},{"id":"c","text":"Confirm explanation occurred before witnessing"},{"id":"d","text":"Re-explain the procedure"}]'::jsonb, ARRAY['c'], false, 'The nurse must confirm that the provider explanation occurred before witnessing the signature.', 'Informed Consent', 52),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which finding invalidates consent?', '[{"id":"a","text":"Patient nervous"},{"id":"b","text":"Patient anxious"},{"id":"c","text":"Patient confused"},{"id":"d","text":"Patient quiet"}]'::jsonb, ARRAY['c'], false, 'Confusion indicates lack of mental competency and invalidates consent.', 'Informed Consent', 53),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The nurse hears a family member answering all questions for the patient. The nurse should:', '[{"id":"a","text":"Accept family''s answers"},{"id":"b","text":"Redirect questions to the patient to ensure autonomy"},{"id":"c","text":"Allow family to decide"},{"id":"d","text":"Ask provider to hurry"}]'::jsonb, ARRAY['b'], false, 'The patient must answer questions independently to demonstrate understanding and preserve autonomy.', 'Informed Consent', 54),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient says: "I trust you, just tell me what to do." The nurse should:', '[{"id":"a","text":"Recommend the procedure"},{"id":"b","text":"Reinforce provider explanation and support patient decision-making"},{"id":"c","text":"Decide for patient"},{"id":"d","text":"Tell family to decide"}]'::jsonb, ARRAY['b'], false, 'The nurse supports the patient in making their own decision by reinforcing education, not making the decision for them.', 'Informed Consent', 55),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which is NOT part of informed consent per document?', '[{"id":"a","text":"Risks"},{"id":"b","text":"Benefits"},{"id":"c","text":"Nurse opinion"},{"id":"d","text":"Alternatives"}]'::jsonb, ARRAY['c'], false, 'Informed consent includes procedure, risks, benefits, and alternatives—not the nurse\'s personal opinion.', 'Informed Consent', 56),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient signs while mildly sedated but oriented. The nurse should:', '[{"id":"a","text":"Accept signature"},{"id":"b","text":"Stop and notify provider because sedation invalidates consent"},{"id":"c","text":"Ask family to confirm"},{"id":"d","text":"Proceed if provider agrees"}]'::jsonb, ARRAY['b'], false, 'Any sedation, even if patient appears oriented, invalidates consent due to impaired decision-making.', 'Informed Consent', 57),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The nurse documents: "Patient understands completely." This is:', '[{"id":"a","text":"Appropriate"},{"id":"b","text":"Required"},{"id":"c","text":"Inappropriate unless supported by documented assessment and summary"},{"id":"d","text":"Optional"}]'::jsonb, ARRAY['c'], false, 'Vague statements are inappropriate. Documentation must include specific assessment details and summary of understanding.', 'Informed Consent', 58),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient states: "I feel rushed." The nurse should:', '[{"id":"a","text":"Continue process"},{"id":"b","text":"Pause and advocate for adequate time"},{"id":"c","text":"Tell patient procedure must proceed"},{"id":"d","text":"Ask family to reassure"}]'::jsonb, ARRAY['b'], false, 'Feeling rushed compromises voluntariness. The nurse must pause and advocate for adequate time.', 'Informed Consent', 59),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The most important element of voluntariness is absence of:', '[{"id":"a","text":"Questions"},{"id":"b","text":"Fear"},{"id":"c","text":"Coercion"},{"id":"d","text":"Anxiety"}]'::jsonb, ARRAY['c'], false, 'Voluntariness requires the absence of coercion or pressure. Some fear and anxiety are normal.', 'Informed Consent', 60),

-- Questions 61-70: Patient Rights & Refusal
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'If a patient refuses after signing consent, the nurse should:', '[{"id":"a","text":"Ignore refusal"},{"id":"b","text":"Notify provider immediately"},{"id":"c","text":"Tell patient refusal is invalid"},{"id":"d","text":"Ask family to override"}]'::jsonb, ARRAY['b'], false, 'Patients have the right to withdraw consent at any time. The provider must be notified immediately.', 'Informed Consent', 61),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The nurse''s role when patient is hesitant includes:', '[{"id":"a","text":"Persuasion"},{"id":"b","text":"Advocacy"},{"id":"c","text":"Decision-making"},{"id":"d","text":"Procedure explanation"}]'::jsonb, ARRAY['b'], false, 'When a patient is hesitant, the nurse acts as advocate to ensure understanding and voluntary decision-making.', 'Informed Consent', 62),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient is alert but intoxicated. Consent is:', '[{"id":"a","text":"Valid"},{"id":"b","text":"Invalid due to impaired decision-making"},{"id":"c","text":"Valid with family"},{"id":"d","text":"Valid if signed"}]'::jsonb, ARRAY['b'], false, 'Intoxication impairs decision-making capacity, making consent invalid even if patient appears alert.', 'Informed Consent', 63),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which ensures legal protection?', '[{"id":"a","text":"Signature alone"},{"id":"b","text":"Provider explanation alone"},{"id":"c","text":"Proper documentation including competency and voluntariness"},{"id":"d","text":"Family presence"}]'::jsonb, ARRAY['c'], false, 'Legal protection requires complete documentation of competency assessment, voluntariness, and education.', 'Informed Consent', 64),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The nurse witnesses consent but notes patient cannot repeat procedure purpose. Action?', '[{"id":"a","text":"Witness anyway"},{"id":"b","text":"Notify provider"},{"id":"c","text":"Ask family to clarify"},{"id":"d","text":"Explain and proceed"}]'::jsonb, ARRAY['b'], false, 'If patient cannot repeat procedure purpose, understanding is questionable. Provider must be notified.', 'Informed Consent', 65),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient asks about a rare complication not discussed. Nurse should:', '[{"id":"a","text":"Provide independent explanation"},{"id":"b","text":"Notify provider for clarification"},{"id":"c","text":"Say it''s unimportant"},{"id":"d","text":"Ignore question"}]'::jsonb, ARRAY['b'], false, 'Questions about complications not discussed by the provider require provider clarification.', 'Informed Consent', 66),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which demonstrates the nurse acting as advocate?', '[{"id":"a","text":"Minimizing concerns"},{"id":"b","text":"Encouraging signature"},{"id":"c","text":"Ensuring patient right to refuse is respected"},{"id":"d","text":"Deciding treatment"}]'::jsonb, ARRAY['c'], false, 'Advocacy includes respecting and protecting the patient\'s right to refuse treatment.', 'Informed Consent', 67),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient signs while crying and shaking. Nurse''s first step:', '[{"id":"a","text":"Witness signature"},{"id":"b","text":"Stop and reassess voluntariness"},{"id":"c","text":"Call family"},{"id":"d","text":"File consent"}]'::jsonb, ARRAY['b'], false, 'Crying and shaking may indicate emotional distress or lack of voluntariness. Reassessment is required.', 'Informed Consent', 68),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'If provider delegates consent explanation to nurse, nurse should:', '[{"id":"a","text":"Accept delegation"},{"id":"b","text":"Refuse because only provider obtains informed consent"},{"id":"c","text":"Explain risks independently"},{"id":"d","text":"Ask CNA to help"}]'::jsonb, ARRAY['b'], false, 'The nurse must refuse delegation. Only the provider can obtain informed consent.', 'Informed Consent', 69),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient does not speak English and declines interpreter. The nurse should:', '[{"id":"a","text":"Respect refusal and proceed"},{"id":"b","text":"Use family interpreter"},{"id":"c","text":"Explain need for licensed interpreter to ensure valid consent"},{"id":"d","text":"Have provider sign"}]'::jsonb, ARRAY['c'], false, 'A licensed interpreter is required for valid consent. The nurse must explain this necessity.', 'Informed Consent', 70),

-- Questions 71-80: Documentation & Boundaries
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The nurse notes consent form missing risk section. Action?', '[{"id":"a","text":"Ignore"},{"id":"b","text":"Fill it in"},{"id":"c","text":"Notify provider because consent incomplete"},{"id":"d","text":"Ask patient to sign anyway"}]'::jsonb, ARRAY['c'], false, 'An incomplete consent form must be corrected by the provider before proceeding.', 'Informed Consent', 71),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient appears pressured by spouse. Which role is primary?', '[{"id":"a","text":"Witness"},{"id":"b","text":"Educator"},{"id":"c","text":"Advocate"},{"id":"d","text":"Recorder"}]'::jsonb, ARRAY['c'], false, 'When pressure is suspected, the advocate role is primary to ensure voluntary decision-making.', 'Informed Consent', 72),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The patient asks: "What happens if I don''t sign?" Nurse should:', '[{"id":"a","text":"Explain consequences independently"},{"id":"b","text":"Support patient''s right to refuse and notify provider"},{"id":"c","text":"Encourage signing"},{"id":"d","text":"Avoid answering"}]'::jsonb, ARRAY['b'], false, 'The nurse supports the right to refuse and notifies the provider to explain consequences.', 'Informed Consent', 73),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which indicates patient competency?', '[{"id":"a","text":"Calm appearance"},{"id":"b","text":"Alert and oriented"},{"id":"c","text":"Family agreement"},{"id":"d","text":"Signed paper"}]'::jsonb, ARRAY['b'], false, 'Competency is indicated by being alert and oriented, not appearance or signatures.', 'Informed Consent', 74),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which scenario requires stopping consent immediately?', '[{"id":"a","text":"Patient yawns"},{"id":"b","text":"Patient confused"},{"id":"c","text":"Patient asks questions"},{"id":"d","text":"Patient smiles"}]'::jsonb, ARRAY['b'], false, 'Confusion invalidates consent and requires immediately stopping the process.', 'Informed Consent', 75),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Nurse documentation must include:', '[{"id":"a","text":"Only signature"},{"id":"b","text":"Nurse opinion"},{"id":"c","text":"Date/time + summary + questions + competency"},{"id":"d","text":"Family comments only"}]'::jsonb, ARRAY['c'], false, 'Complete documentation includes date/time, education summary, questions addressed, and competency assessment.', 'Informed Consent', 76),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient says "I feel forced." Nurse should:', '[{"id":"a","text":"Proceed"},{"id":"b","text":"Notify provider"},{"id":"c","text":"Ignore"},{"id":"d","text":"Ask family to explain"}]'::jsonb, ARRAY['b'], false, 'Any statement indicating feeling forced compromises voluntariness and requires provider notification.', 'Informed Consent', 77),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The nurse cannot:', '[{"id":"a","text":"Reinforce explanation"},{"id":"b","text":"Encourage questions"},{"id":"c","text":"Obtain informed consent"},{"id":"d","text":"Witness signature"}]'::jsonb, ARRAY['c'], false, 'The nurse cannot obtain informed consent—that is the provider\'s exclusive role.', 'Informed Consent', 78),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which best supports ethical autonomy?', '[{"id":"a","text":"Family decision"},{"id":"b","text":"Patient voluntary decision"},{"id":"c","text":"Nurse recommendation"},{"id":"d","text":"Provider pressure"}]'::jsonb, ARRAY['b'], false, 'Autonomy is best supported by the patient making their own voluntary decision without external pressure.', 'Informed Consent', 79),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient signs but later says they misunderstood risks. Nurse should:', '[{"id":"a","text":"Ignore"},{"id":"b","text":"Notify provider immediately"},{"id":"c","text":"Tell patient it''s too late"},{"id":"d","text":"Ask family"}]'::jsonb, ARRAY['b'], false, 'Misunderstanding of risks invalidates consent even after signing. Provider must be notified immediately.', 'Informed Consent', 80),

-- Questions 81-90: Competency & Validity Assessment
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which patient can legally sign?', '[{"id":"a","text":"Confused"},{"id":"b","text":"Sedated"},{"id":"c","text":"Alert, competent, voluntary"},{"id":"d","text":"Intoxicated"}]'::jsonb, ARRAY['c'], false, 'Valid consent requires the patient to be alert, competent, and signing voluntarily without coercion.', 'Informed Consent', 81),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Nurse witnesses signature but patient was not oriented earlier. Action?', '[{"id":"a","text":"Accept"},{"id":"b","text":"Reassess orientation before witnessing"},{"id":"c","text":"Ignore"},{"id":"d","text":"Ask CNA"}]'::jsonb, ARRAY['b'], false, 'Current orientation must be verified before witnessing. Reassessment is required.', 'Informed Consent', 82),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'What makes consent ethically valid?', '[{"id":"a","text":"Signature"},{"id":"b","text":"Provider presence"},{"id":"c","text":"Understanding + voluntariness + competency"},{"id":"d","text":"Family agreement"}]'::jsonb, ARRAY['c'], false, 'Ethical validity requires understanding, voluntariness, and competency—not just a signature.', 'Informed Consent', 83),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Patient hesitant but signs quickly. Nurse should:', '[{"id":"a","text":"Accept signature"},{"id":"b","text":"Pause and reassess voluntariness"},{"id":"c","text":"File consent"},{"id":"d","text":"Ignore"}]'::jsonb, ARRAY['b'], false, 'Hesitancy followed by quick signing may indicate pressure. Voluntariness must be reassessed.', 'Informed Consent', 84),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A patient wants family to decide. Nurse should:', '[{"id":"a","text":"Encourage autonomy"},{"id":"b","text":"Accept family decision automatically"},{"id":"c","text":"Decide for patient"},{"id":"d","text":"Ignore"}]'::jsonb, ARRAY['a'], false, 'The nurse should encourage patient autonomy and independent decision-making when appropriate.', 'Informed Consent', 85),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which invalidates consent?', '[{"id":"a","text":"Anxiety"},{"id":"b","text":"Nervousness"},{"id":"c","text":"Coercion"},{"id":"d","text":"Silence"}]'::jsonb, ARRAY['c'], false, 'Coercion invalidates consent by compromising voluntariness. Some anxiety/nervousness is normal.', 'Informed Consent', 86),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Patient under anesthesia cannot consent because:', '[{"id":"a","text":"Fear"},{"id":"b","text":"Lack of voluntariness"},{"id":"c","text":"Lack of competency due to sedation"},{"id":"d","text":"Time constraint"}]'::jsonb, ARRAY['c'], false, 'Anesthesia/sedation eliminates competency, making consent impossible.', 'Informed Consent', 87),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Nurse''s first step if unsure about validity:', '[{"id":"a","text":"Witness anyway"},{"id":"b","text":"Notify provider"},{"id":"c","text":"Ignore"},{"id":"d","text":"Ask family"}]'::jsonb, ARRAY['b'], false, 'When in doubt about consent validity, the nurse must notify the provider.', 'Informed Consent', 88),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Interpreter ensures:', '[{"id":"a","text":"Faster process"},{"id":"b","text":"Legal compliance and accurate understanding"},{"id":"c","text":"Nurse convenience"},{"id":"d","text":"Family involvement"}]'::jsonb, ARRAY['b'], false, 'Professional interpreters ensure legal compliance and accurate patient understanding.', 'Informed Consent', 89),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'The nurse must verify:', '[{"id":"a","text":"Provider explained procedure"},{"id":"b","text":"Nurse explained procedure"},{"id":"c","text":"Family explained"},{"id":"d","text":"CNA explained"}]'::jsonb, ARRAY['a'], false, 'The nurse verifies that the provider (not nurse, family, or CNA) explained the procedure.', 'Informed Consent', 90),

-- Questions 91-100: Critical Decision Points
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Patient says "I changed my mind." Nurse should:', '[{"id":"a","text":"Respect decision and notify provider"},{"id":"b","text":"Encourage proceeding"},{"id":"c","text":"Ignore"},{"id":"d","text":"Ask family"}]'::jsonb, ARRAY['a'], false, 'The patient has the right to withdraw consent. The nurse respects this and notifies the provider.', 'Informed Consent', 91),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Consent must be:', '[{"id":"a","text":"Quick"},{"id":"b","text":"Signed"},{"id":"c","text":"Voluntary"},{"id":"d","text":"Silent"}]'::jsonb, ARRAY['c'], false, 'The most essential element of valid consent is that it must be voluntary.', 'Informed Consent', 92),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'If patient expresses doubt AFTER signing:', '[{"id":"a","text":"Ignore"},{"id":"b","text":"Notify provider immediately"},{"id":"c","text":"Continue"},{"id":"d","text":"Ask CNA"}]'::jsonb, ARRAY['b'], false, 'Doubt expressed after signing may indicate invalid consent. Provider must be notified immediately.', 'Informed Consent', 93),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Nurse reinforcing explanation should:', '[{"id":"a","text":"Add new risks not discussed"},{"id":"b","text":"Repeat and clarify provider''s information"},{"id":"c","text":"Replace provider"},{"id":"d","text":"Decide"}]'::jsonb, ARRAY['b'], false, 'Reinforcement means repeating and clarifying what the provider said, not adding new information.', 'Informed Consent', 94),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'A confused patient signs. Nurse witnesses. This is:', '[{"id":"a","text":"Valid"},{"id":"b","text":"Invalid"},{"id":"c","text":"Optional"},{"id":"d","text":"Legal"}]'::jsonb, ARRAY['b'], false, 'A confused patient lacks competency. Witnessing such a signature results in invalid consent.', 'Informed Consent', 95),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which is nurse boundary violation?', '[{"id":"a","text":"Encouraging questions"},{"id":"b","text":"Obtaining consent"},{"id":"c","text":"Witnessing signature"},{"id":"d","text":"Using interpreter"}]'::jsonb, ARRAY['b'], false, 'Obtaining informed consent violates nurse boundaries—that is the provider\'s exclusive role.', 'Informed Consent', 96),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which demonstrates advocacy?', '[{"id":"a","text":"Speeding process"},{"id":"b","text":"Ignoring confusion"},{"id":"c","text":"Ensuring patient feels safe asking questions"},{"id":"d","text":"Persuading patient"}]'::jsonb, ARRAY['c'], false, 'Advocacy includes creating a safe environment where patients feel comfortable asking questions.', 'Informed Consent', 97),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Patient appears pressured. Nurse should:', '[{"id":"a","text":"Proceed"},{"id":"b","text":"Assess voluntariness and notify provider"},{"id":"c","text":"Ask family"},{"id":"d","text":"Ignore"}]'::jsonb, ARRAY['b'], false, 'Signs of pressure require assessment of voluntariness and provider notification.', 'Informed Consent', 98),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Incomplete consent form requires:', '[{"id":"a","text":"Nurse correction"},{"id":"b","text":"Provider notification"},{"id":"c","text":"Family signature"},{"id":"d","text":"Immediate filing"}]'::jsonb, ARRAY['b'], false, 'An incomplete form must be corrected by the provider, not the nurse.', 'Informed Consent', 99),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'Which is the most accurate statement?', '[{"id":"a","text":"Nurse obtains consent"},{"id":"b","text":"Provider obtains consent; nurse witnesses and advocates"},{"id":"c","text":"Family interprets always"},{"id":"d","text":"Consent valid under sedation"}]'::jsonb, ARRAY['b'], false, 'The provider obtains informed consent. The nurse witnesses the signature and advocates for the patient.', 'Informed Consent', 100);

-- ============================================
-- VERIFICATION
-- ============================================

-- Show total question count for Nurse's Role in Informed Consent topic
SELECT 
  t.name as topic_name,
  COUNT(q.id) as total_questions
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id 
  AND q.test_id = '00000000-0000-0000-0000-000000000001'
WHERE t.id = '20000000-0000-0000-0000-000000000002'
GROUP BY t.id, t.name;
-- Expected: Nurse's Role in Informed Consent with 100 questions (50 original + 50 new)

-- Verify display_order range
SELECT 
  MIN(display_order) as first_question,
  MAX(display_order) as last_question,
  COUNT(*) as total_count
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000002';
-- Expected: 1 to 100, count = 100
