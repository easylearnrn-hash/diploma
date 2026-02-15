-- ============================================
-- FAMILY DYNAMICS - 100 QUESTIONS
-- ============================================
-- Run this AFTER ADD-SUBJECTS-TOPICS-TABLE.sql
-- All 100 questions for Topic 5: Family Dynamics

-- Delete any existing questions for this topic to avoid duplicates
DELETE FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001' 
  AND topic_id = '20000000-0000-0000-0000-000000000005';

-- Insert 100 Family Dynamics Questions (display_order 1-100 for this topic)
INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES

-- Questions 1-15: Family Structures & Roles
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family dynamics refers to:', '[{"id":"a","text":"Legal guardianship"},{"id":"b","text":"Household income"},{"id":"c","text":"How family members relate to and affect each other"},{"id":"d","text":"Number of family members"}]'::jsonb, ARRAY['c'], false, 'Family dynamics refers to the patterns of interaction and relationships between family members and how they affect each other''s behaviors, emotions, and health.', 'Family Dynamics', 1),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family issues may directly affect:', '[{"id":"a","text":"Hospital billing"},{"id":"b","text":"Patient healing and coping"},{"id":"c","text":"Provider authority"},{"id":"d","text":"Licensure"}]'::jsonb, ARRAY['b'], false, 'Family dynamics directly impact patient healing and coping abilities. Supportive families enhance recovery while dysfunctional families can hinder healing.', 'Family Dynamics', 2),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Which best describes nuclear family?', '[{"id":"a","text":"Parents + grandparents"},{"id":"b","text":"Parents and children living together"},{"id":"c","text":"Step-parents and step-children"},{"id":"d","text":"Two friends raising a child"}]'::jsonb, ARRAY['b'], false, 'A nuclear family consists of parents and their children living together in one household, the traditional family structure.', 'Family Dynamics', 3),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Extended family includes:', '[{"id":"a","text":"Only biological parents"},{"id":"b","text":"Only siblings"},{"id":"c","text":"Grandparents, aunts, uncles living together"},{"id":"d","text":"One parent alone"}]'::jsonb, ARRAY['c'], false, 'Extended family includes relatives beyond parents and children, such as grandparents, aunts, uncles, and cousins living together or nearby.', 'Family Dynamics', 4),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Blended family includes:', '[{"id":"a","text":"Adopted children only"},{"id":"b","text":"Step-parents and step-children"},{"id":"c","text":"Grandparents"},{"id":"d","text":"Friends raising a child"}]'::jsonb, ARRAY['b'], false, 'A blended family is formed when two separate families merge, typically through remarriage, creating step-parent and step-children relationships.', 'Family Dynamics', 5),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Single-parent family means:', '[{"id":"a","text":"Two divorced parents in same home"},{"id":"b","text":"One parent raising child(ren) alone"},{"id":"c","text":"Grandparent guardianship"},{"id":"d","text":"Foster care"}]'::jsonb, ARRAY['b'], false, 'A single-parent family consists of one parent raising one or more children without a partner in the household.', 'Family Dynamics', 6),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Alternative family structure includes:', '[{"id":"a","text":"Only married couples"},{"id":"b","text":"Living arrangements outside traditional"},{"id":"c","text":"Nuclear families only"},{"id":"d","text":"Extended only"}]'::jsonb, ARRAY['b'], false, 'Alternative family structures include any living arrangements outside traditional definitions, such as same-sex couples, friends raising children together, or communal living.', 'Family Dynamics', 7),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'The decision maker role includes:', '[{"id":"a","text":"Paying bills"},{"id":"b","text":"Choosing treatments"},{"id":"c","text":"Providing emotional comfort"},{"id":"d","text":"Feeding patient"}]'::jsonb, ARRAY['b'], false, 'The decision maker role involves making important choices about medical treatments, care plans, and other significant family decisions.', 'Family Dynamics', 8),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'The caregiver role:', '[{"id":"a","text":"Makes financial decisions"},{"id":"b","text":"Provides direct care"},{"id":"c","text":"Controls family power"},{"id":"d","text":"Sets cultural beliefs"}]'::jsonb, ARRAY['b'], false, 'The caregiver role involves providing direct physical care, assistance with activities of daily living, and hands-on support to family members.', 'Family Dynamics', 9),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Financial provider:', '[{"id":"a","text":"Offers emotional comfort"},{"id":"b","text":"Pays household needs"},{"id":"c","text":"Makes all medical decisions"},{"id":"d","text":"Provides nursing care"}]'::jsonb, ARRAY['b'], false, 'The financial provider role involves earning income and managing resources to meet household needs and expenses.', 'Family Dynamics', 10),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Emotional support role includes:', '[{"id":"a","text":"Paying bills"},{"id":"b","text":"Feeding patient"},{"id":"c","text":"Providing comfort and support"},{"id":"d","text":"Choosing treatment plans"}]'::jsonb, ARRAY['c'], false, 'The emotional support role involves providing comfort, encouragement, listening, and psychological support to family members during difficult times.', 'Family Dynamics', 11),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Role strain occurs when:', '[{"id":"a","text":"Roles are equal"},{"id":"b","text":"One person has too much responsibility"},{"id":"c","text":"No caregiver exists"},{"id":"d","text":"Power is shared"}]'::jsonb, ARRAY['b'], false, 'Role strain occurs when one person has excessive responsibilities or conflicting demands, leading to stress, burnout, and inability to fulfill all obligations.', 'Family Dynamics', 12),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family problems can:', '[{"id":"a","text":"Improve coping"},{"id":"b","text":"Reduce stress"},{"id":"c","text":"Cause stress and affect healing"},{"id":"d","text":"Improve communication"}]'::jsonb, ARRAY['c'], false, 'Family problems and dysfunctional dynamics cause stress that can negatively affect patient healing, recovery, and overall health outcomes.', 'Family Dynamics', 13),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'The nurse must respect:', '[{"id":"a","text":"Legal definition only"},{"id":"b","text":"Provider''s view"},{"id":"c","text":"Patient''s definition of family"},{"id":"d","text":"Insurance definition"}]'::jsonb, ARRAY['c'], false, 'The nurse must respect the patient''s definition of family, which may differ from legal or traditional definitions. Patient autonomy determines who is considered family.', 'Family Dynamics', 14),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family can be:', '[{"id":"a","text":"Only a resource"},{"id":"b","text":"Only a stress"},{"id":"c","text":"A resource or a stress"},{"id":"d","text":"Neutral"}]'::jsonb, ARRAY['c'], false, 'Family can serve as either a resource that supports healing and coping, or as a stressor that complicates recovery, depending on the dynamics.', 'Family Dynamics', 15),

