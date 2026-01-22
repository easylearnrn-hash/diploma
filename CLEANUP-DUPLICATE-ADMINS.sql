-- Clean up duplicate admin users and ensure proper configuration
-- Run this in Supabase SQL Editor

-- 1. First, let's see the duplicates
SELECT 
  id,
  email, 
  name,
  username,
  role,
  created_at
FROM admin_users 
WHERE email = 'hrachfilm@gmail.com'
ORDER BY created_at;

-- 2. Delete the newer duplicate (keep the original 'hrach' username entry)
DELETE FROM admin_users 
WHERE email = 'hrachfilm@gmail.com' 
  AND username = 'hrachfilm@gmail.com'
  AND created_at > '2026-01-21 15:00:00';

-- 3. Update the remaining hrachfilm@gmail.com entry to ensure it has the right details
UPDATE admin_users
SET 
  name = 'Hrachya Vardanyan',
  role = 'super_admin',
  title = 'Executive Director',
  permissions = jsonb_build_object(
    'view_applications', true,
    'edit_applications', true,
    'delete_applications', true,
    'send_emails', true,
    'view_email_history', true,
    'manage_users', true,
    'view_reports', true,
    'export_data', true,
    'edit_students', true,
    'view_students', true,
    'delete_students', true,
    'manage_settings', true,
    'system_settings', true,
    'view_audit_logs', true,
    'view_statistics', true,
    'verify_documents', true,
    'compose_templates', true,
    'generate_qr_codes', true,
    'manage_transcripts', true,
    'use_grading_calculator', true,
    'manage_appeals', true,
    'manage_courses', true,
    'print_documents', true
  ),
  status = 'active',
  updated_at = NOW()
WHERE email = 'hrachfilm@gmail.com' 
  AND username = 'hrach';

-- 4. Verify the final state
SELECT 
  email, 
  name,
  username,
  role,
  title,
  status,
  created_at,
  updated_at
FROM admin_users 
ORDER BY email;

-- 5. Show summary
SELECT 
  COUNT(*) as total_admins,
  COUNT(DISTINCT email) as unique_emails,
  COUNT(*) - COUNT(DISTINCT email) as duplicates
FROM admin_users;
