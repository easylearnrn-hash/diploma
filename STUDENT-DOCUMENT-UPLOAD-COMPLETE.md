# Student Document Upload System - Complete Guide

## Overview
Students can now upload documents (payment receipts, transcripts, etc.) directly from their portal's Financial tab. Uploaded documents automatically appear in the admin student page Documents tab.

## Features Implemented

### 1. Upload Button (Student Portal)
**Location:** `Student-page.html` → Financial Tab (Tab 8)  
**Appearance:** Large teal gradient button with upload icon  
**Action:** Opens document upload modal

### 2. Upload Modal
**Components:**
- **Document Type Selector** - Dropdown with 8 options:
  - Invoice Payment Receipt (default)
  - Transcript
  - ID Document
  - Medical Certificate
  - Recommendation Letter
  - Proof of Address
  - Bank Statement
  - Other Document

- **File Input** - Accepts: PDF, JPG, PNG, DOC, DOCX (Max 10MB)
- **Notes Field** - Optional text area for additional context
- **Progress Bar** - Real-time upload progress indicator

### 3. Upload Process Flow
```
1. Student clicks "Upload Document" button
2. Modal opens with form
3. Student selects document type (defaults to "Invoice Payment Receipt")
4. Student selects file (validates size ≤ 10MB)
5. Student adds optional notes
6. Click "Upload" button
7. Progress bar shows:
   - 10%: Preparing upload
   - 30%: Uploading to server
   - 60%: Getting file URL
   - 80%: Saving to database
   - 100%: Complete!
8. Success alert confirms upload
9. Modal closes automatically
```

### 4. Backend Storage
**Storage Location:** Supabase Storage Bucket `application-documents`  
**Path Structure:** `documents/{application_id}/{timestamp}_{filename}`  
**Example:** `documents/abc123-def456/1707849600000_payment_receipt.pdf`

**Database Record:** Stored in `applications.uploaded_documents` JSONB array:
```json
{
  "doc_name": "Invoice Payment Receipt",
  "filename": "payment_receipt.pdf",
  "public_url": "https://...supabase.co/storage/.../documents/...",
  "size": 524288,
  "uploaded_at": "2026-02-13T12:30:00Z",
  "notes": "January tuition payment",
  "uploaded_by": "student"
}
```

### 5. Admin View
**Location:** `admin-student-page.html` → Documents Tab  
**Display:** All uploaded documents appear automatically in the documents grid  
**Information Shown:**
- Document name/type
- File size
- Upload date/time
- Download/view link
- Student notes (if provided)

## Technical Implementation

### Files Modified
1. **Student-page.html** (3 changes)
   - Added upload button in financial panel (line ~1820)
   - Added upload modal HTML (line ~2500)
   - Added JavaScript functions (line ~5900)

### Key Functions

#### `openUploadModal()`
Opens the upload modal and resets the form.

#### `closeUploadModal()`  
Closes modal and clears all inputs.

#### `updateFileName(input)`
Validates file size (max 10MB) when file is selected.

#### `handleUpload(event)`
Main upload handler:
- Prevents form default submission
- Validates file selection
- Shows progress bar
- Uploads to Supabase Storage
- Gets public URL
- Appends to `uploaded_documents` array
- Updates application record
- Shows success/error alerts

### Storage Setup Required

**Supabase Dashboard Steps:**
1. Go to Storage → New Bucket
2. Bucket name: `application-documents`
3. Public: YES ✅
4. File size limit: 10485760 (10MB)
5. Allowed MIME types:
   - `image/jpeg`
   - `image/jpg`
   - `image/png`
   - `application/pdf`
   - `application/msword`
   - `application/vnd.openxmlformats-officedocument.wordprocessingml.document`

**Policies:**
- INSERT: Allow anon/authenticated users
- SELECT: Allow public (for admin viewing)

See `CREATE-DOCUMENT-UPLOAD-STORAGE.sql` for SQL setup script.

## User Experience

### Student View
1. Navigate to Financial tab
2. See invoice (if available)
3. Click **"📤 Upload Document"** button (centered, prominent)
4. Select document type from dropdown
5. Choose file from computer
6. Add optional notes
7. Click "Upload"
8. See progress bar animation
9. Receive success confirmation
10. Document is submitted for admin review

