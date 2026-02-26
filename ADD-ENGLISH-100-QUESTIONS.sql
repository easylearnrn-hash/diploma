-- ============================================
-- ENGLISH - 100 QUESTIONS
-- Test ID: 00000000-0000-0000-0000-000000000025
-- Subject ID: 10000000-0000-0000-0000-000000000025
-- Run AFTER ADD-ENGLISH-SUBJECT.sql
-- ============================================
-- Topic ID map:
--   Conjunctions and Connectors            → ...0396 (Q1–Q12)
--   Clauses, Modifiers, and Negation       → ...0397 (Q13–Q25)
--   Parallel Structure and Voice           → ...0398 (Q26–Q35)
--   Clinical English Terminology           → ...0399 (Q36–Q55)
--   Clinical Abbreviations in Context      → ...0400 (Q56–Q65)
--   Clinical Scenario Reading I            → ...0401 (Q66–Q80)
--   Clinical Scenario Reading II           → ...0402 (Q81–Q92)
--   Professional Nursing Communication     → ...0403 (Q93–Q100)
-- ============================================

-- Prevent duplicate runs
DELETE FROM test_questions
WHERE test_id = '00000000-0000-0000-0000-000000000025';

INSERT INTO test_questions
  (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order)
VALUES

-- =============================================
-- TOPIC 1: Conjunctions and Connectors (Q1–Q12)
-- =============================================

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Choose the correct conjunction: "The patient was in pain, _______ she refused pain medication."',
 '[{"id":"a","text":"but"},{"id":"b","text":"so"},{"id":"c","text":"or"},{"id":"d","text":"for"}]'::jsonb,
 ARRAY['a'], false,
 '"But" is a coordinating conjunction showing contrast — the patient''s refusal contradicts her pain.',
 'Conjunctions and Connectors', 1),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Which word best completes the sentence? "The nurse checked the IV site _______ administering the medication."',
 '[{"id":"a","text":"after"},{"id":"b","text":"before"},{"id":"c","text":"although"},{"id":"d","text":"unless"}]'::jsonb,
 ARRAY['b'], false,
 '"Before" is the correct subordinating conjunction: the IV site must be checked prior to administration.',
 'Conjunctions and Connectors', 2),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Identify the coordinating conjunction: "The doctor ordered an X-ray, yet the patient declined."',
 '[{"id":"a","text":"ordered"},{"id":"b","text":"yet"},{"id":"c","text":"declined"},{"id":"d","text":"doctor"}]'::jsonb,
 ARRAY['b'], false,
 '"Yet" is a coordinating conjunction (FANBOYS: For, And, Nor, But, Or, Yet, So) expressing contrast.',
 'Conjunctions and Connectors', 3),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Which sentence uses "although" correctly?',
 '[{"id":"a","text":"Although gave the medication."},{"id":"b","text":"Although the patient was anxious, she cooperated with the procedure."},{"id":"c","text":"The nurse although documented the vitals."},{"id":"d","text":"Although, the doctor arrived."}]'::jsonb,
 ARRAY['b'], false,
 '"Although" is a subordinating conjunction that introduces a dependent clause, followed by the main clause.',
 'Conjunctions and Connectors', 4),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Which connective word shows a RESULT?',
 '[{"id":"a","text":"however"},{"id":"b","text":"although"},{"id":"c","text":"therefore"},{"id":"d","text":"unless"}]'::jsonb,
 ARRAY['c'], false,
 '"Therefore" is a conjunctive adverb showing result or conclusion. "However" shows contrast; "although" shows concession; "unless" shows condition.',
 'Conjunctions and Connectors', 5),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 '"The patient is febrile; _______, the nurse will reassess in one hour." Which word fits best?',
 '[{"id":"a","text":"but"},{"id":"b","text":"consequently"},{"id":"c","text":"or"},{"id":"d","text":"unless"}]'::jsonb,
 ARRAY['b'], false,
 '"Consequently" correctly links the cause (fever) to the logical result (reassessment). It follows a semicolon as a conjunctive adverb.',
 'Conjunctions and Connectors', 6),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Which sentence uses "nor" correctly?',
 '[{"id":"a","text":"Neither the BP nor the pulse was documented."},{"id":"b","text":"The nurse nor gave the medication."},{"id":"c","text":"Nor the patient responded."},{"id":"d","text":"The patient nor doctor agree."}]'::jsonb,
 ARRAY['a'], false,
 '"Nor" is used with "neither" in correlative conjunction pairs: "neither...nor". It correctly links two negative subjects.',
 'Conjunctions and Connectors', 7),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 '"She will take the medication _______ the doctor approves it." Which word shows condition?',
 '[{"id":"a","text":"and"},{"id":"b","text":"but"},{"id":"c","text":"if"},{"id":"d","text":"yet"}]'::jsonb,
 ARRAY['c'], false,
 '"If" is a subordinating conjunction that introduces a conditional clause — action depends on a condition being met.',
 'Conjunctions and Connectors', 8),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Which word shows CONTRAST between two independent clauses joined by a semicolon?',
 '[{"id":"a","text":"furthermore"},{"id":"b","text":"meanwhile"},{"id":"c","text":"however"},{"id":"d","text":"similarly"}]'::jsonb,
 ARRAY['c'], false,
 '"However" is a conjunctive adverb expressing contrast. "Furthermore" adds information; "meanwhile" shows time; "similarly" shows comparison.',
 'Conjunctions and Connectors', 9),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 '"The nurse washed her hands _______ donning gloves." Which preposition/conjunction is correct?',
 '[{"id":"a","text":"after"},{"id":"b","text":"before"},{"id":"c","text":"while"},{"id":"d","text":"unless"}]'::jsonb,
 ARRAY['b'], false,
 'Hand hygiene occurs BEFORE donning gloves. "Before" correctly expresses the chronological order of events.',
 'Conjunctions and Connectors', 10),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Select the sentence that uses "so that" correctly.',
 '[{"id":"a","text":"The nurse elevated the head of the bed so that the patient could breathe more easily."},{"id":"b","text":"So that the patient slept."},{"id":"c","text":"The nurse so that documented the note."},{"id":"d","text":"So that, she administered oxygen."}]'::jsonb,
 ARRAY['a'], false,
 '"So that" introduces a purpose clause. The main clause must come first, then "so that" + dependent clause expressing the intended outcome.',
 'Conjunctions and Connectors', 11),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000396',
 'Which pair of correlative conjunctions is CORRECT?',
 '[{"id":"a","text":"either...or"},{"id":"b","text":"either...nor"},{"id":"c","text":"both...or"},{"id":"d","text":"neither...and"}]'::jsonb,
 ARRAY['a'], false,
 'Correct correlative conjunction pairs: either...or, neither...nor, both...and, not only...but also.',
 'Conjunctions and Connectors', 12),

