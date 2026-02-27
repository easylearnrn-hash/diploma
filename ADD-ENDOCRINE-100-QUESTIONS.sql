-- ============================================
-- ENDOCRINE SYSTEM — 100 NCLEX QUESTIONS
-- Topics: Diabetes Mellitus, Insulin Patch, Insulin Storage and Checking,
--         Insulin, Mixing of Insulin Guidelines, Metformin
-- Run in Supabase SQL Editor AFTER ADD-ENDOCRINE-SUBJECT.sql
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
-- DIABETES MELLITUS (Questions 1–20)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which pancreatic enzyme breaks down carbohydrates into glucose?',
 '[{"id":"a","text":"Lipase"},{"id":"b","text":"Protease"},{"id":"c","text":"Amylase"},{"id":"d","text":"Glucagon"}]'::jsonb,
 ARRAY['c'], false,
 'Amylase breaks down carbohydrates into glucose. Lipase breaks down fats, protease breaks down proteins, and glucagon is a hormone, not an enzyme.',
 'Diabetes Mellitus', 1),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which pancreatic cells produce glucagon?',
 '[{"id":"a","text":"Beta cells"},{"id":"b","text":"Alpha cells"},{"id":"c","text":"Duct cells"},{"id":"d","text":"Acinar cells"}]'::jsonb,
 ARRAY['b'], false,
 'Alpha cells produce glucagon during hypoglycemia. Beta cells produce insulin. Duct and acinar cells are not responsible for glucagon production.',
 'Diabetes Mellitus', 2),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which pancreatic cells produce insulin?',
 '[{"id":"a","text":"Alpha cells"},{"id":"b","text":"Beta cells"},{"id":"c","text":"Acinar cells"},{"id":"d","text":"Duct cells"}]'::jsonb,
 ARRAY['b'], false,
 'Beta cells release insulin during hyperglycemia. Alpha cells produce glucagon. Acinar and duct cells are not insulin-producing cells.',
 'Diabetes Mellitus', 3),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Normal fasting blood glucose levels range from:',
 '[{"id":"a","text":"60–90 mg/dL"},{"id":"b","text":"70–110 mg/dL"},{"id":"c","text":"80–140 mg/dL"},{"id":"d","text":"90–150 mg/dL"}]'::jsonb,
 ARRAY['b'], false,
 'Normal fasting blood glucose is 70–110 mg/dL. Values below 70 indicate hypoglycemia; values above 110 indicate hyperglycemia.',
 'Diabetes Mellitus', 4),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A fasting blood sugar greater than 110 mg/dL indicates:',
 '[{"id":"a","text":"Normal finding"},{"id":"b","text":"Hypoglycemia"},{"id":"c","text":"Hyperglycemia"},{"id":"d","text":"Controlled diabetes"}]'::jsonb,
 ARRAY['c'], false,
 'A fasting level over 110 mg/dL indicates hyperglycemia. This exceeds normal range. Hypoglycemia refers to low blood sugar, and controlled diabetes cannot be determined from this value alone.',
 'Diabetes Mellitus', 5),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Hemoglobin A1C reflects average blood glucose over approximately:',
 '[{"id":"a","text":"1 week"},{"id":"b","text":"1 month"},{"id":"c","text":"3 months"},{"id":"d","text":"6 months"}]'::jsonb,
 ARRAY['c'], false,
 'A1C measures average glucose over approximately 3 months (the lifespan of a red blood cell). 1 week and 1 month are too short; 6 months is longer than the documented period.',
 'Diabetes Mellitus', 6),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'An A1C level of 6.2% indicates:',
 '[{"id":"a","text":"Normal"},{"id":"b","text":"Prediabetes"},{"id":"c","text":"Diabetes"},{"id":"d","text":"Hypoglycemia"}]'::jsonb,
 ARRAY['b'], false,
 'A1C of 6.0–6.5% indicates prediabetes. Normal is 5.5–5.8%. Diabetes is diagnosed at ≥7%. Hypoglycemia is unrelated to A1C.',
 'Diabetes Mellitus', 7),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'An A1C level of 7% indicates:',
 '[{"id":"a","text":"Normal"},{"id":"b","text":"Prediabetes"},{"id":"c","text":"Diabetes"},{"id":"d","text":"Controlled glucose"}]'::jsonb,
 ARRAY['c'], false,
 'An A1C of 7% or higher indicates diabetes. Normal is below 5.7%, prediabetes is 5.7–6.4%. Controlled diabetes cannot be assumed from this value alone.',
 'Diabetes Mellitus', 8),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Postprandial blood glucose levels should not exceed:',
 '[{"id":"a","text":"120 mg/dL"},{"id":"b","text":"130 mg/dL"},{"id":"c","text":"140 mg/dL"},{"id":"d","text":"160 mg/dL"}]'::jsonb,
 ARRAY['c'], false,
 'Post-meal glucose should not exceed 140 mg/dL. Values above 140 indicate impaired glucose tolerance or hyperglycemia.',
 'Diabetes Mellitus', 9),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Excess glucose is stored in the liver as:',
 '[{"id":"a","text":"Lipids"},{"id":"b","text":"Glycogen"},{"id":"c","text":"Amino acids"},{"id":"d","text":"Ketones"}]'::jsonb,
 ARRAY['b'], false,
 'Glucose is stored in the liver as glycogen through glycogenesis. Lipid storage occurs if glycogen stores are saturated. Amino acids and ketones are not primary glucose storage forms.',
 'Diabetes Mellitus', 10),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'The primary role of insulin is to:',
 '[{"id":"a","text":"Increase blood sugar"},{"id":"b","text":"Break down proteins"},{"id":"c","text":"Transport glucose into cells"},{"id":"d","text":"Stimulate glucagon release"}]'::jsonb,
 ARRAY['c'], false,
 'Insulin transports glucose into cells for energy use. It lowers blood sugar (opposite of A). Protein breakdown and glucagon stimulation are not insulin''s functions.',
 'Diabetes Mellitus', 11),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Glucagon is released during:',
 '[{"id":"a","text":"Hyperglycemia"},{"id":"b","text":"Hypoglycemia"},{"id":"c","text":"Insulin injection"},{"id":"d","text":"Meals only"}]'::jsonb,
 ARRAY['b'], false,
 'Glucagon is released by alpha cells to raise blood sugar during hypoglycemia. Insulin is released during hyperglycemia.',
 'Diabetes Mellitus', 12),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Type 1 diabetes is primarily caused by:',
 '[{"id":"a","text":"Obesity"},{"id":"b","text":"Insulin resistance"},{"id":"c","text":"Autoimmune destruction of beta cells"},{"id":"d","text":"Excess carbohydrate intake"}]'::jsonb,
 ARRAY['c'], false,
 'Type 1 results from autoimmune destruction of pancreatic beta cells. Obesity and insulin resistance describe Type 2. Excess carbohydrate intake is not the primary cause.',
 'Diabetes Mellitus', 13),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Patients with Type 1 diabetes are commonly:',
 '[{"id":"a","text":"Overweight"},{"id":"b","text":"Thin with weight loss"},{"id":"c","text":"Resistant to insulin"},{"id":"d","text":"Asymptomatic"}]'::jsonb,
 ARRAY['b'], false,
 'Type 1 patients are often thin due to fat and muscle breakdown for energy (cells cannot use glucose). Overweight and insulin resistance describe Type 2. Symptoms are clearly present in Type 1.',
 'Diabetes Mellitus', 14),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'The first-line treatment for Type 1 diabetes is:',
 '[{"id":"a","text":"Diet"},{"id":"b","text":"Exercise"},{"id":"c","text":"Metformin"},{"id":"d","text":"Insulin"}]'::jsonb,
 ARRAY['d'], false,
 'Type 1 diabetes requires insulin immediately because beta cells are destroyed. Diet and exercise are insufficient alone. Metformin is used for Type 2.',
 'Diabetes Mellitus', 15),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Type 2 diabetes is commonly associated with:',
 '[{"id":"a","text":"Autoimmune destruction"},{"id":"b","text":"Overweight and lifestyle factors"},{"id":"c","text":"Immediate insulin dependence"},{"id":"d","text":"Childhood onset only"}]'::jsonb,
 ARRAY['b'], false,
 'Type 2 is strongly linked to obesity and lifestyle. Autoimmune destruction describes Type 1. Immediate insulin dependence and childhood onset are not typical characteristics of Type 2.',
 'Diabetes Mellitus', 16),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'The initial treatment approach for Type 2 diabetes includes:',
 '[{"id":"a","text":"Insulin only"},{"id":"b","text":"Diet and exercise"},{"id":"c","text":"Glucagon"},{"id":"d","text":"IV fluids"}]'::jsonb,
 ARRAY['b'], false,
 'Treatment for Type 2 diabetes begins with diet and exercise. Insulin and medications are added if lifestyle changes are insufficient. Glucagon and IV fluids are not first-line treatments.',
 'Diabetes Mellitus', 17),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'If diet and exercise are insufficient in Type 2 diabetes, the next medication is typically:',
 '[{"id":"a","text":"Glucagon"},{"id":"b","text":"Metformin"},{"id":"c","text":"NPH"},{"id":"d","text":"Dextrose"}]'::jsonb,
 ARRAY['b'], false,
 'Metformin is the standard next step after lifestyle changes fail in Type 2 diabetes. Glucagon and dextrose are for hypoglycemia. NPH is an insulin type used later if needed.',
 'Diabetes Mellitus', 18),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A common symptom of hyperglycemia is:',
 '[{"id":"a","text":"Trembling"},{"id":"b","text":"Polyuria"},{"id":"c","text":"Seizures"},{"id":"d","text":"Diaphoresis"}]'::jsonb,
 ARRAY['b'], false,
 'Hyperglycemia causes polyuria as the kidneys excrete excess glucose. Trembling, diaphoresis, and seizures are hypoglycemia symptoms.',
 'Diabetes Mellitus', 19),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A common symptom of hypoglycemia is:',
 '[{"id":"a","text":"Dry mucous membranes"},{"id":"b","text":"Polyphagia"},{"id":"c","text":"Diaphoresis"},{"id":"d","text":"Polyuria"}]'::jsonb,
 ARRAY['c'], false,
 'Diaphoresis (sweating) is a classic symptom of hypoglycemia due to adrenergic stimulation. Dry mucous membranes and polyuria are hyperglycemia signs. Polyphagia is also more associated with hyperglycemia.',
 'Diabetes Mellitus', 20),

