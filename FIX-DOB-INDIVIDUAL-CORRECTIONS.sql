-- ============================================================================
-- INDIVIDUAL DOB CORRECTIONS (Mixed Results - NOT Bulk Fix!)
-- ============================================================================
-- CRITICAL: We found MIXED results - some dates correct, some 1 day off
-- Therefore we MUST verify each student individually via passport
--
-- Confirmed cases:
--   ✅ Kristina Simonyan: Feb 18 (CORRECT - no change)
--   ❌ Mari Melkonyan: Oct 17 → Should be Oct 18
--   ❌ Narine Avetisyan: Dec 24 → Should be Dec 25
-- ============================================================================

-- STEP 1: Fix Mari Melkonyan (Oct 17 → Oct 18, 1983)
UPDATE applications
SET payload = jsonb_set(
  jsonb_set(
    jsonb_set(
      payload::jsonb,
      '{rawDob}',
      to_jsonb('1983-10-18'::text)
    ),
    '{dobIso}',
    to_jsonb('1983-10-18'::text)
  ),
  '{dob}',
  to_jsonb('October 18, 1983'::text)
)
WHERE reference_number = 'ACNHS-ADM-20260113-843';

-- Verify Mari's fix
SELECT 
  reference_number,
  applicant_name,
  payload->>'dob' as dob_display,
  payload->>'rawDob' as raw_dob,
  payload->>'dobIso' as dob_iso
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260113-843';
-- Expected: October 18, 1983 / 1983-10-18 / 1983-10-18


-- ============================================================================
-- STEP 2: Fix Narine Avetisyan (Dec 24 → Dec 25, 1986)
UPDATE applications
SET payload = jsonb_set(
  jsonb_set(
    jsonb_set(
      payload::jsonb,
      '{rawDob}',
      to_jsonb('1986-12-25'::text)
    ),
    '{dobIso}',
    to_jsonb('1986-12-25'::text)
  ),
  '{dob}',
  to_jsonb('December 25, 1986'::text)
)
WHERE reference_number = 'ACNHS-ADM-20260108-970';

-- Verify Narine's fix
SELECT 
  reference_number,
  applicant_name,
  payload->>'dob' as dob_display,
  payload->>'rawDob' as raw_dob,
  payload->>'dobIso' as dob_iso
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260108-970';
-- Expected: December 25, 1986 / 1986-12-25 / 1986-12-25


-- ============================================================================
-- STEP 3: Add rawDob/dobIso to Kristina (Correct date, just add fields)
UPDATE applications
SET payload = jsonb_set(
  jsonb_set(
    payload::jsonb,
    '{rawDob}',
    to_jsonb('1986-02-18'::text)
  ),
  '{dobIso}',
  to_jsonb('1986-02-18'::text)
)
WHERE reference_number = 'ACNHS-ADM-20260113-225';

-- Verify Kristina (date unchanged, just added fields)
SELECT 
  reference_number,
  applicant_name,
  payload->>'dob' as dob_display,
  payload->>'rawDob' as raw_dob,
  payload->>'dobIso' as dob_iso
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260113-225';
-- Expected: February 18, 1986 / 1986-02-18 / 1986-02-18


-- ============================================================================
-- TEMPLATE FOR REMAINING STUDENTS
-- ============================================================================
-- After checking each passport, use this template:

/*
-- If date is CORRECT (just add missing fields):
UPDATE applications
SET payload = jsonb_set(
  jsonb_set(
    payload::jsonb,
    '{rawDob}',
    to_jsonb('YYYY-MM-DD'::text)  -- Use CURRENT date from payload->>'dob'
  ),
  '{dobIso}',
  to_jsonb('YYYY-MM-DD'::text)
)
WHERE reference_number = 'ACNHS-ADM-XXXXXXXX-XXX';

-- If date is WRONG (needs correction + add fields):
UPDATE applications
SET payload = jsonb_set(
  jsonb_set(
    jsonb_set(
      payload::jsonb,
      '{rawDob}',
      to_jsonb('YYYY-MM-DD'::text)  -- Use CORRECTED date from passport
    ),
    '{dobIso}',
    to_jsonb('YYYY-MM-DD'::text)
  ),
  '{dob}',
  to_jsonb('Month DD, YYYY'::text)  -- Formatted version of corrected date
)
WHERE reference_number = 'ACNHS-ADM-XXXXXXXX-XXX';
*/


-- ============================================================================
-- VERIFICATION CHECKLIST
-- ============================================================================
-- Students with uploaded passports (MUST check each one):
--
-- [✓] Mari Melkonyan - Fixed (Oct 18)
-- [✓] Narine Avetisyan - Fixed (Dec 25)
-- [✓] Kristina Simonyan - Correct (Feb 18)
-- [ ] Anahit Hovhannisyan - NEEDS CHECKING
-- [ ] Varduhi Nersesyan - NEEDS CHECKING
-- [ ] Lusine Hovhannisyan - NEEDS CHECKING
-- [ ] Gohar Hovhannisyan - NEEDS CHECKING
-- [ ] Arpine Ktratsyan - NEEDS CHECKING
-- [ ] Sirarpi Khachikyan - NEEDS CHECKING
-- [ ] Meri Hovhanyan - NEEDS CHECKING
-- [ ] Aleksandr Petrosyan - NEEDS CHECKING
-- [ ] Manvel Chakmanyan - NEEDS CHECKING
-- [ ] Hrach Vardan Vardan - NEEDS CHECKING (unusual date: June 24, 2025?)
-- [ ] Zhaklen Akopyan - NEEDS CHECKING
-- [ ] Lusine Kalashyan - NEEDS CHECKING
-- [ ] Mariam Davtyan - NEEDS CHECKING
--
-- Students WITHOUT passports (must contact):
-- [ ] Narine Jamalyan - NO DOCS
-- [ ] Marine Martirosyan - NO DOCS
-- [ ] Alvard Ghukasyan - NO DOCS
-- [ ] Vardan Yeranosyan - NO DOCS
-- [ ] Hrachya Yeranosyan - NO DOCS
-- [ ] Anaeis Baghoomian - NO DOCS
-- [ ] Gohar Ilangyozyan - NO DOCS
-- [ ] Tereza Abramyan - NO DOCS
-- [ ] Azat Abramyan - NO DOCS
-- [ ] Lusine Hakobyan - NO DOCS
-- [ ] Vladislav Saakyan - NO DOCS
-- [ ] Hayk Yeranosyan - NO DOCS
-- [ ] Gayane Zadourian - NO DOCS
-- [ ] Valentina Sookassians - NO DOCS
-- [ ] Armen Kalents - NO DOCS


-- ============================================================================
-- NEXT STEPS
-- ============================================================================
-- 1. Check remaining 12 passport documents
-- 2. For each one, determine if date is correct or needs +1 day
-- 3. Apply individual fixes using template above
-- 4. Contact 15 students without documents via email/SMS
-- 5. Re-run final verification query
