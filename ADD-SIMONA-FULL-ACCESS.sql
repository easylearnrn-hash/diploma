-- Check Simona Gharibyan's admin user record
SELECT 
  id,
  full_name,
  username,
  email,
  title,
  phone_ext,
  status,
  email_sending_access,
  permissions,
  created_at
FROM admin_users 
WHERE email = 's.gharibyan@acnhs.am' 
   OR username LIKE '%simona%' 
   OR email LIKE '%gharibyan%';

-- If she doesn't exist, create her with full permissions
-- Run this AFTER checking if she exists:

INSERT INTO admin_users (
  full_name,
  username,
  email,
  title,
  phone_ext,
  status,
  email_sending_access,
  permissions,
  email_signature
) VALUES (
  'Simona Gharibyan',
  '@simona',
  's.gharibyan@acnhs.am',
  'Executive Director',
  '101',
  'active',
  ARRAY['admissions', 'info', 'documents'],
  ARRAY[
    'Send Emails',
    'Edit Students',
    'Manage Appeals',
    'Verify Documents',
    'Generate Qr Codes',
    'View Applications',
    'Manage Transcripts',
    'Export Data',
    'Manage Users',
    'View Reports',
    'View Students',
    'Manage Settings',
    'Delete Students'
  ],
  NULL
)
ON CONFLICT (email) DO UPDATE SET
  permissions = ARRAY[
    'Send Emails',
    'Edit Students',
    'Manage Appeals',
    'Verify Documents',
    'Generate Qr Codes',
    'View Applications',
    'Manage Transcripts',
    'Export Data',
    'Manage Users',
    'View Reports',
    'View Students',
    'Manage Settings',
    'Delete Students'
  ],
  status = 'active';
