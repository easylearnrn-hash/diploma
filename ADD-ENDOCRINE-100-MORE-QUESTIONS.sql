-- ============================================
-- ENDOCRINE SYSTEM — 100 MORE NCLEX QUESTIONS (SATA)
-- Topics: Diabetes Mellitus, Insulin Patch, Insulin Storage and Checking,
--         Insulin, Mixing of Insulin Guidelines, Metformin
-- display_order: 151–250 (appends to ADD-ENDOCRINE-100-QUESTIONS.sql + ADD-ENDOCRINE-50-MORE-QUESTIONS.sql)
-- Run in Supabase SQL Editor AFTER:
--   1) ADD-ENDOCRINE-SUBJECT.sql
--   2) ADD-ENDOCRINE-100-QUESTIONS.sql
--   3) ADD-ENDOCRINE-50-MORE-QUESTIONS.sql
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
-- METFORMIN (Questions 151–163)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A nurse is reviewing the lab results for a client with Type 2 diabetes who has been on Metformin for six months. Which findings require an immediate change in the clinical plan? Select all that apply. A) A serum creatinine level indicating declining renal function. B) A Hemoglobin A1C (HbA1c) result of 7.4%. C) A fasting blood glucose of 108 mg/dL. D) A report of abdominal bloating and dyspepsia. E) The client is scheduled for an IV contrast study tomorrow.',
 '[{"id":"a","text":"Serum creatinine indicates declining renal function"},{"id":"b","text":"HbA1c result of 7.4%"},{"id":"c","text":"Fasting blood glucose of 108 mg/dL"},{"id":"d","text":"Abdominal bloating and dyspepsia"},{"id":"e","text":"Scheduled for IV contrast study tomorrow"}]'::jsonb,
 ARRAY['a','b','e'], true,
 'Declining renal function requires reassessment/holding metformin due to risk of accumulation and toxicity. HbA1c >7% indicates inadequate control and need to consider additional/alternative therapy. Metformin must be held prior to contrast studies. Bloating/dyspepsia are common GI side effects. Fasting 108 mg/dL is within the 70–110 range.',
 'Metformin', 151),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client on Metformin complains of "stomach issues." Which symptoms are recognized side effects in the document? Select all that apply. A) Abdominal distention. B) Constipation. C) Dyspepsia. D) Jaundice. E) Diarrhea.',
 '[{"id":"a","text":"Abdominal distention"},{"id":"b","text":"Constipation"},{"id":"c","text":"Dyspepsia"},{"id":"d","text":"Jaundice"},{"id":"e","text":"Diarrhea"}]'::jsonb,
 ARRAY['a','b','c','e'], true,
 'The referenced material lists GI side effects including abdominal distention/bloating, constipation, dyspepsia, and diarrhea. Jaundice is not listed as a common expected effect in that document context.',
 'Metformin', 152),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client is prescribed Metformin twice a day. What teaching regarding timing and safety is most important? Select all that apply. A) Take the medication after your meals. B) If scheduled for surgery, stop the medication 24 hours prior. C) You will need a kidney panel every 6 months. D) If you miss a dose, take a double dose with your next meal. E) Check your HbA1c after 3 months to see if the drug is effective.',
 '[{"id":"a","text":"Take the medication after your meals"},{"id":"b","text":"Stop the medication 24 hours prior to surgery"},{"id":"c","text":"You will need a kidney panel every 6 months"},{"id":"d","text":"If you miss a dose, double the next dose"},{"id":"e","text":"Check HbA1c after 3 months"}]'::jsonb,
 ARRAY['a','b','c','e'], true,
 'Metformin is taken after meals to reduce GI upset. It must be stopped 24 hours before surgery and contrast procedures. Kidney function monitoring is recommended every 6 months. HbA1c reflects ~3 months. Doubling doses is unsafe.',
 'Metformin', 153),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client with Type 2 diabetes is scheduled for elective surgery in 48 hours and a CT scan with contrast today. Which instructions regarding Metformin are correct? Select all that apply. A) Stop taking Metformin 24 hours before the CT scan today. B) Continue taking Metformin until the morning of surgery. C) If you accidentally took Metformin today, we must reschedule the CT scan. D) You can resume Metformin immediately after the CT scan is finished. E) Stop taking Metformin 24 hours before your surgery.',
 '[{"id":"a","text":"Stop Metformin 24 hours before the CT scan"},{"id":"b","text":"Continue Metformin until the morning of surgery"},{"id":"c","text":"If taken by mistake, reschedule the CT scan"},{"id":"d","text":"Resume Metformin immediately after the CT scan"},{"id":"e","text":"Stop Metformin 24 hours before surgery"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'Metformin should be held 24 hours before both contrast studies and surgery per the provided guidance. If the client took it, the contrast study is rescheduled and the provider is notified. Immediate resumption after contrast is not advised without verifying renal function and provider direction.',
 'Metformin', 154),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A nurse is preparing a client for a procedure with contrast dye and the client took Metformin this morning. What is the priority nursing intervention? Select all that apply. A) Reschedule the procedure. B) Notify the healthcare provider. C) Administer a bolus of IV fluids to protect the kidneys. D) Document that the medication was taken by mistake. E) Proceed with the procedure but check a kidney panel in 2 hours.',
 '[{"id":"a","text":"Reschedule the procedure"},{"id":"b","text":"Notify the healthcare provider"},{"id":"c","text":"Administer a bolus of IV fluids"},{"id":"d","text":"Document that the medication was taken by mistake"},{"id":"e","text":"Proceed but check renal labs in 2 hours"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'If Metformin is taken prior to contrast, the priority is to notify the provider, reschedule the study, and document the event. Proceeding increases risk if renal function declines from contrast; fluids may be ordered but do not replace holding/rescheduling per this protocol.',
 'Metformin', 155),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client taking Metformin reports frequent diarrhea and bloating. What should the nurse advise? Select all that apply. A) Stop the medication immediately as these are signs of kidney failure. B) Ensure you are taking the medication after meals. C) These are common side effects that often occur with Metformin. D) We need to check your HbA1c to see if the dose is too high. E) Drink plenty of water unless contraindicated, and keep follow-up labs as scheduled.',
 '[{"id":"a","text":"Stop the medication immediately"},{"id":"b","text":"Take the medication after meals"},{"id":"c","text":"These can be common side effects"},{"id":"d","text":"Check HbA1c to see if the dose is too high"},{"id":"e","text":"Hydrate unless contraindicated and keep follow-up labs"}]'::jsonb,
 ARRAY['b','c','e'], true,
 'GI upset is common with metformin and is often improved by taking it after meals. These symptoms alone are not kidney failure; renal monitoring is done via labs. General hydration advice applies unless restricted for another condition.',
 'Metformin', 156),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A nurse is scheduled to review a Metformin patient''s kidney panel. What are the clinical reasons? Select all that apply. A) Metformin can be toxic to the kidneys. B) To check if Metformin is successfully lowering blood sugar. C) To ensure the client can safely continue the medication. D) To monitor for dyspepsia. E) To screen for atherosclerosis.',
 '[{"id":"a","text":"Metformin can be toxic to the kidneys"},{"id":"b","text":"To check if Metformin is lowering blood sugar"},{"id":"c","text":"To ensure it is safe to continue"},{"id":"d","text":"To monitor for dyspepsia"},{"id":"e","text":"To screen for atherosclerosis"}]'::jsonb,
 ARRAY['a','c'], true,
 'Renal panels are used to ensure metformin can be continued safely because impaired renal function increases risk of accumulation and complications. Blood sugar control is monitored with glucose/A1c, not the kidney panel.',
 'Metformin', 157),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A nurse is reviewing Metformin therapy after three months. Which results indicate a need to change the current treatment plan? Select all that apply. A) HbA1c of 7.2%. B) Fasting blood glucose of 105 mg/dL. C) Blood glucose level of 180 mg/dL. D) A kidney panel showing declining renal function. E) HbA1c of 6.5%.',
 '[{"id":"a","text":"HbA1c of 7.2%"},{"id":"b","text":"Fasting blood glucose of 105 mg/dL"},{"id":"c","text":"Blood glucose level of 180 mg/dL"},{"id":"d","text":"Kidney panel showing declining renal function"},{"id":"e","text":"HbA1c of 6.5%"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'HbA1c >7% suggests poor control requiring additional/alternative therapy. A glucose of 180 mg/dL suggests hyperglycemia/poor control. Declining renal function requires reassessing metformin. Fasting 105 and HbA1c 6.5 are within/near target in this document context.',
 'Metformin', 158),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client is scheduled for an IV contrast study tomorrow. Which nursing actions related to Metformin are appropriate? Select all that apply. A) Confirm Metformin has been held per protocol. B) Teach the client to stop Metformin 24 hours prior. C) Encourage the client to take an extra dose to improve imaging. D) Notify the provider if the client took Metformin within the last 24 hours. E) Document teaching and provider notification as applicable.',
 '[{"id":"a","text":"Confirm Metformin has been held"},{"id":"b","text":"Teach to stop Metformin 24 hours prior"},{"id":"c","text":"Take an extra dose"},{"id":"d","text":"Notify provider if taken within 24 hours"},{"id":"e","text":"Document teaching/notification"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Metformin should be held prior to contrast studies per protocol. If taken, the provider/team must be notified and the study may need rescheduling. Extra dosing is unsafe and inappropriate.',
 'Metformin', 159),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'Which findings are NOT typically reasons by themselves to stop Metformin immediately (assuming no other red flags)? Select all that apply. A) Mild abdominal bloating. B) Dyspepsia that improves when taken with food. C) Fasting glucose of 108 mg/dL. D) Stable kidney function on recent labs. E) Scheduled surgery tomorrow morning.',
 '[{"id":"a","text":"Mild abdominal bloating"},{"id":"b","text":"Dyspepsia that improves when taken with food"},{"id":"c","text":"Fasting glucose of 108 mg/dL"},{"id":"d","text":"Stable kidney function on recent labs"},{"id":"e","text":"Scheduled surgery tomorrow morning"}]'::jsonb,
 ARRAY['a','b','c','d'], true,
 'GI upset and fasting 108 can be expected/acceptable. Stable renal labs support ongoing therapy. Surgery tomorrow does require holding metformin per protocol.',
 'Metformin', 160),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A nurse is teaching a client why kidney testing is required while taking Metformin. Which statements are accurate? Select all that apply. A) If kidneys do not clear Metformin, the drug can accumulate and become unsafe. B) Kidney testing is done every 6 months in this protocol. C) Kidney testing replaces the need for HbA1c checks. D) Contrast dye can temporarily worsen kidney function. E) Taking Metformin when kidneys are impaired can increase risk of serious complications.',
 '[{"id":"a","text":"If kidneys don''t clear Metformin, it can accumulate and become unsafe"},{"id":"b","text":"Kidney testing is done every 6 months in this protocol"},{"id":"c","text":"Kidney testing replaces HbA1c"},{"id":"d","text":"Contrast dye can temporarily worsen kidney function"},{"id":"e","text":"Impaired kidneys plus Metformin increases risk of serious complications"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Metformin is cleared renally; impaired function allows accumulation, increasing risk. The protocol calls for periodic kidney panels (not replacing HbA1c). Contrast can worsen renal function, which is why metformin is held.',
 'Metformin', 161),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client''s HbA1c is 7.5% after consistent Metformin use and lifestyle changes. Which nursing interpretations are correct? Select all that apply. A) This value suggests diabetes is not at goal (<7%). B) The provider may add or change medications, possibly including insulin. C) This proves the client is noncompliant. D) A reassessment of diet/exercise and medication plan is warranted. E) Metformin should automatically be doubled without provider involvement.',
 '[{"id":"a","text":"Not at goal (<7%)"},{"id":"b","text":"Provider may add/change meds, possibly insulin"},{"id":"c","text":"Proves noncompliance"},{"id":"d","text":"Reassess plan"},{"id":"e","text":"Automatically double Metformin"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'HbA1c >7% suggests the current plan is not achieving targets; additional therapy may be needed. It does not prove noncompliance by itself. Medication changes require provider direction.',
 'Metformin', 162),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A client is scheduled for contrast tomorrow and elective surgery next week. Which planning steps should the nurse coordinate related to Metformin? Select all that apply. A) Ensure Metformin is held 24 hours before the contrast study. B) Ensure Metformin is held 24 hours before surgery. C) Encourage the client to store Metformin in the car for easy access. D) Coordinate lab follow-up for kidney function as ordered. E) Reinforce taking Metformin on an empty stomach to reduce nausea.',
 '[{"id":"a","text":"Hold 24 hours before contrast"},{"id":"b","text":"Hold 24 hours before surgery"},{"id":"c","text":"Store Metformin in the car"},{"id":"d","text":"Coordinate kidney lab follow-up as ordered"},{"id":"e","text":"Take on an empty stomach"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'Metformin should be held before contrast and surgery per protocol. Kidney function may need follow-up after contrast depending on provider plan. Taking metformin after meals reduces GI irritation; storing meds in a car is unsafe for many meds and not advised here.',
 'Metformin', 163),

