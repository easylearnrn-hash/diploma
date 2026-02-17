-- Check active class join links
SELECT 
  id,
  url,
  group_id,
  is_active,
  ended_at,
  expires_at,
  created_at,
  created_by
FROM class_join_links
WHERE is_active = true 
  AND ended_at IS NULL
ORDER BY created_at DESC
LIMIT 5;
