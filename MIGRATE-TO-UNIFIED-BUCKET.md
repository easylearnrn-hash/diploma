# Migration Guide: Unified Document Storage

## Summary
All application documents (admission form uploads + student RFE uploads) now use the **`application-documents`** bucket with a consistent folder structure.

## New Storage Structure

```
application-documents/
  └── applications/
      ├── ACNHS-2025-001/
      │   ├── photo-1736103613592-headshot.jpg           (admission form)
      │   ├── doc-1736103614123-passport.pdf             (admission form)
      │   ├── doc-1736103615456-diploma.pdf              (admission form)
      │   ├── 1736105234891-updated_transcript.pdf       (student RFE upload)
      │   └── 1736106543210-3x4_photo.jpg                (student RFE upload)
      └── ACNHS-2025-002/
          └── ...
```

## Changes Made

### ✅ Completed Automatically
1. **admission-form.html** - Changed bucket from `application-files` → `application-documents`
2. **application-status.html** - Updated upload path to match: `applications/<reference>/<file>`
3. **admin-applications.html** - Already displays both original and uploaded docs in drawer

### 📋 Manual Steps (If You Have Existing Data)

#### Option 1: Fresh Start (Recommended if testing)
- Simply use the new bucket going forward
- Old data in `application-files` can be deleted or archived

#### Option 2: Migrate Existing Files
If you have production data in `application-files` bucket:

1. **In Supabase Dashboard:**
   - Go to Storage > `application-files` bucket
   - Download all files
   - Go to Storage > `application-documents` bucket
   - Upload files to the `applications/` folder maintaining the same structure

2. **Or use Supabase CLI:**
```bash
# Download from old bucket
supabase storage download application-files applications --recursive

# Upload to new bucket
supabase storage upload application-documents applications --recursive
```

## File Naming Conventions

**Admission Form Documents:**
- Photo: `photo-{timestamp}-{sanitized-filename}`
- Documents: `doc-{timestamp}-{sanitized-filename}`

**Student Uploaded Documents (RFE):**
- Format: `{timestamp}_{sanitized-filename}`

## Database Schema

Documents metadata is stored in `applications.uploaded_documents` (JSONB):
```json
[
  {
    "key": "doc_0",
    "doc_name": "3X4 Photo",
    "filename": "my_photo.jpg",
    "path": "applications/ACNHS-2025-001/1736103613592_my_photo.jpg",
    "public_url": "https://.../application-documents/applications/ACNHS-2025-001/1736103613592_my_photo.jpg",
    "uploaded_at": "2026-01-11T07:56:13.592Z"
  }
]
```

## Testing Checklist

- [ ] Submit new application → files go to `application-documents/applications/ACNHS-xxxx/`
- [ ] Admin can view all documents in drawer
- [ ] Send RFE requesting documents
- [ ] Student uploads documents → files go to same folder
- [ ] Admin sees both original and uploaded docs together
- [ ] All "View" links work correctly

## Benefits

✅ **Single source of truth** - One bucket for all application documents
✅ **Consistent structure** - All files follow `applications/<reference>/` pattern  
✅ **Easier management** - Admins see all docs in one place
✅ **Better organization** - Clear separation by applicant reference number
✅ **Simpler backup** - One bucket to backup instead of multiple

## Rollback (If Needed)

To revert to old system:
1. Change `admission-form.html` line 2006: `'application-files'`
2. Change `application-status.html` student upload path back to: `${referenceNumber}/${timestamp}_${sanitized}`
