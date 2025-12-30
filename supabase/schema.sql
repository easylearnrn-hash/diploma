-- SQL Schema for SMS Verification System
-- Run this in Supabase SQL Editor

-- Create sms_verifications table
CREATE TABLE IF NOT EXISTS public.sms_verifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    phone_number TEXT NOT NULL,
    code TEXT NOT NULL,
    purpose TEXT NOT NULL CHECK (purpose IN ('admission', 'login', 'password-reset')),
    verified BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verified_at TIMESTAMP WITH TIME ZONE,
    attempts INTEGER DEFAULT 0
);

-- Create index for faster lookups
CREATE INDEX idx_sms_verifications_phone ON public.sms_verifications(phone_number);
CREATE INDEX idx_sms_verifications_code ON public.sms_verifications(code);
CREATE INDEX idx_sms_verifications_verified ON public.sms_verifications(verified);

-- Create sms_logs table (optional - for tracking all SMS sent)
CREATE TABLE IF NOT EXISTS public.sms_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    phone_number TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('admission', 'notification', 'verification', 'reminder')),
    status TEXT,
    message_sid TEXT,
    error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for logs
CREATE INDEX idx_sms_logs_phone ON public.sms_logs(phone_number);
CREATE INDEX idx_sms_logs_created ON public.sms_logs(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.sms_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sms_logs ENABLE ROW LEVEL SECURITY;

-- Create policies for sms_verifications
-- Only service role can access (Edge Functions use service role key)
CREATE POLICY "Service role can access all verifications"
    ON public.sms_verifications
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Create policies for sms_logs
CREATE POLICY "Service role can access all logs"
    ON public.sms_logs
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Function to clean up expired verifications (run daily)
CREATE OR REPLACE FUNCTION cleanup_expired_verifications()
RETURNS void AS $$
BEGIN
    DELETE FROM public.sms_verifications
    WHERE expires_at < NOW() - INTERVAL '1 day';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Optional: Create a cron job to run cleanup daily (requires pg_cron extension)
-- SELECT cron.schedule('cleanup-expired-sms', '0 2 * * *', 'SELECT cleanup_expired_verifications();');

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO service_role;
GRANT ALL ON public.sms_verifications TO service_role;
GRANT ALL ON public.sms_logs TO service_role;
