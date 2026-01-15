-- Check if email-attachments bucket is public
-- Run this in Supabase SQL Editor

SELECT 
  name,
  id,
  public
FROM storage.buckets
WHERE name = 'email-attachments';

-- If public is FALSE, run this to make it public:
UPDATE storage.buckets
SET public = true
WHERE name = 'email-attachments';