-- =============================================
-- TOPIC 2: Clauses, Modifiers, and Negation (Q13–Q25)
-- =============================================

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Identify the dependent clause: "The nurse called the doctor because the patient''s BP dropped suddenly."',
 '[{"id":"a","text":"The nurse called the doctor"},{"id":"b","text":"because the patient''s BP dropped suddenly"},{"id":"c","text":"the patient''s BP"},{"id":"d","text":"dropped suddenly"}]'::jsonb,
 ARRAY['b'], false,
 'A dependent clause begins with a subordinating conjunction ("because") and cannot stand alone as a complete sentence.',
 'Clauses, Modifiers, and Negation', 13),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Which sentence contains a dangling modifier?',
 '[{"id":"a","text":"Running down the hall, the nurse tripped."},{"id":"b","text":"Running down the hall, the medication fell off the tray."},{"id":"c","text":"The nurse, running down the hall, reached the patient."},{"id":"d","text":"The nurse ran down the hall quickly."}]'::jsonb,
 ARRAY['b'], false,
 'In option B, "running down the hall" modifies "the medication," which cannot run — the subject performing the action is missing.',
 'Clauses, Modifiers, and Negation', 14),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Which sentence contains a double negative error?',
 '[{"id":"a","text":"The patient does not have any allergies."},{"id":"b","text":"The patient doesn''t have no allergies."},{"id":"c","text":"The nurse did not administer the medication."},{"id":"d","text":"There are no documented allergies."}]'::jsonb,
 ARRAY['b'], false,
 '"Doesn''t" + "no" creates a double negative. The correct form is "doesn''t have any allergies" or "has no allergies."',
 'Clauses, Modifiers, and Negation', 15),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Which sentence correctly places the modifier?',
 '[{"id":"a","text":"The nurse only gave the patient two pills."},{"id":"b","text":"The nurse gave the patient only two pills."},{"id":"c","text":"Only the nurse gave the patient two pills."},{"id":"d","text":"The nurse gave only the patient two pills."}]'::jsonb,
 ARRAY['b'], false,
 '"Only" should be placed directly before "two pills" to clearly indicate the quantity is what is limited, not the patient or the nurse.',
 'Clauses, Modifiers, and Negation', 16),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'What is the independent clause in: "Even though the patient refused surgery, the doctor explained the risks again."',
 '[{"id":"a","text":"Even though the patient refused surgery"},{"id":"b","text":"the doctor explained the risks again"},{"id":"c","text":"the patient refused"},{"id":"d","text":"Even though the patient refused surgery, the doctor"}]'::jsonb,
 ARRAY['b'], false,
 '"The doctor explained the risks again" is the independent clause — it can stand alone as a complete sentence.',
 'Clauses, Modifiers, and Negation', 17),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 '"Administered by the nurse, the patient felt relief within minutes." What is wrong with this sentence?',
 '[{"id":"a","text":"Nothing — it is correct."},{"id":"b","text":"Dangling modifier — the patient was not administered."},{"id":"c","text":"It is missing a conjunction."},{"id":"d","text":"It uses passive voice incorrectly."}]'::jsonb,
 ARRAY['b'], false,
 'The participial phrase "Administered by the nurse" dangles — it must modify the subject immediately following it, but "the patient" was not administered.',
 'Clauses, Modifiers, and Negation', 18),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Which sentence negates correctly in clinical writing?',
 '[{"id":"a","text":"No edema was not observed."},{"id":"b","text":"Edema was not observed."},{"id":"c","text":"No edema wasn''t observed."},{"id":"d","text":"Edema wasn''t not present."}]'::jsonb,
 ARRAY['b'], false,
 '"Edema was not observed" uses a single negative correctly. All other options contain double negatives, which are grammatically incorrect.',
 'Clauses, Modifiers, and Negation', 19),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Identify the relative clause: "The patient who was admitted last night has pneumonia."',
 '[{"id":"a","text":"The patient"},{"id":"b","text":"who was admitted last night"},{"id":"c","text":"has pneumonia"},{"id":"d","text":"was admitted"}]'::jsonb,
 ARRAY['b'], false,
 '"Who was admitted last night" is a relative clause — it begins with the relative pronoun "who" and modifies "the patient."',
 'Clauses, Modifiers, and Negation', 20),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Which sentence has a MISPLACED modifier?',
 '[{"id":"a","text":"The nurse saw a patient walking to the supply room."},{"id":"b","text":"Walking to the supply room, the nurse saw a patient."},{"id":"c","text":"The nurse found the patient sleeping in the hallway."},{"id":"d","text":"The patient was sleeping when the nurse arrived."}]'::jsonb,
 ARRAY['a'], false,
 'In option A, "walking to the supply room" is ambiguous — it could modify either "the nurse" or "a patient." Option B correctly places the modifier next to "the nurse."',
 'Clauses, Modifiers, and Negation', 21),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Choose the correct form: "She _______ received the test results yet."',
 '[{"id":"a","text":"hasn''t"},{"id":"b","text":"hasn''t not"},{"id":"c","text":"didn''t not"},{"id":"d","text":"hasn''t never"}]'::jsonb,
 ARRAY['a'], false,
 '"Hasn''t" is the correct negative auxiliary. Adding "not," "never," or additional negatives creates a double negative.',
 'Clauses, Modifiers, and Negation', 22),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Which sentence uses a subordinate clause correctly?',
 '[{"id":"a","text":"When the nurse arrived."},{"id":"b","text":"Because the patient was in pain."},{"id":"c","text":"The patient reported pain when the nurse arrived for assessment."},{"id":"d","text":"Although the medication."}]'::jsonb,
 ARRAY['c'], false,
 'A subordinate clause must be attached to an independent clause. Option C is the only complete sentence with both a main clause and a correctly placed subordinate clause.',
 'Clauses, Modifiers, and Negation', 23),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 '"Looking at the wound, it appeared infected." This sentence is an example of:',
 '[{"id":"a","text":"Passive voice"},{"id":"b","text":"A dangling modifier"},{"id":"c","text":"A relative clause"},{"id":"d","text":"Correct clinical documentation"}]'::jsonb,
 ARRAY['b'], false,
 '"Looking at the wound" dangles — the subject "it" (the wound) cannot look. The corrected form: "Looking at the wound, the nurse noted it appeared infected."',
 'Clauses, Modifiers, and Negation', 24),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000397',
 'Which is a FRAGMENT (incomplete sentence)?',
 '[{"id":"a","text":"The patient tolerated the procedure well."},{"id":"b","text":"After the medication was administered."},{"id":"c","text":"The nurse documented the assessment findings."},{"id":"d","text":"Vital signs were stable throughout the procedure."}]'::jsonb,
 ARRAY['b'], false,
 '"After the medication was administered" is a dependent clause that cannot stand alone — it is a sentence fragment.',
 'Clauses, Modifiers, and Negation', 25),

