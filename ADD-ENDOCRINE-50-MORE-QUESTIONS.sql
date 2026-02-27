-- ============================================
-- ENDOCRINE SYSTEM — 50 MORE NCLEX QUESTIONS (SATA)
-- Topics: Diabetes Mellitus, Insulin Patch, Insulin Storage and Checking,
--         Insulin, Mixing of Insulin Guidelines, Metformin
-- display_order: 101–150 (appends to ADD-ENDOCRINE-100-QUESTIONS.sql)
-- Run in Supabase SQL Editor AFTER ADD-ENDOCRINE-100-QUESTIONS.sql
-- ============================================
-- Topic UUIDs:
--   Diabetes Mellitus           → 20000000-0000-0000-0000-000000000070
--   Insulin Patch               → 20000000-0000-0000-0000-000000000071
--   Insulin Storage & Checking  → 20000000-0000-0000-0000-000000000072
--   Insulin (types/admin)       → 20000000-0000-0000-0000-000000000073
--   Mixing of Insulin           → 20000000-0000-0000-0000-000000000074
--   Metformin                   → 20000000-0000-0000-0000-000000000075
-- Test config UUID              → 00000000-0000-0000-0000-000000000004
-- ============================================

INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES

-- ============================================
-- MIXING OF INSULIN (Questions 101–116)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A nurse is preparing to administer a mix of Regular (R) and NPH (N) insulin. Which actions should the nurse take to ensure the correct mixing technique? Select all that apply. A) Inject air into the NPH vial first. B) Aspirate the NPH insulin before the Regular insulin. C) Inject air into the Regular vial and immediately withdraw the dose. D) Ensure the total volume in the syringe equals the sum of both doses. E) Rotate the NPH vial vigorously to ensure it is well-mixed before drawing.',
 '[{"id":"a","text":"Inject air into the NPH vial first"},{"id":"b","text":"Aspirate the NPH insulin before the Regular insulin"},{"id":"c","text":"Inject air into the Regular vial and immediately withdraw the dose"},{"id":"d","text":"Ensure the total volume in the syringe equals the sum of both doses"},{"id":"e","text":"Rotate the NPH vial vigorously to ensure it is well-mixed before drawing"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'The correct sequence is NR-RN (Air in N, Air in R, Draw R, Draw N). Air must be injected into the N vial first. Then air is injected into the R vial and the R dose is withdrawn immediately. The total volume must be accurate. One should never shake (rotate vigorously) insulin; it should be rolled gently.',
 'Mixing of Insulin Guidelines', 101),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A client has a blood glucose reading of 180 mg/dL. The nurse must prepare 4 units of Regular (R) and 6 units of NPH (N). Which steps are correct? Select all that apply. A) Draw 10 units of air into the syringe at once. B) Inject 6 units of air into the NPH vial. C) Inject 4 units of air into the Regular vial. D) Withdraw the 6 units of NPH before withdrawing the 4 units of Regular. E) Ensure the first food tray is provided 2 hours after injection.',
 '[{"id":"a","text":"Draw 10 units of air into the syringe at once"},{"id":"b","text":"Inject 6 units of air into the NPH vial"},{"id":"c","text":"Inject 4 units of air into the Regular vial"},{"id":"d","text":"Withdraw the 6 units of NPH before withdrawing the 4 units of Regular"},{"id":"e","text":"Ensure the first food tray is provided 2 hours after injection"}]'::jsonb,
 ARRAY['b','c','e'], true,
 'The NR-RN formula requires injecting 6 units of air into N, then 4 into R. Then 4 units of R are withdrawn first, followed by 6 units of N. The first food tray should be provided 2 hours after injection to align with Regular insulin peak.',
 'Mixing of Insulin Guidelines', 102),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A client on a mix of NPH and Regular insulin is scheduled for two meals. When should the nurse ensure the food trays are provided? Select all that apply. A) Within 15 minutes of the injection. B) 2 hours after the injection. C) 4 hours after the injection. D) 6 hours after the injection. E) 24 hours after the injection.',
 '[{"id":"a","text":"Within 15 minutes of the injection"},{"id":"b","text":"2 hours after the injection"},{"id":"c","text":"4 hours after the injection"},{"id":"d","text":"6 hours after the injection"},{"id":"e","text":"24 hours after the injection"}]'::jsonb,
 ARRAY['b','d'], true,
 'Regular insulin peaks at 2 hours and NPH peaks at 6 hours. Food trays must be provided at these peak times to prevent hypoglycemia.',
 'Mixing of Insulin Guidelines', 103),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Which statements about mixing Regular and NPH insulin are correct? Select all that apply. A) Regular insulin appears clear; NPH appears cloudy. B) Air is injected into NPH first, then Regular, before any insulin is drawn. C) NPH is drawn into the syringe before Regular to avoid contamination. D) If Regular is accidentally contaminated with NPH, the vial must be discarded. E) The syringe should be shaken after drawing to ensure proper mixing.',
 '[{"id":"a","text":"Regular insulin appears clear; NPH appears cloudy"},{"id":"b","text":"Air is injected into NPH first, then Regular, before any insulin is drawn"},{"id":"c","text":"NPH is drawn into the syringe before Regular to avoid contamination"},{"id":"d","text":"If Regular is accidentally contaminated with NPH, the vial must be discarded"},{"id":"e","text":"The syringe should be shaken after drawing to ensure proper mixing"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'Regular is clear; NPH is cloudy. The correct sequence injects air into N first, then R, but draws R first then N. If Regular is contaminated with NPH, the vial is discarded. Syringes are never shaken.',
 'Mixing of Insulin Guidelines', 104),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Why is Regular insulin drawn before NPH when mixing? Select all that apply. A) Regular is drawn first to prevent NPH from contaminating the Regular vial. B) Drawing NPH first would alter the concentration of Regular insulin. C) If NPH enters the Regular vial, NPH becomes ineffective. D) The order prevents cloudy insulin from entering the clear vial. E) Air must be injected into both vials before any insulin is withdrawn.',
 '[{"id":"a","text":"Regular is drawn first to prevent NPH from contaminating the Regular vial"},{"id":"b","text":"Drawing NPH first would alter the concentration of Regular insulin"},{"id":"c","text":"If NPH enters the Regular vial, NPH becomes ineffective"},{"id":"d","text":"The order prevents cloudy insulin from entering the clear vial"},{"id":"e","text":"Air must be injected into both vials before any insulin is withdrawn"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Regular (clear) is drawn first to protect it from contamination by NPH (cloudy). If NPH enters the Regular vial, the Regular concentration is altered and the vial must be discarded. Air is injected into both vials first, before any insulin is drawn.',
 'Mixing of Insulin Guidelines', 105),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A nursing student states: "I will inject air into the Regular vial first because I am drawing it first." What corrections should the instructor make? Select all that apply. A) Air must be injected into NPH first, before the Regular vial. B) The order of air injection does not matter as long as both are injected. C) Injecting air into Regular first risks pushing air into NPH accidentally. D) The NR-RN mnemonic guides the correct sequence. E) Injecting air into Regular first can create positive pressure in the NPH vial.',
 '[{"id":"a","text":"Air must be injected into NPH first, before the Regular vial"},{"id":"b","text":"The order of air injection does not matter as long as both are injected"},{"id":"c","text":"Injecting air into Regular first risks pushing air into NPH accidentally"},{"id":"d","text":"The NR-RN mnemonic guides the correct sequence"},{"id":"e","text":"Injecting air into Regular first can create positive pressure in the NPH vial"}]'::jsonb,
 ARRAY['a','d'], true,
 'The NR-RN mnemonic requires air into N first, then air into R, then draw R, then draw N. The order is not interchangeable and matters for maintaining sterility of the Regular vial.',
 'Mixing of Insulin Guidelines', 106),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'What is the purpose of injecting air into insulin vials before drawing up the dose? Select all that apply. A) To create positive pressure that makes withdrawing insulin easier. B) To mix the insulin before drawing. C) To replace the volume of insulin being removed and maintain vial pressure. D) To prevent a vacuum from forming inside the vial. E) To sterilize the rubber stopper.',
 '[{"id":"a","text":"To create positive pressure that makes withdrawing insulin easier"},{"id":"b","text":"To mix the insulin before drawing"},{"id":"c","text":"To replace the volume of insulin being removed and maintain vial pressure"},{"id":"d","text":"To prevent a vacuum from forming inside the vial"},{"id":"e","text":"To sterilize the rubber stopper"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'Injecting air into the vial before drawing insulin replaces the volume being removed, prevents a vacuum (which would make withdrawal difficult), and creates slight positive pressure to ease withdrawal. It does not mix or sterilize.',
 'Mixing of Insulin Guidelines', 107),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A nurse must administer 8 units Regular and 12 units NPH. In what order should the nurse proceed using the NR-RN method? Select all that apply. A) Inject 12 units of air into NPH vial, do not draw. B) Inject 8 units of air into Regular vial, then draw 8 units Regular. C) Draw 12 units NPH last. D) The final syringe should contain 20 units total. E) After drawing Regular, shake the syringe before drawing NPH.',
 '[{"id":"a","text":"Inject 12 units of air into NPH vial, do not draw"},{"id":"b","text":"Inject 8 units of air into Regular vial, then draw 8 units Regular"},{"id":"c","text":"Draw 12 units NPH last"},{"id":"d","text":"The final syringe should contain 20 units total"},{"id":"e","text":"After drawing Regular, shake the syringe before drawing NPH"}]'::jsonb,
 ARRAY['a','b','c','d'], true,
 'NR-RN: Air into N (12u) → Air into R (8u) + draw R → draw N (12u). Total = 20 units. Never shake the syringe.',
 'Mixing of Insulin Guidelines', 108),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'What happens if NPH insulin accidentally enters the Regular insulin vial during mixing? Select all that apply. A) The Regular vial must be discarded. B) The mixture is still safe to use if the doses are correct. C) The Regular insulin concentration is altered. D) The Regular vial will appear cloudy. E) A new vial of Regular insulin must be opened.',
 '[{"id":"a","text":"The Regular vial must be discarded"},{"id":"b","text":"The mixture is still safe to use if the doses are correct"},{"id":"c","text":"The Regular insulin concentration is altered"},{"id":"d","text":"The Regular vial will appear cloudy"},{"id":"e","text":"A new vial of Regular insulin must be opened"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'If NPH (cloudy) enters the Regular vial, the concentration of Regular is altered and the vial will appear cloudy. The vial must be discarded immediately and a new vial opened.',
 'Mixing of Insulin Guidelines', 109),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Which statements correctly describe the appearance of Regular and NPH insulin? Select all that apply. A) Regular insulin is clear and colorless. B) NPH insulin is cloudy due to its protamine suspension. C) Cloudy Regular insulin indicates contamination. D) A clear NPH vial is normal and expected. E) NPH should be rolled gently to restore its uniform cloudy appearance.',
 '[{"id":"a","text":"Regular insulin is clear and colorless"},{"id":"b","text":"NPH insulin is cloudy due to its protamine suspension"},{"id":"c","text":"Cloudy Regular insulin indicates contamination"},{"id":"d","text":"A clear NPH vial is normal and expected"},{"id":"e","text":"NPH should be rolled gently to restore its uniform cloudy appearance"}]'::jsonb,
 ARRAY['a','b','c','e'], true,
 'Regular is always clear. NPH is cloudy due to its protamine-zinc suspension and must be gently rolled before drawing. If Regular appears cloudy, it is contaminated and must be discarded. A clear NPH vial is NOT normal.',
 'Mixing of Insulin Guidelines', 110),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A nurse is teaching a new graduate about insulin mixing. Which key safety points must be emphasized? Select all that apply. A) Long-acting insulin (Glargine) cannot be mixed with any other insulin. B) NPH can be mixed with Regular insulin. C) If the total insulin drawn is incorrect, push the excess back into the NPH vial. D) Never shake insulin vials or syringes. E) Always verify the type of insulin and dosage with a second nurse before administration.',
 '[{"id":"a","text":"Long-acting insulin (Glargine) cannot be mixed with any other insulin"},{"id":"b","text":"NPH can be mixed with Regular insulin"},{"id":"c","text":"If the total insulin drawn is incorrect, push the excess back into the NPH vial"},{"id":"d","text":"Never shake insulin vials or syringes"},{"id":"e","text":"Always verify the type of insulin and dosage with a second nurse before administration"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Glargine must never be mixed. NPH and Regular can be mixed using NR-RN. If excess is drawn, the dose must be discarded and redrawn — never push back. Insulin is never shaken. Insulin requires two-nurse verification.',
 'Mixing of Insulin Guidelines', 111),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'After mixing Regular and NPH insulin, the nurse notices the syringe contains 2 units more than prescribed. What are appropriate actions? Select all that apply. A) Discard the syringe and start over with new doses. B) Push the 2 extra units back into the NPH vial. C) Push the 2 extra units back into the Regular vial. D) Document the preparation error and notify the charge nurse. E) Administer the 2 extra units since the difference is negligible.',
 '[{"id":"a","text":"Discard the syringe and start over with new doses"},{"id":"b","text":"Push the 2 extra units back into the NPH vial"},{"id":"c","text":"Push the 2 extra units back into the Regular vial"},{"id":"d","text":"Document the preparation error and notify the charge nurse"},{"id":"e","text":"Administer the 2 extra units since the difference is negligible"}]'::jsonb,
 ARRAY['a','d'], true,
 'If the drawn dose is incorrect, the syringe must be discarded and preparation restarted. Pushing excess back into either vial contaminates it. Administering extra units risks hypoglycemia.',
 'Mixing of Insulin Guidelines', 112),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Which insulins are acceptable to mix together in one syringe? Select all that apply. A) Regular + NPH. B) Glargine + Regular. C) Lispro (rapid-acting) + NPH. D) Glargine + Lispro. E) Detemir + Regular.',
 '[{"id":"a","text":"Regular + NPH"},{"id":"b","text":"Glargine + Regular"},{"id":"c","text":"Lispro (rapid-acting) + NPH"},{"id":"d","text":"Glargine + Lispro"},{"id":"e","text":"Detemir + Regular"}]'::jsonb,
 ARRAY['a','c'], true,
 'Regular and Lispro (rapid-acting) can be mixed with NPH (intermediate-acting). Long-acting insulins (Glargine, Detemir) must never be mixed with any other insulin as they alter the pharmacokinetics of both insulins.',
 'Mixing of Insulin Guidelines', 113),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A client asks why their NPH insulin looks "milky" compared to the Regular insulin. Which statements are accurate for the nurse to include? Select all that apply. A) NPH contains protamine and zinc, making it cloudy. B) The cloudiness means it is expired and should not be used. C) Regular insulin is always clear because it has no suspending agents. D) If NPH appears clear, it should not be used. E) Rolling the vial distributes the suspension evenly and restores cloudiness.',
 '[{"id":"a","text":"NPH contains protamine and zinc, making it cloudy"},{"id":"b","text":"The cloudiness means it is expired and should not be used"},{"id":"c","text":"Regular insulin is always clear because it has no suspending agents"},{"id":"d","text":"If NPH appears clear, it should not be used"},{"id":"e","text":"Rolling the vial distributes the suspension evenly and restores cloudiness"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'NPH is cloudy due to its protamine-zinc suspension — this is normal and expected. Regular is clear. If NPH appears clear, the suspension has separated improperly and the vial should not be used. Rolling restores uniform cloudiness.',
 'Mixing of Insulin Guidelines', 114),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'The nurse follows the NR-RN mixing sequence. Which steps represent the correct interpretation of this mnemonic? Select all that apply. A) N = Inject air into NPH vial first. B) R = Inject air into Regular vial and draw Regular next. C) R = Draw Regular insulin into the syringe. D) N = Finally draw NPH insulin into the syringe. E) The sequence minimizes risk of contaminating the Regular insulin vial.',
 '[{"id":"a","text":"N = Inject air into NPH vial first"},{"id":"b","text":"R = Inject air into Regular vial and draw Regular next"},{"id":"c","text":"R = Draw Regular insulin into the syringe"},{"id":"d","text":"N = Finally draw NPH insulin into the syringe"},{"id":"e","text":"The sequence minimizes risk of contaminating the Regular insulin vial"}]'::jsonb,
 ARRAY['a','b','c','d','e'], true,
 'NR-RN fully decoded: N (air into NPH) → R (air into Regular + draw Regular) → R (drawn into syringe) → N (drawn last). The entire sequence protects the Regular vial from NPH contamination.',
 'Mixing of Insulin Guidelines', 115),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Which statements about the timing of food after a Regular + NPH insulin injection are correct? Select all that apply. A) Regular insulin peaks at 2 hours and requires a meal. B) NPH insulin peaks at 6 hours and requires a meal or snack. C) A single meal given immediately after injection covers both insulins. D) Providing food at 2 and 6 hours prevents hypoglycemia at peak times. E) If meals are missed at peak times, the client is at risk for hypoglycemia.',
 '[{"id":"a","text":"Regular insulin peaks at 2 hours and requires a meal"},{"id":"b","text":"NPH insulin peaks at 6 hours and requires a meal or snack"},{"id":"c","text":"A single meal given immediately after injection covers both insulins"},{"id":"d","text":"Providing food at 2 and 6 hours prevents hypoglycemia at peak times"},{"id":"e","text":"If meals are missed at peak times, the client is at risk for hypoglycemia"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Regular peaks at 2 hours (meal 1); NPH peaks at 6 hours (meal 2). Both require food at their respective peaks. A single immediate meal does not cover the 6-hour NPH peak. Missing meals during peaks causes hypoglycemia.',
 'Mixing of Insulin Guidelines', 116),

