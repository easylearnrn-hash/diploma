-- ============================================
-- REORDER ALL SUBJECTS — final correct order
-- Run in Supabase SQL Editor
-- ============================================
-- Final order:
--  1  Medical Terminology           (UUID ...0022)
--  2  Human Anatomy                 (UUID ...0023)
--  3  Drug Classes                  (UUID ...0024)
--  4  Cardiovascular System         (UUID ...0003)
--  5  Endocrine System              (UUID ...0004)
--  6  Gastrointestinal & Hepatic    (UUID ...0005)
--  7  Respiratory System            (UUID ...0006)
--  8  Renal System                  (UUID ...0007)
--  9  Fluids, Electrolytes & Nutr.  (UUID ...0008)
-- 10  Eye Disorders                 (UUID ...0009)
-- 11  EENT                          (UUID ...0010)
-- 12  Burns and Skin                (UUID ...0011)
-- 13  Reproductive & Sexual Health  (UUID ...0012)
-- 14  Maternal Health               (UUID ...0013)
-- 15  Pediatrics                    (UUID ...0014)
-- 16  Medical-Surgical Care         (UUID ...0015)
-- 17  Mental Health                 (UUID ...0016)
-- 18  Autoimmune & Infectious       (UUID ...0017)
-- 19  Neurology                     (UUID ...0002)
-- 20  Cancer                        (UUID ...0018)
-- 21  Musculoskeletal Disorders     (UUID ...0019)
-- 22  Psycho-Social Aspects         (UUID ...0020)
-- 23  Nursing Skills & Fundamentals (UUID ...0001)
-- 24  Pharmacology                  (UUID ...0021)
-- ============================================

-- Step 1: Shift all to high numbers to avoid collisions
UPDATE test_subjects SET display_order = display_order + 200;

-- Step 2: Set final display_order by stable UUID
UPDATE test_subjects SET display_order =  1 WHERE id = '10000000-0000-0000-0000-000000000022'; -- Medical Terminology
UPDATE test_subjects SET display_order =  2 WHERE id = '10000000-0000-0000-0000-000000000023'; -- Human Anatomy
UPDATE test_subjects SET display_order =  3 WHERE id = '10000000-0000-0000-0000-000000000024'; -- Drug Classes
UPDATE test_subjects SET display_order =  4 WHERE id = '10000000-0000-0000-0000-000000000003'; -- Cardiovascular System
UPDATE test_subjects SET display_order =  5 WHERE id = '10000000-0000-0000-0000-000000000004'; -- Endocrine System
UPDATE test_subjects SET display_order =  6 WHERE id = '10000000-0000-0000-0000-000000000005'; -- Gastrointestinal and Hepatic System
UPDATE test_subjects SET display_order =  7 WHERE id = '10000000-0000-0000-0000-000000000006'; -- Respiratory System
UPDATE test_subjects SET display_order =  8 WHERE id = '10000000-0000-0000-0000-000000000007'; -- Renal System
UPDATE test_subjects SET display_order =  9 WHERE id = '10000000-0000-0000-0000-000000000008'; -- Fluids, Electrolytes, and Nutrition
UPDATE test_subjects SET display_order = 10 WHERE id = '10000000-0000-0000-0000-000000000009'; -- Eye Disorders
UPDATE test_subjects SET display_order = 11 WHERE id = '10000000-0000-0000-0000-000000000010'; -- Ear, Eye, Nose, and Throat (EENT)
UPDATE test_subjects SET display_order = 12 WHERE id = '10000000-0000-0000-0000-000000000011'; -- Burns and Skin
UPDATE test_subjects SET display_order = 13 WHERE id = '10000000-0000-0000-0000-000000000012'; -- Reproductive and Sexual Health System
UPDATE test_subjects SET display_order = 14 WHERE id = '10000000-0000-0000-0000-000000000013'; -- Maternal Health
UPDATE test_subjects SET display_order = 15 WHERE id = '10000000-0000-0000-0000-000000000014'; -- Pediatrics
UPDATE test_subjects SET display_order = 16 WHERE id = '10000000-0000-0000-0000-000000000015'; -- Medical-Surgical Care
UPDATE test_subjects SET display_order = 17 WHERE id = '10000000-0000-0000-0000-000000000016'; -- Mental Health
UPDATE test_subjects SET display_order = 18 WHERE id = '10000000-0000-0000-0000-000000000017'; -- Autoimmune and Infectious Disorders
UPDATE test_subjects SET display_order = 19 WHERE id = '10000000-0000-0000-0000-000000000002'; -- Neurology
UPDATE test_subjects SET display_order = 20 WHERE id = '10000000-0000-0000-0000-000000000018'; -- Cancer
UPDATE test_subjects SET display_order = 21 WHERE id = '10000000-0000-0000-0000-000000000019'; -- Musculoskeletal Disorders
UPDATE test_subjects SET display_order = 22 WHERE id = '10000000-0000-0000-0000-000000000020'; -- Psycho-Social Aspects
UPDATE test_subjects SET display_order = 23 WHERE id = '10000000-0000-0000-0000-000000000001'; -- Nursing Skills and Fundamentals
UPDATE test_subjects SET display_order = 24 WHERE id = '10000000-0000-0000-0000-000000000021'; -- Pharmacology

-- ============================================
-- VERIFICATION — should show all 24 subjects in final order
-- ============================================
SELECT display_order, name
FROM test_subjects
ORDER BY display_order;