-- ============================================
-- HYPOGLYCEMIA MANAGEMENT (Questions 21–25)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'An alert hypoglycemic patient should receive:',
 '[{"id":"a","text":"Insulin"},{"id":"b","text":"15 grams of simple carbohydrates"},{"id":"c","text":"Protein only"},{"id":"d","text":"Glucagon injection"}]'::jsonb,
 ARRAY['b'], false,
 'Alert hypoglycemic patients require 15 g of simple carbohydrates immediately to raise blood glucose. Insulin would worsen hypoglycemia. Protein is given later if glucose remains low. Glucagon is reserved for unconscious patients.',
 'Diabetes Mellitus', 21),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'After administering simple carbohydrates for hypoglycemia, the nurse should wait:',
 '[{"id":"a","text":"5 minutes"},{"id":"b","text":"10 minutes"},{"id":"c","text":"15 minutes"},{"id":"d","text":"30 minutes"}]'::jsonb,
 ARRAY['c'], false,
 'The "15-15 rule" states to wait 15 minutes before rechecking glucose after giving 15 g simple carbohydrates. 5 and 10 minutes are too short; 30 minutes delays treatment.',
 'Diabetes Mellitus', 22),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'If blood glucose remains low after simple carbohydrates, the nurse should:',
 '[{"id":"a","text":"Give insulin"},{"id":"b","text":"Provide complex carbohydrates with protein"},{"id":"c","text":"Encourage exercise"},{"id":"d","text":"Give water"}]'::jsonb,
 ARRAY['b'], false,
 'Complex carbohydrates with protein help sustain glucose levels after the initial rise. Insulin worsens hypoglycemia. Exercise increases glucose demand. Water does not raise glucose.',
 'Diabetes Mellitus', 23),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'An unconscious hypoglycemic patient requires:',
 '[{"id":"a","text":"Oral juice"},{"id":"b","text":"Glucagon injection"},{"id":"c","text":"NPH insulin"},{"id":"d","text":"Metformin"}]'::jsonb,
 ARRAY['b'], false,
 'Unconscious patients cannot swallow safely; glucagon injection raises blood glucose without aspiration risk. Oral juice risks aspiration. NPH and metformin would lower glucose further.',
 'Diabetes Mellitus', 24),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Dextrose 50W (D50W) is administered:',
 '[{"id":"a","text":"Orally"},{"id":"b","text":"Intramuscularly"},{"id":"c","text":"Subcutaneously"},{"id":"d","text":"Intravenously"}]'::jsonb,
 ARRAY['d'], false,
 'D50W is given intravenously for severe hypoglycemia when IV access is available. It cannot be given by other routes safely.',
 'Diabetes Mellitus', 25),