-- =============================================
-- TOPIC 3: Parallel Structure and Voice (Q26–Q35)
-- =============================================

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'Which sentence demonstrates correct parallel structure?',
 '[{"id":"a","text":"The nurse assessed, documenting, and reported the findings."},{"id":"b","text":"The nurse assessed, documented, and reported the findings."},{"id":"c","text":"The nurse assessing, documented, and to report the findings."},{"id":"d","text":"The nurse assessed, to document, and reporting the findings."}]'::jsonb,
 ARRAY['b'], false,
 'Parallel structure requires all verbs to be in the same form. "Assessed, documented, and reported" are all simple past tense verbs.',
 'Parallel Structure and Voice', 26),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'Which sentence is written in PASSIVE voice?',
 '[{"id":"a","text":"The nurse administered the medication at 0800."},{"id":"b","text":"The medication was administered by the nurse at 0800."},{"id":"c","text":"The nurse gave the patient pain medication."},{"id":"d","text":"The patient received excellent care."}]'::jsonb,
 ARRAY['b'], false,
 'Passive voice: the subject receives the action ("medication was administered"). Active voice: the subject performs the action ("nurse administered").',
 'Parallel Structure and Voice', 27),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'Identify the parallel structure error: "Her responsibilities included bathing patients, to administer medications, and documentation."',
 '[{"id":"a","text":"bathing patients"},{"id":"b","text":"to administer medications"},{"id":"c","text":"documentation"},{"id":"d","text":"Both B and C break parallel structure"}]'::jsonb,
 ARRAY['d'], false,
 '"Bathing" is a gerund; "to administer" is an infinitive; "documentation" is a noun. Correct parallel form: "bathing patients, administering medications, and documenting care."',
 'Parallel Structure and Voice', 28),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'Which sentence is preferred in nursing documentation?',
 '[{"id":"a","text":"The patient was seen by the nurse."},{"id":"b","text":"The nurse assessed the patient."},{"id":"c","text":"An assessment was performed."},{"id":"d","text":"The patient was assessed."}]'::jsonb,
 ARRAY['b'], false,
 'Active voice is clearer in nursing documentation. "The nurse assessed the patient" directly identifies who performed the action.',
 'Parallel Structure and Voice', 29),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'Choose the sentence with CORRECT parallel structure in a list.',
 '[{"id":"a","text":"Patient education included diet, to exercise, and medications."},{"id":"b","text":"Patient education included diet, exercise, and medications."},{"id":"c","text":"Patient education included diet, exercising, and medications."},{"id":"d","text":"Patient education included dietary, exercise, and medication."}]'::jsonb,
 ARRAY['b'], false,
 'Option B uses three parallel nouns: diet, exercise, medications. All other options mix different grammatical forms.',
 'Parallel Structure and Voice', 30),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'When is passive voice ACCEPTABLE in clinical writing?',
 '[{"id":"a","text":"Never — always use active voice."},{"id":"b","text":"When the focus is on the action rather than who performed it."},{"id":"c","text":"Only when the nurse made an error."},{"id":"d","text":"Only in informal notes."}]'::jsonb,
 ARRAY['b'], false,
 'Passive voice is acceptable when the focus is on what was done to the patient ("Medication was discontinued") rather than who did it.',
 'Parallel Structure and Voice', 31),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 '"The team will interview the patient, review the labs, and to develop a care plan." What is the error?',
 '[{"id":"a","text":"Wrong tense"},{"id":"b","text":"Missing subject"},{"id":"c","text":"Broken parallel structure — to develop should be develop"},{"id":"d","text":"Passive voice"}]'::jsonb,
 ARRAY['c'], false,
 'The list uses future tense base verbs: "will interview, review, and develop." Adding "to" before "develop" breaks the parallel structure.',
 'Parallel Structure and Voice', 32),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'Convert to active voice: "The dressing was changed by the charge nurse every morning."',
 '[{"id":"a","text":"Every morning, the dressing was changed."},{"id":"b","text":"The charge nurse changed the dressing every morning."},{"id":"c","text":"The dressing got changed every morning."},{"id":"d","text":"Changed every morning was the dressing."}]'::jsonb,
 ARRAY['b'], false,
 'Active voice: subject (charge nurse) + verb (changed) + object (dressing). Clear, direct, and preferred in documentation.',
 'Parallel Structure and Voice', 33),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'Which sentence uses parallel structure with correlative conjunctions correctly?',
 '[{"id":"a","text":"The patient was not only tired but also experiencing nausea."},{"id":"b","text":"The patient was not only tired but also nauseous."},{"id":"c","text":"The patient was not only tiring but also nauseated."},{"id":"d","text":"The patient not only tired but nausea."}]'::jsonb,
 ARRAY['b'], false,
 '"Not only...but also" must connect grammatically parallel elements. "Tired" and "nauseous" are both adjectives — correct parallel structure.',
 'Parallel Structure and Voice', 34),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000398',
 'Which sentence correctly uses parallel structure with gerunds?',
 '[{"id":"a","text":"Her job involves assessing patients, to administer drugs, and education."},{"id":"b","text":"Her job involves assessing patients, administering drugs, and educating families."},{"id":"c","text":"Her job involves to assess, administer, and educate."},{"id":"d","text":"Her job is assessment, administer, and to educate."}]'::jsonb,
 ARRAY['b'], false,
 'All three items use the gerund (-ing) form: assessing, administering, educating — consistent and parallel.',
 'Parallel Structure and Voice', 35),

