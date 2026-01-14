-- Quick check for email records
-- Run this in Supabase SQL Editor

-- Check total emails in system
SELECT 
    COUNT(*) as total_emails,
    COUNT(*) FILTER (WHERE status = 'sent') as sent_count,
    COUNT(*) FILTER (WHERE status = 'failed') as failed_count,
    COUNT(*) FILTER (WHERE sender IS NOT NULL) as has_sender,
    COUNT(*) FILTER (WHERE html_body IS NOT NULL) as has_html_body,
    MAX(sent_at) as most_recent_email
FROM email_history;

-- Show last 5 emails with details
SELECT 
    sent_at,
    sender,
    recipient,
    subject,
    status,
    CASE 
        WHEN html_body IS NOT NULL THEN 'Yes (' || LENGTH(html_body) || ' chars)'
        ELSE 'No'
    END as has_html,
    resend_id
FROM email_history 
ORDER BY sent_at DESC NULLS LAST
LIMIT 5;

-- If no results, the table is empty - no emails have been saved yet