-- ============================================
-- METFORMIN (Questions 117–122)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client is prescribed Metformin for Type 2 Diabetes. Which clinical findings would require the nurse to hold the medication and notify the provider? Select all that apply. A) The client is scheduled for a CT scan with contrast in 12 hours. B) The client''s most recent HbA1c was 6.8%. C) The client reports frequent episodes of morning dyspepsia. D) The client''s last kidney panel was performed 8 months ago. E) The client is being prepped for an elective cholecystectomy tomorrow morning.',
 '[{"id":"a","text":"Scheduled CT scan with contrast in 12 hours"},{"id":"b","text":"Most recent HbA1c was 6.8%"},{"id":"c","text":"Frequent episodes of morning dyspepsia"},{"id":"d","text":"Last kidney panel was performed 8 months ago"},{"id":"e","text":"Being prepped for elective cholecystectomy tomorrow morning"}]'::jsonb,
 ARRAY['a','d','e'], true,
 'Metformin must be stopped 24 hours before any surgery or procedure involving contrast dye. Kidney function must be tested every 6 months because Metformin can be nephrotoxic. A 6.8% HbA1c is within target (<7%), and dyspepsia is a known side effect that does not require holding the drug.',
 'Metformin', 117),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client with Type 2 Diabetes is being treated with diet, exercise, and Metformin. Which findings indicate the treatment is currently ineffective and may require addition of insulin? Select all that apply. A) HbA1c level of 7.5%. B) Fasting blood sugar level of 130 mg/dL. C) Postprandial blood sugar level of 135 mg/dL. D) The client has gained significant weight despite exercise. E) The client reports persistent fatigue and blurred vision.',
 '[{"id":"a","text":"HbA1c level of 7.5%"},{"id":"b","text":"Fasting blood sugar level of 130 mg/dL"},{"id":"c","text":"Postprandial blood sugar level of 135 mg/dL"},{"id":"d","text":"The client has gained significant weight despite exercise"},{"id":"e","text":"The client reports persistent fatigue and blurred vision"}]'::jsonb,
 ARRAY['a','b','e'], true,
 'An HbA1c higher than 7% indicates the current treatment is ineffective and insulin may be considered. Fasting blood sugar over 110 indicates hyperglycemia. Symptoms like fatigue and blurred vision are signs of persistent hyperglycemia. Postprandial levels under 140 are considered normal.',
 'Metformin', 118),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client on Metformin reports bloating and diarrhea. What is the nurse''s best response? Select all that apply. A) "These are common side effects of the medication." B) "We must stop the medication immediately as this indicates kidney toxicity." C) "Are you taking the medication after your meals as prescribed?" D) "You should schedule a kidney panel immediately." E) "I will document these symptoms of dyspepsia and abdominal distention."',
 '[{"id":"a","text":"These are common side effects of the medication"},{"id":"b","text":"We must stop the medication immediately as this indicates kidney toxicity"},{"id":"c","text":"Are you taking the medication after your meals as prescribed?"},{"id":"d","text":"You should schedule a kidney panel immediately"},{"id":"e","text":"I will document these symptoms of dyspepsia and abdominal distention"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'Bloating, diarrhea, dyspepsia, and abdominal distention are common GI side effects of Metformin. Metformin should be taken after meals to reduce GI upset. These are not symptoms of kidney toxicity (which is monitored via lab panels every 6 months).',
 'Metformin', 119),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A nurse is preparing a client for a procedure requiring contrast dye. The client accidentally took Metformin this morning. What is the priority nursing action? Select all that apply. A) Proceed with the procedure but monitor kidney function closely afterward. B) Notify the provider and the surgical/radiology team immediately. C) Reschedule the procedure for a later date. D) Administer a large bolus of IV fluids to flush Metformin from the kidneys. E) Document the incident in the client''s medical record.',
 '[{"id":"a","text":"Proceed with the procedure but monitor kidney function closely afterward"},{"id":"b","text":"Notify the provider and the surgical/radiology team immediately"},{"id":"c","text":"Reschedule the procedure for a later date"},{"id":"d","text":"Administer a large bolus of IV fluids to flush Metformin from the kidneys"},{"id":"e","text":"Document the incident in the client''s medical record"}]'::jsonb,
 ARRAY['b','c','e'], true,
 'If Metformin is taken before a contrast procedure, the procedure must be rescheduled. The nurse must notify the provider and radiology team immediately and document the incident.',
 'Metformin', 120),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'When considering Metformin, which clients would be the most appropriate candidates? Select all that apply. A) A Type 2 Diabetic whose blood sugar is not controlled by exercise alone. B) A Type 1 Diabetic who is thin and loses weight easily. C) A client who prefers taking oral medication twice a day after meals. D) A client with a stable kidney panel and no upcoming surgeries. E) A client with an HbA1c of 8% who has not yet tried insulin.',
 '[{"id":"a","text":"Type 2 Diabetic whose blood sugar is not controlled by exercise alone"},{"id":"b","text":"Type 1 Diabetic who is thin and loses weight easily"},{"id":"c","text":"Client who prefers taking oral medication twice a day after meals"},{"id":"d","text":"Client with a stable kidney panel and no upcoming surgeries"},{"id":"e","text":"Client with HbA1c of 8% who has not yet tried insulin"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'Metformin is for Type 2 when lifestyle changes are insufficient. It is taken twice daily after meals. It is safe with healthy kidneys and no planned surgery. It is used before transitioning to insulin when HbA1c is >7%. It is NOT for Type 1.',
 'Metformin', 121),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client with Type 1 Diabetes asks why they cannot take Metformin instead of insulin. Which responses are correct? Select all that apply. A) "In Type 1 Diabetes, your body has stopped producing insulin entirely." B) "Metformin is only for people whose bodies do not respond well to the insulin they make." C) "Metformin can only be used if your HbA1c is below 7%." D) "Your body is breaking down fat and muscle because it lacks insulin; Metformin won''t stop that." E) "Type 1 is an autoimmune condition that requires replacing the hormone your pancreas cannot make."',
 '[{"id":"a","text":"In Type 1, your body has stopped producing insulin entirely"},{"id":"b","text":"Metformin is only for people whose bodies do not respond well to the insulin they make"},{"id":"c","text":"Metformin can only be used if HbA1c is below 7%"},{"id":"d","text":"Your body is breaking down fat and muscle because it lacks insulin; Metformin won''t stop that"},{"id":"e","text":"Type 1 is an autoimmune condition that requires replacing the hormone your pancreas cannot make"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Type 1 is an autoimmune reaction resulting in complete halt of insulin production. Patients break down fat and muscle because they lack insulin entirely. Metformin works for Type 2 insulin resistance, not for absent insulin production.',
 'Metformin', 122),