-- ============================================
-- INSULIN PATCH (Questions 164–182)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client is utilizing a basal-bolus insulin patch pump. Which scenario-based instructions are essential for safety? Select all that apply. A) If you remove the patch for more than a few hours, you are at risk for DKA. B) The patch uses rapid-acting insulin, so it must be clear in appearance. C) You must change the infusion set every 4 days to ensure the site rests. D) Hypoglycemia is a risk if the infusion set becomes blocked. E) Rotate the site daily to prevent hard, lumpy fat deposits.',
 '[{"id":"a","text":"Removing the patch for more than a few hours increases DKA risk"},{"id":"b","text":"Patch uses rapid-acting insulin and should be clear"},{"id":"c","text":"Change the infusion set every 4 days"},{"id":"d","text":"Blocked infusion set causes hypoglycemia"},{"id":"e","text":"Rotate the site daily to prevent lipodystrophy"}]'::jsonb,
 ARRAY['a','b','e'], true,
 'Removing the pump stops insulin delivery, increasing DKA risk. Patch pumps typically use rapid-acting insulin, which is clear. Sites must be rotated to prevent lipodystrophy. Infusion sets are changed every 2–3 days; blockage causes hyperglycemia, not hypoglycemia.',
 'Insulin Patch', 164),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client with Type 1 Diabetes is switched to a basal-bolus insulin patch. Which teaching points are critical for preventing DKA? Select all that apply. A) The patch delivers a continuous steady dose through the skin. B) If the infusion becomes blocked, you may develop DKA. C) Do not remove the patch for long periods. D) The patch automatically checks blood sugar every hour. E) Keep a backup supply of long-acting insulin in case the device fails.',
 '[{"id":"a","text":"Patch delivers a continuous steady dose through the skin"},{"id":"b","text":"Blocked infusion means no insulin and DKA risk"},{"id":"c","text":"Do not remove the patch for long periods"},{"id":"d","text":"Automatically checks blood sugar every hour"},{"id":"e","text":"Keep backup long-acting insulin"}]'::jsonb,
 ARRAY['b','c','e'], true,
 'DKA risk rises when insulin delivery is interrupted (blocked set or patch removal) and when no backup long-acting insulin is available. These devices do not automatically check glucose; monitoring is still required.',
 'Insulin Patch', 165),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client on an Insulet Omnipod is exercising. Which teaching is appropriate about blood sugar changes? Select all that apply. A) Vigorous exercise can cause blood sugar to spike. B) Exercise will always drop blood sugar immediately. C) The body may release stored glucose (glycogen) from the liver. D) The Omnipod will automatically adjust insulin if you start running. E) Check blood sugar because exercise can affect glucose levels.',
 '[{"id":"a","text":"Vigorous exercise can sometimes cause a spike"},{"id":"b","text":"Exercise will always drop blood sugar immediately"},{"id":"c","text":"Body may release stored glucose (glycogen) from liver"},{"id":"d","text":"Omnipod automatically adjusts insulin during running"},{"id":"e","text":"Check blood sugar because exercise affects glucose"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'Exercise can trigger hepatic glycogen release, sometimes causing transient hyperglycemia. Blood glucose should be monitored. Automatic adjustment depends on specific closed-loop systems and is not assumed in this basic teaching.',
 'Insulin Patch', 166),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client on an insulin patch pump is going for a 5-day hiking trip. What advice is essential? Select all that apply. A) Change the infusion set every 2–3 days. B) Do not leave the set for 4 or more days. C) Keep backup insulin in a temperature-controlled environment, not a car. D) You do not need to check blood sugar while hiking. E) If the pump is removed for a long time, you could develop DKA.',
 '[{"id":"a","text":"Change infusion set every 2–3 days"},{"id":"b","text":"Do not leave the set for 4+ days"},{"id":"c","text":"Keep backup insulin temperature-controlled, not in a car"},{"id":"d","text":"No need to check blood sugar while hiking"},{"id":"e","text":"Pump removal for long time increases DKA risk"}]'::jsonb,
 ARRAY['a','b','c','e'], true,
 'Infusion sets should be changed every 48–72 hours. Insulin must be protected from temperature extremes. Glucose monitoring is still required. Prolonged pump removal interrupts insulin delivery and increases DKA risk.',
 'Insulin Patch', 167),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client on a patch pump is going for a long walk. Which instructions are appropriate? Select all that apply. A) Vigorous exercise can cause a temporary spike in blood sugar. B) Your body might release stored glucose (glycogen) for energy. C) Check blood sugar before and after your walk. D) If you remove the patch for the walk, you do not need to worry about DKA. E) The patch will automatically stop insulin if your sugar gets too low.',
 '[{"id":"a","text":"Exercise can cause temporary spike"},{"id":"b","text":"Body may release stored glycogen"},{"id":"c","text":"Check blood sugar before/after"},{"id":"d","text":"Removing patch is safe re: DKA"},{"id":"e","text":"Patch automatically stops insulin for lows"}]'::jsonb,
 ARRAY['a','b','c'], true,
 'Exercise can raise glucose due to glycogen release. Monitoring is essential. Removing the patch increases risk for hyperglycemia/DKA. Automatic shutoff is not assumed in this basic patch teaching.',
 'Insulin Patch', 168),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A client using an insulin patch is found unconscious. What are the priority nursing interventions? Select all that apply. A) Provide 15g simple carbohydrates orally. B) Administer glucagon IM. C) Administer D50W IV. D) Recheck blood glucose in 15 minutes. E) Administer a bolus of insulin via the controller.',
 '[{"id":"a","text":"Provide oral carbohydrates"},{"id":"b","text":"Administer glucagon IM"},{"id":"c","text":"Administer D50W IV"},{"id":"d","text":"Recheck blood glucose in 15 minutes"},{"id":"e","text":"Give insulin bolus"}]'::jsonb,
 ARRAY['b','c','d'], true,
 'Unconscious patients cannot safely take oral carbs. Treat severe hypoglycemia with glucagon IM or IV dextrose, and recheck glucose. Insulin bolus would worsen hypoglycemia.',
 'Insulin Patch', 169),

