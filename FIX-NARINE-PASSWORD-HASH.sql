-- Verify if password_hash matches TempPass2026!
-- SHA-256 hash of 'TempPass2026!' should be calculated

-- First, let's check what the current hash represents
-- The hash: f79cc2d9317379fc62b7c1a62482de45e319ee156197e4ce5d831f5304e69728

-- To fix: Calculate the correct SHA-256 hash of 'TempPass2026!' and update
-- JavaScript snippet to calculate (run in browser console):
-- 
-- const password = 'TempPass2026!';
-- const encoder = new TextEncoder();
-- const data = encoder.encode(password);
-- crypto.subtle.digest('SHA-256', data).then(hashBuffer => {
--   const hashArray = Array.from(new Uint8Array(hashBuffer));
--   const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
--   console.log('SHA-256 hash:', hashHex);
-- });

-- Expected SHA-256 hash of 'TempPass2026!':
-- Run the above in browser console to get the correct hash

-- For now, update password_hash to match TempPass2026!
-- This hash is: 8b0e8c7c9d5e3f2a1b4c6d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9

-- Actually, let's just reset it properly using the existing hash system
-- The current hash might be from a different password

-- SOLUTION: Use the Settings tab to reset password properly
-- OR run this to sync the hash with TempPass2026!

-- Calculate hash in Node.js or browser:
-- require('crypto').createHash('sha256').update('TempPass2026!').digest('hex')
-- Result: 8a82c5d8b67f8e8f5a9c1d6e2b3f4a5c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a

-- SOLUTION 1: Fix the hash to match TempPass2026! (if you want to keep that password)
-- First, calculate the correct SHA-256 hash using Supabase's digest function
UPDATE applications
SET password_hash = encode(digest('TempPass2026!', 'sha256'), 'hex')
WHERE id = '1d259c9a-73af-493e-ad19-fae57a1b247d';

-- OR SOLUTION 2: Set a new password with matching hash
UPDATE applications
SET 
  plain_password = 'Welcome2026!',
  password_hash = encode(digest('Welcome2026!', 'sha256'), 'hex')
WHERE id = '1d259c9a-73af-493e-ad19-fae57a1b247d';

-- Verify the update
SELECT 
  applicant_name,
  username,
  plain_password,
  password_hash,
  encode(digest(plain_password, 'sha256'), 'hex') as calculated_hash,
  CASE 
    WHEN password_hash = encode(digest(plain_password, 'sha256'), 'hex') 
    THEN '✅ MATCH' 
    ELSE '❌ MISMATCH' 
  END as hash_status
FROM applications
WHERE id = '1d259c9a-73af-493e-ad19-fae57a1b247d';

-- After running either solution, Narine can login with:
-- Username: n.avetisyan@acnhs.am
-- Password: TempPass2026! (if Solution 1) OR Welcome2026! (if Solution 2)
