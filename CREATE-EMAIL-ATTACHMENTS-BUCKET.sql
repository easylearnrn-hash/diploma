-- Storage bucket for email attachments captured by the admin inbox
-- Run this once in Supabase SQL editor

INSERT INTO storage.buckets (id, name, public)
VALUES ('email-attachments', 'email-attachments', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public (anon) read so attachments can be viewed in the admin UI
DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM pg_policies
		WHERE schemaname = 'storage'
			AND tablename = 'objects'
			AND policyname = 'Public read email attachments'
	) THEN
		EXECUTE 'CREATE POLICY "Public read email attachments"
						 ON storage.objects FOR SELECT
						 TO public
						 USING (bucket_id = ''email-attachments'');';
	END IF;
END $$ LANGUAGE plpgsql;

-- Allow authenticated/service role uploads since attachments are stored from edge functions
DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM pg_policies
		WHERE schemaname = 'storage'
			AND tablename = 'objects'
			AND policyname = 'Service role upload email attachments'
	) THEN
		EXECUTE 'CREATE POLICY "Service role upload email attachments"
						 ON storage.objects FOR INSERT
						 TO service_role
						 WITH CHECK (bucket_id = ''email-attachments'');';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM pg_policies
		WHERE schemaname = 'storage'
			AND tablename = 'objects'
			AND policyname = 'Service role update email attachments'
	) THEN
		EXECUTE 'CREATE POLICY "Service role update email attachments"
						 ON storage.objects FOR UPDATE
						 TO service_role
						 USING (bucket_id = ''email-attachments'')
						 WITH CHECK (bucket_id = ''email-attachments'');';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM pg_policies
		WHERE schemaname = 'storage'
			AND tablename = 'objects'
			AND policyname = 'Service role delete email attachments'
	) THEN
		EXECUTE 'CREATE POLICY "Service role delete email attachments"
						 ON storage.objects FOR DELETE
						 TO service_role
						 USING (bucket_id = ''email-attachments'');';
	END IF;
END $$ LANGUAGE plpgsql;
