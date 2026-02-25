-- ============================================================
-- TWELVE CRANIAL NERVES — Armenian Translations (100 questions)
-- ============================================================
-- Run AFTER:
--   1. ADD-QUESTION-ARMENIAN-TRANSLATIONS.sql  (adds _hy columns)
--   2. ADD-CRANIAL-NERVES-100-QUESTIONS.sql     (inserts EN questions)
-- Topic: Twelve Cranial Nerves
-- topic_id = '20000000-0000-0000-0000-000000000032'
-- test_id  = '00000000-0000-0000-0000-000000000001'
-- ============================================================

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր գանգուղեղային նյարդն է պատասխանատու հոտառության համար:',
  options_hy = '[{"id":"a","text":"Տեսողական (II)"},{"id":"b","text":"Հոտառական (I)"},{"id":"c","text":"Դիմային (VII)"},{"id":"d","text":"Թափառող (X)"}]'::jsonb,
  rationale_hy = 'Հոտառական նյարդը (I) զգայական նյարդ է, որի հիմնական գործառույթը հոտառությունն է։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 1;

UPDATE test_questions SET
  question_stem_hy = 'Զննման ժամանակ հիվանդը չի կարողանում շարժել լեզուն: Ո՞ր գանգուղեղային նյարդն է ամենայն հավանականությամբ վնասված:',
  options_hy = '[{"id":"a","text":"Հավելյալ (XI)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Ենթալեզվային (XII)"},{"id":"d","text":"Եռվորյակ (V)"}]'::jsonb,
  rationale_hy = 'Ենթալեզվային նյարդը (XII) շարժիչ նյարդ է՝ լեզվի շարժման համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 2;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդն է հիմնական պարասիմպաթիկ նյարդը՝ վերահսկելով սիրտը, թոքերը և մարսողությունը:',
  options_hy = '[{"id":"a","text":"Թափառող (X)"},{"id":"b","text":"Ճախարակային (IV)"},{"id":"c","text":"Զատող (VI)"},{"id":"d","text":"Ակնաշարժ (III)"}]'::jsonb,
  rationale_hy = 'Թափառող նյարդը (X) հիմնական պարասիմպաթիկ վերահսկողություն է ապահովում ներքին օրգանների համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 3;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր խառը գանգուղեղային նյարդն է պատասխանատու դեմքի զգայունության և ծամելու շարժիչ գործառույթի համար:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Եռվորյակ (V)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Հոտառական (I)"}]'::jsonb,
  rationale_hy = 'Եռվորյակ նյարդը (V) ապահովում է դեմքի զգայունությունը և ծամելու շարժիչ վերահսկողությունը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 4;

UPDATE test_questions SET
  question_stem_hy = 'Լսողության կորուստ և գլխապտույտ. Ո՞ր զգայական գանգուղեղային նյարդի վնասումն է կասկածվում:',
  options_hy = '[{"id":"a","text":"Տեսողական (II)"},{"id":"b","text":"Լսողական (VIII) (Վեստիբուլոկոխլեար)"},{"id":"c","text":"Հավելյալ (XI)"},{"id":"d","text":"Ճախարակային (IV)"}]'::jsonb,
  rationale_hy = 'VIII նյարդը պատասխանատու է լսողության և հավասարակշռության համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 5;

UPDATE test_questions SET
  question_stem_hy = 'Ուսերը թոթվել և գլուխը շրջել. Ո՞ր նյարդն է ստուգվում:',
  options_hy = '[{"id":"a","text":"Հավելյալ (XI)"},{"id":"b","text":"Ենթալեզվային (XII)"},{"id":"c","text":"Դիմային (VII)"},{"id":"d","text":"Թափառող (X)"}]'::jsonb,
  rationale_hy = 'XI նյարդը վերահսկում է կրծոսկրակրծային և սեղանարդաձև մկանները։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 6;

UPDATE test_questions SET
  question_stem_hy = 'Տեսողություն՝ ազդանշանները ցանցաթաղանթից դեպի ծոծրակային բլիթ. Ո՞ր նյարդն է պատասխանատու:',
  options_hy = '[{"id":"a","text":"Ակնաշարժ (III)"},{"id":"b","text":"Եռվորյակ (V)"},{"id":"c","text":"Տեսողական (II)"},{"id":"d","text":"Զատող (VI)"}]'::jsonb,
  rationale_hy = 'Տեսողական նյարդը (II) զտյալ զգայական նյարդ է՝ տեսողության համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 7;

UPDATE test_questions SET
  question_stem_hy = 'Լեզվի հետին 1/3-ի համի կորուստ. Ո՞ր խառը նյարդն է հավանաբար վնասված:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Եռվորյակ (V)"}]'::jsonb,
  rationale_hy = 'Լեզվի հետին 1/3-ի համի զգացողությունը կապված է IX նյարդի հետ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 8;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր շարժիչ նյարդն է վերահսկում բբի սեղմումը և աչքի մկանների շարժումների մեծ մասը:',
  options_hy = '[{"id":"a","text":"Ակնաշարժ (III)"},{"id":"b","text":"Ճախարակային (IV)"},{"id":"c","text":"Զատող (VI)"},{"id":"d","text":"Տեսողական (II)"}]'::jsonb,
  rationale_hy = 'III նյարդը վերահսկում է բբի սեղմումը, կոպի բարձրացումը և աչքի մկանների մեծ մասը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 9;

