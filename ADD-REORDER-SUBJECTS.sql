-- ============================================
-- REORDER SUBJECTS — set correct display_order
-- Run in Supabase SQL Editor
-- Also renames "Fundamentals of Nursing" → "Nursing Skills and Fundamentals"
-- ============================================

-- Step 1: Temporarily set all to high values to avoid unique-constraint
--         collisions during the update (if display_order has a UNIQUE index)
UPDATE test_subjects SET display_order = display_order + 100;

-- Step 2: Apply correct display_order for each subject (by UUID)
UPDATE test_subjects SET display_order =  1 WHERE id = '10000000-0000-0000-0000-000000000003'; -- Cardiovascular System
UPDATE test_subjects SET display_order =  2 WHERE id = '10000000-0000-0000-0000-000000000004'; -- Endocrine System
UPDATE test_subjects SET display_order =  3 WHERE id = '10000000-0000-0000-0000-000000000005'; -- Gastrointestinal and Hepatic System
UPDATE test_subjects SET display_order =  4 WHERE id = '10000000-0000-0000-0000-000000000006'; -- Respiratory System
UPDATE test_subjects SET display_order =  5 WHERE id = '10000000-0000-0000-0000-000000000007'; -- Renal System
UPDATE test_subjects SET display_order =  6 WHERE id = '10000000-0000-0000-0000-000000000008'; -- Fluids, Electrolytes, and Nutrition
UPDATE test_subjects SET display_order =  7 WHERE id = '10000000-0000-0000-0000-000000000009'; -- Eye Disorders
UPDATE test_subjects SET display_order =  8 WHERE id = '10000000-0000-0000-0000-000000000010'; -- Ear, Eye, Nose, and Throat (EENT)
UPDATE test_subjects SET display_order =  9 WHERE id = '10000000-0000-0000-0000-000000000011'; -- Burns and Skin
UPDATE test_subjects SET display_order = 10 WHERE id = '10000000-0000-0000-0000-000000000012'; -- Reproductive and Sexual Health System
UPDATE test_subjects SET display_order = 11 WHERE id = '10000000-0000-0000-0000-000000000013'; -- Maternal Health
UPDATE test_subjects SET display_order = 12 WHERE id = '10000000-0000-0000-0000-000000000014'; -- Pediatrics
UPDATE test_subjects SET display_order = 13 WHERE id = '10000000-0000-0000-0000-000000000015'; -- Medical-Surgical Care
UPDATE test_subjects SET display_order = 14 WHERE id = '10000000-0000-0000-0000-000000000016'; -- Mental Health
UPDATE test_subjects SET display_order = 15 WHERE id = '10000000-0000-0000-0000-000000000017'; -- Autoimmune and Infectious Disorders
UPDATE test_subjects SET display_order = 16 WHERE id = '10000000-0000-0000-0000-000000000002'; -- Neurology
UPDATE test_subjects SET display_order = 17 WHERE id = '10000000-0000-0000-0000-000000000018'; -- Cancer
UPDATE test_subjects SET display_order = 18 WHERE id = '10000000-0000-0000-0000-000000000019'; -- Musculoskeletal Disorders
UPDATE test_subjects SET display_order = 19 WHERE id = '10000000-0000-0000-0000-000000000020'; -- Psycho-Social Aspects
UPDATE test_subjects SET display_order = 20 WHERE id = '10000000-0000-0000-0000-000000000001'; -- Nursing Skills and Fundamentals
UPDATE test_subjects SET display_order = 21 WHERE id = '10000000-0000-0000-0000-000000000021'; -- Pharmacology

-- Step 3: Rename "Fundamentals of Nursing" → "Nursing Skills and Fundamentals"
UPDATE test_subjects
SET name = 'Nursing Skills and Fundamentals'
WHERE id = '10000000-0000-0000-0000-000000000001';

-- Also update the test_config title for Fundamentals to match
UPDATE test_configs
SET title       = 'Nursing Skills and Fundamentals – NCLEX Comprehensive Assessment',
    description = 'Core nursing concepts, safety, infection control, vital signs, documentation, and patient-centered care for NCLEX preparation'
WHERE subject_id = '10000000-0000-0000-0000-000000000001';

-- ============================================
-- VERIFICATION — shows final order
-- ============================================
SELECT display_order, name
FROM test_subjects
ORDER BY display_order;