-- =============================================
-- TOPIC 4: Clinical English Terminology (Q36–Q55)
-- =============================================

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'A patient is described as "febrile." This means the patient:',
 '[{"id":"a","text":"Is cold"},{"id":"b","text":"Has a fever"},{"id":"c","text":"Is sweating"},{"id":"d","text":"Has low blood pressure"}]'::jsonb,
 ARRAY['b'], false,
 '"Febrile" means having a fever (temperature ≥ 38°C / 100.4°F). "Afebrile" means without fever.',
 'Clinical English Terminology', 36),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'A patient experiences "orthostatic hypotension." What does this mean?',
 '[{"id":"a","text":"High BP when lying flat"},{"id":"b","text":"BP drop when standing up"},{"id":"c","text":"Normal BP with position changes"},{"id":"d","text":"BP drop during sleep"}]'::jsonb,
 ARRAY['b'], false,
 'Orthostatic hypotension is a significant drop in BP (≥20 mmHg systolic) upon standing, causing dizziness or fainting.',
 'Clinical English Terminology', 37),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'The order reads "NPO after midnight." This means:',
 '[{"id":"a","text":"Nothing by mouth — no food or drink"},{"id":"b","text":"No pain ordered"},{"id":"c","text":"Normal procedure ordered"},{"id":"d","text":"Nurse to provide oxygen"}]'::jsonb,
 ARRAY['a'], false,
 'NPO = Nil Per Os (Latin: nothing by mouth). The patient must not eat or drink anything after the specified time.',
 'Clinical English Terminology', 38),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'A medication is ordered "PRN." The nurse should give it:',
 '[{"id":"a","text":"Every day"},{"id":"b","text":"As needed"},{"id":"c","text":"Before meals"},{"id":"d","text":"At bedtime"}]'::jsonb,
 ARRAY['b'], false,
 'PRN = Pro Re Nata (Latin: as needed). The medication is given when the patient requires it based on clinical judgment.',
 'Clinical English Terminology', 39),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'A patient''s heart rate is 112 bpm. The correct clinical term is:',
 '[{"id":"a","text":"Bradycardia"},{"id":"b","text":"Normocardic"},{"id":"c","text":"Tachycardia"},{"id":"d","text":"Dysrhythmia"}]'::jsonb,
 ARRAY['c'], false,
 'Tachycardia is defined as a heart rate > 100 bpm. Bradycardia is < 60 bpm.',
 'Clinical English Terminology', 40),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'The term "dyspnea" refers to:',
 '[{"id":"a","text":"Chest pain"},{"id":"b","text":"Difficulty breathing"},{"id":"c","text":"Rapid breathing"},{"id":"d","text":"Painful swallowing"}]'::jsonb,
 ARRAY['b'], false,
 'Dyspnea means difficulty or labored breathing. Tachypnea = rapid breathing; dysphagia = difficulty swallowing.',
 'Clinical English Terminology', 41),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'A patient is described as "diaphoretic." What does this mean?',
 '[{"id":"a","text":"Confused"},{"id":"b","text":"Sweating profusely"},{"id":"c","text":"Unable to speak"},{"id":"d","text":"Having difficulty urinating"}]'::jsonb,
 ARRAY['b'], false,
 'Diaphoretic means profusely sweating, often associated with hypoglycemia, MI, or shock.',
 'Clinical English Terminology', 42),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'The documentation states the patient is "lethargic." This means the patient is:',
 '[{"id":"a","text":"Agitated and confused"},{"id":"b","text":"Alert and oriented"},{"id":"c","text":"Abnormally drowsy and sluggish"},{"id":"d","text":"Completely unresponsive"}]'::jsonb,
 ARRAY['c'], false,
 'Lethargy is a state of abnormal drowsiness, sluggishness, and reduced responsiveness — greater than normal sleep but still arousable.',
 'Clinical English Terminology', 43),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'A wound is described as having "purulent drainage." This means:',
 '[{"id":"a","text":"Clear and watery drainage"},{"id":"b","text":"Bloody drainage"},{"id":"c","text":"Thick, cloudy, pus-like drainage"},{"id":"d","text":"Pink-tinged serous drainage"}]'::jsonb,
 ARRAY['c'], false,
 'Purulent drainage is thick, opaque, and pus-like — indicating infection. Serous = clear/watery; sanguineous = bloody; serosanguineous = pink-tinged.',
 'Clinical English Terminology', 44),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 '"The patient is afebrile" means:',
 '[{"id":"a","text":"Has a high fever"},{"id":"b","text":"Has no fever"},{"id":"c","text":"Has chills"},{"id":"d","text":"Temperature is rising"}]'::jsonb,
 ARRAY['b'], false,
 'The prefix "a-" means without. Afebrile = without fever. Temperature is within normal range.',
 'Clinical English Terminology', 45),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'The term "emesis" means:',
 '[{"id":"a","text":"Urination"},{"id":"b","text":"Defecation"},{"id":"c","text":"Vomiting"},{"id":"d","text":"Expectoration"}]'::jsonb,
 ARRAY['c'], false,
 'Emesis means vomiting or vomited matter. Expectoration is coughing up sputum from the respiratory tract.',
 'Clinical English Terminology', 46),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 '"Ambulate the patient TID." In clinical English, this means:',
 '[{"id":"a","text":"Turn the patient three times daily"},{"id":"b","text":"Walk the patient three times daily"},{"id":"c","text":"Bathe the patient at three set times"},{"id":"d","text":"Assess the patient three times daily"}]'::jsonb,
 ARRAY['b'], false,
 'Ambulate means to walk. TID = ter in die (Latin: three times a day). Ambulate TID = walk the patient three times daily.',
 'Clinical English Terminology', 47),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'A patient is "obtunded." This level of consciousness means:',
 '[{"id":"a","text":"Alert and fully oriented"},{"id":"b","text":"Confused but arousable"},{"id":"c","text":"Difficult to arouse, reduced response to stimuli"},{"id":"d","text":"No response to any stimulus"}]'::jsonb,
 ARRAY['c'], false,
 'Obtunded describes significantly reduced alertness — the patient requires vigorous stimuli to respond. Levels: alert → lethargic → obtunded → stuporous → comatose.',
 'Clinical English Terminology', 48),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'The chart note reads "Patient c/o chest pain." What does "c/o" mean?',
 '[{"id":"a","text":"Complains of"},{"id":"b","text":"Correction of"},{"id":"c","text":"Care of"},{"id":"d","text":"Comparison of"}]'::jsonb,
 ARRAY['a'], false,
 '"c/o" is the standard nursing abbreviation for "complains of" — used to document a patient''s subjective symptoms.',
 'Clinical English Terminology', 49),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 '"The incision is approximated." In clinical English this means:',
 '[{"id":"a","text":"The wound edges are separated"},{"id":"b","text":"The wound edges are close together, well-healed"},{"id":"c","text":"The wound is infected"},{"id":"d","text":"The wound needs debridement"}]'::jsonb,
 ARRAY['b'], false,
 '"Approximated" in wound assessment means the wound edges are aligned and touching, indicating proper healing.',
 'Clinical English Terminology', 50),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'A patient is described as "somnolent." This means:',
 '[{"id":"a","text":"Unable to breathe"},{"id":"b","text":"Excessively sleepy but arousable"},{"id":"c","text":"Unconscious"},{"id":"d","text":"Restless and agitated"}]'::jsonb,
 ARRAY['b'], false,
 'Somnolent means excessively drowsy or sleepy but capable of being awakened. It is a level above lethargic.',
 'Clinical English Terminology', 51),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'The term "pruritus" means:',
 '[{"id":"a","text":"Rash"},{"id":"b","text":"Itching"},{"id":"c","text":"Swelling"},{"id":"d","text":"Pain"}]'::jsonb,
 ARRAY['b'], false,
 'Pruritus is the medical term for itching, commonly associated with allergic reactions, liver disease, or skin conditions.',
 'Clinical English Terminology', 52),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 '"Administer analgesic PRN for pain rated ≥ 5/10." The nurse should give the medication:',
 '[{"id":"a","text":"Every 4 hours regardless of pain level"},{"id":"b","text":"Only when the patient reports pain of 5 or more out of 10"},{"id":"c","text":"Before meals"},{"id":"d","text":"Only at night"}]'::jsonb,
 ARRAY['b'], false,
 'PRN means as needed. The threshold stated is pain ≥ 5/10 — the nurse gives the analgesic only when the patient reports meeting this criterion.',
 'Clinical English Terminology', 53),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 '"Patient is A&O ×3." This means the patient is:',
 '[{"id":"a","text":"Alert and oriented to person, place, and time"},{"id":"b","text":"Anxious and observed three times"},{"id":"c","text":"Awake and obeying three commands"},{"id":"d","text":"Assessed and ordered three medications"}]'::jsonb,
 ARRAY['a'], false,
 'A&O ×3 = Alert and Oriented × 3 (person, place, time). A&O ×4 adds event/situation.',
 'Clinical English Terminology', 54),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000399',
 'The phrase "bilateral lower extremity edema" describes:',
 '[{"id":"a","text":"Swelling in both legs"},{"id":"b","text":"Pain in the lower back"},{"id":"c","text":"Rash on both arms"},{"id":"d","text":"Bruising on both feet"}]'::jsonb,
 ARRAY['a'], false,
 'Bilateral = both sides; lower extremity = leg; edema = fluid swelling. The phrase means swelling in both legs.',
 'Clinical English Terminology', 55),