-- ============================================
-- INSULIN PATCH (Questions 123–130)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A nurse is providing education to a client prescribed a basal-bolus insulin patch. Which instructions should be included? Select all that apply. A) "You can deliver an extra dose of insulin during meals using the remote controller." B) "The patch will provide a steady, slow dose of insulin throughout the 24-hour period." C) "Change the patch and infusion set every 5 days to ensure proper absorption." D) "Avoid placing the patch on areas where the skin is red or irritated." E) "Rotate the application site each time you apply a new patch."',
 '[{"id":"a","text":"You can deliver an extra dose of insulin during meals using the remote controller"},{"id":"b","text":"The patch will provide a steady, slow dose of insulin throughout the 24-hour period"},{"id":"c","text":"Change the patch and infusion set every 5 days"},{"id":"d","text":"Avoid placing the patch on areas where the skin is red or irritated"},{"id":"e","text":"Rotate the application site each time you apply a new patch"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Basal-bolus patches allow a steady basal dose and on-demand bolus doses via controller. Patches must not be placed on irritated skin and sites must be rotated. Infusion sets must be changed every 2–3 days, not every 5 days.',
 'Insulin Patch', 123),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client is prescribed a "Basal-only" insulin patch. What should the nurse include in teaching? Select all that apply. A) It delivers a steady dose of insulin for 24 to 72 hours. B) You must press a button on the patch to deliver insulin for snacks. C) It is used to control fasting blood sugar levels. D) It is a transdermal device that delivers insulin through the skin. E) It is only used for patients with Type 1 Diabetes.',
 '[{"id":"a","text":"It delivers a steady dose of insulin for 24 to 72 hours"},{"id":"b","text":"You must press a button on the patch to deliver insulin for snacks"},{"id":"c","text":"It is used to control fasting blood sugar levels"},{"id":"d","text":"It is a transdermal device that delivers insulin through the skin"},{"id":"e","text":"It is only used for patients with Type 1 Diabetes"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'A basal-only patch delivers a steady dose for 24–72 hours to control fasting blood sugar. It is a transdermal device. On-demand bolus dosing is a feature of basal-bolus patches, not basal-only. It can be used for both Type 1 and Type 2 patients.',
 'Insulin Patch', 124),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Which of the following are considered types of insulin patches or patch pumps? Select all that apply. A) V-Go. B) Metformin Transdermal. C) CeQur Simplicity. D) Insulet Omnipod. E) Lantus Patch.',
 '[{"id":"a","text":"V-Go"},{"id":"b","text":"Metformin Transdermal"},{"id":"c","text":"CeQur Simplicity"},{"id":"d","text":"Insulet Omnipod"},{"id":"e","text":"Lantus Patch"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'V-Go, CeQur Simplicity, and Insulet Omnipod are insulin patches/patch pumps. Metformin is an oral medication, and there is no such thing as a Lantus patch.',
 'Insulin Patch', 125),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Which instructions regarding the insulin patch would be considered advanced clinical education for a patient who struggles with adherence? Select all that apply. A) "The patch is a needle-free option, though some use microneedles that are virtually painless." B) "It is a discreet way to manage your insulin without multiple daily injections." C) "You must still check your blood glucose levels frequently unless you have a CGM." D) "The patch only works for Type 2 diabetes because Type 1 requires injections." E) "If you remove the patch for a long time, you are at risk for Diabetic Ketoacidosis."',
 '[{"id":"a","text":"The patch is a needle-free option; some use microneedles that are virtually painless"},{"id":"b","text":"It is a discreet way to manage insulin without multiple daily injections"},{"id":"c","text":"You must still check blood glucose frequently unless you have a CGM"},{"id":"d","text":"The patch only works for Type 2 diabetes because Type 1 requires injections"},{"id":"e","text":"If you remove the patch for a long time, you are at risk for DKA"}]'::jsonb,
 ARRAY['a','b','c','e'], true,
 'The patch is promoted for adherence-challenged patients as discreet and nearly needle-free. Frequent monitoring is still required. Prolonged removal stops insulin delivery, risking DKA. It is used for both Type 1 and Type 2.',
 'Insulin Patch', 126),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Which complications can occur if an insulin pump infusion set is not rotated or changed frequently? Select all that apply. A) Lipodystrophy. B) Hypoglycemia. C) Infection at the site. D) Insulin absorption issues. E) Diabetic Ketoacidosis (DKA) if the infusion is blocked.',
 '[{"id":"a","text":"Lipodystrophy"},{"id":"b","text":"Hypoglycemia"},{"id":"c","text":"Infection at the site"},{"id":"d","text":"Insulin absorption issues"},{"id":"e","text":"DKA if the infusion is blocked"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'Failure to rotate or change sets every 2–3 days increases risk of infection, lipodystrophy, and absorption issues. A blocked infusion stops insulin delivery, leading to hyperglycemia and DKA. Hypoglycemia results from excess insulin, not removal or blockage.',
 'Insulin Patch', 127),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client on an insulin patch pump is found confused and sweaty. What should the nurse''s immediate actions be? Select all that apply. A) Check the client''s blood glucose level. B) Remove the insulin patch immediately. C) Provide a source of simple carbohydrates if the client is alert enough to swallow. D) Administer a bolus of insulin via the patch controller. E) Prepare for glucagon administration if the client''s LOC deteriorates.',
 '[{"id":"a","text":"Check the client''s blood glucose level"},{"id":"b","text":"Remove the insulin patch immediately"},{"id":"c","text":"Provide simple carbohydrates if the client is alert enough to swallow"},{"id":"d","text":"Administer a bolus of insulin via the patch controller"},{"id":"e","text":"Prepare for glucagon administration if LOC deteriorates"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'Sweating and confusion are signs of hypoglycemia. Check glucose first. If alert, give simple carbs. If LOC worsens, glucagon is needed. Administering a bolus would worsen hypoglycemia. Removing the patch is for DKA prevention, not acute hypoglycemia treatment.',
 'Insulin Patch', 128),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client using an insulin patch reports consistently high morning blood sugars. Which factors should the nurse investigate? Select all that apply. A) Is the client eating a snack before bed? B) Is the infusion set being changed every 2 to 3 days? C) Is the patch being placed over broken or irritated skin? D) Is the client using the bolus function for late-night snacks? E) Is the client''s body naturally activating sugars in the morning to wake up?',
 '[{"id":"a","text":"Is the client eating a snack before bed?"},{"id":"b","text":"Is the infusion set being changed every 2 to 3 days?"},{"id":"c","text":"Is the patch being placed over broken or irritated skin?"},{"id":"d","text":"Is the client using the bolus function for late-night snacks?"},{"id":"e","text":"Is the body naturally activating sugars in the morning?"}]'::jsonb,
 ARRAY['b','c','e'], true,
 'High morning sugars may result from the body''s natural waking sugar activation, poor absorption from a set not changed every 2–3 days, or placement on irritated skin. Eating before bed is a strategy to prevent morning hypoglycemia, not hyperglycemia.',
 'Insulin Patch', 129),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A nurse is evaluating a client''s understanding of their insulin pump and DKA risk. Which client statements indicate a need for further instruction? Select all that apply. A) "I don''t need to check my blood sugar as long as I have the pump on." B) "If the tube gets blocked, I might be at risk for high blood sugar and ketoacidosis." C) "I only need to worry about DKA if I accidentally take too much insulin." D) "The pump uses rapid-acting insulin, so I need a backup plan if it fails." E) "I should carry backup long-acting insulin in case the pump stops working."',
 '[{"id":"a","text":"I don''t need to check my blood sugar as long as I have the pump on"},{"id":"b","text":"If the tube gets blocked, I might be at risk for high blood sugar and ketoacidosis"},{"id":"c","text":"I only need to worry about DKA if I accidentally take too much insulin"},{"id":"d","text":"The pump uses rapid-acting insulin, so I need a backup plan if it fails"},{"id":"e","text":"I should carry backup long-acting insulin in case the pump stops working"}]'::jsonb,
 ARRAY['a','c'], true,
 'Insulin pumps do not replace the need for glucose monitoring. DKA occurs from a lack of insulin (e.g., blocked/removed pump), not from excess insulin which causes hypoglycemia. Backup long-acting insulin is essential.',
 'Insulin Patch', 130),

