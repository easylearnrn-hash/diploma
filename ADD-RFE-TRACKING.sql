-- ========================================
-- ADD RFE (REQUEST FOR EVIDENCE) TRACKING
-- Run this in Supabase SQL Editor
-- ========================================

-- Add columns for detailed status tracking and RFE management
ALTER TABLE public.applications
ADD COLUMN IF NOT EXISTS status_message TEXT,
ADD COLUMN IF NOT EXISTS rfe_documents_requested JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- Update status check constraint to include new professional statuses
ALTER TABLE public.applications 
DROP CONSTRAINT IF EXISTS applications_status_check;

ALTER TABLE public.applications
ADD CONSTRAINT applications_status_check 
CHECK (status IN (
  'SUBMITTED', 
  'UNDER REVIEW', 
  'ACTIVELY REVIEWING',
  'RFE PREPARING', 
  'RFE SENT',
  'ADDITIONAL DOCUMENTS REQUESTED',
  'DOCUMENTS RECEIVED',
  'FINAL REVIEW',
  'APPROVED', 
  'DENIED',
  'ON HOLD',
  'WITHDRAWN'
));

-- Create index for faster filtering by detailed statuses
CREATE INDEX IF NOT EXISTS idx_applications_status_message ON public.applications(status_message);

-- Success message
SELECT 'RFE tracking columns added successfully!' as message;
