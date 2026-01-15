-- Check what attachments look like in the database for recent emails
SELECT 
  id,
  subject,
  recipient,
  sent_at,
  attachments,
  CASE 
    WHEN attachments IS NULL THEN 'NULL'
    WHEN jsonb_array_length(attachments) = 0 THEN 'EMPTY_ARRAY'
    ELSE 'HAS_ATTACHMENTS'
  END as attachment_status
FROM email_history
WHERE recipient = 'hayk.yeranosyan@yahoo.com'
   OR subject ILIKE '%orientation%'
ORDER BY sent_at DESC
LIMIT 5;
