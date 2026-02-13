-- ==========================================
-- PORTAL ALERTS SYSTEM - VERIFICATION TESTS
-- ==========================================
-- Run these queries to verify your alerts system is working correctly

-- ==========================================
-- TEST 1: Verify All Tables Exist
-- ==========================================

SELECT 
    'Test 1: Tables Exist' AS test_name,
    CASE 
        WHEN COUNT(*) = 4 THEN '✅ PASS - All 4 tables exist'
        ELSE '❌ FAIL - Missing tables'
    END AS result
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN (
    'portal_alerts', 
    'portal_alert_templates',
    'portal_alert_impressions',
    'portal_alert_responses'
  );

-- ==========================================
-- TEST 2: Verify Templates Loaded
-- ==========================================

SELECT 
    'Test 2: Prebuilt Templates' AS test_name,
    CASE 
        WHEN COUNT(*) >= 10 THEN CONCAT('✅ PASS - ', COUNT(*), ' templates loaded')
        ELSE CONCAT('❌ FAIL - Only ', COUNT(*), ' templates (expected 10)')
    END AS result
FROM portal_alert_templates;

-- ==========================================
-- TEST 3: List All Template Names
-- ==========================================

SELECT 
    'Template ' || ROW_NUMBER() OVER (ORDER BY created_at) AS number,
    template_name,
    severity,
    requires_response
FROM portal_alert_templates
ORDER BY created_at;

-- ==========================================
-- TEST 4: Verify RLS is Enabled
-- ==========================================

SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN '✅ RLS Enabled'
        ELSE '❌ RLS Disabled'
    END AS status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename LIKE 'portal_alert%'
ORDER BY tablename;

-- ==========================================
-- TEST 5: Count RLS Policies
-- ==========================================

SELECT 
    tablename,
    COUNT(*) AS policy_count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Has Policies'
        ELSE '⚠️ No Policies'
    END AS status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename LIKE 'portal_alert%'
GROUP BY tablename
ORDER BY tablename;

-- ==========================================
-- TEST 6: Verify Table Columns
-- ==========================================

-- Check portal_alerts columns
SELECT 
    'portal_alerts' AS table_name,
    COUNT(column_name) AS column_count,
    CASE 
        WHEN COUNT(column_name) >= 20 THEN '✅ All columns present'
        ELSE '⚠️ Missing columns'
    END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'portal_alerts';

-- ==========================================
-- TEST 7: Create Test Alert (Optional)
-- ==========================================

-- Uncomment to create a test alert
/*
INSERT INTO portal_alerts (
    title,
    message_html,
    severity,
    target_type,
    display_mode,
    date_rule_type,
    is_active,
    created_by
) VALUES (
    'Test Alert - System Verification',
    '<p>This is a test alert to verify the system is working correctly.</p><p>If you see this, everything is set up properly! ✅</p>',
    'info',
    'all',
    'once_ever',
    'always',
    true,
    'system@test.com'
);
*/

-- ==========================================
-- TEST 8: Check Active Alerts
-- ==========================================

SELECT 
    COUNT(*) AS active_alert_count,
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('✅ ', COUNT(*), ' active alert(s)')
        ELSE '⚠️ No active alerts (create one to test)'
    END AS status
FROM portal_alerts
WHERE is_active = true;

-- ==========================================
-- TEST 9: View Sample Alert Configuration
-- ==========================================

SELECT 
    id,
    title,
    severity,
    target_type,
    display_mode,
    date_rule_type,
    is_active,
    created_at
FROM portal_alerts
ORDER BY created_at DESC
LIMIT 5;

-- ==========================================
-- TEST 10: Verify Indexes Exist
-- ==========================================

SELECT 
    schemaname,
    tablename,
    indexname,
    '✅' AS status
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename LIKE 'portal_alert%'
ORDER BY tablename, indexname;

-- ==========================================
-- TEST 11: Check Table Constraints
-- ==========================================

