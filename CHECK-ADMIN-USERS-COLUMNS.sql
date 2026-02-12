-- Check the actual columns in admin_users table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'admin_users' 
ORDER BY ordinal_position;