-- ============================================
-- INSULIN STORAGE AND CHECKING (Questions 183–194)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A nurse is evaluating a client''s technique for checking blood sugar. Which actions indicate the client needs more education? Select all that apply. A) Uses the very first drop of blood for the meter. B) Cleans finger with alcohol before prick. C) Shakes the insulin vial before checking blood sugar. D) Applies the second drop of blood to the test strip. E) Inserts the strip into the meter after applying blood.',
 '[{"id":"a","text":"Uses the first drop of blood"},{"id":"b","text":"Cleans finger with alcohol"},{"id":"c","text":"Shakes insulin vial before checking"},{"id":"d","text":"Uses second drop"},{"id":"e","text":"Inserts strip after applying blood"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'The first drop should be wiped away; the second is used. The strip must be inserted into the meter before applying blood. Shaking insulin is improper handling.',
 'Insulin Storage and Checking', 183),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A nurse is preparing to perform a fingerstick blood glucose test. Which actions promote accuracy and safety? Select all that apply. A) Cleaning the site with alcohol. B) Pricking the center of the finger pad for the most blood. C) Wiping away the first drop of blood. D) Using the second drop of blood for the test strip. E) Applying pressure with an alcohol swab after the prick.',
 '[{"id":"a","text":"Clean site with alcohol"},{"id":"b","text":"Prick the center of the finger pad"},{"id":"c","text":"Wipe away first drop"},{"id":"d","text":"Use second drop"},{"id":"e","text":"Apply pressure after the prick"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'Cleaning, wiping the first drop, using the second, and applying pressure afterward are correct steps. Pricking the side of the fingertip is generally preferred; the document focus here is wiping first drop and using second.',
 'Insulin Storage and Checking', 184),