-- Questions 16-30: Dysfunctional Dynamics
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Poor communication includes:', '[{"id":"a","text":"Active listening"},{"id":"b","text":"Arguing and not listening"},{"id":"c","text":"Clear expression"},{"id":"d","text":"Calm discussion"}]'::jsonb, ARRAY['b'], false, 'Poor communication involves arguing, not listening to others, interrupting, and failing to express needs clearly, which creates family conflict.', 'Family Dynamics', 16),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Role confusion means:', '[{"id":"a","text":"Clear leadership"},{"id":"b","text":"No one knows who''s in charge"},{"id":"c","text":"Strong decision-making"},{"id":"d","text":"Balanced roles"}]'::jsonb, ARRAY['b'], false, 'Role confusion occurs when family members are unclear about their responsibilities or who has authority, leading to chaos and ineffective functioning.', 'Family Dynamics', 17),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Power struggles involve:', '[{"id":"a","text":"Cooperation"},{"id":"b","text":"Fighting over control"},{"id":"c","text":"Clear hierarchy"},{"id":"d","text":"Emotional support"}]'::jsonb, ARRAY['b'], false, 'Power struggles involve family members fighting over control, authority, and decision-making, which creates conflict and delays important decisions.', 'Family Dynamics', 18),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Neglect involves:', '[{"id":"a","text":"Providing care"},{"id":"b","text":"Ignoring needs"},{"id":"c","text":"Paying bills"},{"id":"d","text":"Teaching"}]'::jsonb, ARRAY['b'], false, 'Neglect involves ignoring or failing to meet the physical, emotional, or medical needs of family members, which threatens safety and well-being.', 'Family Dynamics', 19),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Abuse involves:', '[{"id":"a","text":"Comfort"},{"id":"b","text":"Harming family members"},{"id":"c","text":"Counseling"},{"id":"d","text":"Support"}]'::jsonb, ARRAY['b'], false, 'Abuse involves physical, emotional, sexual, or financial harm to family members. Nurses must recognize signs and report suspected abuse.', 'Family Dynamics', 20),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Dysfunctional families may impact:', '[{"id":"a","text":"Patient coping"},{"id":"b","text":"Room assignment"},{"id":"c","text":"Insurance"},{"id":"d","text":"Licensure"}]'::jsonb, ARRAY['a'], false, 'Dysfunctional family dynamics directly impact patient coping abilities, stress levels, and recovery outcomes.', 'Family Dynamics', 21),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Role confusion may result in:', '[{"id":"a","text":"Efficient decision-making"},{"id":"b","text":"Increased stress"},{"id":"c","text":"Clear leadership"},{"id":"d","text":"Balanced care"}]'::jsonb, ARRAY['b'], false, 'Role confusion leads to increased stress as family members are uncertain about responsibilities, creating chaos and delayed decisions.', 'Family Dynamics', 22),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Power struggles most affect:', '[{"id":"a","text":"Financial provider"},{"id":"b","text":"Family control dynamics"},{"id":"c","text":"Insurance policy"},{"id":"d","text":"Room location"}]'::jsonb, ARRAY['b'], false, 'Power struggles primarily affect family control dynamics, creating conflict over who has authority and how decisions are made.', 'Family Dynamics', 23),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Dysfunctional communication is:', '[{"id":"a","text":"Healthy coping"},{"id":"b","text":"Resource"},{"id":"c","text":"Stressor"},{"id":"d","text":"Legal structure"}]'::jsonb, ARRAY['c'], false, 'Dysfunctional communication acts as a stressor that increases family conflict, reduces problem-solving, and impairs patient coping.', 'Family Dynamics', 24),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Neglect directly affects:', '[{"id":"a","text":"Emotional support"},{"id":"b","text":"Patient safety and well-being"},{"id":"c","text":"Family income"},{"id":"d","text":"Cultural beliefs"}]'::jsonb, ARRAY['b'], false, 'Neglect directly threatens patient safety and well-being by failing to meet essential physical, emotional, or medical needs.', 'Family Dynamics', 25),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Abuse in families requires:', '[{"id":"a","text":"Ignoring"},{"id":"b","text":"Nurse reporting per policy"},{"id":"c","text":"Family decision"},{"id":"d","text":"Patient approval only"}]'::jsonb, ARRAY['b'], false, 'Nurses are mandatory reporters of suspected abuse and must follow institutional policy and legal requirements to protect vulnerable patients.', 'Family Dynamics', 26),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Dysfunctional dynamics create:', '[{"id":"a","text":"Healing"},{"id":"b","text":"Barriers to recovery"},{"id":"c","text":"Effective coping"},{"id":"d","text":"Clear communication"}]'::jsonb, ARRAY['b'], false, 'Dysfunctional family dynamics create barriers to recovery by increasing stress, reducing support, and complicating patient care.', 'Family Dynamics', 27),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Conflicting family values may cause:', '[{"id":"a","text":"Cooperation"},{"id":"b","text":"Treatment delays"},{"id":"c","text":"Healing"},{"id":"d","text":"Financial stability"}]'::jsonb, ARRAY['b'], false, 'Conflicting family values and beliefs can cause delays in treatment decisions as members disagree about appropriate care.', 'Family Dynamics', 28),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Poor family boundaries mean:', '[{"id":"a","text":"Healthy respect"},{"id":"b","text":"Lack of privacy and autonomy"},{"id":"c","text":"Clear limits"},{"id":"d","text":"Effective communication"}]'::jsonb, ARRAY['b'], false, 'Poor family boundaries result in lack of privacy, autonomy, and personal space, leading to enmeshment or dysfunction.', 'Family Dynamics', 29),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Enabling behavior in families involves:', '[{"id":"a","text":"Supporting recovery"},{"id":"b","text":"Allowing harmful behaviors to continue"},{"id":"c","text":"Setting clear limits"},{"id":"d","text":"Promoting independence"}]'::jsonb, ARRAY['b'], false, 'Enabling involves protecting family members from consequences of their actions, inadvertently allowing harmful behaviors to continue.', 'Family Dynamics', 30),

