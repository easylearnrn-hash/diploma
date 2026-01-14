-- Fix existing emails: Update status based on direction
-- Incoming emails (TO @acnhs.am) should have status='received'
-- Outgoing emails (FROM @acnhs.am) should have status='sent'

-- Step 1: Show current status
SELECT 
  id,
  sender,
  recipient,
  status as current_status,
  CASE 
    WHEN recipient LIKE '%@acnhs.am' THEN 'received'
    ELSE 'sent'
  END as correct_status,
  sent_at
FROM email_history
ORDER BY sent_at DESC;

-- Step 2: Update incoming emails (TO @acnhs.am) to status='received'
UPDATE email_history
SET status = 'received'
WHERE recipient LIKE '%@acnhs.am'
  AND status != 'received'
  AND status != 'failed';

-- Step 3: Verify the fix
SELECT 
  status,
  COUNT(*) as count,
  STRING_AGG(
    CASE 
      WHEN recipient LIKE '%@acnhs.am' THEN '📥 Incoming'
      ELSE '📤 Outgoing'
    END,
    ', '
  ) as directions
FROM email_history
GROUP BY status
ORDER BY count DESC;

-- Step 4: Show all emails with correct status
SELECT 
  CASE 
    WHEN recipient LIKE '%@acnhs.am' THEN '📥 INBOX'
    ELSE '📤 SENT'
  END as tab,
  sender,
  recipient,
  subject,
  status,
  sent_at
FROM email_history
ORDER BY sent_at DESC;
