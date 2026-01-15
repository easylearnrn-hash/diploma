-- Check the Djjs email attachment details
SELECT 
  id,
  subject,
  sent_at,
  attachments,
  attachments->0->>'public_url' as attachment_url,
  attachments->0->>'storage_path' as storage_path,
  attachments->0->>'filename' as filename
FROM email_history
WHERE subject = 'Djjs'
ORDER BY sent_at DESC
LIMIT 1;
