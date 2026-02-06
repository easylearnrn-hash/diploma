-- CHECK SENT EMAILS STATUS IN DATABASE
-- This will help us understand why sent emails aren't showing in the Sent tab

-- 1. Check all email statuses
SELECT 
    status,
    COUNT(*) as count
FROM email_history
GROUP BY status
ORDER BY count DESC;

-- 2. Check emails sent BY admissions/acnhs (should be outgoing)
SELECT 
    id,
    sender,
    recipient,
    subject,
    status,
    sent_at,
    CASE 
        WHEN sender LIKE '%@acnhs.am' THEN 'From ACNHS'
        WHEN recipient LIKE '%@acnhs.am' THEN 'To ACNHS'
        ELSE 'External'
    END as direction
FROM email_history
WHERE sender LIKE '%@acnhs.am'  -- Emails sent FROM acnhs addresses
ORDER BY sent_at DESC
LIMIT 20;

-- 3. Check if sent_by_admin column exists
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'email_history'
AND column_name IN ('status', 'sent_by_admin', 'sender', 'recipient');

-- 4. Count emails that SHOULD appear in Sent tab
SELECT 
    COUNT(*) as sent_count,
    COUNT(*) FILTER (WHERE status = 'sent') as status_sent,
    COUNT(*) FILTER (WHERE sender LIKE '%@acnhs.am') as from_acnhs
FROM email_history;