-- ============================================
-- INSULIN STORAGE AND CHECKING (Questions 131–136)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'When educating a client on insulin storage, which instructions are accurate? Select all that apply. A) Keep unopened vials in the refrigerator. B) Once opened, a vial can be stored at room temperature away from sunlight. C) Discard an opened vial exactly 60 days after the opening date. D) If a vial is accidentally shaken, allow it to rest before use. E) Store a backup insulin supply in the car for easy access during travel.',
 '[{"id":"a","text":"Keep unopened vials in the refrigerator"},{"id":"b","text":"Once opened, store at room temperature away from sunlight"},{"id":"c","text":"Discard an opened vial exactly 60 days after opening"},{"id":"d","text":"If accidentally shaken, allow the vial to rest before use"},{"id":"e","text":"Store a backup supply in the car for easy access during travel"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'Unopened vials must be refrigerated. Opened vials can be kept at room temperature away from sunlight but expire 28–30 days after opening, not 60. If shaken, insulin must rest. Insulin should never be stored in a car due to temperature extremes.',
 'Insulin Storage and Checking', 131),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A nurse is reviewing storage of insulin vials in a clinic. Which observations require immediate intervention? Select all that apply. A) An unopened vial of Lantus is sitting on the counter at room temperature. B) An opened vial of NPH is stored in the refrigerator labeled with an opening date 10 days ago. C) A vial of Regular insulin appears cloudy and is being used. D) Vials are stored in a small refrigerator in the staff breakroom. E) A syringe is pre-filled with Glargine and NPH mixed together.',
 '[{"id":"a","text":"Unopened Lantus sitting on the counter at room temperature"},{"id":"b","text":"Opened NPH refrigerated and labeled with an opening date 10 days ago"},{"id":"c","text":"Regular insulin appears cloudy and is being used"},{"id":"d","text":"Vials stored in a small refrigerator in the staff breakroom"},{"id":"e","text":"Syringe pre-filled with Glargine and NPH mixed together"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'Unopened vials must be refrigerated. Regular insulin must always be clear — if cloudy, discard immediately. Glargine cannot be mixed with any other insulin. An opened NPH refrigerated at 10 days is within the 28–30 day window.',
 'Insulin Storage and Checking', 132),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'Which actions are correct when a nurse performs a capillary blood glucose test (fingerstick)? Select all that apply. A) Use the first drop of blood to ensure the most accurate reading. B) Clean the finger with an alcohol swab before pricking. C) Squeeze the finger gently to encourage a blood drop to form. D) Place the second drop of blood onto the test strip. E) Apply a clean patch or alcohol swab to the site after the test.',
 '[{"id":"a","text":"Use the first drop of blood to ensure the most accurate reading"},{"id":"b","text":"Clean the finger with an alcohol swab before pricking"},{"id":"c","text":"Squeeze the finger gently to encourage a blood drop to form"},{"id":"d","text":"Place the second drop of blood onto the test strip"},{"id":"e","text":"Apply a clean patch or alcohol swab after the test"}]'::jsonb,
 ARRAY['b','c','d','e'], true,
 'The first drop of blood should be wiped away; the second drop is used for the meter. The site should be cleaned first, squeezed gently for a drop, and pressure applied afterward to stop bleeding.',
 'Insulin Storage and Checking', 133),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A nurse is instructing a client on how to use a glucose meter. Which common errors should the nurse warn about? Select all that apply. A) Cleaning the site with alcohol before the prick. B) Using the first drop of blood for the test. C) Forgetting to wipe away the first drop of blood. D) Shaking the insulin vial before checking blood sugar. E) Applying blood to the test strip before inserting it into the meter.',
 '[{"id":"a","text":"Cleaning the site with alcohol before the prick"},{"id":"b","text":"Using the first drop of blood for the test"},{"id":"c","text":"Forgetting to wipe away the first drop of blood"},{"id":"d","text":"Shaking the insulin vial before checking blood sugar"},{"id":"e","text":"Applying blood to the strip before inserting it into the meter"}]'::jsonb,
 ARRAY['b','c','e'], true,
 'Using the first drop is an error — it must be wiped away. The strip must be in the meter before applying blood. Cleaning with alcohol is correct. Shaking insulin is an error in administration, not a meter-specific error.',
 'Insulin Storage and Checking', 134),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A nurse opens a new vial of Regular insulin. Which storage and handling instructions are correct? Select all that apply. A) Label the vial with the opening date. B) The vial can be kept at room temperature for up to 28–30 days. C) Keep the vial away from direct sunlight and heat. D) If the vial was refrigerated, warm it in your hands before injecting to reduce discomfort. E) The vial should be stored in the freezer when not in use.',
 '[{"id":"a","text":"Label the vial with the opening date"},{"id":"b","text":"The vial can be kept at room temperature for up to 28–30 days"},{"id":"c","text":"Keep the vial away from direct sunlight and heat"},{"id":"d","text":"Warm the refrigerated vial in your hands before injecting"},{"id":"e","text":"Store in the freezer when not in use"}]'::jsonb,
 ARRAY['a','b','c','d'], true,
 'Opened vials should be labeled with the opening date and discarded after 28–30 days. They should be kept away from sunlight and heat. Refrigerated insulin can be warmed in the palms to reduce injection pain. Freezing damages insulin.',
 'Insulin Storage and Checking', 135),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A client asks which insulins should appear cloudy versus clear. Which statements are correct? Select all that apply. A) Regular (short-acting) insulin is clear. B) NPH (intermediate-acting) insulin is cloudy. C) Glargine (long-acting) insulin is cloudy. D) Lispro (rapid-acting) insulin is clear. E) If any insulin expected to be clear appears cloudy, it should be discarded.',
 '[{"id":"a","text":"Regular (short-acting) insulin is clear"},{"id":"b","text":"NPH (intermediate-acting) insulin is cloudy"},{"id":"c","text":"Glargine (long-acting) insulin is cloudy"},{"id":"d","text":"Lispro (rapid-acting) insulin is clear"},{"id":"e","text":"If any insulin expected to be clear appears cloudy, discard it"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Regular and Lispro (rapid-acting) are clear. NPH is the only cloudy insulin due to its protamine suspension. Glargine is clear. Any clear insulin that appears cloudy has been contaminated and must be discarded.',
 'Insulin Storage and Checking', 136),

