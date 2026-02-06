-- URGENT DIAGNOSTIC: Check the 15 emails sent in the last 10 minutes

-- 1. Show ALL emails from the last 15 minutes
SELECT 
    id,
    sender,
    recipient,
    subject,
    status,
    sent_at,
    CASE 
        WHEN sender LIKE '%@acnhs.am' AND recipient NOT LIKE '%@acnhs.am' THEN '📤 OUTGOING (should be sent)'
        WHEN sender NOT LIKE '%@acnhs.am' AND recipient LIKE '%@acnhs.am' THEN '📥 INCOMING (should be received)'
        WHEN sender LIKE '%@acnhs.am' AND recipient LIKE '%@acnhs.am' THEN '🔄 INTERNAL'
        ELSE '❓ UNKNOWN'
    END as expected_direction,
    NOW() - sent_at as time_ago
FROM email_history
WHERE sent_at > NOW() - INTERVAL '15 minutes'
ORDER BY sent_at DESC;

-- 2. Count by status in last 15 minutes
SELECT 
    status,
    COUNT(*) as count,
    STRING_AGG(SUBSTRING(subject, 1, 50), ' | ') as subjects
FROM email_history
WHERE sent_at > NOW() - INTERVAL '15 minutes'
GROUP BY status;

-- 3. Check if your sent emails have the wrong status
SELECT 
    COUNT(*) as total_last_15min,
    COUNT(*) FILTER (WHERE status = 'sent') as has_status_sent,
    COUNT(*) FILTER (WHERE status = 'received') as has_status_received,
    COUNT(*) FILTER (WHERE sender LIKE '%@acnhs.am') as from_acnhs
FROM email_history
WHERE sent_at > NOW() - INTERVAL '15 minutes';

-- 4. Show EXACTLY what email system should be loading (last 500 emails)
SELECT 
    COUNT(*) as total_in_last_500,
    COUNT(*) FILTER (WHERE status = 'sent') as status_sent,
    COUNT(*) FILTER (WHERE status = 'received') as status_received,
    MAX(sent_at) as most_recent_email
FROM (
    SELECT * FROM email_history 
    ORDER BY sent_at DESC 
    LIMIT 500
) recent_emails;