UPDATE test_questions SET
  question_stem_hy = 'Զատող (VI) նյարդը հիմնականում պատասխանատու է աչքի ո՞ր շարժման համար:',
  options_hy = '[{"id":"a","text":"Աչքը դեպի ներս դարձնելը"},{"id":"b","text":"Աչքը դեպի վար պտտելը"},{"id":"c","text":"Աչքը դեպի դուրս դարձնելը"},{"id":"d","text":"Կոպը բարձրացնելը"}]'::jsonb,
  rationale_hy = 'VI նյարդը վերահսկում է կողմնային ուղիղ մկանը՝ աչքը դեպի դուրս դարձնելու համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 10;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդն է պատասխանատու դիմախաղի և լեզվի առաջնային 2/3-ի համի համար:',
  options_hy = '[{"id":"a","text":"Եռվորյակ (V)"},{"id":"b","text":"Դիմային (VII)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Ենթալեզվային (XII)"}]'::jsonb,
  rationale_hy = 'VII նյարդը վերահսկում է դիմախաղը և ապահովում է լեզվի առջևի 2/3-ի համը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 11;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդն է պտտում աչքը դեպի վար և ներս (վերին թեք մկան):',
  options_hy = '[{"id":"a","text":"Ակնաշարժ (III)"},{"id":"b","text":"Ճախարակային (IV)"},{"id":"c","text":"Զատող (VI)"},{"id":"d","text":"Տեսողական (II)"}]'::jsonb,
  rationale_hy = 'IV նյարդը շարժում է վերին թեք մկանը՝ դեպի վար/ներս պտույտի համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 12;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր խառը նյարդն է պատասխանատու կլման և թքարտադրության համար:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Հավելյալ (XI)"}]'::jsonb,
  rationale_hy = 'IX նյարդը ներգրավված է կլման և թքարտադրության մեջ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 13;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդն է սկիզբ առնում քթից և փոխանցում հոտառության ազդանշաններ:',
  options_hy = '[{"id":"a","text":"Տեսողական (II)"},{"id":"b","text":"Հոտառական (I)"},{"id":"c","text":"Եռվորյակ (V)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'I նյարդը փոխանցում է հոտառության ազդանշանները։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 14;

UPDATE test_questions SET
  question_stem_hy = 'Խռպոտություն և ձայնալարերի խնդիր. ո՞ր նյարդն է կարող ներգրավված լինել:',
  options_hy = '[{"id":"a","text":"Լեզվաըմպանային (IX)"},{"id":"b","text":"Թափառող (X)"},{"id":"c","text":"Հավելյալ (XI)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'X նյարդը ներգրավված է կոկորդի/ձայնային ապարատի վերահսկման մեջ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 15;

UPDATE test_questions SET
  question_stem_hy = 'Ուղեղի ո՞ր մասն է պատասխանատու հավասարակշռության և շարժման համար:',
  options_hy = '[{"id":"a","text":"Մեծ ուղեղ"},{"id":"b","text":"Միջակա ուղեղ"},{"id":"c","text":"Ուղեղիկ"},{"id":"d","text":"Հիպոֆիզ"}]'::jsonb,
  rationale_hy = 'Ուղեղիկը պատասխանատու է շարժումների համակարգման և հավասարակշռության համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 16;

UPDATE test_questions SET
  question_stem_hy = 'Որո՞նք են «խառը» նյարդեր:',
  options_hy = '[{"id":"a","text":"I և II"},{"id":"b","text":"III և VI"},{"id":"c","text":"V և VII"},{"id":"d","text":"XI և XII"}]'::jsonb,
  rationale_hy = 'V և VII նյարդերը ունեն և՛ զգայական, և՛ շարժիչ գործառույթներ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 17;

UPDATE test_questions SET
  question_stem_hy = 'Ակնաշարժ (III) նյարդը վերահսկում է աչքի մկանների մեծ մասը՝ բացառությամբ քանիսի՞:',
  options_hy = '[{"id":"a","text":"0"},{"id":"b","text":"1"},{"id":"c","text":"2"},{"id":"d","text":"4"}]'::jsonb,
  rationale_hy = 'Երկու մկան վերահսկվում է IV և VI նյարդերով։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 18;

UPDATE test_questions SET
  question_stem_hy = 'Տեսողության ազդանշանները փոխանցվում են ուղեղի ո՞ր բլթին:',
  options_hy = '[{"id":"a","text":"Ճակատային"},{"id":"b","text":"Քունքային"},{"id":"c","text":"Ծոծրակային"},{"id":"d","text":"Ծոծրակային և ճակատային"}]'::jsonb,
  rationale_hy = 'Տեսողությունը մշակվում է ծոծրակային բլթում։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 19;

UPDATE test_questions SET
  question_stem_hy = 'Եռվորյակ նյարդի ո՞ր ճյուղն է պատասխանատու դեմքի միջին հատվածի համար:',
  options_hy = '[{"id":"a","text":"Ակնային"},{"id":"b","text":"Վերին ծնոտային"},{"id":"c","text":"Ստորին ծնոտային"},{"id":"d","text":"Քունքային"}]'::jsonb,
  rationale_hy = 'Վերին ծնոտային ճյուղը ապահովում է դեմքի միջին հատվածի զգայունությունը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 20;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդն ունի 3 ճյուղ՝ ակնային, վերին ծնոտային, ստորին ծնոտային:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Եռվորյակ (V)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Թափառող (X)"}]'::jsonb,
  rationale_hy = 'V նյարդը բաժանվում է 3 ճյուղերի։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 21;

UPDATE test_questions SET
  question_stem_hy = 'Զատող (VI) նյարդը վերահսկում է աչքի ո՞ր մկանը:',
  options_hy = '[{"id":"a","text":"Վերին թեք"},{"id":"b","text":"Կողմնային ուղիղ"},{"id":"c","text":"Միջային ուղիղ"},{"id":"d","text":"Ստորին ուղիղ"}]'::jsonb,
  rationale_hy = 'VI նյարդը վերահսկում է կողմնային ուղիղ մկանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 22;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր կառուցվածքն է ներառում Պոնսը և Երկարավուն ուղեղը:',
  options_hy = '[{"id":"a","text":"Մեծ ուղեղ"},{"id":"b","text":"Միջակա ուղեղ"},{"id":"c","text":"Ուղեղաբուն"},{"id":"d","text":"Ուղեղիկ"}]'::jsonb,
  rationale_hy = 'Պոնսն ու Երկարավուն ուղեղը ուղեղաբնի մասեր են։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 23;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդերն են պատասխանատու աչքի շարժումների համար:',
  options_hy = '[{"id":"a","text":"I, II, III"},{"id":"b","text":"III, IV, VI"},{"id":"c","text":"V, VII, IX"},{"id":"d","text":"VIII, X, XII"}]'::jsonb,
  rationale_hy = 'III, IV, VI նյարդերը ապահովում են աչքի շարժումները։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 24;

