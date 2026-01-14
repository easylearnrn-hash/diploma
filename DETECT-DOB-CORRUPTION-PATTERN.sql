-- CRITICAL: Detect if DOB dates are off by 1 day (timezone bug indicator)
-- This query helps identify which dates might be corrupted

-- ============================================================================
-- ANALYSIS: Pattern Detection
-- ============================================================================
-- If dates were corrupted by timezone bug, they would be:
-- - Consistently off by EXACTLY 1 day (not random)
-- - Always EARLIER (e.g., Oct 18 entered → Oct 17 stored)
-- - Only affecting applications in PST/EST timezones
-- - Would show pattern of "day before" across multiple records

-- ============================================================================
-- STEP 1: Check submission times vs timezone
-- ============================================================================
-- Applications submitted during PST business hours (likely Armenia or US timezones)
-- are most at risk of having the bug

SELECT 
  reference_number,
  applicant_name,
  payload->>'dob' as dob_display,
  submission_date,
  EXTRACT(HOUR FROM submission_date AT TIME ZONE 'UTC') as utc_hour,
  EXTRACT(HOUR FROM submission_date AT TIME ZONE 'Asia/Yerevan') as armenia_hour,
  EXTRACT(HOUR FROM submission_date AT TIME ZONE 'America/Los_Angeles') as pst_hour,
  -- Check if submitted during business hours (higher chance of being correct timezone)
  CASE 
    WHEN EXTRACT(HOUR FROM submission_date AT TIME ZONE 'Asia/Yerevan') BETWEEN 9 AND 18 
    THEN 'Armenia business hours'
    WHEN EXTRACT(HOUR FROM submission_date AT TIME ZONE 'America/Los_Angeles') BETWEEN 9 AND 18 
    THEN 'US business hours'
    ELSE 'Off hours'
  END as likely_timezone
FROM applications
WHERE payload->>'rawDob' IS NULL
ORDER BY submission_date DESC;

-- ============================================================================
-- STEP 2: Statistical analysis
-- ============================================================================
-- Check if there's a pattern in the day of month
-- If many dates fall on 1st, it might indicate "2nd became 1st" bug

SELECT 
  EXTRACT(DAY FROM TO_DATE(payload->>'dob', 'FMMonth DD, YYYY')) as day_of_month,
  COUNT(*) as frequency,
  STRING_AGG(applicant_name, ', ') as students
FROM applications
WHERE 
  payload->>'rawDob' IS NULL
  AND payload->>'dob' IS NOT NULL
GROUP BY day_of_month
ORDER BY frequency DESC, day_of_month;

-- ============================================================================
-- STEP 3: Check uploaded passport/ID documents
-- ============================================================================
-- The most reliable way to verify DOB is to check uploaded documents

SELECT 
  a.reference_number,
  a.applicant_name,
  a.payload->>'dob' as system_dob,
  a.payload->>'uploadedDocuments' as has_docs,
  a.submission_date,
  'Check passport scan for correct DOB' as action
FROM applications a
WHERE 
  a.payload->>'rawDob' IS NULL
  AND a.payload->>'dob' IS NOT NULL
ORDER BY a.submission_date DESC;

-- ============================================================================
-- STEP 4: Compare with students table (if DOB is stored there)
-- ============================================================================
-- If students were approved and DOB was manually entered in students table,
-- we can compare to find discrepancies

SELECT 
  a.reference_number,
  a.applicant_name,
  a.payload->>'dob' as application_dob,
  s.date_of_birth as student_record_dob,
  CASE 
    WHEN s.date_of_birth IS NULL THEN 'Not yet approved'
    WHEN a.payload->>'dob' = TO_CHAR(s.date_of_birth, 'FMMonth DD, YYYY') THEN '✓ Match'
    ELSE '✗ MISMATCH - needs verification'
  END as verification_status
FROM applications a
LEFT JOIN students s ON s.application_id = a.id
WHERE a.payload->>'rawDob' IS NULL
ORDER BY verification_status, a.submission_date DESC;

-- ============================================================================
-- RECOMMENDATIONS
-- ============================================================================
-- 
-- Based on the data:
-- 
-- 1. IF SUBMISSIONS WERE DURING ARMENIA HOURS (UTC+4):
--    - Dates are LIKELY CORRECT (timezone bug less likely)
--    - Armenia is UTC+4, so "Oct 18" entered at noon Armenia time
--      = 08:00 UTC, which doesn't trigger the bug
-- 
-- 2. IF SUBMISSIONS WERE DURING US WEST COAST HOURS (PST = UTC-8):
--    - Dates MAY BE WRONG by 1 day
--    - "Oct 18" entered at noon PST = 20:00 UTC
--    - When date is parsed as UTC midnight (00:00), it becomes Oct 17 in PST
-- 
-- 3. VERIFICATION PRIORITY:
--    a) Check passport scans (most reliable)
--    b) Contact students via email/SMS
--    c) Compare with manually entered student records
--    d) Look for pattern in submission times
-- 
-- 4. IF YOU FIND SYSTEMATIC PATTERN:
--    - All dates consistently 1 day early = timezone bug confirmed
--    - Random discrepancies = data entry errors
--    - No pattern = dates might be correct already
