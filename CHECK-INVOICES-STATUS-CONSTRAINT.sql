-- Check current status constraint on invoices table
SELECT 
  conname AS constraint_name,
  pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'invoices'::regclass
  AND contype = 'c'
  AND conname LIKE '%status%';