UPDATE test_questions SET
  question_stem_hy = 'Գլուխը դեպի կողմ շրջելու անկարողություն. ո՞ր նյարդն է կասկածվում:',
  options_hy = '[{"id":"a","text":"Թափառող (X)"},{"id":"b","text":"Հավելյալ (XI)"},{"id":"c","text":"Ենթալեզվային (XII)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'XI նյարդը վերահսկում է գլխի պտույտը (sternocleidomastoid)։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 25;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդն է թույլ տալիս բարձրացնել կոպը:',
  options_hy = '[{"id":"a","text":"Տեսողական (II)"},{"id":"b","text":"Ակնաշարժ (III)"},{"id":"c","text":"Ճախարակային (IV)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'III նյարդը վերահսկում է կոպի բարձրացումը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 26;

UPDATE test_questions SET
  question_stem_hy = 'Ստորին ծնոտային ճյուղը վերահսկում է ո՞ր գործառույթը:',
  options_hy = '[{"id":"a","text":"Ճակատի զգայունությունը"},{"id":"b","text":"Դեմքի միջին հատվածի զգայունությունը"},{"id":"c","text":"Ծնոտի շարժումը և ծամելը"},{"id":"d","text":"Աչքի պտույտը"}]'::jsonb,
  rationale_hy = 'Mandibular ճյուղը ունի ծամելու շարժիչ գործառույթ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 27;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր զգայական նյարդն է ազդանշանները ցանցաթաղանթից փոխանցում ուղեղին:',
  options_hy = '[{"id":"a","text":"Հոտառական (I)"},{"id":"b","text":"Տեսողական (II)"},{"id":"c","text":"Ակնաշարժ (III)"},{"id":"d","text":"Զատող (VI)"}]'::jsonb,
  rationale_hy = 'II նյարդը տեսողական ազդանշանները փոխանցում է ուղեղին։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 28;

UPDATE test_questions SET
  question_stem_hy = 'Ինչպե՞ս են դասակարգվում XI և XII նյարդերը:',
  options_hy = '[{"id":"a","text":"Զգայական"},{"id":"b","text":"Շարժիչ"},{"id":"c","text":"Խառը"},{"id":"d","text":"Պարասիմպաթիկ"}]'::jsonb,
  rationale_hy = 'XI և XII նյարդերը շարժիչ են։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 29;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր կառուցվածքն է պատասխանատու հորմոնալ վերահսկողության համար:',
  options_hy = '[{"id":"a","text":"Ուղեղիկ"},{"id":"b","text":"Ուղեղաբուն"},{"id":"c","text":"Հիպոֆիզ"},{"id":"d","text":"Միջակա ուղեղ"}]'::jsonb,
  rationale_hy = 'Հիպոֆիզը պատասխանատու է հորմոնների վերահսկման համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 30;

UPDATE test_questions SET
  question_stem_hy = 'Լսողական (VIII) նյարդի 2 բաղադրիչներն են՝',
  options_hy = '[{"id":"a","text":"Զգայական և շարժիչ"},{"id":"b","text":"Լսողություն և հավասարակշռություն"},{"id":"c","text":"Վերին ծնոտային և ստորին ծնոտային"},{"id":"d","text":"Ակնային և տեսողական"}]'::jsonb,
  rationale_hy = 'VIII նյարդը ունի խխունջային (լսողություն) և անդաստակային (հավասարակշռություն) մասեր։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 31;

UPDATE test_questions SET
  question_stem_hy = 'Դիմային (VII) նյարդի վնասումը ամենայն հավանականությամբ կհանգեցնի՝',
  options_hy = '[{"id":"a","text":"Հոտառության կորուստ"},{"id":"b","text":"Ատամների զգայունության կորուստ"},{"id":"c","text":"Դեմքի կախվածություն/դիմախաղի կորուստ"},{"id":"d","text":"Գլուխը շրջելու դժվարություն"}]'::jsonb,
  rationale_hy = 'VII նյարդը վերահսկում է դիմախաղի մկանները։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 32;

UPDATE test_questions SET
  question_stem_hy = '«Մինի-ինսուլտից» հետո կլման դժվարություն. ո՞ր խառը նյարդն է պատասխանատու կլման շարժիչ ֆունկցիայի համար:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Հավելյալ (XI)"},{"id":"d","text":"Ենթալեզվային (XII)"}]'::jsonb,
  rationale_hy = 'IX նյարդը մասնակցում է կլմանը և թքարտադրությանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 33;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդն է «իջնում ներքև»՝ վերահսկելով սիրտը և մարսողական համակարգը:',
  options_hy = '[{"id":"a","text":"Հավելյալ (XI)"},{"id":"b","text":"Թափառող (X)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Զատող (VI)"}]'::jsonb,
  rationale_hy = 'X նյարդը հիմնական պարասիմպաթիկ նյարդն է՝ դեպի սիրտ/թոքեր/մարսողություն։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 34;

UPDATE test_questions SET
  question_stem_hy = 'Ճախարակային (IV) նյարդը ինչպես է դասակարգվում:',
  options_hy = '[{"id":"a","text":"Զգայական"},{"id":"b","text":"Շարժիչ"},{"id":"c","text":"Խառը"},{"id":"d","text":"Ե՛վ զգայական, և՛ շարժիչ"}]'::jsonb,
  rationale_hy = 'IV նյարդը շարժիչ է՝ վերին թեք մկանին։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 35;

UPDATE test_questions SET
  question_stem_hy = 'Եռվորյակ (V) նյարդի ո՞ր ճյուղն է ապահովում ճակատի և աչքերի շրջակայքի զգայունությունը:',
  options_hy = '[{"id":"a","text":"Ակնային"},{"id":"b","text":"Վերին ծնոտային"},{"id":"c","text":"Ստորին ծնոտային"},{"id":"d","text":"Տեսողական"}]'::jsonb,
  rationale_hy = 'Ophthalmic ճյուղը ապահովում է ճակատ/աչք շրջանի զգայունությունը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 36;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր մասն է հորմոնալ վերահսկողության հիմնական կենտրոնը (տրված հավաքածուում):',
  options_hy = '[{"id":"a","text":"Մեծ ուղեղ"},{"id":"b","text":"Միջակա ուղեղ"},{"id":"c","text":"Հիպոֆիզ"},{"id":"d","text":"Ուղեղաբուն"}]'::jsonb,
  rationale_hy = 'Հիպոֆիզը պատասխանատու է հորմոնալ վերահսկողության համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 37;

