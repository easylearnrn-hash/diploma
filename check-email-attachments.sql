-- Check what attachments look like in email_history
SELECT 
  id,
  subject,
  recipient,
  attachments,
  jsonb_array_length(attachments) as attachment_count
FROM email_history 
WHERE attachments IS NOT NULL 
  AND jsonb_array_length(attachments) > 0
ORDER BY created_at DESC
LIMIT 3;
