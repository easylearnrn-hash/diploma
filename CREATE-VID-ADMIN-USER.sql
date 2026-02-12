-- Create first admin user for VID
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql/new

-- Option 1: Create user with email 'Hrachfilm@gmail.com' (Recommended)
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  confirmation_token,
  is_sso_user,
  confirmation_sent_at
)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'Hrachfilm@gmail.com',
  crypt('ACNHSAdmin2026!', gen_salt('bf')),  -- Default password: ACNHSAdmin2026!
  NOW(),
  NOW(),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  '',
  false,
  NOW()
);

-- Check if user was created successfully
SELECT id, email, email_confirmed_at, created_at 
FROM auth.users 
WHERE email = 'Hrachfilm@gmail.com';

-- IMPORTANT: After running this, your login credentials are:
-- Email: Hrachfilm@gmail.com
-- Password: ACNHSAdmin2026!
-- 
-- Change the password after first login!