UPDATE test_questions SET
  question_stem_hy = 'XI նյարդի վնասում. ո՞ր շարժումը կխանգարվի:',
  options_hy = '[{"id":"a","text":"Լեզվի շարժում"},{"id":"b","text":"Ծամել"},{"id":"c","text":"Ուսերի բարձրացում"},{"id":"d","text":"Դիմախաղ"}]'::jsonb,
  rationale_hy = 'XI նյարդը վերահսկում է սեղանարդաձև մկանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 38;

UPDATE test_questions SET
  question_stem_hy = 'III նյարդը պատասխանատու է՝',
  options_hy = '[{"id":"a","text":"Հոտառություն"},{"id":"b","text":"Բբի սեղմում"},{"id":"c","text":"Լսողություն"},{"id":"d","text":"Հավասարակշռություն"}]'::jsonb,
  rationale_hy = 'III նյարդը ունի պարասիմպաթիկ ֆունկցիա՝ բբի սեղմման համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 39;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդերն են զտյալ զգայական:',
  options_hy = '[{"id":"a","text":"I, II, VIII"},{"id":"b","text":"III, IV, VI"},{"id":"c","text":"V, VII, IX"},{"id":"d","text":"X, XI, XII"}]'::jsonb,
  rationale_hy = 'I (հոտ), II (տեսողություն), VIII (լսողություն/հավասարակշռություն)՝ զտյալ զգայական են։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 40;

UPDATE test_questions SET
  question_stem_hy = 'Ո՞ր նյարդն է պատասխանատու լեզվի շարժիչ վերահսկողության համար:',
  options_hy = '[{"id":"a","text":"Թափառող (X)"},{"id":"b","text":"Հավելյալ (XI)"},{"id":"c","text":"Ենթալեզվային (XII)"},{"id":"d","text":"Լեզվաըմպանային (IX)"}]'::jsonb,
  rationale_hy = 'XII նյարդը շարժիչ է՝ լեզվի համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 41;

UPDATE test_questions SET
  question_stem_hy = 'Gag reflex և կլում. ո՞ր երկու նյարդերն են հիմնականում գնահատվում:',
  options_hy = '[{"id":"a","text":"VII և IX"},{"id":"b","text":"IX և X"},{"id":"c","text":"X և XI"},{"id":"d","text":"V և VII"}]'::jsonb,
  rationale_hy = 'IX և X նյարդերը մասնակցում են կոկորդի/կլման գործառույթներին։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 42;

UPDATE test_questions SET
  question_stem_hy = 'Զգայական տեղեկատվության «relay station» (միջնորդակայան)՝ ո՞րն է:',
  options_hy = '[{"id":"a","text":"Ուղեղիկ"},{"id":"b","text":"Պոնս"},{"id":"c","text":"Տեսաթումբ"},{"id":"d","text":"Երկարավուն ուղեղ"}]'::jsonb,
  rationale_hy = 'Տեսաթումբը ծառայում է որպես զգայական տեղեկատվության միջնորդակայան։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 43;

UPDATE test_questions SET
  question_stem_hy = 'Չի կարողանում ամուր փակել աչքը + կորցրել է լեզվի առջևի համը. ո՞ր նյարդը:',
  options_hy = '[{"id":"a","text":"Եռվորյակ (V)"},{"id":"b","text":"Դիմային (VII)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Ակնաշարժ (III)"}]'::jsonb,
  rationale_hy = 'VII նյարդը ապահովում է աչքի փակումը և լեզվի առջևի 2/3-ի համը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 44;

UPDATE test_questions SET
  question_stem_hy = 'Հավասարակշռության տեղեկատվությունը ուղեղին փոխանցող նյարդը՝',
  options_hy = '[{"id":"a","text":"Տեսողական (II)"},{"id":"b","text":"Լսողական (VIII)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Հավելյալ (XI)"}]'::jsonb,
  rationale_hy = 'VIII նյարդի անդաստակային մասը պատասխանատու է հավասարակշռության համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 45;

UPDATE test_questions SET
  question_stem_hy = 'Վերին թեք մկանով աչքը դեպի վար/ներս պտտող նյարդը՝',
  options_hy = '[{"id":"a","text":"Ակնաշարժ (III)"},{"id":"b","text":"Ճախարակային (IV)"},{"id":"c","text":"Զատող (VI)"},{"id":"d","text":"Տեսողական (II)"}]'::jsonb,
  rationale_hy = 'IV նյարդը վերահսկում է վերին թեք մկանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 46;

UPDATE test_questions SET
  question_stem_hy = 'Ատամների և ստորին ծնոտի զգայունության կորուստ. ո՞ր ճյուղը:',
  options_hy = '[{"id":"a","text":"Ակնային"},{"id":"b","text":"Վերին ծնոտային"},{"id":"c","text":"Ստորին ծնոտային"},{"id":"d","text":"Տեսողական"}]'::jsonb,
  rationale_hy = 'Mandibular ճյուղը ապահովում է ստորին ծնոտ/ատամների զգայունությունը և ծամելը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 47;

UPDATE test_questions SET
  question_stem_hy = 'Հավասարակշռություն և շարժումների համակարգում. ո՞ր ուղեղային հատվածը:',
  options_hy = '[{"id":"a","text":"Մեծ ուղեղ"},{"id":"b","text":"Ուղեղաբուն"},{"id":"c","text":"Ուղեղիկ"},{"id":"d","text":"Միջակա ուղեղ"}]'::jsonb,
  rationale_hy = 'Ուղեղիկը համակարգում է շարժումները և պահպանում հավասարակշռությունը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 48;

UPDATE test_questions SET
  question_stem_hy = '«Խառը» նյարդ՝ դեմքի զգայական + ծամելու շարժիչ. ո՞րը:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Եռվորյակ (V)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Հավելյալ (XI)"}]'::jsonb,
  rationale_hy = 'V նյարդը ունի դեմքի զգայական և ծամելու շարժիչ ֆունկցիա։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 49;