-- ============================================
-- INSULIN — TYPES & ADMINISTRATION (Questions 26–35)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Rapid-acting insulin requires food within:',
 '[{"id":"a","text":"15 minutes"},{"id":"b","text":"1 hour"},{"id":"c","text":"2 hours"},{"id":"d","text":"6 hours"}]'::jsonb,
 ARRAY['a'], false,
 'Rapid-acting insulin peaks quickly; food must be provided within 15 minutes to prevent hypoglycemia. Longer intervals do not match the peak action of rapid-acting insulin.',
 'Insulin', 26),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Regular insulin can be administered:',
 '[{"id":"a","text":"Subcutaneously only"},{"id":"b","text":"Intravenously only"},{"id":"c","text":"Subcutaneously or intravenously"},{"id":"d","text":"Intramuscularly only"}]'::jsonb,
 ARRAY['c'], false,
 'Regular insulin is the only insulin type that can be given both subcutaneously and intravenously. All other insulins are subcutaneous only.',
 'Insulin', 27),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'If regular insulin appears cloudy, the nurse should:',
 '[{"id":"a","text":"Shake it"},{"id":"b","text":"Roll it"},{"id":"c","text":"Discard and document"},{"id":"d","text":"Use it"}]'::jsonb,
 ARRAY['c'], false,
 'Regular insulin must be clear. Any cloudiness indicates contamination or degradation; the vial must be discarded. Shaking and using it are unsafe actions.',
 'Insulin', 28),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'NPH insulin is characterized as:',
 '[{"id":"a","text":"Clear"},{"id":"b","text":"Cloudy"},{"id":"c","text":"IV only"},{"id":"d","text":"Peakless"}]'::jsonb,
 ARRAY['b'], false,
 'NPH is an intermediate-acting insulin and is characteristically cloudy. Regular insulin is clear. IV administration and being peakless describe long-acting insulin.',
 'Insulin', 29),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Long-acting insulin has:',
 '[{"id":"a","text":"2-hour peak"},{"id":"b","text":"6-hour peak"},{"id":"c","text":"No peak"},{"id":"d","text":"Immediate peak"}]'::jsonb,
 ARRAY['c'], false,
 'Long-acting insulin (e.g., glargine, detemir) has no peak and provides steady 24-hour coverage. All other options describe incorrect characteristics.',
 'Insulin', 30),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Insulin should be injected:',
 '[{"id":"a","text":"Intramuscularly"},{"id":"b","text":"Intravenously"},{"id":"c","text":"Subcutaneously"},{"id":"d","text":"Intradermally"}]'::jsonb,
 ARRAY['c'], false,
 'Insulin is routinely given subcutaneously for proper absorption. IV is only used for regular insulin in clinical emergencies. IM and intradermal routes are incorrect for routine use.',
 'Insulin', 31),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Injection sites should be rotated to prevent:',
 '[{"id":"a","text":"Infection"},{"id":"b","text":"Lipodystrophy"},{"id":"c","text":"DKA"},{"id":"d","text":"Hyperglycemia"}]'::jsonb,
 ARRAY['b'], false,
 'Repeated injections into the same site cause lipodystrophy (abnormal fat tissue distribution), which impairs insulin absorption. Rotation prevents this complication.',
 'Insulin', 32),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Which insulin type has no peak and provides steady 24-hour coverage?',
 '[{"id":"a","text":"Regular"},{"id":"b","text":"NPH"},{"id":"c","text":"Rapid-acting"},{"id":"d","text":"Long-acting"}]'::jsonb,
 ARRAY['d'], false,
 'Long-acting insulin (e.g., glargine) has no peak and provides consistent basal coverage over 24 hours. Regular and NPH have defined peaks. Rapid-acting peaks within 1 hour.',
 'Insulin', 33),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Which insulin is clear and should not be rolled?',
 '[{"id":"a","text":"NPH"},{"id":"b","text":"Regular"},{"id":"c","text":"Premixed"},{"id":"d","text":"Intermediate"}]'::jsonb,
 ARRAY['b'], false,
 'Regular insulin is clear and should never be rolled or shaken. NPH and other cloudy insulins require gentle rolling to re-suspend the suspension before use.',
 'Insulin', 34),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'Which insulin is cloudy and requires gentle rolling before use?',
 '[{"id":"a","text":"Glargine"},{"id":"b","text":"Regular"},{"id":"c","text":"NPH"},{"id":"d","text":"Aspart"}]'::jsonb,
 ARRAY['c'], false,
 'NPH is a suspension and is cloudy; it requires gentle rolling to re-mix before use. Glargine, regular, and aspart are clear insulins that must NOT be rolled.',
 'Insulin', 35),

