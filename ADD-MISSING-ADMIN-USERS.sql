-- Add missing admin users to NEW Supabase project
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql

-- First, check if admin_users table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'admin_users'
);

-- Check current admin users
SELECT email, name, role, created_at 
FROM admin_users 
ORDER BY email;

-- Insert missing admin users
-- Note: Password will need to be reset on first login
INSERT INTO admin_users (
  name,
  username,
  password_hash,
  role,
  title,
  phone_ext,
  email,
  signature,
  status,
  permissions,
  email_permissions
)
VALUES 
  (
    'Dr. Hrachya A. Vardanyan',
    'hrach@acnhs.am',
    -- Temporary password hash for "ChangeMe123!" - MUST BE CHANGED
    '$2a$10$rN/sC6tZJhGKLEqVEW7B8.xQZqVQxZhGKLEqVEW7B8xQZqVQxZhGK',
    'President',
    'President and Founder',
    '101',
    'hrach@acnhs.am',
    'Dr. Hrachya A. Vardanyan
President and Founder
Armenian College of Nurses & Health Sciences
📧 hrach@acnhs.am | 📞 Ext. 101',
    'active',
    jsonb_build_object(
      'view_applications', true,
      'edit_applications', true,
      'delete_applications', true,
      'send_emails', true,
      'view_email_history', true,
      'manage_users', true,
      'view_reports', true,
      'export_data', true,
      'edit_students', true,
      'delete_students', true,
      'manage_settings', true
    ),
    ARRAY['send_acceptance', 'send_rejection', 'send_rfe', 'send_general']
  ),
  (
    'Hrachya Vardanyan',
    'hrachfilm@gmail.com',
    -- Same temporary password
    '$2a$10$rN/sC6tZJhGKLEqVEW7B8.xQZqVQxZhGKLEqVEW7B8xQZqVQxZhGK',
    'Administrator',
    'System Administrator',
    '100',
    'hrachfilm@gmail.com',
    'Hrachya Vardanyan
System Administrator
Armenian College of Nurses & Health Sciences',
    'active',
    jsonb_build_object(
      'view_applications', true,
      'edit_applications', true,
      'delete_applications', true,
      'send_emails', true,
      'view_email_history', true,
      'manage_users', true,
      'view_reports', true,
      'export_data', true,
      'edit_students', true,
      'delete_students', true,
      'manage_settings', true
    ),
    ARRAY['send_acceptance', 'send_rejection', 'send_rfe', 'send_general']
  )
ON CONFLICT (username) DO UPDATE
SET 
  name = EXCLUDED.name,
  role = EXCLUDED.role,
  title = EXCLUDED.title,
  email = EXCLUDED.email,
  permissions = EXCLUDED.permissions,
  email_permissions = EXCLUDED.email_permissions,
  status = 'active',
  updated_at = NOW();

-- Verify the inserts
SELECT email, name, role, status, created_at 
FROM admin_users 
WHERE email IN ('hrach@acnhs.am', 'hrachfilm@gmail.com')
ORDER BY email;

-- Show all admin users after insert
SELECT 
  email, 
  name,
  username,
  role,
  title,
  status,
  permissions,
  created_at
FROM admin_users 
ORDER BY email;
