-- Add 'invite' to registrations status check constraint
-- Run this in the Supabase SQL Editor

ALTER TABLE public.registrations
  DROP CONSTRAINT IF EXISTS registrations_status_check;

ALTER TABLE public.registrations
  ADD CONSTRAINT registrations_status_check
  CHECK (status IN ('pending', 'contacted', 'invite', 'approved', 'rejected'));