-- ============================================
-- INSULIN (Questions 195–216)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Which teaching points regarding long-acting insulin (Glargine) are consistent? Select all that apply. A) This insulin is clear and should not be rolled. B) You can mix this with Regular insulin. C) It should be taken at the same time every day, usually before bed. D) A bedtime snack is recommended to prevent hypoglycemia during the night. E) This insulin will peak about 6 hours after you take it.',
 '[{"id":"a","text":"Clear and should not be rolled"},{"id":"b","text":"Can be mixed with Regular"},{"id":"c","text":"Take at same time daily, usually before bed"},{"id":"d","text":"Bedtime snack recommended"},{"id":"e","text":"Peaks about 6 hours after"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'Glargine is clear, long-acting, taken consistently (often at bedtime) and has no peak. It cannot be mixed with any other insulin.',
 'Insulin', 195),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Which characteristics are specific to NPH (intermediate-acting) insulin? Select all that apply. A) Identified by the letter N. B) Peak time of 2 hours. C) Appears cloudy and must be rolled. D) Can be administered IV if Regular is unavailable. E) Should be given with a food tray about 6 hours after administration.',
 '[{"id":"a","text":"Identified by the letter N"},{"id":"b","text":"Peak time of 2 hours"},{"id":"c","text":"Cloudy and must be rolled"},{"id":"d","text":"Can be given IV"},{"id":"e","text":"Food tray needed around 6 hours after"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'NPH is intermediate-acting (N), cloudy and rolled gently, peaks around 6 hours (meal/snack needed). It is subcutaneous only, never IV.',
 'Insulin', 196),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A nurse is preparing Lispro insulin for a client. What are the essential administration rules? Select all that apply. A) The insulin should be clear. B) Provide the food tray 2 hours after injection. C) Ensure the food tray is available within 15 minutes of injection. D) Administer via the subcutaneous route. E) Roll the vial for 1 minute before drawing.',
 '[{"id":"a","text":"Insulin should be clear"},{"id":"b","text":"Food tray 2 hours after"},{"id":"c","text":"Food tray within 15 minutes"},{"id":"d","text":"Administer subcutaneously"},{"id":"e","text":"Roll vial for 1 minute"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'Lispro is rapid-acting, clear, and given subcutaneously with food available within 15 minutes. Two-hour timing is for Regular peak. Rolling may be used to warm refrigerated insulin; it is not required as a mixing step for clear insulin.',
 'Insulin', 197),