### Admin View
1. Open admin student page for any student
2. Click **"📄 Documents"** tab
3. See all uploaded documents in grid
4. Click document to view/download
5. See upload metadata (date, size, notes)
6. Documents from student uploads have `uploaded_by: "student"` flag

## Security & Validation

### Client-Side Validation
- File type check (PDF, JPG, PNG, DOC, DOCX only)
- File size limit (10MB maximum)
- Required fields enforced (document type, file)

### Server-Side Security
- Supabase Storage handles authentication
- Files stored in student's application folder
- Public read access (for admin viewing)
- Upload permissions via RLS policies

### Error Handling
- File size exceeded → Alert with clear message
- Upload failure → Error alert with details
- Network issues → Retry suggestion
- Missing application ID → Graceful error message

## Database Structure

### Before Upload
```sql
applications.uploaded_documents = []
-- or null
```

### After Upload
```sql
applications.uploaded_documents = [
  {
    "doc_name": "Invoice Payment Receipt",
    "filename": "receipt_jan_2026.pdf",
    "public_url": "https://zlvnxvrzotamhpezqedr.supabase.co/storage/v1/object/public/application-documents/documents/abc123/1707849600_receipt_jan_2026.pdf",
    "size": 524288,
    "uploaded_at": "2026-02-13T12:30:00.000Z",
    "notes": "January tuition payment - Bank transfer confirmation",
    "uploaded_by": "student"
  }
]
```

### Admin Query (Already Implemented)
The existing `loadDocuments()` function in `admin-student-page.html` reads from `uploaded_documents` array, so no changes needed - documents appear automatically!

## Testing Checklist

### Student Portal
- [ ] Upload button visible in Financial tab
- [ ] Button styled correctly (teal gradient, shadow, hover effect)
- [ ] Modal opens when button clicked
- [ ] Document type dropdown shows 8 options
- [ ] Default selection is "Invoice Payment Receipt"
- [ ] File input accepts PDF, JPG, PNG, DOC, DOCX
- [ ] File size validation works (reject >10MB)
- [ ] Progress bar animates during upload
- [ ] Success alert appears after upload
- [ ] Modal closes after successful upload
- [ ] Cancel button works
- [ ] Background click closes modal

### Admin Portal
- [ ] Open student page
- [ ] Navigate to Documents tab
- [ ] See uploaded document in grid
- [ ] Document name shows selected type
- [ ] File size displays correctly
- [ ] Upload date shows
- [ ] Click document to view/download
- [ ] Notes field shows student notes (if provided)
- [ ] Document has `uploaded_by: "student"` metadata

### Error Cases
- [ ] Upload >10MB file → Size error
- [ ] Upload without file → Validation error
- [ ] Network failure → Error message
- [ ] Invalid file type → Validation error

## Future Enhancements (Optional)

1. **Multi-file Upload** - Allow selecting multiple files at once
2. **Drag & Drop** - Drag files directly onto modal
3. **File Preview** - Show thumbnail before upload
4. **Delete Option** - Allow students to delete their uploads
5. **Notification System** - Email admins when new document uploaded
6. **Document Status** - Admin can mark as "reviewed", "approved", "rejected"
7. **File Compression** - Auto-compress large images
8. **Upload History** - Show list of previously uploaded documents

## Troubleshooting

### "Upload failed: Storage bucket not found"
**Solution:** Create `application-documents` bucket in Supabase Dashboard (see setup section above)

### "Upload failed: Permission denied"
**Solution:** Check bucket policies - ensure INSERT allowed for anon/authenticated users

### "Document doesn't appear in admin page"
**Solution:** Refresh admin page, verify `application_id` matches between student and application

### "File too large" error on small files
**Solution:** Clear browser cache, check file size in bytes (10MB = 10,485,760 bytes)

## Support

For issues or questions:
- Check browser console for detailed error messages
- Verify Supabase Storage bucket exists and has correct policies
- Ensure student has valid `application_id` in their profile
- Test with small PDF file first (< 1MB)

---

**Status:** ✅ Complete and Ready for Testing  
**Version:** 1.0  
**Date:** February 13, 2026  
**Author:** AI Assistant