UPDATE test_questions SET
  question_stem_hy = 'III նյարդի բբի սեղմումը նյարդային համակարգի ո՞ր տեսակի օրինակ է:',
  options_hy = '[{"id":"a","text":"Սոմատիկ"},{"id":"b","text":"Պարասիմպաթիկ"},{"id":"c","text":"Միայն զգայական"},{"id":"d","text":"Սիմպաթիկ"}]'::jsonb,
  rationale_hy = 'Բբի սեղմումը պարասիմպաթիկ ֆունկցիա է։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 50;

UPDATE test_questions SET
  question_stem_hy = 'Լեզվի առջևի 2/3-ի համը՝ ո՞ր նյարդը:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Եռվորյակ (V)"}]'::jsonb,
  rationale_hy = 'VII նյարդը ապահովում է լեզվի առջևի 2/3-ի համը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 51;

UPDATE test_questions SET
  question_stem_hy = 'Քթից սկիզբ առնող և քունքային բլիթ «ուղարկող» նյարդը՝',
  options_hy = '[{"id":"a","text":"Տեսողական (II)"},{"id":"b","text":"Հոտառական (I)"},{"id":"c","text":"Եռվորյակ (V)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'I նյարդը փոխանցում է հոտառության ազդանշաններ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 52;

UPDATE test_questions SET
  question_stem_hy = 'Դիմախաղի համաչափություն ստուգելիս՝ ո՞ր նյարդն է գնահատվում:',
  options_hy = '[{"id":"a","text":"Եռվորյակ (V)"},{"id":"b","text":"Դիմային (VII)"},{"id":"c","text":"Ակնաշարժ (III)"},{"id":"d","text":"Զատող (VI)"}]'::jsonb,
  rationale_hy = 'VII նյարդը վերահսկում է դիմախաղի մկանները։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 53;

UPDATE test_questions SET
  question_stem_hy = 'Հիպոֆիզով հորմոնալ վերահսկում՝ ո՞ր ուղեղային մասում (տրված հավաքածուում):',
  options_hy = '[{"id":"a","text":"Ուղեղիկ"},{"id":"b","text":"Միջակա ուղեղ"},{"id":"c","text":"Ուղեղաբուն"},{"id":"d","text":"Մեծ ուղեղ"}]'::jsonb,
  rationale_hy = 'Տրված հավաքածուում հիպոֆիզը կապվում է միջակա ուղեղի տարածաշրջանի հետ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 54;

UPDATE test_questions SET
  question_stem_hy = 'III նյարդի վնասումից դժվարություններ կլինեն բոլորը, ԲԱՑԱՌՈՒԹՅԱՄԲ՝',
  options_hy = '[{"id":"a","text":"Կոպի բարձրացում"},{"id":"b","text":"Բբի սեղմում"},{"id":"c","text":"Աչքի շարժումների մեծ մասը"},{"id":"d","text":"Տեսողության զգացողություն"}]'::jsonb,
  rationale_hy = 'Տեսողությունը ապահովում է II նյարդը, ոչ թե III-ը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 55;

UPDATE test_questions SET
  question_stem_hy = 'Միակ նյարդը, որը «իջնում է» մինչև սիրտ և ստամոքս՝',
  options_hy = '[{"id":"a","text":"Լեզվաըմպանային (IX)"},{"id":"b","text":"Թափառող (X)"},{"id":"c","text":"Հավելյալ (XI)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'X նյարդը իջնում է դեպի կրծքավանդակի և որովայնի օրգաններ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 56;

UPDATE test_questions SET
  question_stem_hy = 'V նյարդի վնասում. ո՞ր արդյունքն է սպասելի:',
  options_hy = '[{"id":"a","text":"Ժպտալու անկարողություն"},{"id":"b","text":"Դեմքի զգայունության կորուստ"},{"id":"c","text":"Լսողության կորուստ"},{"id":"d","text":"Երկտեսություն"}]'::jsonb,
  rationale_hy = 'V նյարդը փոխանցում է դեմքի զգայական տեղեկատվություն։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 57;

UPDATE test_questions SET
  question_stem_hy = 'Վերին թեք մկանով աչքը դեպի վար/ներս պտտող նյարդը՝',
  options_hy = '[{"id":"a","text":"Ճախարակային (IV)"},{"id":"b","text":"Զատող (VI)"},{"id":"c","text":"Ակնաշարժ (III)"},{"id":"d","text":"Տեսողական (II)"}]'::jsonb,
  rationale_hy = 'IV նյարդը վերահսկում է վերին թեք մկանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 58;

UPDATE test_questions SET
  question_stem_hy = 'Թքարտադրության համար պատասխանատու խառը նյարդը՝',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Ենթալեզվային (XII)"}]'::jsonb,
  rationale_hy = 'IX նյարդը մասնակցում է թքարտադրությանը և կլմանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 59;

UPDATE test_questions SET
  question_stem_hy = 'I և II նյարդերի դասակարգումը՝',
  options_hy = '[{"id":"a","text":"Շարժիչ"},{"id":"b","text":"Զգայական"},{"id":"c","text":"Խառը"},{"id":"d","text":"Ավտոնոմ"}]'::jsonb,
  rationale_hy = 'I և II նյարդերը զտյալ զգայական են։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 60;

UPDATE test_questions SET
  question_stem_hy = 'Գլխի պտույտի շարժիչ ֆունկցիան՝ ո՞ր նյարդը:',
  options_hy = '[{"id":"a","text":"Թափառող (X)"},{"id":"b","text":"Հավելյալ (XI)"},{"id":"c","text":"Ենթալեզվային (XII)"},{"id":"d","text":"Լեզվաըմպանային (IX)"}]'::jsonb,
  rationale_hy = 'XI նյարդը վերահսկում է գլխի պտույտը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 61;

UPDATE test_questions SET
  question_stem_hy = 'Տեսողական ազդանշանները II նյարդից ստանում է ո՞ր բլիթը:',
  options_hy = '[{"id":"a","text":"Ճակատային"},{"id":"b","text":"Քունքային"},{"id":"c","text":"Ծոծրակային"},{"id":"d","text":"Գագաթային"}]'::jsonb,
  rationale_hy = 'Տեսողությունը մշակվում է ծոծրակային բլթում։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 62;

