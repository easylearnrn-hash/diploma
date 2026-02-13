-- ==========================================
-- STUDENT DOCUMENT UPLOAD STORAGE SETUP
-- ==========================================
-- Run this in Supabase SQL Editor to create storage bucket
-- for student document uploads (payment receipts, etc.)

-- Create storage bucket if it doesn't exist
-- NOTE: This must be done via Supabase Dashboard → Storage → New Bucket
-- Bucket name: application-documents
-- Public: YES (for easy access by admins)
-- File size limit: 10MB
-- Allowed MIME types: image/*, application/pdf, application/msword, application/vnd.openxmlformats-officedocument.wordprocessingml.document

-- If you prefer to create via SQL, use this (may not work in all Supabase versions):
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'application-documents',
  'application-documents',
  true,
  10485760, -- 10MB in bytes
  ARRAY[
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  ]
)
ON CONFLICT (id) DO NOTHING;

-- Create RLS policies for the bucket
-- Allow students to upload to their own application folder
CREATE POLICY "Students can upload to their application folder"
ON storage.objects
FOR INSERT
TO anon, authenticated
WITH CHECK (
  bucket_id = 'application-documents' AND
  (storage.foldername(name))[1] = 'documents'
);

-- Allow public read access (so admins can view)
CREATE POLICY "Public read access for application documents"
ON storage.objects
FOR SELECT
TO anon, authenticated, public
USING (bucket_id = 'application-documents');

-- Allow admins to delete (optional - for cleanup)
CREATE POLICY "Admins can delete documents"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'application-documents');

-- ==========================================
-- VERIFICATION QUERIES
-- ==========================================

-- Check if bucket exists
SELECT * FROM storage.buckets WHERE id = 'application-documents';

-- Check policies
SELECT * FROM pg_policies WHERE tablename = 'objects' AND policyname LIKE '%application%';

-- ==========================================
-- MANUAL SETUP INSTRUCTIONS (RECOMMENDED)
-- ==========================================

/*
If the SQL above doesn't work, create the bucket manually:

1. Go to Supabase Dashboard: https://supabase.com/dashboard
2. Navigate to Storage → New Bucket
3. Settings:
   - Name: application-documents
   - Public: YES (checked)
   - File size limit: 10485760 (10MB)
   - Allowed MIME types:
     * image/jpeg
     * image/jpg
     * image/png
     * application/pdf
     * application/msword
     * application/vnd.openxmlformats-officedocument.wordprocessingml.document

4. After creating bucket, go to Policies tab and add:
   
   Policy 1: "Allow public uploads"
   - Allowed operation: INSERT
   - Target roles: anon, authenticated
   - USING expression: true
   - WITH CHECK expression: bucket_id = 'application-documents'
   
   Policy 2: "Allow public reads"
   - Allowed operation: SELECT  
   - Target roles: public
   - USING expression: bucket_id = 'application-documents'

5. Save and test by uploading a document from student portal
*/
