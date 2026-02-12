-- Check RLS policies for both admin-hub and student hub access

-- 1. Check students table RLS policies (affects both hubs)
SELECT 
  tablename,
  policyname,
  permissive,
  roles,
  cmd as operation,
  qual as using_expression
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename = 'students'
ORDER BY policyname;

-- 2. Check if RLS is enabled on students table
SELECT 
  schemaname,
  tablename, 
  rowsecurity as rls_enabled,
  CASE 
    WHEN rowsecurity THEN '🔒 RLS Enabled - Policies apply'
    ELSE '⚠️ RLS Disabled - All roles can access'
  END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename = 'students';

-- 3. Check admin_users table RLS policies (affects admin-hub login)
SELECT 
  tablename,
  policyname,
  permissive,
  roles,
  cmd as operation,
  qual as using_expression
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename = 'admin_users'
ORDER BY policyname;

-- 4. Check published_notes table (affects student hub notes view)
SELECT 
  tablename,
  policyname,
  permissive,
  roles,
  cmd as operation
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename = 'published_notes'
ORDER BY policyname;

-- 5. Check what permissions anon role has on key tables
SELECT 
  table_name,
  STRING_AGG(privilege_type, ', ' ORDER BY privilege_type) as permissions
FROM information_schema.role_table_grants 
WHERE grantee = 'anon' 
  AND table_schema = 'public'
  AND table_name IN ('students', 'admin_users', 'published_notes', 'applications')
GROUP BY table_name
ORDER BY table_name;

-- 6. Check authenticated role permissions
SELECT 
  table_name,
  STRING_AGG(privilege_type, ', ' ORDER BY privilege_type) as permissions
FROM information_schema.role_table_grants 
WHERE grantee = 'authenticated' 
  AND table_schema = 'public'
  AND table_name IN ('students', 'admin_users', 'published_notes', 'applications')
GROUP BY table_name
ORDER BY table_name;

-- Summary: What this tells us
-- - Students can access hub.html if they can SELECT from students table with their ID
-- - Admins can access admin-hub.html if isAdmin=true in sessionStorage (no DB check)
-- - Both hubs use anon role by default (unless using auth.signIn)