-- =============================================
-- TOPIC 5: Clinical Abbreviations in Context (Q56–Q65)
-- =============================================

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 '"Give acetaminophen 500 mg PO q4h PRN temp >38.5°C." In this order, PO means:',
 '[{"id":"a","text":"By injection"},{"id":"b","text":"By mouth"},{"id":"c","text":"Per rectum"},{"id":"d","text":"Topically"}]'::jsonb,
 ARRAY['b'], false,
 'PO = Per Os (Latin: by mouth). This is the most common oral medication route abbreviation.',
 'Clinical Abbreviations in Context', 56),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 'The order states "Vital signs q2h." How often should vitals be taken?',
 '[{"id":"a","text":"Every day"},{"id":"b","text":"Every 20 minutes"},{"id":"c","text":"Every 2 hours"},{"id":"d","text":"Twice daily"}]'::jsonb,
 ARRAY['c'], false,
 '"q" = every (from Latin "quaque"); q2h = every 2 hours.',
 'Clinical Abbreviations in Context', 57),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 '"Administer insulin AC." When should this be given?',
 '[{"id":"a","text":"After meals"},{"id":"b","text":"Before meals"},{"id":"c","text":"At bedtime"},{"id":"d","text":"With meals"}]'::jsonb,
 ARRAY['b'], false,
 'AC = ante cibum (Latin: before meals). PC = post cibum (after meals). HS = hora somni (at bedtime).',
 'Clinical Abbreviations in Context', 58),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 'The chart states "I&O q8h." What does I&O stand for?',
 '[{"id":"a","text":"Identify and observe"},{"id":"b","text":"Intake and output"},{"id":"c","text":"IV and oral"},{"id":"d","text":"Infection and observation"}]'::jsonb,
 ARRAY['b'], false,
 'I&O = Intake and Output. Nurses measure fluid intake (oral, IV) and output (urine, drainage) to monitor fluid balance.',
 'Clinical Abbreviations in Context', 59),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 '"STAT" on a medication order means:',
 '[{"id":"a","text":"Standard treatment"},{"id":"b","text":"Slowly titrate"},{"id":"c","text":"Immediately"},{"id":"d","text":"Stop the medication"}]'::jsonb,
 ARRAY['c'], false,
 'STAT = statim (Latin: immediately). A STAT order must be carried out at once due to urgency.',
 'Clinical Abbreviations in Context', 60),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 '"Metformin 500 mg PO BID with meals." How many times daily is this medication given?',
 '[{"id":"a","text":"Once daily"},{"id":"b","text":"Three times daily"},{"id":"c","text":"Four times daily"},{"id":"d","text":"Twice daily"}]'::jsonb,
 ARRAY['d'], false,
 'BID = bis in die (Latin: twice a day). The medication is given two times per day, with meals.',
 'Clinical Abbreviations in Context', 61),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 '"Restart PO fluids once patient is no longer NPO." This instruction means the patient may drink when:',
 '[{"id":"a","text":"The IV is removed"},{"id":"b","text":"The restriction to nothing by mouth is lifted"},{"id":"c","text":"Pain is controlled"},{"id":"d","text":"The patient asks for water"}]'::jsonb,
 ARRAY['b'], false,
 'NPO = nil per os (nothing by mouth). PO fluids restart only after the doctor lifts the NPO restriction.',
 'Clinical Abbreviations in Context', 62),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 '"SOB noted on ambulation." SOB in clinical context stands for:',
 '[{"id":"a","text":"Side of bed"},{"id":"b","text":"Shortness of breath"},{"id":"c","text":"Stable on breathing"},{"id":"d","text":"Status of blood"}]'::jsonb,
 ARRAY['b'], false,
 'SOB = Shortness of Breath. It is documented when a patient reports difficulty breathing, especially during activity.',
 'Clinical Abbreviations in Context', 63),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 '"Foley catheter to gravity drainage with q shift I&O." What does "q shift" mean?',
 '[{"id":"a","text":"Every hour"},{"id":"b","text":"Every day"},{"id":"c","text":"Each nursing shift"},{"id":"d","text":"When the patient requests"}]'::jsonb,
 ARRAY['c'], false,
 '"q shift" means each nursing shift (typically every 8–12 hours). I&O is recorded at each shift change.',
 'Clinical Abbreviations in Context', 64),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000400',
 '"Dressing change QD with NS irrigation." QD means:',
 '[{"id":"a","text":"Four times daily"},{"id":"b","text":"Every other day"},{"id":"c","text":"Once daily"},{"id":"d","text":"Twice daily"}]'::jsonb,
 ARRAY['c'], false,
 'QD = quaque die (Latin: once daily). Note: QD is on the JCAHO "Do Not Use" list due to confusion with QID — hospitals may require writing "daily" instead.',
 'Clinical Abbreviations in Context', 65),