-- ============================================
-- INSULIN STORAGE & CHECKING (Questions 36–45)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'Long-acting insulin should:',
 '[{"id":"a","text":"Be mixed with other insulins"},{"id":"b","text":"Never be mixed with other insulins"},{"id":"c","text":"Be shaken before use"},{"id":"d","text":"Be administered IV"}]'::jsonb,
 ARRAY['b'], false,
 'Long-acting insulins (e.g., glargine, detemir) must never be mixed with any other insulin as mixing alters their pharmacokinetics and delays action.',
 'Insulin Storage and Checking', 36),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'Insulin must be refrigerated before opening.',
 '[{"id":"a","text":"True"},{"id":"b","text":"False"},{"id":"c","text":"Only NPH"},{"id":"d","text":"Only long-acting"}]'::jsonb,
 ARRAY['a'], false,
 'All insulin types must be refrigerated before opening to maintain potency. Once opened, most insulins can be stored at room temperature for 28–30 days.',
 'Insulin Storage and Checking', 37),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'After opening, insulin typically expires in:',
 '[{"id":"a","text":"7 days"},{"id":"b","text":"14 days"},{"id":"c","text":"28–30 days"},{"id":"d","text":"60 days"}]'::jsonb,
 ARRAY['c'], false,
 'Once opened and stored at room temperature, most insulin vials expire in 28–30 days. Using expired insulin risks inadequate glucose control.',
 'Insulin Storage and Checking', 38),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'Insulin should never be:',
 '[{"id":"a","text":"Refrigerated"},{"id":"b","text":"Rolled"},{"id":"c","text":"Shaken"},{"id":"d","text":"Labeled"}]'::jsonb,
 ARRAY['c'], false,
 'Insulin should never be shaken as it creates air bubbles and denatures the protein. Gentle rolling is acceptable for cloudy insulins. Refrigeration, labeling, and rolling are appropriate actions.',
 'Insulin Storage and Checking', 39),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'Cloudy insulin (NPH) should be prepared by:',
 '[{"id":"a","text":"Shaking vigorously"},{"id":"b","text":"Rolling gently between the palms"},{"id":"c","text":"Freezing before use"},{"id":"d","text":"Discarding immediately"}]'::jsonb,
 ARRAY['b'], false,
 'Cloudy (NPH) insulin should be rolled gently between the palms to re-suspend the particles evenly. Shaking creates bubbles. Freezing and discarding are incorrect.',
 'Insulin Storage and Checking', 40),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A patient stores insulin in a car during extreme temperatures. The priority concern is:',
 '[{"id":"a","text":"Increased potency"},{"id":"b","text":"Insulin degradation due to temperature extremes"},{"id":"c","text":"Improved stability"},{"id":"d","text":"No concern exists"}]'::jsonb,
 ARRAY['b'], false,
 'Extreme temperatures (heat or freezing) degrade insulin, making it ineffective. Insulin should be stored at consistent cool room temperature or refrigerated.',
 'Insulin Storage and Checking', 41),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'If insulin is expired before opening, the nurse should:',
 '[{"id":"a","text":"Use immediately"},{"id":"b","text":"Discard"},{"id":"c","text":"Freeze"},{"id":"d","text":"Dilute with saline"}]'::jsonb,
 ARRAY['b'], false,
 'Expired insulin must be discarded as it may have reduced potency, leading to inadequate glucose control and potential hyperglycemia.',
 'Insulin Storage and Checking', 42),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'What action prevents discomfort when injecting cold insulin from the refrigerator?',
 '[{"id":"a","text":"Shake vigorously"},{"id":"b","text":"Warm between palms before injecting"},{"id":"c","text":"Freeze briefly"},{"id":"d","text":"Inject immediately"}]'::jsonb,
 ARRAY['b'], false,
 'Warming insulin between the palms before injection reduces pain and discomfort. Shaking damages insulin. Freezing and immediate injection are incorrect.',
 'Insulin Storage and Checking', 43),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A nurse observes a cloudy insulin vial with uneven separation. The correct action is:',
 '[{"id":"a","text":"Shake vigorously"},{"id":"b","text":"Roll gently between palms"},{"id":"c","text":"Discard immediately"},{"id":"d","text":"Add saline"}]'::jsonb,
 ARRAY['b'], false,
 'Cloudy insulin with separation (NPH) should be rolled gently to mix evenly. Vigorous shaking creates bubbles and denatures the protein. Adding saline is never appropriate.',
 'Insulin Storage and Checking', 44),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'The first step in checking capillary blood glucose is to:',
 '[{"id":"a","text":"Prick the finger"},{"id":"b","text":"Insert the strip into the glucometer"},{"id":"c","text":"Clean the finger with alcohol"},{"id":"d","text":"Apply blood to the strip"}]'::jsonb,
 ARRAY['b'], false,
 'The strip is inserted first to prepare the glucometer, then the finger is cleaned, pricked, and the blood applied. This sequence ensures accurate readings.',
 'Insulin Storage and Checking', 45),

-- ============================================
-- MIXING OF INSULIN GUIDELINES (Questions 46–55)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Regular insulin can be mixed with:',
 '[{"id":"a","text":"Glargine"},{"id":"b","text":"NPH"},{"id":"c","text":"Lispro"},{"id":"d","text":"Glucagon"}]'::jsonb,
 ARRAY['b'], false,
 'Regular insulin can be mixed with NPH. Glargine is a long-acting insulin that must never be mixed. Lispro should not be mixed with NPH. Glucagon is not an insulin.',
 'Mixing of Insulin Guidelines', 46),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'When mixing insulin, air is injected into which vial first?',
 '[{"id":"a","text":"Regular"},{"id":"b","text":"NPH"},{"id":"c","text":"Long-acting"},{"id":"d","text":"Glargine"}]'::jsonb,
 ARRAY['b'], false,
 'Air is injected into the NPH (cloudy) vial first without withdrawing insulin, then air is injected into the regular vial. This prevents contamination of the regular vial.',
 'Mixing of Insulin Guidelines', 47),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'When mixing insulin, which insulin is drawn up first?',
 '[{"id":"a","text":"NPH"},{"id":"b","text":"Regular"},{"id":"c","text":"Long-acting"},{"id":"d","text":"Glucagon"}]'::jsonb,
 ARRAY['b'], false,
 'Regular (clear) insulin is drawn up first after injecting air into both vials. This prevents contamination of the regular vial with NPH. Remember: "Clear before cloudy."',
 'Mixing of Insulin Guidelines', 48),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'The purpose of injecting air into the NPH vial before mixing is to:',
 '[{"id":"a","text":"Increase potency"},{"id":"b","text":"Prevent air bubbles and allow easier withdrawal"},{"id":"c","text":"Decrease absorption rate"},{"id":"d","text":"Sterilize the insulin"}]'::jsonb,
 ARRAY['b'], false,
 'Injecting air into the NPH vial equalizes pressure and makes withdrawal of the correct dose easier and more accurate. It does not affect potency, absorption, or sterility.',
 'Mixing of Insulin Guidelines', 49),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A patient mixes NPH and regular insulin but draws NPH first. The primary concern is:',
 '[{"id":"a","text":"Reduced absorption"},{"id":"b","text":"Contamination of the regular insulin vial with NPH"},{"id":"c","text":"Hypotension"},{"id":"d","text":"Lipodystrophy"}]'::jsonb,
 ARRAY['b'], false,
 'Drawing NPH first contaminates the regular insulin vial, altering its clear appearance and pharmacokinetics. Regular must always be drawn first (clear before cloudy).',
 'Mixing of Insulin Guidelines', 50),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Long-acting insulin (glargine) should NEVER be mixed because:',
 '[{"id":"a","text":"It is too expensive"},{"id":"b","text":"Mixing alters its pH and prolonged-release mechanism"},{"id":"c","text":"It causes immediate hypoglycemia"},{"id":"d","text":"It becomes too cloudy"}]'::jsonb,
 ARRAY['b'], false,
 'Glargine''s prolonged-release mechanism depends on a specific pH. Mixing with other insulins alters the pH, converting it to short-acting and losing its steady 24-hour coverage.',
 'Mixing of Insulin Guidelines', 51),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Which mnemonic helps remember insulin mixing order?',
 '[{"id":"a","text":"Cloudy before clear"},{"id":"b","text":"Clear before cloudy"},{"id":"c","text":"NPH then regular"},{"id":"d","text":"Long-acting first"}]'::jsonb,
 ARRAY['b'], false,
 '"Clear before cloudy" reminds nurses to draw regular (clear) insulin before NPH (cloudy) to prevent vial contamination. This is a standard nursing safety mnemonic.',
 'Mixing of Insulin Guidelines', 52),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'After mixing regular and NPH insulin, the nurse should administer the dose:',
 '[{"id":"a","text":"Immediately"},{"id":"b","text":"After 1 hour"},{"id":"c","text":"After 2 hours"},{"id":"d","text":"After refrigerating"}]'::jsonb,
 ARRAY['a'], false,
 'Mixed insulin should be administered immediately after preparation to maintain accurate dosing and prevent alterations in the mixture''s pharmacokinetics.',
 'Mixing of Insulin Guidelines', 53),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A patient asks why you inject air into the vials before mixing. The best explanation is:',
 '[{"id":"a","text":"To sterilize the vials"},{"id":"b","text":"To equalize pressure and allow accurate withdrawal"},{"id":"c","text":"To increase insulin potency"},{"id":"d","text":"To mix the insulin automatically"}]'::jsonb,
 ARRAY['b'], false,
 'Injecting air equalizes pressure inside the vial, making it easier to withdraw the exact prescribed dose without creating a vacuum.',
 'Mixing of Insulin Guidelines', 54),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'Which insulins should NEVER be mixed together?',
 '[{"id":"a","text":"Regular and NPH"},{"id":"b","text":"Glargine and any other insulin"},{"id":"c","text":"NPH and detemir"},{"id":"d","text":"Regular and lispro"}]'::jsonb,
 ARRAY['b'], false,
 'Glargine must never be mixed with any other insulin. Regular and NPH can be safely mixed. Other long-acting insulins like detemir also should not be mixed.',
 'Mixing of Insulin Guidelines', 55),

