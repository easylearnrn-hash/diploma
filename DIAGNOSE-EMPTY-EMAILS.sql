-- Emergency Email System Diagnostic
-- This will show EXACTLY what's in your email_history table

-- 1. Count total records
SELECT 
    'Total Email Records' as metric,
    COUNT(*) as count
FROM email_history;

-- 2. Show ALL records (even if empty)
SELECT 
    id,
    sent_at,
    sender,
    recipient,
    subject,
    status,
    SUBSTRING(body, 1, 100) as body_preview
FROM email_history 
ORDER BY sent_at DESC NULLS LAST;

-- 3. If empty, show table structure to confirm it exists
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'email_history'
ORDER BY ordinal_position;

-- 4. Check if table has any rows at all
SELECT 
    schemaname,
    relname as tablename,
    n_live_tup as row_count,
    n_dead_tup as dead_rows
FROM pg_stat_user_tables
WHERE relname = 'email_history';

-- DIAGNOSIS:
-- If COUNT(*) = 0 → No emails have been sent through the system yet
-- If table doesn't exist → Need to run CREATE-EMAIL-HISTORY-TABLE.sql
-- If rows > 0 but not showing in UI → Check email-system.html query filters
