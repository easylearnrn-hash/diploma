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

-- ==========================================
-- TRANSCRIPT VERIFICATION SYSTEM
-- ==========================================

-- Create transcripts table for verification codes
CREATE TABLE IF NOT EXISTS public.transcripts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    verification_code TEXT UNIQUE NOT NULL,
    student_id TEXT NOT NULL,
    student_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    program TEXT NOT NULL,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    transcript_type TEXT NOT NULL CHECK (transcript_type IN ('standard', 'ministry', 'us-evaluation')),
    status TEXT NOT NULL DEFAULT 'valid' CHECK (status IN ('valid', 'invalid', 'revoked')),
    cumulative_gpa DECIMAL(3,2),
    total_credits DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for fast lookups
CREATE INDEX idx_transcripts_verification_code ON public.transcripts(verification_code);
CREATE INDEX idx_transcripts_student_id ON public.transcripts(student_id);
CREATE INDEX idx_transcripts_status ON public.transcripts(status);
CREATE INDEX idx_transcripts_issue_date ON public.transcripts(issue_date);

-- Enable Row Level Security
ALTER TABLE public.transcripts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read valid transcripts by verification code (for public verification)
CREATE POLICY "Public can verify transcripts"
    ON public.transcripts
    FOR SELECT
    USING (true);

-- Policy: Only service role can insert/update/delete
CREATE POLICY "Service role can manage transcripts"
    ON public.transcripts
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_transcripts_updated_at
    BEFORE UPDATE ON public.transcripts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL ON public.transcripts TO service_role;
GRANT SELECT ON public.transcripts TO anon;
GRANT SELECT ON public.transcripts TO authenticated;

-- Insert sample transcript for testing
INSERT INTO public.transcripts (
    verification_code,
    student_id,
    student_name,
    date_of_birth,
    program,
    transcript_type,
    issue_date,
    status,
    cumulative_gpa,
    total_credits,
    metadata
) VALUES (
    'TR-2025-001',
    'ACNHS2025001',
    'John Doe',
    '2000-05-15',
    'Bachelor of Science in Nursing',
    'standard',
    '2025-01-15',
    'valid',
    3.75,
    120.00,
    '{"term": "Spring 2025", "dean": "Dr. Sarah Johnson"}'::jsonb
);
