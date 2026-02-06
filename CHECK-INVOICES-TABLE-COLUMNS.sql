-- Check the actual column names in the invoices table

SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'invoices'
ORDER BY ordinal_position;

-- Also check Narine's invoice specifically
SELECT *
FROM invoices
WHERE student_id = 'ACNHS-7022395'
LIMIT 1;