-- =============================================
-- TOPIC 6: Clinical Scenario Reading I (Q66–Q80)
-- =============================================

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The nurse reads: "Patient is a 65-year-old male admitted for exacerbation of COPD. He is SOB at rest, SpO2 88% on room air." What is the PRIORITY nursing action?',
 '[{"id":"a","text":"Administer scheduled oral medications"},{"id":"b","text":"Apply supplemental oxygen and reassess SpO2"},{"id":"c","text":"Encourage oral fluids"},{"id":"d","text":"Obtain a urine sample"}]'::jsonb,
 ARRAY['b'], false,
 'SpO2 of 88% on room air indicates hypoxemia. The priority is to apply supplemental oxygen to raise saturation to ≥90–94% for COPD patients.',
 'Clinical Scenario Reading I', 66),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The shift note reads: "Patient is alert, oriented, and ambulating independently. No complaints. Vital signs stable. Skin intact. Appetite fair." Based on this note, the patient:',
 '[{"id":"a","text":"Requires immediate intervention"},{"id":"b","text":"Appears to be in stable condition"},{"id":"c","text":"Is confused and at fall risk"},{"id":"d","text":"Has wound drainage documented"}]'::jsonb,
 ARRAY['b'], false,
 'The note describes a stable, alert, mobile patient with no complaints and intact skin — indicating stable clinical status.',
 'Clinical Scenario Reading I', 67),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The doctor''s order reads: "If systolic BP drops below 90, give 500 mL NS bolus IV and notify physician." The patient''s current BP is 86/52. What should the nurse do?',
 '[{"id":"a","text":"Wait and recheck in one hour"},{"id":"b","text":"Administer the NS bolus and call the physician"},{"id":"c","text":"Elevate the patient''s head"},{"id":"d","text":"Give oral fluids"}]'::jsonb,
 ARRAY['b'], false,
 'The systolic BP (86) is below the threshold (90). The nurse must follow the conditional order: administer 500 mL NS bolus and notify the physician.',
 'Clinical Scenario Reading I', 68),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The nurse receives this handoff: "Room 204 is a post-op day 1 patient following appendectomy. She''s febrile at 38.7°C, reports pain 7/10, and has not voided since surgery." What requires the MOST immediate attention?',
 '[{"id":"a","text":"Pain management and urine output monitoring"},{"id":"b","text":"Immediate discharge planning"},{"id":"c","text":"Routine morning care"},{"id":"d","text":"Patient education about diet"}]'::jsonb,
 ARRAY['a'], false,
 'The patient has uncontrolled pain (7/10), fever (possible infection), and urinary retention — all require immediate attention. Pain and urinary output are the clinical priorities.',
 'Clinical Scenario Reading I', 69),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The nursing note states: "Patient verbalized understanding of insulin self-injection technique using teach-back." This phrase means:',
 '[{"id":"a","text":"The patient wrote a note about insulin"},{"id":"b","text":"The patient demonstrated and explained the technique back to the nurse"},{"id":"c","text":"The nurse injected insulin for the patient"},{"id":"d","text":"A video was shown to the patient"}]'::jsonb,
 ARRAY['b'], false,
 'Teach-back is a method where the patient demonstrates or explains the skill back to the nurse to confirm comprehension.',
 'Clinical Scenario Reading I', 70),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The MAR reads: "Lisinopril 10 mg PO daily. Hold if SBP < 100." The patient''s current SBP is 92 mmHg. What should the nurse do?',
 '[{"id":"a","text":"Administer the medication as scheduled"},{"id":"b","text":"Hold the medication and document the reason"},{"id":"c","text":"Crush and mix the medication with food"},{"id":"d","text":"Double the dose"}]'::jsonb,
 ARRAY['b'], false,
 'The hold parameter is SBP < 100. With an SBP of 92, the nurse must withhold lisinopril and document the clinical reason for holding.',
 'Clinical Scenario Reading I', 71),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'A patient says, "I feel like my heart is pounding and I can''t catch my breath." The nurse''s BEST initial response is:',
 '[{"id":"a","text":"I''ll get you some water."},{"id":"b","text":"Tell me more — when did this start and what were you doing?"},{"id":"c","text":"You''re probably just anxious."},{"id":"d","text":"I''ll call the doctor right away."}]'::jsonb,
 ARRAY['b'], false,
 'The nurse should gather more information using therapeutic communication before taking action. Asking about onset and activity helps assess urgency and guides intervention.',
 'Clinical Scenario Reading I', 72),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The care plan states: "Encourage fluid intake of at least 2000 mL/day unless contraindicated." The patient drank 800 mL during the day shift. How much more should the patient drink before midnight?',
 '[{"id":"a","text":"800 mL"},{"id":"b","text":"1200 mL"},{"id":"c","text":"2000 mL"},{"id":"d","text":"No more fluid needed"}]'::jsonb,
 ARRAY['b'], false,
 '2000 mL total − 800 mL consumed = 1200 mL remaining. The nurse should encourage this amount before the day ends.',
 'Clinical Scenario Reading I', 73),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The nursing report states: "Patient is non-compliant with low-sodium diet — ate fast food brought in by family." In professional clinical English, "non-compliant" should be replaced with:',
 '[{"id":"a","text":"Lazy"},{"id":"b","text":"Stubborn"},{"id":"c","text":"Did not adhere to the prescribed low-sodium diet"},{"id":"d","text":"Refused care"}]'::jsonb,
 ARRAY['c'], false,
 '"Non-compliant" is stigmatizing language. Professional clinical documentation uses objective, non-judgmental descriptions of behavior.',
 'Clinical Scenario Reading I', 74),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The order reads: "Ambulate patient in hallway BID with assistance as needed." The patient is anxious about falling. What is the BEST response?',
 '[{"id":"a","text":"Skip ambulation since the patient is scared."},{"id":"b","text":"Force the patient to walk regardless of fear."},{"id":"c","text":"Explain the benefits, address concerns, and ambulate with two-person assist if needed."},{"id":"d","text":"Document refusal and do nothing."}]'::jsonb,
 ARRAY['c'], false,
 'The nurse should provide patient education about ambulation benefits, acknowledge the patient''s concern, and offer physical support to promote safety and compliance.',
 'Clinical Scenario Reading I', 75),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The chart note reads: "Wound site without signs of infection: no redness, no warmth, no purulent drainage." What does this statement confirm?',
 '[{"id":"a","text":"The wound is infected"},{"id":"b","text":"The wound is showing signs of healing without infection"},{"id":"c","text":"The wound requires debridement"},{"id":"d","text":"The wound has serosanguineous drainage"}]'::jsonb,
 ARRAY['b'], false,
 'The absence of redness (erythema), warmth, and purulent discharge indicates the wound is not currently infected and is consistent with normal healing.',
 'Clinical Scenario Reading I', 76),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The doctor writes: "Patient may be discharged once tolerating PO, afebrile ×24h, and pain controlled on oral analgesics." The patient''s temperature has been normal for 18 hours. Is the patient ready for discharge?',
 '[{"id":"a","text":"Yes — afebrile for 18 hours is sufficient"},{"id":"b","text":"No — must remain afebrile for a full 24 hours"},{"id":"c","text":"Yes — if pain is controlled"},{"id":"d","text":"No — a new doctor must write a new order"}]'::jsonb,
 ARRAY['b'], false,
 'The order specifies "afebrile ×24 hours." At 18 hours the criterion is not yet met — all three conditions must be satisfied before discharge.',
 'Clinical Scenario Reading I', 77),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The nursing note states: "Patient expressed concern about going home alone. Lives independently. No support system identified." The nurse''s BEST next step is:',
 '[{"id":"a","text":"Discharge the patient immediately"},{"id":"b","text":"Ignore the concern as it is social, not medical"},{"id":"c","text":"Consult social work for discharge planning and home safety assessment"},{"id":"d","text":"Ask the patient to find their own support"}]'::jsonb,
 ARRAY['c'], false,
 'Social determinants of health affect outcomes. A social work referral addresses the safety concern and is part of holistic discharge planning.',
 'Clinical Scenario Reading I', 78),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The care plan states: "Reposition patient every 2 hours to prevent pressure injuries." During a busy shift, the nurse repositioned the patient every 4 hours. This is an example of:',
 '[{"id":"a","text":"Appropriate clinical judgment"},{"id":"b","text":"A deviation from the care plan that must be documented and addressed"},{"id":"c","text":"An acceptable variation"},{"id":"d","text":"Evidence-based practice"}]'::jsonb,
 ARRAY['b'], false,
 'Deviating from the care plan without documented clinical rationale is a care delivery failure. The nurse must document why and address the deviation.',
 'Clinical Scenario Reading I', 79),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000401',
 'The MAR shows: "Metoprolol 25 mg PO BID — last dose given 0800." It is now 2000. Should the nurse give the next dose?',
 '[{"id":"a","text":"No — the patient already had the medication today"},{"id":"b","text":"Yes — BID means twice daily, so a second dose at 2000 is appropriate"},{"id":"c","text":"No — metoprolol is only given once daily"},{"id":"d","text":"Yes — give double dose to compensate"}]'::jsonb,
 ARRAY['b'], false,
 'BID = twice daily. A 0800 and 2000 schedule is a standard 12-hour BID split. The 2000 dose is appropriate and due.',
 'Clinical Scenario Reading I', 80),

