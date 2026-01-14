-- Verify the email should be visible in email-system.html
-- Based on console log: 📤 SENT tab: Showing 0 sent emails

-- This is the EXACT query email-system.html should be running
SELECT 
    id,
    sender,
    recipient,
    subject,
    status,
    sent_at,
    body,
    html_body
FROM email_history
ORDER BY sent_at DESC
LIMIT 500;

-- Check if filtering logic is correct
-- SENT tab filter: sender is @acnhs.am OR (status='sent' AND sender IS NULL)
SELECT 
    id,
    sender,
    recipient,
    subject,
    status,
    sent_at,
    -- This is the SENT tab filter logic
    CASE 
        WHEN sender LIKE '%@acnhs.am' THEN 'YES - sender is ACNHS'
        WHEN sender IS NULL AND status = 'sent' THEN 'YES - no sender but sent'
        ELSE 'NO - would not show in SENT tab'
    END as would_show_in_sent_tab
FROM email_history;

-- Debug: Show what the JavaScript is filtering
WITH acnhs_emails AS (
    SELECT unnest(ARRAY[
        'admissions@acnhs.am',
        'info@acnhs.am',
        'documents@acnhs.am',
        'international@acnhs.am',
        'registrar@acnhs.am',
        'finance@acnhs.am',
        'ceo@acnhs.am',
        'dean@acnhs.am',
        'academic@acnhs.am',
        'student-services@acnhs.am',
        'legal@acnhs.am',
        'hr@acnhs.am',
        'it@acnhs.am',
        'library@acnhs.am',
        'alumni@acnhs.am',
        'research@acnhs.am',
        'do-not-reply@acnhs.am'
    ]) as email
)
SELECT 
    e.id,
    e.sender,
    e.recipient,
    e.status,
    CASE 
        WHEN LOWER(e.sender) = ANY(SELECT email FROM acnhs_emails) THEN 'MATCH - sender in list'
        WHEN e.sender IS NULL AND e.status = 'sent' THEN 'MATCH - NULL sender fallback'
        ELSE 'NO MATCH - sender not in list: ' || COALESCE(e.sender, 'NULL')
    END as filter_result
FROM email_history e;

-- SOLUTION: The email should show up!
-- If it's not showing, the issue is in the JavaScript, not the database.
-- Refresh the page and check browser console for:
-- "📧 Main admin - showing ALL X emails" 
-- It should say "1 email" not "0 emails"