-- Questions 31-45: Nurse's Role
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'First nursing action is to:', '[{"id":"a","text":"Judge family"},{"id":"b","text":"Assess who''s involved"},{"id":"c","text":"Remove family"},{"id":"d","text":"Assign blame"}]'::jsonb, ARRAY['b'], false, 'The first nursing action is to assess who is involved in the patient''s care and support system without judgment.', 'Family Dynamics', 31),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'The nurse should assess:', '[{"id":"a","text":"Who makes decisions"},{"id":"b","text":"Who pays bills"},{"id":"c","text":"Who owns the house"},{"id":"d","text":"Who is oldest"}]'::jsonb, ARRAY['a'], false, 'The nurse should assess who makes decisions for the patient to understand family dynamics and ensure proper communication.', 'Family Dynamics', 32),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'The nurse includes family in care:', '[{"id":"a","text":"Always"},{"id":"b","text":"Only if provider agrees"},{"id":"c","text":"If patient allows"},{"id":"d","text":"If legal guardian only"}]'::jsonb, ARRAY['c'], false, 'The nurse includes family in care only if the patient allows, respecting patient autonomy and privacy rights.', 'Family Dynamics', 33),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Respect includes:', '[{"id":"a","text":"Forcing beliefs"},{"id":"b","text":"Ignoring culture"},{"id":"c","text":"Acknowledging cultural differences"},{"id":"d","text":"Standardizing all care"}]'::jsonb, ARRAY['c'], false, 'Respect includes acknowledging and honoring cultural differences in family structures, values, and decision-making processes.', 'Family Dynamics', 34),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Referral is appropriate when:', '[{"id":"a","text":"Family is perfect"},{"id":"b","text":"Dynamics cause problems"},{"id":"c","text":"Patient stable"},{"id":"d","text":"No stress"}]'::jsonb, ARRAY['b'], false, 'Referral to social work, counseling, or support services is appropriate when family dynamics cause problems that interfere with care.', 'Family Dynamics', 35),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Social work referral supports:', '[{"id":"a","text":"Punishment"},{"id":"b","text":"Counseling"},{"id":"c","text":"Isolation"},{"id":"d","text":"Financial billing"}]'::jsonb, ARRAY['b'], false, 'Social work referral provides counseling, resources, and support to help families cope with challenges and improve dynamics.', 'Family Dynamics', 36),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse must:', '[{"id":"a","text":"Redefine family"},{"id":"b","text":"Respect patient''s family definition"},{"id":"c","text":"Follow legal only"},{"id":"d","text":"Ignore alternative families"}]'::jsonb, ARRAY['b'], false, 'The nurse must respect the patient''s definition of family, regardless of legal or traditional definitions.', 'Family Dynamics', 37),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse should support:', '[{"id":"a","text":"Power struggles"},{"id":"b","text":"Communication and coping"},{"id":"c","text":"Role confusion"},{"id":"d","text":"Abuse"}]'::jsonb, ARRAY['b'], false, 'The nurse should support healthy communication and coping strategies to strengthen family functioning and patient outcomes.', 'Family Dynamics', 38),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'When family is stressor, nurse should:', '[{"id":"a","text":"Exclude automatically"},{"id":"b","text":"Refer and support"},{"id":"c","text":"Ignore"},{"id":"d","text":"Blame patient"}]'::jsonb, ARRAY['b'], false, 'When family acts as a stressor, the nurse should refer to appropriate resources and provide support while protecting the patient.', 'Family Dynamics', 39),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family as resource means:', '[{"id":"a","text":"Financial only"},{"id":"b","text":"Emotional and care support"},{"id":"c","text":"Legal only"},{"id":"d","text":"Cultural only"}]'::jsonb, ARRAY['b'], false, 'Family as a resource provides emotional support, care assistance, and helps with coping, enhancing patient recovery.', 'Family Dynamics', 40),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse promotes healthy dynamics by:', '[{"id":"a","text":"Taking sides"},{"id":"b","text":"Facilitating communication"},{"id":"c","text":"Making family decisions"},{"id":"d","text":"Ignoring conflicts"}]'::jsonb, ARRAY['b'], false, 'The nurse promotes healthy dynamics by facilitating open communication and helping family members express concerns constructively.', 'Family Dynamics', 41),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Cultural sensitivity requires:', '[{"id":"a","text":"Imposing own values"},{"id":"b","text":"Understanding family customs"},{"id":"c","text":"Standardizing care"},{"id":"d","text":"Ignoring beliefs"}]'::jsonb, ARRAY['b'], false, 'Cultural sensitivity requires understanding and respecting family customs, values, and traditions in care delivery.', 'Family Dynamics', 42),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse recognizes role strain by assessing:', '[{"id":"a","text":"Financial status"},{"id":"b","text":"Caregiver burden and stress"},{"id":"c","text":"Home ownership"},{"id":"d","text":"Employment history"}]'::jsonb, ARRAY['b'], false, 'The nurse recognizes role strain by assessing caregiver burden, stress levels, and ability to cope with responsibilities.', 'Family Dynamics', 43),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Teaching family members is appropriate when:', '[{"id":"a","text":"Nurse decides only"},{"id":"b","text":"Patient consents"},{"id":"c","text":"Family demands"},{"id":"d","text":"Provider insists"}]'::jsonb, ARRAY['b'], false, 'Teaching family members about patient care is appropriate when the patient consents to family involvement.', 'Family Dynamics', 44),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse advocates for patient by:', '[{"id":"a","text":"Supporting family over patient"},{"id":"b","text":"Honoring patient wishes"},{"id":"c","text":"Making decisions for patient"},{"id":"d","text":"Ignoring patient preferences"}]'::jsonb, ARRAY['b'], false, 'The nurse advocates for the patient by honoring patient wishes and preferences, even when family disagrees.', 'Family Dynamics', 45),

