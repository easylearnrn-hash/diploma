-- Create monthly_expenses table in Supabase
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS monthly_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  amount NUMERIC(10, 2) NOT NULL,
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE monthly_expenses ENABLE ROW LEVEL SECURITY;

-- Allow admins to read all expenses
CREATE POLICY "Admins can view expenses"
  ON monthly_expenses
  FOR SELECT
  USING (true);

-- Allow admins to insert expenses
CREATE POLICY "Admins can add expenses"
  ON monthly_expenses
  FOR INSERT
  WITH CHECK (true);

-- Allow admins to delete expenses
CREATE POLICY "Admins can delete expenses"
  ON monthly_expenses
  FOR DELETE
  USING (true);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_monthly_expenses_created_at 
  ON monthly_expenses(created_at DESC);

-- Verify table creation
SELECT * FROM monthly_expenses;
