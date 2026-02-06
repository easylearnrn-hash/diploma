-- Check if Narine's original password is stored anywhere in payload
SELECT 
  id,
  applicant_name,
  username,
  plain_password,
  password_hash,
  payload->'latestCredentials' as latest_credentials,
  payload->'studentPortal' as student_portal,
  payload->'credentials' as credentials,
  payload->'password' as password_field
FROM applications
WHERE id = '1d259c9a-73af-493e-ad19-fae57a1b247d';

-- Check if there's any password info in the payload JSONB
