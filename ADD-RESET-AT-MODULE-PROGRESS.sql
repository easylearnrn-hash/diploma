-- Add reset_at column to module_progress
-- This is used to trigger progress resets from the admin hub
-- WITHOUT relying on published_at (which changes on every routine publish).
--
-- Run in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql

ALTER TABLE public.module_progress
  ADD COLUMN IF NOT EXISTS reset_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

COMMENT ON COLUMN public.module_progress.reset_at IS
  'Set to NOW() by admin when explicitly resetting a student progress. '
  'The module page checks this against localStorage reset_seen_at and '
  'zeros out progress if reset_at is newer. Never written by publish actions.';