-- ============================================
-- INSULIN PATCH (Questions 56–65)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Insulin patch therapy primarily delivers:',
 '[{"id":"a","text":"Basal insulin"},{"id":"b","text":"IV insulin"},{"id":"c","text":"Oral insulin"},{"id":"d","text":"Glucagon"}]'::jsonb,
 ARRAY['a'], false,
 'Insulin patches deliver continuous basal insulin transdermally. IV and oral routes are not used for patches. Glucagon is not an insulin.',
 'Insulin Patch', 56),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Transdermal means:',
 '[{"id":"a","text":"Through muscle"},{"id":"b","text":"Through vein"},{"id":"c","text":"Through skin"},{"id":"d","text":"Through artery"}]'::jsonb,
 ARRAY['c'], false,
 'Transdermal means through the skin. Intramuscular is through muscle, intravenous is through a vein, and intra-arterial is through an artery.',
 'Insulin Patch', 57),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Infusion sets for an insulin pump should be changed every:',
 '[{"id":"a","text":"24 hours"},{"id":"b","text":"48–72 hours"},{"id":"c","text":"5 days"},{"id":"d","text":"1 week"}]'::jsonb,
 ARRAY['b'], false,
 'Infusion sets should be changed every 48–72 hours to prevent infection and ensure proper insulin delivery. Longer intervals risk occlusion and infection.',
 'Insulin Patch', 58),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A blocked pump infusion set increases risk of:',
 '[{"id":"a","text":"Hypoglycemia"},{"id":"b","text":"Diabetic ketoacidosis (DKA)"},{"id":"c","text":"Weight gain"},{"id":"d","text":"Bradycardia"}]'::jsonb,
 ARRAY['b'], false,
 'A blocked infusion set stops insulin delivery, leading to hyperglycemia and risk of DKA. Hypoglycemia would result from excess insulin, not absence.',
 'Insulin Patch', 59),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Removing an insulin pump for an extended period increases risk of:',
 '[{"id":"a","text":"Hypoglycemia"},{"id":"b","text":"Hyperglycemia"},{"id":"c","text":"Seizure"},{"id":"d","text":"Infection"}]'::jsonb,
 ARRAY['b'], false,
 'Pump removal stops insulin delivery, causing hyperglycemia. Hypoglycemia would result from too much insulin, not absence of it.',
 'Insulin Patch', 60),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A patient forgets to remove the old insulin patch before applying a new one. The priority concern is:',
 '[{"id":"a","text":"Skin infection"},{"id":"b","text":"Insulin overdose causing hypoglycemia"},{"id":"c","text":"Skin dryness"},{"id":"d","text":"Bruising"}]'::jsonb,
 ARRAY['b'], false,
 'Two active patches double insulin delivery, dramatically increasing the risk of hypoglycemia. Always remove the old patch before applying a new one.',
 'Insulin Patch', 61),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Insulin patch therapy does NOT eliminate the need for:',
 '[{"id":"a","text":"Diet"},{"id":"b","text":"Exercise"},{"id":"c","text":"Blood glucose monitoring"},{"id":"d","text":"Kidney testing"}]'::jsonb,
 ARRAY['c'], false,
 'Blood glucose monitoring is always required regardless of insulin delivery method to ensure doses are effective and prevent hypo/hyperglycemia.',
 'Insulin Patch', 62),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A patient using a pump removes it overnight. The nurse anticipates risk for:',
 '[{"id":"a","text":"Hypoglycemia"},{"id":"b","text":"Hyperglycemia"},{"id":"c","text":"Bradycardia"},{"id":"d","text":"Hypotension"}]'::jsonb,
 ARRAY['b'], false,
 'Removing the pump overnight stops all basal insulin delivery, leading to hyperglycemia. The patient must have an alternative insulin plan during removal.',
 'Insulin Patch', 63),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'Which intervention prevents lipodystrophy at insulin pump infusion sites?',
 '[{"id":"a","text":"Using the same site every time"},{"id":"b","text":"Rotating infusion sites"},{"id":"c","text":"Shaking the insulin before loading"},{"id":"d","text":"Freezing the insulin cartridge"}]'::jsonb,
 ARRAY['b'], false,
 'Rotating infusion sites prevents lipodystrophy (abnormal fat tissue development) caused by repeated mechanical trauma and insulin exposure at one site.',
 'Insulin Patch', 64),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'An insulin pump infusion site appears red, swollen, and warm. The nurse''s priority action is:',
 '[{"id":"a","text":"Continue monitoring"},{"id":"b","text":"Change the infusion site immediately"},{"id":"c","text":"Apply ice"},{"id":"d","text":"Increase insulin dose"}]'::jsonb,
 ARRAY['b'], false,
 'Redness, swelling, and warmth indicate site infection or irritation. The infusion set must be removed and reinserted at a new site immediately to prevent systemic infection.',
 'Insulin Patch', 65),

