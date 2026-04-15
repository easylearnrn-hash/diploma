-- ============================================================
-- ADD DELETE POLICIES FOR student_form_submissions + storage
-- Run this in: Supabase Dashboard → SQL Editor
-- ============================================================

-- DELETE policy on the submissions table
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename  = 'student_form_submissions'
          AND policyname = 'Allow anon delete student form submissions'
    ) THEN
        CREATE POLICY "Allow anon delete student form submissions"
            ON public.student_form_submissions
            FOR DELETE TO anon
            USING (true);
    END IF;
END $$;

-- DELETE policy on storage objects (so files can be removed too)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'storage'
          AND tablename  = 'objects'
          AND policyname = 'Allow anon delete from student-documents'
    ) THEN
        CREATE POLICY "Allow anon delete from student-documents"
            ON storage.objects FOR DELETE TO anon
            USING (bucket_id = 'student-documents');
    END IF;
END $$;
