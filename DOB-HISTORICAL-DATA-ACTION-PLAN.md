# 🚨 CRITICAL: Existing Student DOB Data May Be Corrupted

## ⚠️ THE SITUATION

**Discovery:** Existing applications (submitted before Jan 14, 2026 07:00 UTC) have:
- ❌ `rawDob`: **NULL** (missing source of truth)
- ❌ `dobIso`: **NULL** (missing ISO format)
- ⚠️ `dob`: **Display format only** (e.g., "October 17, 1983")

**Problem:** We **cannot automatically verify** if these dates are correct or off by 1 day.

**Affected Students (confirmed):**
- Mari Melkonyan: October 17, 1983
- Anahit Hovhannisyan: April 2, 2007
- Varduhi Nersesyan: May 27, 1982
- Kristina Simonyan: February 18, 1986
- Lusine Hovhannisyan: April 23, 1990
- Narine Avetisyan: [date not provided]
- **Plus many more...**

---

## 🔍 WHY WE CAN'T AUTO-FIX

The applications were submitted with an **older version** of the form that:
1. ✅ Used safe `formatDateValue()` for display (YYYY-MM-DD → "Month DD, YYYY")
2. ❌ But didn't save the original `rawDob` input value
3. ❌ So we can't reverse-engineer the correct date

**Example:**
- If display shows "October 17, 1983", the student might have entered:
  - **1983-10-17** (correct) OR
  - **1983-10-18** (off by 1 day due to timezone bug)

---

## ✅ VERIFICATION METHODS (Priority Order)

### Method 1: Check Uploaded Passport/ID Documents 🏆
**Most Reliable**

1. Run query: `DETECT-DOB-CORRUPTION-PATTERN.sql` (Step 3)
2. Access uploaded passport scans for each student
3. Compare DOB on passport vs system DOB
4. If mismatch found → Update using correction template

**SQL to find documents:**
```sql
SELECT 
  reference_number,
  applicant_name,
  payload->>'dob' as system_dob,
  payload->'uploadedDocuments' as docs
FROM applications
WHERE payload->>'rawDob' IS NULL;
```

---

### Method 2: Contact Students Directly 📧
**Most Accurate for Missing Documents**

Send verification message:
```
Subject: ACNHS Application - Birth Date Verification

Dear [Student Name],

We are updating our records and need to confirm your date of birth 
as listed in your application:

Current System Record: [October 17, 1983]

Please reply with:
✓ CORRECT - if this matches your passport/ID
✗ WRONG - and provide the correct date

Thank you,
Armenian College of Nurses
```

**Students to contact:** Run `RECOVER-MISSING-DOB-DATA.sql` (Step 3)

---

### Method 3: Check Student Records Table 📋
**If DOB was manually verified during approval**

```sql
-- Find mismatches between application and student records
SELECT 
  a.reference_number,
  a.applicant_name,
  a.payload->>'dob' as application_dob,
  s.date_of_birth as verified_dob,
  s.date_of_birth::text = 
    TO_CHAR(TO_DATE(a.payload->>'dob', 'FMMonth DD, YYYY'), 'YYYY-MM-DD') 
    as matches
FROM applications a
INNER JOIN students s ON s.application_id = a.id
WHERE a.payload->>'rawDob' IS NULL;
```

---

### Method 4: Pattern Analysis 📊
**Detect systematic corruption**

Run: `DETECT-DOB-CORRUPTION-PATTERN.sql`

**Look for:**
- ✓ All submissions during Armenia hours (likely correct)
- ⚠️ Submissions during PST hours (higher risk)
- ⚠️ Many dates falling on 1st of month (2nd became 1st)
- ⚠️ Students reporting wrong dates consistently

---

## 🛠️ CORRECTION PROCEDURE

### Once Verified (After Method 1, 2, or 3)

**Template for single student:**
```sql
-- Example: Correcting Mari Melkonyan's DOB
-- Verified via passport: October 18, 1983 (not October 17)

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
```

**Bulk correction (if pattern found):**
```sql
-- If ALL dates are off by 1 day, add 1 day to each
UPDATE applications
SET payload = jsonb_set(
  jsonb_set(
    jsonb_set(
      payload::jsonb,
      '{rawDob}',
      to_jsonb(
        TO_CHAR(
          TO_DATE(payload->>'dob', 'FMMonth DD, YYYY') + INTERVAL '1 day',
          'YYYY-MM-DD'
        )
      )
    ),
    '{dobIso}',
    to_jsonb(
      TO_CHAR(
        TO_DATE(payload->>'dob', 'FMMonth DD, YYYY') + INTERVAL '1 day',
        'YYYY-MM-DD'
      )
    )
  ),
  '{dob}',
  to_jsonb(
    TO_CHAR(
      TO_DATE(payload->>'dob', 'FMMonth DD, YYYY') + INTERVAL '1 day',
      'FMMonth DD, YYYY'
    )
  )
)
WHERE 
  payload->>'rawDob' IS NULL
  AND payload->>'dob' IS NOT NULL;
```

⚠️ **WARNING:** Only run bulk correction if you've verified the pattern is consistent!

---

## 📋 ACTION PLAN

### Immediate (Today)
- [ ] Run `DETECT-DOB-CORRUPTION-PATTERN.sql` to analyze pattern
- [ ] Check 2-3 passport scans to verify if dates are wrong
- [ ] Determine if it's systematic (all wrong) or random

### Short-term (This Week)
- [ ] If systematic: Apply bulk correction
- [ ] If random: Contact each student individually
- [ ] Update student records in `students` table

### Long-term (Ongoing)
- [ ] ✅ Fix is deployed - all NEW applications are safe
- [ ] Monitor new submissions to ensure `rawDob` is captured
- [ ] Add validation to prevent future data integrity issues

---

## 🎯 SUCCESS CRITERIA

✅ All applications have `rawDob` field populated  
✅ All `rawDob` matches `dobIso`  
✅ All dates verified against passport/ID documents  
✅ Students confirm their listed DOB is correct  
✅ No complaints about wrong birth dates  

---

## 📞 SUPPORT

If you discover dates are systematically wrong:
1. Contact me immediately: hrachfilm@gmail.com
2. Provide results from pattern analysis queries
3. Share 2-3 passport scan examples
4. I'll help build the correct bulk fix

---

## 🔐 PREVENTION (Already Implemented)

✅ **admission-form.html** now captures:
- `rawDob`: Original YYYY-MM-DD input (source of truth)
- `dobIso`: Same as rawDob (no timezone conversion)
- `dob`: Formatted display

✅ **All future applications** will be verifiable and correct

⚠️ **Only historical data** (before Jan 14, 2026 07:00 UTC) needs manual verification

---

**Status:** INVESTIGATION REQUIRED  
**Priority:** HIGH (affects legal identity data)  
**Owner:** Admin team + hrachfilm@gmail.com