-- ============================================
-- METFORMIN (Questions 66–75)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'Metformin is indicated when:',
 '[{"id":"a","text":"Exercise alone is sufficient"},{"id":"b","text":"Diet and exercise alone are insufficient for Type 2 diabetes"},{"id":"c","text":"Type 1 diabetes is diagnosed"},{"id":"d","text":"A patient has hypoglycemia"}]'::jsonb,
 ARRAY['b'], false,
 'Metformin is the first oral medication added when lifestyle changes alone fail to control Type 2 diabetes. It is not used for Type 1 or hypoglycemia.',
 'Metformin', 66),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'Metformin should be stopped before surgery or contrast procedures for:',
 '[{"id":"a","text":"12 hours"},{"id":"b","text":"24 hours"},{"id":"c","text":"48 hours"},{"id":"d","text":"72 hours"}]'::jsonb,
 ARRAY['b'], false,
 'Metformin must be held 24 hours before contrast procedures to prevent lactic acidosis, which can result from contrast-induced acute kidney injury impairing metformin excretion.',
 'Metformin', 67),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'Kidney function for a patient on metformin should be checked every:',
 '[{"id":"a","text":"3 months"},{"id":"b","text":"6 months"},{"id":"c","text":"9 months"},{"id":"d","text":"12 months"}]'::jsonb,
 ARRAY['b'], false,
 'Kidney function (eGFR/creatinine) should be monitored every 6 months for patients on metformin to detect renal impairment early, which would require dose adjustment or discontinuation.',
 'Metformin', 68),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A patient on metformin is scheduled for contrast imaging in 12 hours. The best nursing action is:',
 '[{"id":"a","text":"Continue the medication as scheduled"},{"id":"b","text":"Hold metformin before the procedure"},{"id":"c","text":"Double the dose"},{"id":"d","text":"Replace with insulin"}]'::jsonb,
 ARRAY['b'], false,
 'Metformin must be held before contrast procedures due to risk of lactic acidosis if contrast causes acute kidney injury impairing drug excretion. It should be held at least 24 hours prior.',
 'Metformin', 69),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A patient''s A1C after 3 months of metformin is 8%. The next likely treatment step is:',
 '[{"id":"a","text":"Stop all treatment"},{"id":"b","text":"Continue metformin alone"},{"id":"c","text":"Add insulin therapy"},{"id":"d","text":"Switch to glucagon"}]'::jsonb,
 ARRAY['c'], false,
 'If A1C remains above 7% despite metformin therapy, insulin is typically added to achieve better glycemic control. Stopping treatment and using glucagon are incorrect.',
 'Metformin', 70),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'The most serious adverse effect associated with metformin is:',
 '[{"id":"a","text":"Hypoglycemia"},{"id":"b","text":"Lactic acidosis"},{"id":"c","text":"Weight gain"},{"id":"d","text":"Hypertension"}]'::jsonb,
 ARRAY['b'], false,
 'Lactic acidosis is the most serious, though rare, adverse effect of metformin, particularly in patients with renal impairment. Metformin alone does not typically cause hypoglycemia.',
 'Metformin', 71),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'Metformin is contraindicated in patients with:',
 '[{"id":"a","text":"Type 2 diabetes"},{"id":"b","text":"Renal impairment (low eGFR)"},{"id":"c","text":"Obesity"},{"id":"d","text":"Hypertension"}]'::jsonb,
 ARRAY['b'], false,
 'Metformin is contraindicated in renal impairment because reduced kidney function prevents excretion, increasing lactic acidosis risk. It is actually indicated in Type 2 diabetes and useful in obese patients.',
 'Metformin', 72),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A common gastrointestinal side effect of metformin is:',
 '[{"id":"a","text":"Constipation"},{"id":"b","text":"Nausea and diarrhea"},{"id":"c","text":"Jaundice"},{"id":"d","text":"Bleeding"}]'::jsonb,
 ARRAY['b'], false,
 'Nausea, diarrhea, and GI upset are the most common side effects of metformin, especially when starting therapy. Taking it with food reduces these effects.',
 'Metformin', 73),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'Metformin primarily works by:',
 '[{"id":"a","text":"Stimulating insulin secretion from beta cells"},{"id":"b","text":"Reducing hepatic glucose production"},{"id":"c","text":"Blocking glucagon release"},{"id":"d","text":"Increasing insulin breakdown"}]'::jsonb,
 ARRAY['b'], false,
 'Metformin primarily reduces hepatic glucose production (gluconeogenesis) and improves insulin sensitivity. It does not stimulate insulin secretion like sulfonylureas.',
 'Metformin', 74),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A patient on metformin reports dark urine and jaundice. The nurse should:',
 '[{"id":"a","text":"Reassure the patient it is normal"},{"id":"b","text":"Hold metformin and notify the provider immediately"},{"id":"c","text":"Double the dose"},{"id":"d","text":"Encourage increased fluid intake only"}]'::jsonb,
 ARRAY['b'], false,
 'Dark urine and jaundice suggest hepatic or renal dysfunction. Metformin should be held and the provider notified immediately to evaluate liver and kidney function.',
 'Metformin', 75),

