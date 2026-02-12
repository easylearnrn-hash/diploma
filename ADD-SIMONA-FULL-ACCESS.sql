-- Check Simona Gharibyan's admin user record
SELECT 
  id,
  name,
  username,
  email,
  title,
  phone_ext,
  status,
  email_permissions,
  permissions,
  created_at
FROM admin_users 
WHERE email = 's.gharibyan@acnhs.am' 
   OR username LIKE '%simona%' 
   OR email LIKE '%gharibyan%';

-- If she doesn't exist, create her with full permissions
-- Run this AFTER checking if she exists:

-- First check if user exists
DO $$
DECLARE
  user_exists boolean;
BEGIN
  SELECT EXISTS(SELECT 1 FROM admin_users WHERE email = 's.gharibyan@acnhs.am') INTO user_exists;
  
  IF user_exists THEN
    -- Update existing user with full permissions
    UPDATE admin_users 
    SET 
      permissions = jsonb_build_object(
        'send_emails', true,
        'edit_students', true,
        'manage_appeals', true,
        'verify_documents', true,
        'generate_qr_codes', true,
        'view_applications', true,
        'manage_transcripts', true,
        'export_data', true,
        'manage_users', true,
        'view_reports', true,
        'view_students', true,
        'manage_settings', true,
        'delete_students', true
      ),
      status = 'active',
      email_permissions = ARRAY['admissions', 'info', 'documents']
    WHERE email = 's.gharibyan@acnhs.am';
    
    RAISE NOTICE 'Updated existing user: s.gharibyan@acnhs.am';
  ELSE
    -- Insert new user with full permissions
    INSERT INTO admin_users (
      name,
      username,
      email,
      title,
      phone_ext,
      status,
      email_permissions,
      permissions,
      signature,
      role
    ) VALUES (
      'Simona Gharibyan',
      'simona',
      's.gharibyan@acnhs.am',
      'Executive Director',
      '101',
      'active',
      ARRAY['admissions', 'info', 'documents'],
      jsonb_build_object(
        'send_emails', true,
        'edit_students', true,
        'manage_appeals', true,
        'verify_documents', true,
        'generate_qr_codes', true,
        'view_applications', true,
        'manage_transcripts', true,
        'export_data', true,
        'manage_users', true,
        'view_reports', true,
        'view_students', true,
        'manage_settings', true,
        'delete_students', true
      ),
      NULL,
      'admin'
    );
    
    RAISE NOTICE 'Created new user: s.gharibyan@acnhs.am';
  END IF;
END $$;

-- Verify the user has all permissions
SELECT 
  name,
  email,
  status,
  jsonb_pretty(permissions) as permissions_formatted
FROM admin_users 
WHERE email = 's.gharibyan@acnhs.am';