-- Questions 46-70: Advanced Application
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Patient identifies best friend as family. Nurse should:', '[{"id":"a","text":"Reject"},{"id":"b","text":"Respect definition"},{"id":"c","text":"Ask legal proof"},{"id":"d","text":"Ignore"}]'::jsonb, ARRAY['b'], false, 'The nurse should respect the patient''s definition of family, even if it includes non-relatives like close friends.', 'Family Dynamics', 46),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Overburdened caregiver experiencing stress demonstrates:', '[{"id":"a","text":"Healthy coping"},{"id":"b","text":"Role strain"},{"id":"c","text":"Emotional support"},{"id":"d","text":"Power struggle"}]'::jsonb, ARRAY['b'], false, 'An overburdened caregiver experiencing stress demonstrates role strain from excessive responsibilities and inadequate support.', 'Family Dynamics', 47),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family arguing over treatment indicates:', '[{"id":"a","text":"Healthy communication"},{"id":"b","text":"Power struggle"},{"id":"c","text":"Financial conflict"},{"id":"d","text":"Role strain only"}]'::jsonb, ARRAY['b'], false, 'Family arguing over treatment indicates a power struggle for control over decision-making and care direction.', 'Family Dynamics', 48),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'No one present at bedside, patient feels unsupported:', '[{"id":"a","text":"Resource"},{"id":"b","text":"Dysfunction"},{"id":"c","text":"Power"},{"id":"d","text":"Extended"}]'::jsonb, ARRAY['b'], false, 'Lack of family presence when patient feels unsupported indicates dysfunction in family relationships or availability.', 'Family Dynamics', 49),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Cultural differences require:', '[{"id":"a","text":"Standard approach"},{"id":"b","text":"Respect and understanding"},{"id":"c","text":"Exclusion"},{"id":"d","text":"Legal override"}]'::jsonb, ARRAY['b'], false, 'Cultural differences in family structure and decision-making require respect, understanding, and culturally sensitive care approaches.', 'Family Dynamics', 50),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse includes family if:', '[{"id":"a","text":"Hospital policy demands"},{"id":"b","text":"Patient consents"},{"id":"c","text":"Family insists"},{"id":"d","text":"Insurance requires"}]'::jsonb, ARRAY['b'], false, 'The nurse includes family in care only if the patient consents, maintaining patient autonomy and privacy rights.', 'Family Dynamics', 51),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Role strain most affects:', '[{"id":"a","text":"Decision maker"},{"id":"b","text":"Person with excessive responsibilities"},{"id":"c","text":"Emotional supporter only"},{"id":"d","text":"Financial provider only"}]'::jsonb, ARRAY['b'], false, 'Role strain most affects the person carrying excessive responsibilities without adequate support or resources.', 'Family Dynamics', 52),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Extended family example:', '[{"id":"a","text":"Parents only"},{"id":"b","text":"Parents + grandparents"},{"id":"c","text":"Single parent"},{"id":"d","text":"Friends"}]'::jsonb, ARRAY['b'], false, 'Extended family includes multiple generations living together, such as parents and grandparents in the same household.', 'Family Dynamics', 53),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Dysfunctional families may:', '[{"id":"a","text":"Improve coping"},{"id":"b","text":"Increase stress"},{"id":"c","text":"Improve communication"},{"id":"d","text":"Reduce anxiety"}]'::jsonb, ARRAY['b'], false, 'Dysfunctional families increase patient stress, complicate recovery, and create barriers to effective coping.', 'Family Dynamics', 54),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Healthy dynamics promote:', '[{"id":"a","text":"Healing"},{"id":"b","text":"Conflict"},{"id":"c","text":"Abuse"},{"id":"d","text":"Neglect"}]'::jsonb, ARRAY['a'], false, 'Healthy family dynamics promote healing through emotional support, effective communication, and collaborative decision-making.', 'Family Dynamics', 55),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Emotional support role reduces:', '[{"id":"a","text":"Healing"},{"id":"b","text":"Stress"},{"id":"c","text":"Coping"},{"id":"d","text":"Communication"}]'::jsonb, ARRAY['b'], false, 'The emotional support role reduces patient stress by providing comfort, encouragement, and psychological support.', 'Family Dynamics', 56),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family decision maker may influence:', '[{"id":"a","text":"Treatment choices"},{"id":"b","text":"Insurance only"},{"id":"c","text":"Room number"},{"id":"d","text":"Staffing"}]'::jsonb, ARRAY['a'], false, 'The family decision maker influences treatment choices, care plans, and major medical decisions affecting patient care.', 'Family Dynamics', 57),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Alternative family example:', '[{"id":"a","text":"Two friends raising child"},{"id":"b","text":"Married parents only"},{"id":"c","text":"Extended only"},{"id":"d","text":"Single grandparent"}]'::jsonb, ARRAY['a'], false, 'Alternative family structures include non-traditional arrangements like two friends raising a child together.', 'Family Dynamics', 58),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse should refer when:', '[{"id":"a","text":"Family healthy"},{"id":"b","text":"Power struggles disrupt care"},{"id":"c","text":"No conflict"},{"id":"d","text":"Patient stable"}]'::jsonb, ARRAY['b'], false, 'The nurse should refer to counseling or social work when power struggles or dysfunction disrupt patient care.', 'Family Dynamics', 59),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Neglect in family affects:', '[{"id":"a","text":"Healing"},{"id":"b","text":"Room location"},{"id":"c","text":"Staffing"},{"id":"d","text":"Equipment"}]'::jsonb, ARRAY['a'], false, 'Family neglect negatively affects patient healing by failing to provide necessary emotional support and care assistance.', 'Family Dynamics', 60),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Caregiver support groups help:', '[{"id":"a","text":"Increase isolation"},{"id":"b","text":"Reduce burden and share resources"},{"id":"c","text":"Replace professional care"},{"id":"d","text":"Eliminate all stress"}]'::jsonb, ARRAY['b'], false, 'Caregiver support groups reduce burden by providing emotional support, practical advice, and shared resources for coping.', 'Family Dynamics', 61),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse observes family conflict during rounds. Best action:', '[{"id":"a","text":"Ignore and leave"},{"id":"b","text":"Intervene and facilitate discussion"},{"id":"c","text":"Call security immediately"},{"id":"d","text":"Blame one family member"}]'::jsonb, ARRAY['b'], false, 'When observing family conflict, the nurse should intervene to facilitate constructive discussion and de-escalate tension.', 'Family Dynamics', 62),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Patient refuses to allow family visits. Nurse should:', '[{"id":"a","text":"Allow family anyway"},{"id":"b","text":"Honor patient wishes"},{"id":"c","text":"Force reconciliation"},{"id":"d","text":"Ignore request"}]'::jsonb, ARRAY['b'], false, 'The nurse must honor the patient''s wishes regarding family visits, respecting autonomy and potential reasons for boundaries.', 'Family Dynamics', 63),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Multigenerational family decision-making may involve:', '[{"id":"a","text":"One person only"},{"id":"b","text":"Complex consensus-building"},{"id":"c","text":"Excluding elders"},{"id":"d","text":"Ignoring traditions"}]'::jsonb, ARRAY['b'], false, 'Multigenerational families may require complex consensus-building that respects elders, traditions, and multiple perspectives.', 'Family Dynamics', 64),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse identifies caregiver burnout. Priority intervention:', '[{"id":"a","text":"Ignore signs"},{"id":"b","text":"Offer resources and respite care"},{"id":"c","text":"Blame caregiver"},{"id":"d","text":"Discharge patient"}]'::jsonb, ARRAY['b'], false, 'When identifying caregiver burnout, priority is offering resources, support services, and respite care to prevent crisis.', 'Family Dynamics', 65),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Same-sex parents request inclusion in care. Nurse should:', '[{"id":"a","text":"Refuse based on personal beliefs"},{"id":"b","text":"Respect and include per patient wishes"},{"id":"c","text":"Question legality"},{"id":"d","text":"Require legal documents"}]'::jsonb, ARRAY['b'], false, 'The nurse should respect and include same-sex parents per patient wishes, providing non-discriminatory, patient-centered care.', 'Family Dynamics', 66),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family member asks to make decisions against patient wishes. Nurse:', '[{"id":"a","text":"Follows family wishes"},{"id":"b","text":"Advocates for patient autonomy"},{"id":"c","text":"Ignores both"},{"id":"d","text":"Avoids situation"}]'::jsonb, ARRAY['b'], false, 'The nurse advocates for patient autonomy, ensuring patient wishes take precedence over family preferences when patient is competent.', 'Family Dynamics', 67),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Immigrant family with language barrier. Best nursing action:', '[{"id":"a","text":"Use family child as interpreter"},{"id":"b","text":"Obtain professional interpreter"},{"id":"c","text":"Speak louder"},{"id":"d","text":"Avoid communication"}]'::jsonb, ARRAY['b'], false, 'Best practice is obtaining professional interpreter services to ensure accurate communication and respect family dignity.', 'Family Dynamics', 68),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Adult children disagree about parent''s care. Nurse should:', '[{"id":"a","text":"Choose one side"},{"id":"b","text":"Facilitate family meeting"},{"id":"c","text":"Ignore conflict"},{"id":"d","text":"Make decision for them"}]'::jsonb, ARRAY['b'], false, 'When adult children disagree, the nurse should facilitate a family meeting to discuss concerns and work toward consensus.', 'Family Dynamics', 69),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Signs of healthy family coping include:', '[{"id":"a","text":"Constant arguing"},{"id":"b","text":"Open communication and mutual support"},{"id":"c","text":"Avoiding patient"},{"id":"d","text":"Refusing help"}]'::jsonb, ARRAY['b'], false, 'Healthy family coping is demonstrated by open communication, mutual support, and collaborative problem-solving.', 'Family Dynamics', 70),

