-- Check what statuses exist in email_history
SELECT 
  status,
  COUNT(*) as count,
  STRING_AGG(DISTINCT sender, ', ') as senders,
  STRING_AGG(DISTINCT recipient, ', ') as recipients
FROM email_history
GROUP BY status
ORDER BY count DESC;

-- Show all 4 emails with their details
SELECT 
  id,
  sender,
  recipient,
  subject,
  status,
  sent_at,
  CASE 
    WHEN sender LIKE '%@acnhs.am' THEN '📤 Outgoing (from ACNHS)'
    WHEN recipient LIKE '%@acnhs.am' THEN '📥 Incoming (to ACNHS)'
    ELSE '❓ Unknown direction'
  END as direction
FROM email_history
ORDER BY sent_at DESC;

-- Analysis: Find incoming vs outgoing
SELECT 
  CASE 
    WHEN sender LIKE '%@acnhs.am' AND recipient NOT LIKE '%@acnhs.am' THEN 'Outgoing (ACNHS → External)'
    WHEN recipient LIKE '%@acnhs.am' AND sender NOT LIKE '%@acnhs.am' THEN 'Incoming (External → ACNHS)'
    WHEN sender LIKE '%@acnhs.am' AND recipient LIKE '%@acnhs.am' THEN 'Internal (ACNHS → ACNHS)'
    ELSE 'External (External → External)'
  END as email_type,
  COUNT(*) as count
FROM email_history
GROUP BY email_type
ORDER BY count DESC;
