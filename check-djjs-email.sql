-- Check the "Djjs" email for attachments
SELECT 
  id,
  subject,
  sender,
  recipient,
  sent_at,
  status,
  attachments,
  CASE 
    WHEN attachments IS NULL THEN 'NO_ATTACHMENTS'
    WHEN jsonb_array_length(attachments) = 0 THEN 'EMPTY_ARRAY'
    ELSE jsonb_array_length(attachments)::text || ' ATTACHMENTS'
  END as attachment_status,
  LENGTH(html_body) as html_length,
  LENGTH(body) as plain_length
FROM email_history
WHERE subject ILIKE '%Djjs%'
   OR subject ILIKE '%dj%'
ORDER BY sent_at DESC
LIMIT 5;