-- =============================================
-- TOPIC 7: Clinical Scenario Reading II (Q81–Q92)
-- =============================================

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'A nurse reads: "If the patient''s SpO2 drops below 92% despite 4L O2 via NC, increase to 100% NRB mask and notify the physician immediately." SpO2 is now 90% on 4L NC. The nurse should:',
 '[{"id":"a","text":"Continue current oxygen and recheck in an hour"},{"id":"b","text":"Apply 100% non-rebreather mask and notify the physician"},{"id":"c","text":"Decrease the oxygen flow"},{"id":"d","text":"Encourage deep breathing only"}]'::jsonb,
 ARRAY['b'], false,
 'The conditional order is clear: SpO2 < 92% despite 4L NC → escalate to 100% NRB mask and immediately notify the physician.',
 'Clinical Scenario Reading II', 81),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'The order reads: "Hold morning diuretic if patient weight is more than 2 kg below yesterday''s weight." Yesterday''s weight: 74 kg. Today''s weight: 71.5 kg. Should the nurse give the diuretic?',
 '[{"id":"a","text":"Yes — give the diuretic as ordered"},{"id":"b","text":"No — the patient lost more than 2 kg; hold the diuretic"},{"id":"c","text":"Give half the dose"},{"id":"d","text":"Weigh the patient again before deciding"}]'::jsonb,
 ARRAY['b'], false,
 '74 − 71.5 = 2.5 kg loss, which exceeds the 2 kg threshold. The hold parameter is triggered — withhold the diuretic and notify the physician.',
 'Clinical Scenario Reading II', 82),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'A patient states: "I know I''m supposed to take my blood pressure pills every day, but I only take them when I feel bad." The nurse BEST understands this as:',
 '[{"id":"a","text":"The patient has good medication judgment"},{"id":"b","text":"The patient misunderstands the purpose and requires medication education"},{"id":"c","text":"The patient should be discharged immediately"},{"id":"d","text":"The patient''s approach is acceptable for antihypertensives"}]'::jsonb,
 ARRAY['b'], false,
 'Antihypertensives must be taken consistently to maintain therapeutic effect. The patient''s statement reveals a misconception — education about daily adherence is necessary.',
 'Clinical Scenario Reading II', 83),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'The physician writes: "Discontinue heparin drip when therapeutic INR is achieved on warfarin (INR 2.0–3.0)." The patient''s INR today is 2.4. What should the nurse do?',
 '[{"id":"a","text":"Continue the heparin drip until INR reaches 3.0"},{"id":"b","text":"Discontinue the heparin drip as the INR is within the therapeutic range"},{"id":"c","text":"Double the warfarin dose"},{"id":"d","text":"Stop warfarin and continue heparin"}]'::jsonb,
 ARRAY['b'], false,
 'INR 2.4 is within the therapeutic range of 2.0–3.0. Per the conditional order, the heparin drip should be discontinued.',
 'Clinical Scenario Reading II', 84),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'A nursing note states: "Patient denies pain, dyspnea, or nausea. Tolerating clear liquids without difficulty. BM this morning — formed, brown, no blood." What does this note BEST indicate?',
 '[{"id":"a","text":"The patient has gastrointestinal bleeding"},{"id":"b","text":"The patient is progressing well post-operatively"},{"id":"c","text":"The patient requires further testing"},{"id":"d","text":"The patient is NPO"}]'::jsonb,
 ARRAY['b'], false,
 'All findings are normal and positive: no symptoms, tolerating oral intake, and normal bowel movement — consistent with smooth post-operative recovery.',
 'Clinical Scenario Reading II', 85),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'The order reads: "Wean oxygen by 1L every 30 minutes as tolerated, maintaining SpO2 ≥ 94%." The patient is on 4L. The nurse decreases to 3L and SpO2 remains at 96%. What should the nurse do next?',
 '[{"id":"a","text":"Stop weaning — 3L is the final target"},{"id":"b","text":"Decrease oxygen to 2L after 30 minutes if SpO2 stays ≥ 94%"},{"id":"c","text":"Increase back to 4L"},{"id":"d","text":"Discontinue oxygen entirely now"}]'::jsonb,
 ARRAY['b'], false,
 'The wean protocol continues: decrease by 1L every 30 minutes as long as SpO2 stays ≥ 94%. The next step is to try 2L after 30 minutes.',
 'Clinical Scenario Reading II', 86),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'The SBAR handoff states: "Situation: Patient is confused and pulling at IV lines. Background: 82-year-old with dementia, on multiple sedating medications. Assessment: Possible delirium. Recommendation: Evaluate for delirium triggers and consider reorientation measures." The purpose of the recommendation is to:',
 '[{"id":"a","text":"Restrain the patient immediately"},{"id":"b","text":"Identify and address the underlying cause of confusion"},{"id":"c","text":"Discharge the patient"},{"id":"d","text":"Increase sedative medications"}]'::jsonb,
 ARRAY['b'], false,
 'SBAR recommendations should guide action. The recommendation is to identify delirium triggers (pain, infection, medications) and use non-pharmacological reorientation — not restraints or more sedation.',
 'Clinical Scenario Reading II', 87),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 '"The patient''s urine output has been less than 30 mL/hour for the past 3 hours." Based on this clinical reading, the nurse should:',
 '[{"id":"a","text":"Document and continue monitoring without action"},{"id":"b","text":"Notify the physician — urine output < 30 mL/hour for 3 hours indicates oliguria and possible renal compromise"},{"id":"c","text":"Encourage the patient to drink more water"},{"id":"d","text":"Insert a new Foley catheter"}]'::jsonb,
 ARRAY['b'], false,
 'Normal urine output is 0.5–1 mL/kg/hour or at least 30 mL/hour. Output < 30 mL/hour for 3 consecutive hours (oliguria) is a clinical concern requiring immediate physician notification.',
 'Clinical Scenario Reading II', 88),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'The physician order states: "Resume oral intake only when patient is alert, able to swallow without coughing, and gag reflex is intact." The patient woke up, is oriented, but coughs when swallowing. Can oral intake be resumed?',
 '[{"id":"a","text":"Yes — the patient is alert, so it is safe"},{"id":"b","text":"No — coughing when swallowing indicates a swallowing problem; all criteria must be met"},{"id":"c","text":"Give thin liquids only"},{"id":"d","text":"Resume intake and document the cough"}]'::jsonb,
 ARRAY['b'], false,
 'All three conditions must be met simultaneously. Coughing when swallowing suggests dysphagia or absent gag reflex — an aspiration risk. Oral intake must remain withheld.',
 'Clinical Scenario Reading II', 89),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'The nursing note reads: "Family at bedside, informed of plan of care. Patient verbalized agreement with treatment plan. Questions answered by attending physician." What does this note document?',
 '[{"id":"a","text":"Informed consent was obtained by the nurse"},{"id":"b","text":"The patient and family were educated and the patient agreed to the care plan"},{"id":"c","text":"The family refused treatment"},{"id":"d","text":"A new physician took over care"}]'::jsonb,
 ARRAY['b'], false,
 'The note documents patient/family education, shared decision-making, and patient agreement with the plan — not formal surgical consent, but agreement with the treatment approach.',
 'Clinical Scenario Reading II', 90),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'The order reads: "If patient reports nausea, administer ondansetron 4 mg IV; if vomiting occurs, repeat dose in 4 hours." The patient vomited at 0600 and again at 0930. Can the nurse give a second dose at 0930?',
 '[{"id":"a","text":"Yes — vomiting occurred, so dose can be given anytime"},{"id":"b","text":"No — only 3.5 hours have passed since the first dose; must wait until 1000"},{"id":"c","text":"Yes — 4 hours have passed"},{"id":"d","text":"No — ondansetron cannot be repeated"}]'::jsonb,
 ARRAY['b'], false,
 '0600 + 4 hours = 1000. At 0930, only 3.5 hours have elapsed. The nurse must wait until 1000 to administer the repeat dose per the order.',
 'Clinical Scenario Reading II', 91),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000402',
 'A patient says: "If I stop taking these pills, I feel fine — so why should I keep taking them?" The nurse BEST interprets this as:',
 '[{"id":"a","text":"The patient no longer needs the medication"},{"id":"b","text":"A knowledge deficit about chronic disease management and the nature of maintenance medications"},{"id":"c","text":"Medication refusal that should be reported"},{"id":"d","text":"Evidence the medication is not needed"}]'::jsonb,
 ARRAY['b'], false,
 'Feeling fine off medication is a common misconception with chronic conditions (HTN, diabetes, asthma). The nurse should provide education about the role of maintenance medications in preventing complications.',
 'Clinical Scenario Reading II', 92),

