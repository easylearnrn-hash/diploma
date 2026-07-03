-- Storage bucket for Export.html document files
-- Run once in Supabase SQL Editor

-- 1. Create the bucket (15 MB per-file limit)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('export-files', 'export-files', false, 15728640)
ON CONFLICT (id) DO NOTHING;

-- 2. Allow anonymous access (same pattern as the rest of this project)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename  = 'objects'
      AND policyname = 'export_files_anon_all'
  ) THEN
    CREATE POLICY "export_files_anon_all" ON storage.objects
      FOR ALL TO anon
      USING     (bucket_id = 'export-files')
      WITH CHECK(bucket_id = 'export-files');
  END IF;
END $$;