UPDATE test_questions SET
  question_stem_hy = 'Ծամելու մկաններ վերահսկող խառը նյարդը՝',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Եռվորյակ (V)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Ենթալեզվային (XII)"}]'::jsonb,
  rationale_hy = 'V նյարդի շարժիչ մասը վերահսկում է ծամելը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 63;

UPDATE test_questions SET
  question_stem_hy = 'VIII նյարդը պատասխանատու է՝',
  options_hy = '[{"id":"a","text":"Համ և հոտ"},{"id":"b","text":"Լսողություն և հավասարակշռություն"},{"id":"c","text":"Տեսողություն և դեմքի զգայունություն"},{"id":"d","text":"Կլում և ձայնալարեր"}]'::jsonb,
  rationale_hy = 'VIII նյարդը ապահովում է լսողություն/հավասարակշռություն։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 64;

UPDATE test_questions SET
  question_stem_hy = 'Աչքը դեպի դուրս դարձնող շարժիչ նյարդը՝',
  options_hy = '[{"id":"a","text":"Ակնաշարժ (III)"},{"id":"b","text":"Ճախարակային (IV)"},{"id":"c","text":"Զատող (VI)"},{"id":"d","text":"Տեսողական (II)"}]'::jsonb,
  rationale_hy = 'VI նյարդը վերահսկում է կողմնային ուղիղ մկանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 65;

UPDATE test_questions SET
  question_stem_hy = 'Կլման դժվարություն + թուլացած gag reflex + թքարտադրություն. ո՞ր նյարդը:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Հավելյալ (XI)"},{"id":"d","text":"Ենթալեզվային (XII)"}]'::jsonb,
  rationale_hy = 'IX նյարդը ներգրավված է կլման, gag reflex-ի և թքարտադրության մեջ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 66;

UPDATE test_questions SET
  question_stem_hy = 'Պոնսի հետ միասին հիշատակվող և կենսական գործառույթների հետ կապված ուղեղաբնի շրջանը՝',
  options_hy = '[{"id":"a","text":"Մեծ ուղեղ"},{"id":"b","text":"Տեսաթումբ"},{"id":"c","text":"Երկարավուն ուղեղ"},{"id":"d","text":"Ենթատեսաթումբ"}]'::jsonb,
  rationale_hy = 'Պոնսը և երկարավուն ուղեղը ուղեղաբնի շրջաններ են։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 67;

UPDATE test_questions SET
  question_stem_hy = 'Թափառող (X) նյարդի հիմնական դերը՝',
  options_hy = '[{"id":"a","text":"Հոտ և համ"},{"id":"b","text":"Սրտի/թոքերի հիմնական պարասիմպաթիկ վերահսկում"},{"id":"c","text":"Ճակատի շարժում"},{"id":"d","text":"Լսողություն/հավասարակշռություն"}]'::jsonb,
  rationale_hy = 'X նյարդը հիմնական պարասիմպաթիկ նյարդն է։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 68;

UPDATE test_questions SET
  question_stem_hy = 'Դիմախաղը վերահսկող խառը նյարդը՝',
  options_hy = '[{"id":"a","text":"Եռվորյակ (V)"},{"id":"b","text":"Դիմային (VII)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Թափառող (X)"}]'::jsonb,
  rationale_hy = 'VII նյարդի շարժիչ մասը վերահսկում է դիմախաղը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 69;

UPDATE test_questions SET
  question_stem_hy = 'III նյարդը բբի սեղմումից բացի վերահսկում է նաև՝',
  options_hy = '[{"id":"a","text":"Աչքը փակելը"},{"id":"b","text":"Կոպի բարձրացում"},{"id":"c","text":"Թարթում"},{"id":"d","text":"Արցունքարտադրություն"}]'::jsonb,
  rationale_hy = 'III նյարդը ապահովում է կոպի բարձրացումը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 70;

UPDATE test_questions SET
  question_stem_hy = 'Լեզվի շարժումը վերահսկող շարժիչ նյարդը՝',
  options_hy = '[{"id":"a","text":"Թափառող (X)"},{"id":"b","text":"Ենթալեզվային (XII)"},{"id":"c","text":"Հավելյալ (XI)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'XII նյարդը շարժիչ է՝ լեզվի համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 71;

UPDATE test_questions SET
  question_stem_hy = 'XI նյարդը ուսերը թոթվելու համար վերահսկում է՝',
  options_hy = '[{"id":"a","text":"Կրծոսկրակրծային"},{"id":"b","text":"Սեղանարդաձև"},{"id":"c","text":"Կողմնային ուղիղ"},{"id":"d","text":"Վերին թեք"}]'::jsonb,
  rationale_hy = 'XI նյարդը վերահսկում է սեղանարդաձև մկանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 72;

UPDATE test_questions SET
  question_stem_hy = 'Զգայական տեղեկատվության relay station՝',
  options_hy = '[{"id":"a","text":"Ենթատեսաթումբ"},{"id":"b","text":"Տեսաթումբ"},{"id":"c","text":"Միջին ուղեղ"},{"id":"d","text":"Պոնս"}]'::jsonb,
  rationale_hy = 'Տեսաթումբը միջնորդում է զգայական ազդանշանները։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 73;

UPDATE test_questions SET
  question_stem_hy = 'IV նյարդը աչքը պտտում է՝',
  options_hy = '[{"id":"a","text":"Դեպի դուրս"},{"id":"b","text":"Դեպի վար և ներս"},{"id":"c","text":"Դեպի վեր և դուրս"},{"id":"d","text":"Ուղղակի դեպի ներս"}]'::jsonb,
  rationale_hy = 'IV նյարդը վերահսկում է վերին թեք մկանը (վար/ներս)։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 74;

UPDATE test_questions SET
  question_stem_hy = 'Դեմքի և ատամների ցավի/զգայության նյարդը՝',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Եռվորյակ (V)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Լեզվաըմպանային (IX)"}]'::jsonb,
  rationale_hy = 'V նյարդը փոխանցում է դեմքի/ատամների զգայունություն։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 75;

UPDATE test_questions SET
  question_stem_hy = 'Զտյալ զգայական նյարդերի քանակը՝',
  options_hy = '[{"id":"a","text":"2"},{"id":"b","text":"3"},{"id":"c","text":"4"},{"id":"d","text":"5"}]'::jsonb,
  rationale_hy = 'I, II, VIII՝ երեք զտյալ զգայական նյարդեր են։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 76;

