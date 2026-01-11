-- Add uploaded_documents column to applications table
-- This stores metadata about documents uploaded by students

ALTER TABLE applications
ADD COLUMN IF NOT EXISTS uploaded_documents JSONB DEFAULT '[]'::jsonb;

-- Add comment explaining the column structure
COMMENT ON COLUMN applications.uploaded_documents IS 
'Array of uploaded document metadata. Each entry: {key, doc_name, filename, path, public_url, uploaded_at}';

-- Create index for faster queries on uploaded documents
CREATE INDEX IF NOT EXISTS idx_applications_uploaded_documents 
ON applications USING GIN (uploaded_documents);