-- Questions 71-100: NCLEX High-Yield Scenarios
('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'NCLEX tip emphasizes family impacts:', '[{"id":"a","text":"Billing"},{"id":"b","text":"Healing and coping"},{"id":"c","text":"Licensure"},{"id":"d","text":"Shift length"}]'::jsonb, ARRAY['b'], false, 'NCLEX emphasizes that family dynamics significantly impact patient healing, coping abilities, and overall outcomes.', 'Family Dynamics', 71),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family resource can:', '[{"id":"a","text":"Harm healing"},{"id":"b","text":"Improve coping"},{"id":"c","text":"Replace nurse"},{"id":"d","text":"Replace provider"}]'::jsonb, ARRAY['b'], false, 'Supportive families serve as valuable resources that improve patient coping through emotional support and care assistance.', 'Family Dynamics', 72),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family stress may:', '[{"id":"a","text":"Enhance recovery"},{"id":"b","text":"Delay healing"},{"id":"c","text":"Improve communication"},{"id":"d","text":"Reduce anxiety"}]'::jsonb, ARRAY['b'], false, 'Family stress and dysfunction can delay healing by creating barriers to recovery and reducing patient coping ability.', 'Family Dynamics', 73),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse''s primary assessment question:', '[{"id":"a","text":"Who is oldest?"},{"id":"b","text":"Who is involved?"},{"id":"c","text":"Who earns money?"},{"id":"d","text":"Who owns house?"}]'::jsonb, ARRAY['b'], false, 'The primary assessment question is identifying who is involved in the patient''s support system and care.', 'Family Dynamics', 74),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Respecting beliefs prevents:', '[{"id":"a","text":"Cultural conflict"},{"id":"b","text":"Healing"},{"id":"c","text":"Education"},{"id":"d","text":"Assessment"}]'::jsonb, ARRAY['a'], false, 'Respecting family beliefs and cultural practices prevents conflict and promotes therapeutic nurse-family relationships.', 'Family Dynamics', 75),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Dysfunctional communication leads to:', '[{"id":"a","text":"Calmness"},{"id":"b","text":"Stress"},{"id":"c","text":"Cooperation"},{"id":"d","text":"Healing"}]'::jsonb, ARRAY['b'], false, 'Dysfunctional communication patterns lead to increased stress, conflict, and barriers to effective family functioning.', 'Family Dynamics', 76),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Emotional support strengthens:', '[{"id":"a","text":"Stress"},{"id":"b","text":"Coping"},{"id":"c","text":"Conflict"},{"id":"d","text":"Abuse"}]'::jsonb, ARRAY['b'], false, 'Emotional support from family strengthens patient coping abilities and resilience during illness and recovery.', 'Family Dynamics', 77),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Decision maker role affects:', '[{"id":"a","text":"Emotional support"},{"id":"b","text":"Treatment direction"},{"id":"c","text":"Linen changes"},{"id":"d","text":"Billing"}]'::jsonb, ARRAY['b'], false, 'The decision maker role significantly affects treatment direction, care plans, and major medical decisions.', 'Family Dynamics', 78),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Power struggle primarily affects:', '[{"id":"a","text":"Authority and control"},{"id":"b","text":"Finances"},{"id":"c","text":"Hygiene"},{"id":"d","text":"Nutrition"}]'::jsonb, ARRAY['a'], false, 'Power struggles primarily affect family authority and control dynamics, creating conflict over decision-making.', 'Family Dynamics', 79),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse referral resource:', '[{"id":"a","text":"Counseling"},{"id":"b","text":"Punishment"},{"id":"c","text":"Security"},{"id":"d","text":"Insurance"}]'::jsonb, ARRAY['a'], false, 'Appropriate nurse referral resources include counseling, social work, and support services for families experiencing dysfunction.', 'Family Dynamics', 80),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Role strain warning sign:', '[{"id":"a","text":"Balanced workload"},{"id":"b","text":"Excessive burden"},{"id":"c","text":"Healthy coping"},{"id":"d","text":"Equal sharing"}]'::jsonb, ARRAY['b'], false, 'Warning sign of role strain is excessive burden on one person without adequate support or resources.', 'Family Dynamics', 81),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Alternative family is:', '[{"id":"a","text":"Illegal"},{"id":"b","text":"Outside traditional structure"},{"id":"c","text":"Always extended"},{"id":"d","text":"Nuclear"}]'::jsonb, ARRAY['b'], false, 'Alternative families exist outside traditional structures and should be respected as valid support systems.', 'Family Dynamics', 82),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Respecting family supports:', '[{"id":"a","text":"Trust"},{"id":"b","text":"Conflict"},{"id":"c","text":"Neglect"},{"id":"d","text":"Abuse"}]'::jsonb, ARRAY['a'], false, 'Respecting family definitions and dynamics builds trust and therapeutic relationships between nurse, patient, and family.', 'Family Dynamics', 83),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family dysfunction most directly affects:', '[{"id":"a","text":"Patient coping"},{"id":"b","text":"Charting"},{"id":"c","text":"Staffing"},{"id":"d","text":"Licensure"}]'::jsonb, ARRAY['a'], false, 'Family dysfunction most directly affects patient coping, stress levels, and ability to manage illness and recovery.', 'Family Dynamics', 84),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Healthy family dynamics:', '[{"id":"a","text":"Promote healing"},{"id":"b","text":"Promote neglect"},{"id":"c","text":"Promote abuse"},{"id":"d","text":"Promote confusion"}]'::jsonb, ARRAY['a'], false, 'Healthy family dynamics promote healing through effective communication, emotional support, and collaborative care.', 'Family Dynamics', 85),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse excludes family when:', '[{"id":"a","text":"Patient does not allow"},{"id":"b","text":"They disagree"},{"id":"c","text":"Cultural difference"},{"id":"d","text":"Financial strain"}]'::jsonb, ARRAY['a'], false, 'The nurse excludes family only when the patient does not allow their involvement, respecting patient autonomy.', 'Family Dynamics', 86),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Caregiver role involves:', '[{"id":"a","text":"Direct care"},{"id":"b","text":"Diagnosis"},{"id":"c","text":"Legal action"},{"id":"d","text":"Policy creation"}]'::jsonb, ARRAY['a'], false, 'The caregiver role involves providing direct care, assistance with ADLs, and hands-on support to family members.', 'Family Dynamics', 87),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Financial provider ensures:', '[{"id":"a","text":"Emotional comfort"},{"id":"b","text":"Household needs met"},{"id":"c","text":"Teaching"},{"id":"d","text":"Assessment"}]'::jsonb, ARRAY['b'], false, 'The financial provider role ensures household needs are met through income generation and resource management.', 'Family Dynamics', 88),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Power struggle may delay:', '[{"id":"a","text":"Treatment decisions"},{"id":"b","text":"Billing"},{"id":"c","text":"Hygiene"},{"id":"d","text":"Linen change"}]'::jsonb, ARRAY['a'], false, 'Power struggles among family members can delay critical treatment decisions, compromising patient care.', 'Family Dynamics', 89),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse supports:', '[{"id":"a","text":"Abuse"},{"id":"b","text":"Healthy coping"},{"id":"c","text":"Conflict"},{"id":"d","text":"Power struggle"}]'::jsonb, ARRAY['b'], false, 'The nurse supports healthy coping mechanisms and constructive family interactions to promote patient outcomes.', 'Family Dynamics', 90),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Dysfunctional role confusion means:', '[{"id":"a","text":"Clear leadership"},{"id":"b","text":"Unclear authority"},{"id":"c","text":"Shared decisions"},{"id":"d","text":"Healthy system"}]'::jsonb, ARRAY['b'], false, 'Dysfunctional role confusion means unclear authority and responsibilities, leading to chaos and ineffective care.', 'Family Dynamics', 91),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family as stressor requires:', '[{"id":"a","text":"Ignoring"},{"id":"b","text":"Referral and support"},{"id":"c","text":"Punishment"},{"id":"d","text":"Exclusion"}]'::jsonb, ARRAY['b'], false, 'When family acts as a stressor, appropriate nursing action is referral to support services and continued assessment.', 'Family Dynamics', 92),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Emotional support helps:', '[{"id":"a","text":"Increase stress"},{"id":"b","text":"Decrease coping"},{"id":"c","text":"Decrease stress"},{"id":"d","text":"Increase conflict"}]'::jsonb, ARRAY['c'], false, 'Emotional support from family members helps decrease patient stress and anxiety during illness and recovery.', 'Family Dynamics', 93),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family healing impact is:', '[{"id":"a","text":"Neutral"},{"id":"b","text":"Significant"},{"id":"c","text":"Irrelevant"},{"id":"d","text":"Minimal"}]'::jsonb, ARRAY['b'], false, 'Family dynamics have a significant impact on patient healing, recovery rates, and overall health outcomes.', 'Family Dynamics', 94),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse should never:', '[{"id":"a","text":"Respect culture"},{"id":"b","text":"Force own beliefs"},{"id":"c","text":"Refer to counseling"},{"id":"d","text":"Assess roles"}]'::jsonb, ARRAY['b'], false, 'The nurse should never force own beliefs or values on families, maintaining professional boundaries and cultural sensitivity.', 'Family Dynamics', 95),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Family decision maker:', '[{"id":"a","text":"Assists dressing"},{"id":"b","text":"Chooses treatments"},{"id":"c","text":"Provides feeding"},{"id":"d","text":"Collects I&O"}]'::jsonb, ARRAY['b'], false, 'The family decision maker chooses treatments and makes major decisions affecting patient care direction.', 'Family Dynamics', 96),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Poor communication increases:', '[{"id":"a","text":"Cooperation"},{"id":"b","text":"Stress"},{"id":"c","text":"Healing"},{"id":"d","text":"Coping"}]'::jsonb, ARRAY['b'], false, 'Poor family communication increases stress, creates barriers to care, and complicates decision-making processes.', 'Family Dynamics', 97),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Alternative family may:', '[{"id":"a","text":"Be excluded"},{"id":"b","text":"Be respected per patient definition"},{"id":"c","text":"Be rejected"},{"id":"d","text":"Be ignored"}]'::jsonb, ARRAY['b'], false, 'Alternative families must be respected according to patient definition, regardless of traditional or legal definitions.', 'Family Dynamics', 98),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Nurse includes family to:', '[{"id":"a","text":"Replace nurse care"},{"id":"b","text":"Support healing and coping"},{"id":"c","text":"Transfer accountability"},{"id":"d","text":"Avoid assessment"}]'::jsonb, ARRAY['b'], false, 'The nurse includes family to support patient healing and coping through emotional support and care collaboration.', 'Family Dynamics', 99),

('00000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'Ultimate NCLEX takeaway:', '[{"id":"a","text":"Family always helps"},{"id":"b","text":"Family never helps"},{"id":"c","text":"Family can be resource or stressor"},{"id":"d","text":"Family irrelevant"}]'::jsonb, ARRAY['c'], false, 'Ultimate NCLEX principle: Family can be either a valuable resource that supports healing or a stressor that complicates recovery, depending on dynamics.', 'Family Dynamics', 100);

-- ============================================
-- VERIFICATION
-- ============================================

-- Show total question count for Family Dynamics topic
SELECT 
  t.name as topic_name,
  COUNT(q.id) as total_questions
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id 
  AND q.test_id = '00000000-0000-0000-0000-000000000001'
WHERE t.id = '20000000-0000-0000-0000-000000000005'
GROUP BY t.id, t.name;
-- Expected: Family Dynamics with 100 questions

-- Verify display_order range
SELECT 
  MIN(display_order) as first_question,
  MAX(display_order) as last_question,
  COUNT(*) as total_count
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000005';
-- Expected: 1 to 100, count = 100