UPDATE test_questions SET
  question_stem_hy = 'Հորմոնալ վերահսկողության համար պատասխանատու կառուցվածքը՝',
  options_hy = '[{"id":"a","text":"Տեսաթումբ"},{"id":"b","text":"Հիպոֆիզ"},{"id":"c","text":"Ուղեղիկ"},{"id":"d","text":"Երկարավուն ուղեղ"}]'::jsonb,
  rationale_hy = 'Հիպոֆիզը ղեկավարում է հորմոնալ վերահսկողությունը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 77;

UPDATE test_questions SET
  question_stem_hy = 'Լեզվի հետին 1/3-ի համը՝ ո՞ր նյարդը:',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Եռվորյակ (V)"}]'::jsonb,
  rationale_hy = 'IX նյարդը ապահովում է հետին 1/3-ի համը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 78;

UPDATE test_questions SET
  question_stem_hy = 'Քթից հոտառության ազդանշանները փոխանցվում են ո՞ր բլթին (տրված հավաքածուում):',
  options_hy = '[{"id":"a","text":"Ծոծրակային"},{"id":"b","text":"Ճակատային"},{"id":"c","text":"Քունքային"},{"id":"d","text":"Գագաթային"}]'::jsonb,
  rationale_hy = 'Հոտառության ուղիները տրված հավաքածուում նշվում են որպես դեպի քունքային բլիթ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 79;

UPDATE test_questions SET
  question_stem_hy = 'III նյարդը բբի սեղմումից բացի վերահսկում է՝',
  options_hy = '[{"id":"a","text":"Աչքի շարժումը դեպի ներս"},{"id":"b","text":"Կոպի բարձրացում"},{"id":"c","text":"Աչքի պտույտ"},{"id":"d","text":"Ուսերի բարձրացում"}]'::jsonb,
  rationale_hy = 'III նյարդի գործառույթներից մեկն է կոպի բարձրացումը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 80;

UPDATE test_questions SET
  question_stem_hy = 'Խառը նյարդ՝ լեզվի առջևի 2/3-ի համ. ո՞րը:',
  options_hy = '[{"id":"a","text":"Եռվորյակ (V)"},{"id":"b","text":"Դիմային (VII)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Ենթալեզվային (XII)"}]'::jsonb,
  rationale_hy = 'VII նյարդը ապահովում է լեզվի առջևի 2/3-ի համը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 81;

UPDATE test_questions SET
  question_stem_hy = 'Լեզուն հանելիս ստուգվում է՝',
  options_hy = '[{"id":"a","text":"Թափառող (X)"},{"id":"b","text":"Հավելյալ (XI)"},{"id":"c","text":"Ենթալեզվային (XII)"},{"id":"d","text":"Լեզվաըմպանային (IX)"}]'::jsonb,
  rationale_hy = 'XII նյարդը վերահսկում է լեզվի շարժումը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 82;

UPDATE test_questions SET
  question_stem_hy = 'Բարդ շարժումներ, կեցվածք, հավասարակշռություն՝',
  options_hy = '[{"id":"a","text":"Մեծ ուղեղ"},{"id":"b","text":"Ուղեղիկ"},{"id":"c","text":"Ուղեղաբուն"},{"id":"d","text":"Միջակա ուղեղ"}]'::jsonb,
  rationale_hy = 'Ուղեղիկը համակարգում է շարժումները և պահպանում հավասարակշռությունը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 83;

UPDATE test_questions SET
  question_stem_hy = 'Պարասիմպաթիկ ազդանշանների հիմնական փոխանցողը դեպի օրգաններ՝',
  options_hy = '[{"id":"a","text":"Լեզվաըմպանային (IX)"},{"id":"b","text":"Թափառող (X)"},{"id":"c","text":"Հավելյալ (XI)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'X նյարդը հիմնական պարասիմպաթիկ նյարդն է։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 84;

UPDATE test_questions SET
  question_stem_hy = 'VI նյարդի դասակարգումը՝',
  options_hy = '[{"id":"a","text":"Զգայական"},{"id":"b","text":"Շարժիչ"},{"id":"c","text":"Խառը"},{"id":"d","text":"Ավտոնոմ"}]'::jsonb,
  rationale_hy = 'VI նյարդը շարժիչ է՝ կողմնային ուղիղ մկանին։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 85;

UPDATE test_questions SET
  question_stem_hy = 'Ցանցաթաղանթից դեպի ծոծրակային բլիթ ազդանշաններ փոխանցող նյարդը՝',
  options_hy = '[{"id":"a","text":"Հոտառական (I)"},{"id":"b","text":"Տեսողական (II)"},{"id":"c","text":"Ակնաշարժ (III)"},{"id":"d","text":"Ճախարակային (IV)"}]'::jsonb,
  rationale_hy = 'II նյարդը տեսողական ազդանշանները փոխանցում է ուղեղին։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 86;

UPDATE test_questions SET
  question_stem_hy = 'Ծնոտի զգայական տեղեկատվություն ապահովող ճյուղը՝',
  options_hy = '[{"id":"a","text":"Ակնային"},{"id":"b","text":"Վերին ծնոտային"},{"id":"c","text":"Ստորին ծնոտային"},{"id":"d","text":"Ակնաշարժ"}]'::jsonb,
  rationale_hy = 'Mandibular ճյուղը կապված է ծնոտի զգայունության հետ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 87;

UPDATE test_questions SET
  question_stem_hy = 'Կլման դժվարություն + թքարտադրության բացակայություն՝',
  options_hy = '[{"id":"a","text":"Դիմային (VII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Հավելյալ (XI)"},{"id":"d","text":"Ենթալեզվային (XII)"}]'::jsonb,
  rationale_hy = 'IX նյարդը մասնակցում է կլման և թքարտադրության մեջ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 88;

UPDATE test_questions SET
  question_stem_hy = 'XI նյարդը վերահսկում է՝',
  options_hy = '[{"id":"a","text":"Կողմնային ուղիղ"},{"id":"b","text":"Վերին թեք"},{"id":"c","text":"Սեղանարդաձև և կրծոսկրակրծային"},{"id":"d","text":"Լեզվի մկաններ"}]'::jsonb,
  rationale_hy = 'XI նյարդը վերահսկում է ուսերի բարձրացումը և գլխի պտույտը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 89;

