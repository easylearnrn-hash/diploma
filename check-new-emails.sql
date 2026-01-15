-- Check if any RECENT emails have attachments stored
SELECT 
  id,
  subject,
  recipient,
  sent_at,
  jsonb_array_length(attachments) as attachment_count,
  attachments->0->>'filename' as first_attachment_name,
  attachments->0->>'storage_path' as first_attachment_path
FROM email_history
WHERE attachments IS NOT NULL 
  AND jsonb_array_length(attachments) > 0
ORDER BY sent_at DESC
LIMIT 5;