-- =============================================
-- TOPIC 8: Professional Nursing Communication (Q93–Q100)
-- =============================================

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000403',
 'Which opening statement is the MOST therapeutic when a patient appears upset?',
 '[{"id":"a","text":"You need to calm down."},{"id":"b","text":"I can see you''re distressed. I''m here to listen."},{"id":"c","text":"Stop crying or I can''t help you."},{"id":"d","text":"This is not that serious."}]'::jsonb,
 ARRAY['b'], false,
 'Acknowledging the patient''s feelings and offering presence is the foundation of therapeutic communication. Dismissing or demanding calm is non-therapeutic.',
 'Professional Nursing Communication', 93),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000403',
 'The nurse is using SBAR to report a concern to the physician. What does SBAR stand for?',
 '[{"id":"a","text":"Symptoms, Background, Assessment, Review"},{"id":"b","text":"Situation, Background, Assessment, Recommendation"},{"id":"c","text":"Situation, Brief, Assessment, Report"},{"id":"d","text":"Summary, Background, Action, Response"}]'::jsonb,
 ARRAY['b'], false,
 'SBAR = Situation (what''s happening), Background (relevant history), Assessment (clinical interpretation), Recommendation (what you need).',
 'Professional Nursing Communication', 94),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000403',
 'A patient says, "I''m scared about my surgery." The nurse BEST responds:',
 '[{"id":"a","text":"Everyone feels that way — you''ll be fine."},{"id":"b","text":"There''s nothing to be afraid of."},{"id":"c","text":"Surgery can feel scary. What concerns you most?"},{"id":"d","text":"The surgeon is very experienced, so don''t worry."}]'::jsonb,
 ARRAY['c'], false,
 'Acknowledging the emotion and using an open-ended question validates the patient''s feelings and invites them to share their specific concern. Dismissal and false reassurance are non-therapeutic.',
 'Professional Nursing Communication', 95),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000403',
 'When providing discharge education, which method BEST confirms the patient understood the instructions?',
 '[{"id":"a","text":"Handing the patient a written pamphlet"},{"id":"b","text":"Reading the instructions aloud to the patient"},{"id":"c","text":"Having the patient repeat the key points in their own words (teach-back)"},{"id":"d","text":"Asking the patient if they have any questions"}]'::jsonb,
 ARRAY['c'], false,
 'Teach-back is the evidence-based gold standard for confirming patient understanding — the patient must demonstrate or verbalize comprehension, not just listen.',
 'Professional Nursing Communication', 96),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000403',
 'Which phrase in nursing documentation is MOST professional and objective?',
 '[{"id":"a","text":"Patient is being dramatic about pain."},{"id":"b","text":"Patient seems to be exaggerating."},{"id":"c","text":"Patient reports pain 8/10 on numeric scale; grimacing noted."},{"id":"d","text":"Patient is a difficult person."}]'::jsonb,
 ARRAY['c'], false,
 'Objective documentation uses measurable, observable data without bias or judgment. Option C records both the subjective report and an objective clinical finding.',
 'Professional Nursing Communication', 97),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000403',
 'The patient does not speak English. The nurse needs to explain a new medication. The BEST action is:',
 '[{"id":"a","text":"Ask the patient''s adult family member to translate"},{"id":"b","text":"Use gestures and hope the patient understands"},{"id":"c","text":"Use a trained medical interpreter"},{"id":"d","text":"Skip the explanation and just give the medication"}]'::jsonb,
 ARRAY['c'], false,
 'A trained medical interpreter ensures accurate, confidential communication. Using family members is discouraged due to accuracy, privacy, and liability concerns.',
 'Professional Nursing Communication', 98),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000403',
 'Which is the CORRECT way to communicate a concern to a physician using assertive language?',
 '[{"id":"a","text":"I''m sorry to bother you, but maybe could you possibly look at this patient?"},{"id":"b","text":"Doctor, I''m concerned about Mrs. Jones in room 3 — her BP dropped to 82/50 in the last 30 minutes. I recommend you evaluate her now."},{"id":"c","text":"There''s a patient with low BP somewhere."},{"id":"d","text":"I think the patient might be fine, but her BP seems low."}]'::jsonb,
 ARRAY['b'], false,
 'Assertive communication is clear, specific, and action-oriented. Option B identifies the patient, the finding, and makes a clear recommendation — consistent with SBAR.',
 'Professional Nursing Communication', 99),

('00000000-0000-0000-0000-000000000025', '20000000-0000-0000-0000-000000000403',
 'A nurse is about to give a patient a new medication. Which statement uses BEST professional communication for patient education?',
 '[{"id":"a","text":"Here''s your pill. Take it."},{"id":"b","text":"This is metformin. It helps control your blood sugar. Common side effects include nausea and stomach upset, especially at first. Take it with food. Do you have any questions?"},{"id":"c","text":"The doctor ordered this — just take it."},{"id":"d","text":"This pill is for diabetes — you should know what it is."}]'::jsonb,
 ARRAY['b'], false,
 'Professional medication education includes: drug name, purpose, common side effects, administration instruction, and invitation for questions. This ensures informed consent and patient safety.',
 'Professional Nursing Communication', 100);

-- ============================================
-- VERIFICATION
-- ============================================
SELECT
  t.name AS topic_name,
  COUNT(q.id) AS question_count
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id
  AND q.test_id = '00000000-0000-0000-0000-000000000025'
WHERE t.subject_id = '10000000-0000-0000-0000-000000000025'
GROUP BY t.name, t.display_order
ORDER BY t.display_order;