SELECT 
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    CASE contype
        WHEN 'c' THEN 'Check'
        WHEN 'f' THEN 'Foreign Key'
        WHEN 'p' THEN 'Primary Key'
        WHEN 'u' THEN 'Unique'
        ELSE contype::text
    END AS constraint_type
FROM pg_constraint
WHERE conrelid IN (
    'portal_alerts'::regclass,
    'portal_alert_templates'::regclass,
    'portal_alert_impressions'::regclass,
    'portal_alert_responses'::regclass
)
ORDER BY table_name, constraint_type;

-- ==========================================
-- TEST 12: Simulate Student View Query
-- ==========================================

-- This simulates what a student would see
-- Replace 'student-uuid' with a real student ID to test
/*
SELECT 
    id,
    title,
    message_html,
    severity,
    display_mode,
    requires_response
FROM portal_alerts
WHERE is_active = true
  AND (
    target_type = 'all' 
    OR 'student-uuid' = ANY(SELECT jsonb_array_elements_text(target_student_ids))
  )
ORDER BY created_at DESC;
*/

-- ==========================================
-- TEST 13: Check Sample Impression Record
-- ==========================================

SELECT 
    COUNT(*) AS impression_count,
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('✅ ', COUNT(*), ' impression(s) recorded')
        ELSE '⚠️ No impressions yet (students need to view alerts)'
    END AS status
FROM portal_alert_impressions;

-- ==========================================
-- TEST 14: Check Sample Response Record
-- ==========================================

SELECT 
    COUNT(*) AS response_count,
    CASE 
        WHEN COUNT(*) > 0 THEN CONCAT('✅ ', COUNT(*), ' response(s) recorded')
        ELSE '⚠️ No responses yet (students need to answer alerts)'
    END AS status
FROM portal_alert_responses;

-- ==========================================
-- TEST 15: Full System Health Check
-- ==========================================

SELECT 
    '🏥 PORTAL ALERTS SYSTEM HEALTH CHECK' AS status,
    (SELECT COUNT(*) FROM portal_alerts) AS total_alerts,
    (SELECT COUNT(*) FROM portal_alerts WHERE is_active = true) AS active_alerts,
    (SELECT COUNT(*) FROM portal_alert_templates) AS templates,
    (SELECT COUNT(*) FROM portal_alert_impressions) AS total_views,
    (SELECT COUNT(*) FROM portal_alert_responses) AS total_responses,
    CASE 
        WHEN (SELECT COUNT(*) FROM portal_alert_templates) >= 10 
         AND (SELECT COUNT(*) FROM information_schema.tables 
              WHERE table_schema = 'public' 
              AND table_name LIKE 'portal_alert%') = 4
        THEN '✅ SYSTEM HEALTHY'
        ELSE '⚠️ SETUP INCOMPLETE'
    END AS overall_status;

-- ==========================================
-- EXPECTED RESULTS SUMMARY
-- ==========================================

/*
✅ Expected Test Results:

Test 1: All 4 tables exist
Test 2: 10 templates loaded
Test 3: List of 10 template names
Test 4: RLS enabled on all 4 tables
Test 5: Multiple policies per table
Test 6: 20+ columns in portal_alerts
Test 7: (Optional) Test alert created
Test 8: Shows count of active alerts
Test 9: Shows recent alerts (if any)
Test 10: Shows indexes on tables
Test 11: Shows constraints (PK, FK, Check)
Test 12: (Optional) Simulates student query
Test 13: Shows impression count
Test 14: Shows response count
Test 15: Overall system health ✅

If all tests pass, your alerts system is ready! 🎉
*/

-- ==========================================
-- CLEANUP TEST DATA (Optional)
-- ==========================================

-- Uncomment to remove test alert if you created one
/*
DELETE FROM portal_alerts 
WHERE title = 'Test Alert - System Verification';
*/