-- ============================================
-- INSULIN — TYPES AND ADMINISTRATION (Questions 137–144)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A nurse is preparing to administer rapid-acting insulin. Which actions are appropriate? Select all that apply. A) Ensure the food tray is available within 15 minutes of administration. B) Administer via IV route if the patient is in DKA. C) Use the abdomen as the preferred site, staying 2 inches away from the umbilicus. D) Check the appearance of the insulin; it should be clear. E) If the vial was in the refrigerator, roll it between the palms to warm it.',
 '[{"id":"a","text":"Ensure the food tray is available within 15 minutes"},{"id":"b","text":"Administer via IV route if the patient is in DKA"},{"id":"c","text":"Use the abdomen, staying 2 inches from the umbilicus"},{"id":"d","text":"Check the appearance; it should be clear"},{"id":"e","text":"If refrigerated, roll between palms to warm it"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'Rapid-acting insulin requires food within 15 minutes. Injections should be subcutaneous in the abdomen 1.5–2 inches from the umbilicus. It is clear and can be warmed in the palms if refrigerated. Only Regular (short-acting) insulin can be given IV.',
 'Insulin', 137),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A nurse is preparing to administer NPH insulin. What are the key characteristics of this insulin type? Select all that apply. A) It is identified by the letter "N." B) It appears as a cloudy medication. C) It can be administered intravenously in emergencies. D) It has a peak time of approximately 6 hours. E) It is an intermediate-acting insulin.',
 '[{"id":"a","text":"It is identified by the letter N"},{"id":"b","text":"It appears as a cloudy medication"},{"id":"c","text":"It can be administered intravenously in emergencies"},{"id":"d","text":"It has a peak time of approximately 6 hours"},{"id":"e","text":"It is an intermediate-acting insulin"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'NPH (N) is intermediate-acting, cloudy, identified by the letter N, and peaks at 6 hours. It is administered only subcutaneously — never IV.',
 'Insulin', 138),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A client is being discharged with a prescription for Glargine (Lantus). What should the nurse teach? Select all that apply. A) This insulin is typically taken before bed. B) It is a long-acting insulin that lasts for 24 hours. C) You can mix this in the same syringe with your Regular insulin. D) This insulin has no peak time. E) You should eat a snack before bed to prevent morning hypoglycemia.',
 '[{"id":"a","text":"This insulin is typically taken before bed"},{"id":"b","text":"It is a long-acting insulin lasting 24 hours"},{"id":"c","text":"You can mix it in the same syringe with Regular insulin"},{"id":"d","text":"This insulin has no peak time"},{"id":"e","text":"Eat a snack before bed to prevent morning hypoglycemia"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Glargine is long-acting (24 hours), has no peak, and is usually taken before bed. A snack before bed helps prevent morning hypoglycemia. Long-acting insulin cannot be mixed with any other insulin.',
 'Insulin', 139),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A nurse is managing a client on a Regular insulin infusion for DKA. Which outcomes indicate the treatment is meeting its therapeutic goal? Select all that apply. A) The blood glucose level drops by 60 mg/dL per hour. B) The blood glucose level drops by 100 mg/dL per hour. C) The blood glucose level drops by 70 mg/dL per hour. D) The blood glucose level reaches 110 mg/dL within the first hour. E) The insulin is being administered via an intravenous line.',
 '[{"id":"a","text":"Blood glucose drops by 60 mg/dL per hour"},{"id":"b","text":"Blood glucose drops by 100 mg/dL per hour"},{"id":"c","text":"Blood glucose drops by 70 mg/dL per hour"},{"id":"d","text":"Blood glucose reaches 110 mg/dL within the first hour"},{"id":"e","text":"Insulin is being administered via IV line"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'For Regular insulin infusions in DKA, the goal is a glucose drop of 50–75 mg/dL per hour. Regular insulin is the only type that can be given IV. A drop of 100 mg/dL per hour is too rapid.',
 'Insulin', 140),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A nurse is rotating injection sites for a client receiving four insulin injections daily. Why is this practice essential? Select all that apply. A) To prevent the buildup of plaque in blood vessels (atherosclerosis). B) To avoid the development of lipodystrophy. C) To ensure consistent and effective insulin absorption. D) To prevent the medication from being absorbed too quickly. E) To reduce localized skin irritation and damage.',
 '[{"id":"a","text":"To prevent atherosclerosis"},{"id":"b","text":"To avoid the development of lipodystrophy"},{"id":"c","text":"To ensure consistent and effective insulin absorption"},{"id":"d","text":"To prevent the medication from being absorbed too quickly"},{"id":"e","text":"To reduce localized skin irritation and damage"}]'::jsonb,
 ARRAY['b','c','e'], true,
 'Rotating sites prevents lipodystrophy and ensures consistent absorption. It also reduces skin irritation. Atherosclerosis is associated with excess glucose storage, not injection site choice.',
 'Insulin', 141),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A nurse is providing education on how to avoid lipodystrophy. Which advice is correct? Select all that apply. A) "Inject insulin at least 1.5 to 2 inches away from your belly button." B) "You can use your thighs, buttocks, or upper arms for injections." C) "Always use the exact same spot for your morning injection to ensure consistent absorption." D) "Rotate the injection site every single day." E) "If the skin feels lumpy or hard, avoid that area for future injections."',
 '[{"id":"a","text":"Inject at least 1.5 to 2 inches away from the belly button"},{"id":"b","text":"Thighs, buttocks, or upper arms are acceptable sites"},{"id":"c","text":"Always use the exact same spot for the morning injection"},{"id":"d","text":"Rotate the injection site every single day"},{"id":"e","text":"If skin feels lumpy or hard, avoid that area"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Injections should be 1.5–2 inches from the umbilicus. Thighs, buttocks, and upper arms are acceptable sites. Sites must be rotated daily to prevent lipodystrophy. Using the same spot every day causes lipodystrophy.',
 'Insulin', 142),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A nurse is preparing to administer insulin to a client. Which steps are vital for safety and infection control? Select all that apply. A) Clean the injection site with an alcohol swab. B) Warm the vial in the hands if it was refrigerated. C) Never shake the vial; roll it instead. D) Aspirate for blood return before injecting the insulin. E) Ensure the insulin is being injected into the subcutaneous fat.',
 '[{"id":"a","text":"Clean the injection site with an alcohol swab"},{"id":"b","text":"Warm the vial in hands if refrigerated"},{"id":"c","text":"Never shake the vial; roll it instead"},{"id":"d","text":"Aspirate for blood return before injecting"},{"id":"e","text":"Ensure injection into subcutaneous fat"}]'::jsonb,
 ARRAY['a','b','c','e'], true,
 'Sites should be cleaned, refrigerated vials warmed to prevent pain, and vials rolled, never shaken. Insulin is injected subcutaneously. Aspiration for blood return is not required for subcutaneous insulin injections.',
 'Insulin', 143),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A nurse is teaching a client about a basal-bolus regimen using Lispro (rapid-acting) and Glargine (long-acting). Which nursing judgments are correct? Select all that apply. A) Lispro should be given within 15 minutes of the client''s meal. B) Glargine can be mixed with Lispro in a single syringe to reduce injections. C) The Lispro dose will reach its highest effectiveness much faster than Glargine. D) If the client is NPO, the Lispro should likely be held. E) The Glargine will provide steady control for 24 hours without a specific peak.',
 '[{"id":"a","text":"Lispro should be given within 15 minutes of the client''s meal"},{"id":"b","text":"Glargine can be mixed with Lispro in a single syringe"},{"id":"c","text":"Lispro will reach its highest effectiveness much faster than Glargine"},{"id":"d","text":"If the client is NPO, the Lispro should likely be held"},{"id":"e","text":"Glargine provides steady 24-hour control without a specific peak"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'Rapid-acting Lispro requires food within 15 minutes and has a distinct peak. Glargine has no peak and lasts 24 hours. Long-acting insulin cannot be mixed with any other insulin. If the patient is NPO, the rapid-acting dose should be held to prevent hypoglycemia.',
 'Insulin', 144),