-- ============================================
-- ADVANCED CLINICAL APPLICATION (Questions 76–100)
-- ============================================

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A patient with Type 1 diabetes becomes confused, diaphoretic, and pale. The patient is alert but slow to respond. What is the nurse''s priority action?',
 '[{"id":"a","text":"Administer regular insulin"},{"id":"b","text":"Give 15 grams of simple carbohydrates"},{"id":"c","text":"Start IV D50W immediately"},{"id":"d","text":"Encourage the patient to walk"}]'::jsonb,
 ARRAY['b'], false,
 'The patient is alert and symptomatic for hypoglycemia. The first step is 15 g simple carbohydrates (15-15 rule). Insulin would worsen hypoglycemia. IV D50W is for unconscious patients. Walking increases glucose demand.',
 'Diabetes Mellitus', 76),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A patient receiving NPH insulin at 8:00 AM begins shaking and reports dizziness at 2:00 PM. The most likely cause is:',
 '[{"id":"a","text":"Hyperglycemia"},{"id":"b","text":"NPH peak effect causing hypoglycemia"},{"id":"c","text":"Insulin resistance"},{"id":"d","text":"Dehydration"}]'::jsonb,
 ARRAY['b'], false,
 'NPH peaks approximately 4–12 hours after administration. At 2:00 PM (6 hours after an 8 AM dose), the peak effect is expected, making hypoglycemia the most likely cause of shaking and dizziness.',
 'Insulin', 77),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A patient mixes NPH and regular insulin but draws NPH first. What is the primary concern?',
 '[{"id":"a","text":"Reduced absorption rate"},{"id":"b","text":"Contamination of the regular insulin vial with NPH"},{"id":"c","text":"Hypotension"},{"id":"d","text":"Lipodystrophy"}]'::jsonb,
 ARRAY['b'], false,
 'Drawing NPH first introduces NPH particles into the regular vial, contaminating it and altering its clear, short-acting properties. Always draw regular (clear) before NPH (cloudy).',
 'Mixing of Insulin Guidelines', 78),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A patient using an insulin pump reports nausea and elevated glucose levels. The infusion site appears kinked. What complication is most likely?',
 '[{"id":"a","text":"Hypoglycemia"},{"id":"b","text":"Lipodystrophy"},{"id":"c","text":"Diabetic ketoacidosis (DKA)"},{"id":"d","text":"Kidney toxicity"}]'::jsonb,
 ARRAY['c'], false,
 'A kinked infusion set blocks insulin delivery. Without insulin, glucose rises and fatty acid breakdown produces ketones, leading to DKA. The nurse must change the site and administer insulin immediately.',
 'Insulin Patch', 79),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A patient on metformin is scheduled for contrast imaging in 12 hours. What is the best nursing action?',
 '[{"id":"a","text":"Continue medication as prescribed"},{"id":"b","text":"Hold metformin before the procedure"},{"id":"c","text":"Double the dose before imaging"},{"id":"d","text":"Give insulin instead"}]'::jsonb,
 ARRAY['b'], false,
 'Metformin must be held at least 24 hours before contrast procedures to prevent lactic acidosis, which can result from contrast dye causing acute kidney injury and impaired metformin excretion.',
 'Metformin', 80),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A patient with hyperglycemia develops blurred vision and confusion. What best explains these findings?',
 '[{"id":"a","text":"Hypoxia"},{"id":"b","text":"Fluid shifts affecting the brain and eyes"},{"id":"c","text":"Seizure activity"},{"id":"d","text":"Insulin overdose"}]'::jsonb,
 ARRAY['b'], false,
 'Hyperglycemia causes osmotic fluid shifts: the lens of the eye swells causing blurred vision, and cerebral dehydration causes confusion. These are classic signs of uncontrolled hyperglycemia.',
 'Diabetes Mellitus', 81),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A nurse prepares to give long-acting insulin with regular insulin in one syringe. What is the correct action?',
 '[{"id":"a","text":"Mix them and administer"},{"id":"b","text":"Administer the mixture IV"},{"id":"c","text":"Do not mix; administer separately"},{"id":"d","text":"Shake before mixing"}]'::jsonb,
 ARRAY['c'], false,
 'Long-acting insulin (glargine, detemir) must never be mixed with any other insulin. Mixing alters the pH and destroys the prolonged-release mechanism, converting it to short-acting.',
 'Mixing of Insulin Guidelines', 82),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A patient with Type 2 diabetes has an A1C of 8% after 3 months of metformin therapy. What is the next likely treatment?',
 '[{"id":"a","text":"Discontinue all therapy"},{"id":"b","text":"Increase exercise only"},{"id":"c","text":"Add insulin therapy"},{"id":"d","text":"Add glucagon"}]'::jsonb,
 ARRAY['c'], false,
 'An A1C of 8% after 3 months of metformin indicates inadequate control. Adding insulin is the standard next step to achieve the target A1C below 7%.',
 'Metformin', 83),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A hypoglycemic patient is unconscious without IV access. What is the priority intervention?',
 '[{"id":"a","text":"Give oral glucose gel"},{"id":"b","text":"Start IV D50W"},{"id":"c","text":"Administer IM glucagon"},{"id":"d","text":"Give NPH insulin"}]'::jsonb,
 ARRAY['c'], false,
 'For an unconscious patient without IV access, IM glucagon is the priority to safely raise blood glucose without aspiration risk. Oral glucose risks aspiration. NPH lowers glucose.',
 'Diabetes Mellitus', 84),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A patient repeatedly stores insulin at room temperature in direct sunlight. What complication is most likely?',
 '[{"id":"a","text":"Increased potency"},{"id":"b","text":"Insulin degradation and loss of effectiveness"},{"id":"c","text":"Hypotension"},{"id":"d","text":"Lipodystrophy"}]'::jsonb,
 ARRAY['b'], false,
 'Direct sunlight and excessive heat break down insulin''s protein structure, causing degradation and loss of glucose-lowering effectiveness. Insulin should be stored away from light and heat.',
 'Insulin Storage and Checking', 85),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A patient injects insulin repeatedly at the umbilicus. Why is this incorrect?',
 '[{"id":"a","text":"Reduced absorption"},{"id":"b","text":"Increased pain"},{"id":"c","text":"The umbilicus must be avoided; inject 1.5–2 inches away"},{"id":"d","text":"Causes immediate hyperglycemia"}]'::jsonb,
 ARRAY['c'], false,
 'Insulin should not be injected directly into the umbilicus. Injections must be 1.5–2 inches away from the navel to ensure proper absorption and prevent tissue damage.',
 'Insulin', 86),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A patient using rapid-acting insulin delays meals by 2 hours. Which symptom is most expected?',
 '[{"id":"a","text":"Polyuria"},{"id":"b","text":"Diaphoresis and trembling"},{"id":"c","text":"Dry mouth"},{"id":"d","text":"Blurred vision"}]'::jsonb,
 ARRAY['b'], false,
 'Rapid-acting insulin peaks within 1 hour. A 2-hour meal delay results in hypoglycemia, causing diaphoresis and trembling due to adrenergic stimulation.',
 'Insulin', 87),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A patient''s blood glucose decreases 100 mg/dL/hr during IV regular insulin infusion for DKA. The concern is:',
 '[{"id":"a","text":"Inadequate therapy"},{"id":"b","text":"Excessively rapid drop risking hypoglycemia and cerebral edema"},{"id":"c","text":"Hyperglycemia"},{"id":"d","text":"Insulin resistance"}]'::jsonb,
 ARRAY['b'], false,
 'The recommended glucose reduction during DKA treatment is 50–75 mg/dL/hr. A drop of 100 mg/dL/hr is too rapid, risking hypoglycemia and cerebral edema from osmotic shifts.',
 'Insulin', 88),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A patient removes an insulin patch and forgets to replace it for 8 hours. Which finding is expected?',
 '[{"id":"a","text":"Seizures"},{"id":"b","text":"Hyperglycemia"},{"id":"c","text":"Bradycardia"},{"id":"d","text":"Pale clammy skin"}]'::jsonb,
 ARRAY['b'], false,
 'Removing the patch stops basal insulin delivery. Without insulin, blood glucose rises, causing hyperglycemia over 8 hours. Seizures and pale clammy skin indicate hypoglycemia.',
 'Insulin Patch', 89),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which symptom best differentiates hypoglycemia from hyperglycemia?',
 '[{"id":"a","text":"Blurred vision"},{"id":"b","text":"Polyuria"},{"id":"c","text":"Diaphoresis"},{"id":"d","text":"Fatigue"}]'::jsonb,
 ARRAY['c'], false,
 'Diaphoresis (sweating) is caused by adrenergic activation specific to hypoglycemia. Blurred vision and fatigue occur in both conditions. Polyuria is specific to hyperglycemia.',
 'Diabetes Mellitus', 90),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000074',
 'A patient correctly mixes insulin but misses the follow-up meal timing. What complication may occur?',
 '[{"id":"a","text":"Hyperglycemia"},{"id":"b","text":"Hypoglycemia"},{"id":"c","text":"DKA"},{"id":"d","text":"Atherosclerosis"}]'::jsonb,
 ARRAY['b'], false,
 'Mixed regular and NPH insulin acts rapidly. Missing the meal timing means no glucose is available when insulin peaks, causing hypoglycemia.',
 'Mixing of Insulin Guidelines', 91),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000071',
 'A patient develops lipodystrophy at pump infusion sites. What is the best intervention?',
 '[{"id":"a","text":"Use the same site consistently"},{"id":"b","text":"Increase the insulin dose"},{"id":"c","text":"Rotate infusion sites systematically"},{"id":"d","text":"Stop blood glucose monitoring"}]'::jsonb,
 ARRAY['c'], false,
 'Rotating infusion sites prevents and treats lipodystrophy. Using the same site perpetuates the condition. Increasing dose and stopping monitoring are unsafe.',
 'Insulin Patch', 92),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000072',
 'A patient has capillary (finger stick) and venous glucose results that differ by 15 mg/dL. What should the nurse understand?',
 '[{"id":"a","text":"Only venous results are valid"},{"id":"b","text":"Only capillary results are valid"},{"id":"c","text":"A difference of up to 15 mg/dL between methods is clinically acceptable"},{"id":"d","text":"One result must be discarded"}]'::jsonb,
 ARRAY['c'], false,
 'Capillary and venous glucose values may differ slightly due to physiological differences. A variance of up to 15 mg/dL is generally considered clinically acceptable. Both methods fall within normal ranges.',
 'Insulin Storage and Checking', 93),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A patient with Type 1 diabetes is thin despite excessive hunger and eating. Why?',
 '[{"id":"a","text":"Insulin resistance"},{"id":"b","text":"Without insulin, glucose cannot enter cells, so fat and muscle are broken down for energy"},{"id":"c","text":"Excess insulin prevents weight gain"},{"id":"d","text":"Kidney failure causes weight loss"}]'::jsonb,
 ARRAY['b'], false,
 'In Type 1 diabetes, the absence of insulin prevents glucose from entering cells. The body breaks down fat and muscle for energy, causing weight loss despite adequate food intake.',
 'Diabetes Mellitus', 94),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A patient on long-acting insulin asks why there is no peak effect. The best explanation is:',
 '[{"id":"a","text":"It is ineffective"},{"id":"b","text":"It works instantly"},{"id":"c","text":"It provides steady 24-hour glucose control without fluctuations"},{"id":"d","text":"It causes hypoglycemia at peak times"}]'::jsonb,
 ARRAY['c'], false,
 'Long-acting insulin (e.g., glargine) is designed to provide consistent basal coverage over 24 hours with no peak, reducing hypoglycemia risk while maintaining steady glucose control.',
 'Insulin', 95),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A patient with hyperglycemia reports extreme thirst and frequent urination. These findings are best explained by:',
 '[{"id":"a","text":"Low blood glucose"},{"id":"b","text":"Excess insulin"},{"id":"c","text":"Elevated blood glucose causing osmotic diuresis"},{"id":"d","text":"Glucagon deficiency"}]'::jsonb,
 ARRAY['c'], false,
 'Elevated blood glucose causes osmotic diuresis (polyuria) as the kidneys excrete excess glucose, pulling water along with it. This fluid loss causes polydipsia (extreme thirst).',
 'Diabetes Mellitus', 96),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'A patient receiving rapid-acting insulin does not eat within 15 minutes of injection. The nurse anticipates:',
 '[{"id":"a","text":"Hyperglycemia"},{"id":"b","text":"Hypoglycemia"},{"id":"c","text":"DKA"},{"id":"d","text":"Hypertension"}]'::jsonb,
 ARRAY['b'], false,
 'Rapid-acting insulin acts within 15 minutes. Without food, there is no glucose for the insulin to act on, resulting in hypoglycemia.',
 'Diabetes Mellitus', 97),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000073',
 'A patient injects insulin repeatedly into the same abdominal site. The nurse expects:',
 '[{"id":"a","text":"DKA"},{"id":"b","text":"Lipodystrophy at the injection site"},{"id":"c","text":"Hypoglycemia"},{"id":"d","text":"Kidney failure"}]'::jsonb,
 ARRAY['b'], false,
 'Repeated injections into the same site cause lipodystrophy (abnormal fat tissue changes), which impairs insulin absorption and glycemic control.',
 'Insulin', 98),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000070',
 'Which symptom indicates severe hypoglycemia requiring emergency intervention?',
 '[{"id":"a","text":"Polyuria"},{"id":"b","text":"Seizures or loss of consciousness"},{"id":"c","text":"Polydipsia"},{"id":"d","text":"Dry mouth"}]'::jsonb,
 ARRAY['b'], false,
 'Seizures and loss of consciousness indicate severe hypoglycemia requiring emergency glucagon injection or IV D50W. Polyuria, polydipsia, and dry mouth are hyperglycemia symptoms.',
 'Diabetes Mellitus', 99),

('00000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000075',
 'A patient with Type 2 diabetes asks why they must stop metformin before a CT scan with contrast. The best explanation is:',
 '[{"id":"a","text":"Contrast dye boosts metformin effectiveness too much"},{"id":"b","text":"Contrast dye can temporarily impair kidneys, causing metformin accumulation and lactic acidosis risk"},{"id":"c","text":"Metformin interferes with imaging quality"},{"id":"d","text":"It is a routine precaution with no clinical basis"}]'::jsonb,
 ARRAY['b'], false,
 'Contrast dye can cause transient acute kidney injury. Impaired kidneys cannot excrete metformin, causing dangerous accumulation and lactic acidosis. This is the clinical rationale for holding metformin before contrast procedures.',
 'Metformin', 100);

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
