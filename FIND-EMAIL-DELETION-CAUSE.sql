-- EMERGENCY: Find out what's deleting emails and why new ones aren't saving

-- 1. Check if there are any DELETE triggers or rules on the table
SELECT 
    trigger_name,
    event_manipulation,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'email_history';

-- 2. Check for any CASCADE delete rules
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.referential_constraints AS rc
    ON tc.constraint_name = rc.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON rc.constraint_name = ccu.constraint_name
WHERE tc.table_name = 'email_history' AND tc.constraint_type = 'FOREIGN KEY';

-- 3. Check RLS policies - especially DELETE and UPDATE policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'email_history';

-- 4. Check for any scheduled jobs or functions that might delete old emails
SELECT 
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'public' 
  AND (routine_definition ILIKE '%email_history%' 
   OR routine_definition ILIKE '%DELETE%');

-- 5. Show table ownership and permissions
SELECT 
    grantee,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_name = 'email_history';

-- CRITICAL: Check if emails are being inserted at all
-- This will show the LAST operation on email_history
SELECT 
    relname,
    n_tup_ins as total_inserts,
    n_tup_upd as total_updates,
    n_tup_del as total_deletes,
    n_live_tup as current_rows,
    n_dead_tup as dead_rows,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE relname = 'email_history';
