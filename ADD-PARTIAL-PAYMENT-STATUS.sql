-- Add 'partial' status to invoices table
ALTER TABLE invoices 
DROP CONSTRAINT IF EXISTS invoices_status_check;

ALTER TABLE invoices 
ADD CONSTRAINT invoices_status_check 
CHECK (status IN ('unpaid', 'paid', 'partial', 'overdue', 'cancelled'));