UPDATE test_questions SET
  question_stem_hy = 'Լսողություն և հավասարակշռություն փոխանցող նյարդը՝',
  options_hy = '[{"id":"a","text":"Տեսողական (II)"},{"id":"b","text":"Լսողական (VIII)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Դիմային (VII)"}]'::jsonb,
  rationale_hy = 'VIII նյարդը պատասխանատու է լսողության և հավասարակշռության համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 90;

UPDATE test_questions SET
  question_stem_hy = 'Կոկորդի/ձայնային ապարատի շարժիչ վերահսկող խառը նյարդը՝',
  options_hy = '[{"id":"a","text":"Լեզվաըմպանային (IX)"},{"id":"b","text":"Դիմային (VII)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Հավելյալ (XI)"}]'::jsonb,
  rationale_hy = 'X նյարդը ներգրավված է կոկորդի և ձայնային ապարատի վերահսկման մեջ։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 91;

UPDATE test_questions SET
  question_stem_hy = 'Տեսողական ազդանշանների մշակում՝ ո՞ր բլթում:',
  options_hy = '[{"id":"a","text":"Ճակատային"},{"id":"b","text":"Ծոծրակային"},{"id":"c","text":"Քունքային"},{"id":"d","text":"Գագաթային"}]'::jsonb,
  rationale_hy = 'Տեսողությունը մշակվում է ծոծրակային բլթում։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 92;

UPDATE test_questions SET
  question_stem_hy = 'Այտի զգայունություն (Q-tip). ո՞ր ճյուղը:',
  options_hy = '[{"id":"a","text":"Ակնային"},{"id":"b","text":"Վերին ծնոտային"},{"id":"c","text":"Ստորին ծնոտային"},{"id":"d","text":"Ակնաշարժ"}]'::jsonb,
  rationale_hy = 'Maxillary ճյուղը ապահովում է միջին դեմքի (այդ թվում՝ այտերի) զգայունությունը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 93;

UPDATE test_questions SET
  question_stem_hy = 'Դիմախաղի մկանների հիմնական շարժիչ վերահսկող նյարդը՝',
  options_hy = '[{"id":"a","text":"Եռվորյակ (V)"},{"id":"b","text":"Դիմային (VII)"},{"id":"c","text":"Լեզվաըմպանային (IX)"},{"id":"d","text":"Հավելյալ (XI)"}]'::jsonb,
  rationale_hy = 'VII նյարդը վերահսկում է դիմախաղի մկանները։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 94;

UPDATE test_questions SET
  question_stem_hy = 'III նյարդը չի վերահսկում վերին թեք մկանը և ո՞ր այլ մկանը:',
  options_hy = '[{"id":"a","text":"Միջային ուղիղ"},{"id":"b","text":"Կողմնային ուղիղ"},{"id":"c","text":"Ստորին ուղիղ"},{"id":"d","text":"Վերին ուղիղ"}]'::jsonb,
  rationale_hy = 'Կողմնային ուղիղը վերահսկվում է VI նյարդով, վերին թեքը՝ IV նյարդով։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 95;

UPDATE test_questions SET
  question_stem_hy = 'Լսողական ազդանշանների փոխանցման համար պատասխանատու զգայական նյարդը՝',
  options_hy = '[{"id":"a","text":"Լսողական (VIII)"},{"id":"b","text":"Լեզվաըմպանային (IX)"},{"id":"c","text":"Թափառող (X)"},{"id":"d","text":"Տեսողական (II)"}]'::jsonb,
  rationale_hy = 'VIII նյարդի խխունջային մասը պատասխանատու է լսողության համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 96;

UPDATE test_questions SET
  question_stem_hy = 'Պոնսի հետ միասին հիշատակվող և կենսական գործառույթների համար կարևոր ուղեղաբնի մասը՝',
  options_hy = '[{"id":"a","text":"Մեծ ուղեղ"},{"id":"b","text":"Միջակա ուղեղ"},{"id":"c","text":"Երկարավուն ուղեղ"},{"id":"d","text":"Ուղեղիկ"}]'::jsonb,
  rationale_hy = 'Երկարավուն ուղեղը ուղեղաբնի կարևոր շրջան է կենսական կենտրոններով։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 97;

UPDATE test_questions SET
  question_stem_hy = 'IV նյարդը վերահսկում է ո՞ր մկանը:',
  options_hy = '[{"id":"a","text":"Կողմնային ուղիղ"},{"id":"b","text":"Վերին թեք"},{"id":"c","text":"Սեղանարդաձև"},{"id":"d","text":"Կրծոսկրակրծային"}]'::jsonb,
  rationale_hy = 'IV նյարդը վերահսկում է վերին թեք մկանը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 98;

UPDATE test_questions SET
  question_stem_hy = 'Ծամելու ընթացքում ծնոտի շարժիչ ֆունկցիան՝ ո՞ր նյարդը:',
  options_hy = '[{"id":"a","text":"Եռվորյակ (V)"},{"id":"b","text":"Դիմային (VII)"},{"id":"c","text":"Ենթալեզվային (XII)"},{"id":"d","text":"Հավելյալ (XI)"}]'::jsonb,
  rationale_hy = 'V նյարդի շարժիչ մասը (Mandibular) վերահսկում է ծամելը։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 99;

UPDATE test_questions SET
  question_stem_hy = 'XII նյարդի դասակարգումը՝',
  options_hy = '[{"id":"a","text":"Զգայական"},{"id":"b","text":"Շարժիչ"},{"id":"c","text":"Խառը"},{"id":"d","text":"Ավտոնոմ"}]'::jsonb,
  rationale_hy = 'XII նյարդը զտյալ շարժիչ նյարդ է՝ լեզվի համար։'
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND display_order = 100;

-- ============================================================
-- Verification: should return 100 rows with translations
-- ============================================================
SELECT COUNT(*) AS cranial_nerves_hy_count
FROM test_questions
WHERE test_id  = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000032'
  AND question_stem_hy IS NOT NULL;
