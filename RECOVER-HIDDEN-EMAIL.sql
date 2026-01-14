-- Find and recover the hidden email record
-- Your table shows 1 live row + 1 dead row, but queries return 0 results

-- 1. Show ALL records including those with NULL values
SELECT 
    id,
    sender,
    recipient,
    subject,
    status,
    sent_at,
    created_at,
    resend_id,
    CASE 
        WHEN sender IS NULL THEN '⚠️ NULL sender'
        ELSE '✅ Has sender'
    END as sender_status,
    CASE 
        WHEN recipient IS NULL THEN '⚠️ NULL recipient'
        ELSE '✅ Has recipient'
    END as recipient_status
FROM email_history 
ORDER BY created_at DESC NULLS LAST, sent_at DESC NULLS LAST;

-- 2. Count records by status
SELECT 
    status,
    COUNT(*) as count
FROM email_history
GROUP BY status;

-- 3. Check for records with missing required fields
SELECT 
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE recipient IS NULL) as null_recipient,
    COUNT(*) FILTER (WHERE subject IS NULL) as null_subject,
    COUNT(*) FILTER (WHERE body IS NULL) as null_body,
    COUNT(*) FILTER (WHERE status IS NULL) as null_status,
    COUNT(*) FILTER (WHERE sender IS NULL) as null_sender
FROM email_history;

-- 4. Clean up dead rows (vacuum the table)
VACUUM email_history;

-- 5. After vacuum, check row count again
SELECT 
    schemaname,
    relname as tablename,
    n_live_tup as row_count,
    n_dead_tup as dead_rows,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'email_history';

-- 6. If record has NULL in NOT NULL columns, it won't show up
-- Check table constraints
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'email_history'::regclass
ORDER BY contype;

-- SOLUTION: If you see a record with issues, you can either:
-- A) Delete it and start fresh:
--    DELETE FROM email_history WHERE id = '<problematic-id>';
--    VACUUM email_history;

-- B) Fix the record (if it has NULL values):
--    UPDATE email_history 
--    SET sender = 'admissions@acnhs.am',
--        subject = COALESCE(subject, 'No Subject'),
--        body = COALESCE(body, ''),
--        status = COALESCE(status, 'sent')
--    WHERE id = '<record-id>';
