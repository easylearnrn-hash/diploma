-- ==========================================
-- FIX: Update hrachfilm@gmail.com password to SHA-256
-- ==========================================
-- Problem: Multiple accounts with same email but different passwords/hashes
-- Solution: Consolidate and update to SHA-256 format

-- STEP 1: Generate your SHA-256 hash
-- Open generate-password-hash.html and enter your password
-- Replace 'YOUR_SHA256_HASH_HERE' below with the generated hash

-- STEP 2: Update ALL hrachfilm@gmail.com accounts to use the same SHA-256 hash
UPDATE admin_users 
SET password_hash = 'YOUR_SHA256_HASH_HERE',
    updated_at = NOW()
WHERE email = 'hrachfilm@gmail.com';

-- STEP 3: Verify all accounts are updated
SELECT 
  email, 
  name, 
  username,
  role, 
  status,
  LEFT(password_hash, 30) || '...' as password_hash_preview,
  updated_at
FROM admin_users 
WHERE email = 'hrachfilm@gmail.com'
ORDER BY created_at;

-- STEP 4: (OPTIONAL) Delete duplicate account if you only want one
-- Keep the super_admin (username: hrach) and delete the Administrator duplicate
-- DELETE FROM admin_users 
-- WHERE email = 'hrachfilm@gmail.com' 
-- AND username = 'hrachfilm@gmail.com'
-- AND role = 'Administrator';

-- STEP 5: Final verification - should show 1 or 2 accounts depending on Step 4
SELECT 
  email, 
  username,
  role,
  status
FROM admin_users 
WHERE email = 'hrachfilm@gmail.com';

-- ==========================================
-- EXPECTED RESULT AFTER FIX:
-- ==========================================
-- All hrachfilm@gmail.com accounts will have SHA-256 password
-- invoice.html login will work
-- login.html will also work with same credentials
-- ==========================================
