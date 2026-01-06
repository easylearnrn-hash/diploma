-- Add UPDATE and DELETE policies for registrations table
-- Run this in Supabase SQL Editor to enable editing and deleting registrations

-- Allow anonymous update access for admin page
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'registrations'
          AND policyname = 'Public can update registrations'
    ) THEN
        CREATE POLICY "Public can update registrations"
            ON public.registrations
            FOR UPDATE
            TO anon
            USING (true)
            WITH CHECK (true);
    END IF;
END$$;

-- Allow anonymous delete access for admin page
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'registrations'
          AND policyname = 'Public can delete registrations'
    ) THEN
        CREATE POLICY "Public can delete registrations"
            ON public.registrations
            FOR DELETE
            TO anon
            USING (true);
    END IF;
END$$;

-- Grant UPDATE and DELETE permissions to anonymous users
GRANT UPDATE, DELETE ON public.registrations TO anon;

-- Verify policies were created
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'registrations'
ORDER BY policyname;
