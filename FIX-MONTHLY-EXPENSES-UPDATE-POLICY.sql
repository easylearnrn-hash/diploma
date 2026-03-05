-- Fix: Add missing UPDATE policy for monthly_expenses table
-- RLS was enabled but no UPDATE policy existed, so edits silently failed
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql

CREATE POLICY "Admins can update expenses"
  ON monthly_expenses
  FOR UPDATE
  USING (true)
  WITH CHECK (true);