-- ============================================
-- DIABETES MELLITUS — SATA (Questions 145–150)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A client has been diagnosed with Type 1 Diabetes. Which characteristics should the nurse include in teaching? Select all that apply. A) It is caused by the autoimmune destruction of beta cells. B) The body stops responding well to insulin due to lifestyle habits. C) It usually results in weight loss and a thin appearance. D) The body breaks down fat and muscle for fuel. E) It typically develops in older adults over the age of 40.',
 '[{"id":"a","text":"Caused by autoimmune destruction of beta cells"},{"id":"b","text":"The body stops responding well to insulin due to lifestyle habits"},{"id":"c","text":"Usually results in weight loss and thin appearance"},{"id":"d","text":"The body breaks down fat and muscle for fuel"},{"id":"e","text":"Typically develops in older adults over age 40"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'Type 1 is an autoimmune reaction destroying beta cells. Without insulin, the body breaks down fat and muscle for fuel, leading to weight loss and a thin appearance. Type 2 is associated with lifestyle factors and typically affects those over 40.',
 'Diabetes Mellitus', 145),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse is assessing a client with Type 2 Diabetes who has gained 20 pounds in the last year. Which statements about Type 2 Diabetes are relevant? Select all that apply. A) Weight gain is commonly seen in Type 2 Diabetes. B) The condition is often seen as a problem with how much a person eats. C) The pancreas produces more insulin to compensate for resistance, which can contribute to weight changes. D) These patients break down muscle for fuel because they have no insulin. E) Lifestyle habits like overeating and inactivity play a big role.',
 '[{"id":"a","text":"Weight gain is commonly seen in Type 2 Diabetes"},{"id":"b","text":"Often seen as a problem with how much a person eats"},{"id":"c","text":"Pancreas overproduces insulin to compensate for resistance"},{"id":"d","text":"Patients break down muscle for fuel because they have no insulin"},{"id":"e","text":"Lifestyle habits like overeating and inactivity play a big role"}]'::jsonb,
 ARRAY['a','b','c','e'], true,
 'Type 2 is associated with weight gain, overeating, sedentary lifestyle, and pancreatic overproduction of insulin to compensate for insulin resistance. Breaking down muscle for fuel is a characteristic of Type 1, not Type 2.',
 'Diabetes Mellitus', 146),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse is assessing a client for signs of hyperglycemia. Which clinical manifestations should the nurse look for? Select all that apply. A) Polydipsia (extreme thirst). B) Diaphoresis (profuse sweating). C) Polyphagia (excessive hunger). D) Blurred vision. E) Dry mucous membranes.',
 '[{"id":"a","text":"Polydipsia (extreme thirst)"},{"id":"b","text":"Diaphoresis (profuse sweating)"},{"id":"c","text":"Polyphagia (excessive hunger)"},{"id":"d","text":"Blurred vision"},{"id":"e","text":"Dry mucous membranes"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'Hyperglycemia signs include polydipsia, polyphagia, blurred vision, and dry mucous membranes due to dehydration. Diaphoresis is a sign of hypoglycemia, not hyperglycemia.',
 'Diabetes Mellitus', 147),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse identifies that a client is experiencing hypoglycemia. Which signs and symptoms should the nurse expect? Select all that apply. A) Diaphoresis (profuse sweating). B) Polyuria (increased urination). C) Tachycardia (rapid heartbeat). D) Shaking or trembling. E) Dizziness and weakness.',
 '[{"id":"a","text":"Diaphoresis (profuse sweating)"},{"id":"b","text":"Polyuria (increased urination)"},{"id":"c","text":"Tachycardia (rapid heartbeat)"},{"id":"d","text":"Shaking or trembling"},{"id":"e","text":"Dizziness and weakness"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'Hypoglycemia symptoms include diaphoresis, tachycardia, trembling, and dizziness/weakness. Polyuria is a symptom of hyperglycemia.',
 'Diabetes Mellitus', 148),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A client has a blood sugar of 50 mg/dL and is conscious but confused. Which actions should the nurse take? Select all that apply. A) Give 15 grams of simple carbs (e.g., 1/2 cup of orange juice). B) Wait 15 minutes and then recheck the blood glucose level. C) If blood glucose is still low, provide complex carbs (carbs + protein). D) Administer a glucagon injection intramuscularly immediately. E) Provide a full meal with 100 grams of carbohydrates.',
 '[{"id":"a","text":"Give 15 grams of simple carbs (e.g., 1/2 cup orange juice)"},{"id":"b","text":"Wait 15 minutes and recheck blood glucose"},{"id":"c","text":"If still low, provide complex carbs (carbs + protein)"},{"id":"d","text":"Administer glucagon IM immediately"},{"id":"e","text":"Provide a full meal with 100 grams of carbohydrates"}]'::jsonb,
 ARRAY['a','b','c'], true,
 'For an alert patient, the 15–15 rule applies: give 15g simple carbs, wait 15 minutes, recheck. If still low, provide complex carbs with protein. Glucagon is reserved for patients who are not alert or cannot swallow safely.',
 'Diabetes Mellitus', 149),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse is teaching a client about "Basal" versus "Bolus" insulin. Which explanations are correct? Select all that apply. A) "Basal insulin is a constant, low-level dose to control fasting blood sugar." B) "Bolus insulin is a larger dose given with meals." C) "Bolus insulin is used to control postprandial glucose levels." D) "Basal insulin should only be used when the patient is exercising." E) "Both types can be delivered through some types of insulin patches."',
 '[{"id":"a","text":"Basal insulin is a constant, low-level dose to control fasting blood sugar"},{"id":"b","text":"Bolus insulin is a larger dose given with meals"},{"id":"c","text":"Bolus insulin controls postprandial glucose levels"},{"id":"d","text":"Basal insulin should only be used when the patient is exercising"},{"id":"e","text":"Both types can be delivered through some insulin patches"}]'::jsonb,
 ARRAY['a','b','c','e'], true,
 'Basal insulin is constant and low-level for fasting sugar control. Bolus insulin is a larger dose given with meals to control postprandial glucose. Both can be delivered via a basal-bolus patch. Basal insulin is not restricted to exercise periods.',
 'Diabetes Mellitus', 150);

-- ============================================
-- VERIFICATION
-- ============================================
SELECT
  tt.name AS topic,
  tt.display_order,
  COUNT(tq.id) AS question_count
FROM test_questions tq
JOIN test_topics tt ON tt.id = tq.topic_id
WHERE tq.test_id = '00000000-0000-0000-0000-000000000004'
  AND tt.subject_id = '10000000-0000-0000-0000-000000000004'
GROUP BY tt.name, tt.display_order
ORDER BY tt.display_order;