-- ============================================
-- MIXING OF INSULIN (Questions 217–232)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A nurse is preparing to mix NPH and Regular insulin. Which student actions require instructor intervention? Select all that apply. A) Injecting air into the Regular vial before injecting air into the NPH vial. B) Drawing up the NPH insulin before the Regular insulin. C) Shaking the NPH vial to mix the suspension. D) Withdrawing 10 units of air total for a 4u R/6u N dose. E) Wiping the tops of both vials with alcohol before starting.',
 '[{"id":"a","text":"Injecting air into Regular before NPH"},{"id":"b","text":"Drawing NPH before Regular"},{"id":"c","text":"Shaking the NPH vial"},{"id":"d","text":"Withdrawing 10 units of air total"},{"id":"e","text":"Wiping vial tops with alcohol"}]'::jsonb,
 ARRAY['a','b','c'], true,
 'NR-RN requires air into N first, then air into R. Regular (clear) must be drawn before NPH (cloudy) to prevent contamination. Insulin is rolled, never shaken. Wiping vial tops is correct.',
 'Mixing of Insulin Guidelines', 217),

-- ============================================
-- DIABETES MELLITUS (Questions 233–250)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A client with Type 1 Diabetes presents with headache, blurred vision, and polyuria. What is the physiological basis for these symptoms? Select all that apply. A) Breaking down muscle and fat for energy due to lack of insulin. B) High glucose causes fluid shifts that affect vision. C) Alpha cells overproduce insulin to compensate. D) Liver saturated and converts excess glucose into fat. E) Body activates more sugars in the morning to wake up.',
 '[{"id":"a","text":"Breakdown of muscle and fat due to lack of insulin"},{"id":"b","text":"High glucose causes fluid shifts affecting vision"},{"id":"c","text":"Alpha cells overproduce insulin"},{"id":"d","text":"Liver converts excess glucose into fat when saturated"},{"id":"e","text":"Body activates sugars in morning to wake up"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'In Type 1 diabetes, lack of insulin leads to fat/muscle breakdown for fuel. Hyperglycemia causes osmotic fluid shifts that can blur vision, and excess glucose can be stored as fat when the liver is saturated. Morning sugar activation (dawn phenomenon teaching) can contribute to elevated morning glucose. Alpha cells produce glucagon, not insulin.',
 'Diabetes Mellitus', 233),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which statements regarding the Rule of 15 for an alert hypoglycemic patient are correct? Select all that apply. A) 15g simple carbs can be found in 1/2 cup of milk. B) 15g simple carbs can be found in 1/2 cup of orange juice. C) If still low after 15 minutes, give 15g of complex carbs. D) Check blood glucose 15 minutes after the first carbohydrate dose. E) Simple carbs keep sugar in the blood longer than proteins.',
 '[{"id":"a","text":"15g simple carbs: 1/2 cup milk"},{"id":"b","text":"15g simple carbs: 1/2 cup orange juice"},{"id":"c","text":"If still low, give complex carbs"},{"id":"d","text":"Recheck glucose after 15 minutes"},{"id":"e","text":"Simple carbs keep sugar longer than proteins"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'Milk and 1/2 cup juice are common 15g simple carb options in this protocol. Recheck glucose after 15 minutes. If still low, repeat simple carbs; complex carbs are used after stabilization. Protein helps sustain glucose longer than simple carbs.',
 'Diabetes Mellitus', 234),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse is documenting risk factors for Type 2 Diabetes. Which entries are appropriate? Select all that apply. A) BMI 32 (overweight). B) Sedentary lifestyle. C) Autoimmune destruction of beta cells. D) Age 45 years. E) HbA1c 6.2% (prediabetes).',
 '[{"id":"a","text":"BMI 32 (overweight)"},{"id":"b","text":"Sedentary lifestyle"},{"id":"c","text":"Autoimmune destruction of beta cells"},{"id":"d","text":"Age 45 years"},{"id":"e","text":"HbA1c 6.2% (prediabetes)"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Type 2 risk factors include overweight, sedentary lifestyle, age >40, and prediabetes range A1c. Autoimmune beta-cell destruction describes Type 1 diabetes.',
 'Diabetes Mellitus', 235),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A client has a postprandial glucose of 160 mg/dL. How should the nurse interpret this? Select all that apply. A) Within normal postprandial range. B) Hyperglycemia. C) Exceeds postprandial target of <140 mg/dL. D) Needs glucagon. E) Normal fasting level.',
 '[{"id":"a","text":"Within normal postprandial range"},{"id":"b","text":"Hyperglycemia"},{"id":"c","text":"Exceeds postprandial target <140 mg/dL"},{"id":"d","text":"Needs glucagon"},{"id":"e","text":"Normal fasting level"}]'::jsonb,
 ARRAY['b','c'], true,
 'Postprandial glucose is typically targeted to remain below 140 mg/dL in this document set. A reading of 160 indicates hyperglycemia. Glucagon is for hypoglycemia.',
 'Diabetes Mellitus', 236),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which physiological processes occur during morning hyperglycemia? Select all that apply. A) Body activates sugars to provide energy for waking. B) Pancreas releases a surge of insulin at 5 AM. C) Liver releases stored glycogen (glucose depot). D) Alpha cells release glucagon. E) Beta cells release amylase.',
 '[{"id":"a","text":"Body activates sugars to wake up"},{"id":"b","text":"Pancreas surge of insulin at 5 AM"},{"id":"c","text":"Liver releases stored glycogen"},{"id":"d","text":"Alpha cells release glucagon"},{"id":"e","text":"Beta cells release amylase"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'Morning hyperglycemia teaching emphasizes physiologic sugar activation: hepatic glycogen release (depot) driven by counter-regulatory hormones such as glucagon from alpha cells. Beta cells produce insulin; amylase is an exocrine enzyme, not released by beta cells.',
 'Diabetes Mellitus', 237),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A client has an HbA1c of 8.5%. What does this indicate? Select all that apply. A) The client has diabetes. B) Poor control over the last 3 months. C) Prediabetes. D) May need insulin if currently only on Metformin. E) At target.',
 '[{"id":"a","text":"Has diabetes"},{"id":"b","text":"Poor control over ~3 months"},{"id":"c","text":"Prediabetes"},{"id":"d","text":"May need insulin if only on Metformin"},{"id":"e","text":"At target"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'An A1c >7% indicates diabetes not at goal and poor glycemic control, reflecting ~3 months. This may prompt adding medications such as insulin if lifestyle/metformin are inadequate. Prediabetes is 6.0–6.5%.',
 'Diabetes Mellitus', 238),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A client''s blood sugar is 75 mg/dL. How should the nurse interpret this? Select all that apply. A) Within normal range. B) Hypoglycemia. C) No immediate low-sugar intervention needed. D) Hyperglycemia. E) Monitor for symptoms.',
 '[{"id":"a","text":"Within normal range"},{"id":"b","text":"Hypoglycemia"},{"id":"c","text":"No immediate low-sugar intervention needed"},{"id":"d","text":"Hyperglycemia"},{"id":"e","text":"Monitor for symptoms"}]'::jsonb,
 ARRAY['a','c','e'], true,
 'Normal range is 70–110 mg/dL in this document set. A value of 75 is normal but near the lower end; monitor for symptoms and trends, especially if insulin was recently given.',
 'Diabetes Mellitus', 239),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which clinical manifestations are associated with hyperglycemia? Select all that apply. A) Polydipsia. B) Polyuria. C) Pale, clammy skin. D) Blurred vision. E) Fatigue.',
 '[{"id":"a","text":"Polydipsia"},{"id":"b","text":"Polyuria"},{"id":"c","text":"Pale, clammy skin"},{"id":"d","text":"Blurred vision"},{"id":"e","text":"Fatigue"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Hyperglycemia causes polydipsia, polyuria, blurred vision, and fatigue. Pale/clammy skin is more consistent with hypoglycemia.',
 'Diabetes Mellitus', 240),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse explains excess glucose storage in diabetes. What happens when the liver is saturated? Select all that apply. A) Stored as fat in abdomen. B) Stored as fat under skin. C) Converted into pancreatic enzymes. D) Contributes to atherosclerosis. E) Released by alpha cells to raise sugar.',
 '[{"id":"a","text":"Stored as fat in the abdomen"},{"id":"b","text":"Stored as fat under the skin"},{"id":"c","text":"Converted into pancreatic enzymes"},{"id":"d","text":"Contributes to atherosclerosis"},{"id":"e","text":"Released by alpha cells to raise sugar"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'When glycogen storage is saturated, excess glucose is stored as fat in the body (including abdominal/subcutaneous deposits). These processes are linked to atherosclerosis risk. Alpha cells release glucagon, not glucose.',
 'Diabetes Mellitus', 241),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse teaches about atherosclerosis in diabetes. Which statements are correct? Select all that apply. A) Plaque buildup in blood vessels. B) Associated with excess glucose storage. C) Caused by lack of amylase. D) Linked to fat storage when liver saturated. E) Prevented by rotating injection sites.',
 '[{"id":"a","text":"Plaque buildup in blood vessels"},{"id":"b","text":"Associated with excess glucose storage"},{"id":"c","text":"Caused by lack of amylase"},{"id":"d","text":"Linked to fat storage when liver saturated"},{"id":"e","text":"Prevented by rotating injection sites"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'Atherosclerosis is plaque buildup and is associated with metabolic effects of excess glucose storage, including fat storage when glycogen capacity is exceeded. Injection site rotation prevents lipodystrophy, not atherosclerosis.',
 'Diabetes Mellitus', 242),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which characteristics distinguish Type 1 Diabetes from Type 2? Select all that apply. A) Type 1 is autoimmune. B) Type 2 is insulin resistance. C) Type 1 patients are usually overweight. D) Type 1 causes muscle breakdown for fuel. E) Type 2 often develops over age 40.',
 '[{"id":"a","text":"Type 1 is autoimmune"},{"id":"b","text":"Type 2 is insulin resistance"},{"id":"c","text":"Type 1 patients are usually overweight"},{"id":"d","text":"Type 1 causes muscle breakdown for fuel"},{"id":"e","text":"Type 2 often develops over age 40"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Type 1 is autoimmune destruction of beta cells with catabolism (fat/muscle breakdown). Type 2 is characterized by insulin resistance and commonly develops later in life.',
 'Diabetes Mellitus', 243),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse is teaching a client where to inject insulin. Which statements are accurate? Select all that apply. A) Buttocks or thighs are options. B) Inject exactly 1 inch from the belly button. C) Abdomen is preferred site. D) Rotate sites daily. E) Upper arms (posterior/under biceps area) can be used.',
 '[{"id":"a","text":"Buttocks or thighs are options"},{"id":"b","text":"Inject exactly 1 inch from belly button"},{"id":"c","text":"Abdomen is preferred site"},{"id":"d","text":"Rotate sites daily"},{"id":"e","text":"Upper arms can be used"}]'::jsonb,
 ARRAY['a','c','d','e'], true,
 'Common subcutaneous sites include abdomen (preferred for consistent absorption), thighs, buttocks, and upper arms. Sites should be rotated daily to prevent lipodystrophy. Teach 1.5–2 inches away from the umbilicus, not 1 inch.',
 'Diabetes Mellitus', 244),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse assesses for polyphagia. What will the client report? Select all that apply. A) Constant thirst. B) Hungry all the time. C) Urinating more than usual. D) Cannot get enough to eat. E) Blurry vision.',
 '[{"id":"a","text":"Constant thirst"},{"id":"b","text":"Hungry all the time"},{"id":"c","text":"Urinating more than usual"},{"id":"d","text":"Cannot get enough to eat"},{"id":"e","text":"Blurry vision"}]'::jsonb,
 ARRAY['b','d'], true,
 'Polyphagia means excessive hunger. Thirst is polydipsia, and increased urination is polyuria.',
 'Diabetes Mellitus', 245),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A nurse is teaching a client about symptoms of hyperglycemia. Which should be reported? Select all that apply. A) Polydipsia. B) Polyphagia. C) Diaphoresis. D) Polyuria. E) Blurred vision.',
 '[{"id":"a","text":"Polydipsia"},{"id":"b","text":"Polyphagia"},{"id":"c","text":"Diaphoresis"},{"id":"d","text":"Polyuria"},{"id":"e","text":"Blurred vision"}]'::jsonb,
 ARRAY['a','b','d','e'], true,
 'Hyperglycemia commonly presents with the 3 Ps (polydipsia, polyphagia, polyuria) and blurred vision. Diaphoresis is more consistent with hypoglycemia.',
 'Diabetes Mellitus', 246),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A client is alert with glucose 65 mg/dL. According to the Rule of 15, which actions are correct? Select all that apply. A) Give 15g simple carbs. B) Give a high-protein sandwich immediately. C) Wait 15 minutes and recheck. D) If still low, repeat 15g simple carbs. E) Give 15g complex carbs if still low on the second check.',
 '[{"id":"a","text":"Give 15g simple carbs"},{"id":"b","text":"Give high-protein sandwich immediately"},{"id":"c","text":"Wait 15 minutes and recheck"},{"id":"d","text":"If still low, repeat 15g simple carbs"},{"id":"e","text":"Give complex carbs if still low on second check"}]'::jsonb,
 ARRAY['a','c','d'], true,
 'Rule of 15: give 15g simple carbs, wait 15 minutes, recheck. If still low, repeat simple carbs. Complex carbs/protein are used after stabilization, not as the immediate repeat dose.',
 'Diabetes Mellitus', 247),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A client is found unconscious with glucose 42 mg/dL. What are priority actions? Select all that apply. A) Give glucagon IM. B) Give D50W IV. C) Place simple carbs in buccal area. D) Recheck glucose in 15 minutes. E) Give Regular insulin.',
 '[{"id":"a","text":"Administer glucagon IM"},{"id":"b","text":"Administer D50W IV"},{"id":"c","text":"Place oral carbs in buccal area"},{"id":"d","text":"Recheck glucose in 15 minutes"},{"id":"e","text":"Administer Regular insulin"}]'::jsonb,
 ARRAY['a','b','d'], true,
 'Unconscious patients require parenteral treatment (glucagon IM or IV dextrose). Oral carbs are unsafe due to aspiration risk. Recheck glucose after treatment; insulin would worsen hypoglycemia.',
 'Diabetes Mellitus', 248),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which simple carbohydrate options approximate 15g for hypoglycemia treatment in this protocol? Select all that apply. A) 1/2 cup orange juice. B) 1/2 can regular soda. C) 1/2 cup milk. D) 1 slice bread with butter. E) 1 cup apple juice.',
 '[{"id":"a","text":"1/2 cup orange juice"},{"id":"b","text":"1/2 can regular soda"},{"id":"c","text":"1/2 cup milk"},{"id":"d","text":"1 slice bread with butter"},{"id":"e","text":"1 cup apple juice"}]'::jsonb,
 ARRAY['a','b','c'], true,
 'The protocol lists 15g simple carb options such as 1/2 cup juice, 1/2 can regular soda, or 1/2 cup milk. Bread is complex, and 1 cup juice is typically ~30g.',
 'Diabetes Mellitus', 249),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'What is the role of GLUT-4 in glucose regulation? Select all that apply. A) It is a glucose transporter. B) Activated when insulin binds receptors. C) Moves glucose into fat and muscle cells. D) Breaks down lipids. E) Produced by alpha cells.',
 '[{"id":"a","text":"Glucose transporter"},{"id":"b","text":"Activated when insulin binds receptors"},{"id":"c","text":"Moves glucose into fat and muscle cells"},{"id":"d","text":"Breaks down lipids"},{"id":"e","text":"Produced by alpha cells"}]'::jsonb,
 ARRAY['a','b','c'], true,
 'GLUT-4 is an insulin-responsive glucose transporter that translocates to the cell membrane when insulin binds its receptor, allowing glucose entry into muscle and fat cells.',
 'Diabetes Mellitus', 250);

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
