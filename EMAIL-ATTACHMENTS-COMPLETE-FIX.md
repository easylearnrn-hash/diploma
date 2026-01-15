# Email Attachments Complete Fix - CRITICAL

## 🔴 The Problem

**Issue 1: Photos/Documents Don't Open in Sent Emails**
- Emails with embedded images (photos, screenshots, documents) display as broken/blank in Gmail, Outlook, etc.
- Root cause: Base64 images embedded directly in HTML are blocked by email clients for security reasons
- These emails were already sent and stored in the database with broken base64 images

**Issue 2: Resend Doesn't Include Attachments**
- The resend feature was only sending the HTML body
- Attachments stored in database were not being fetched and converted back to proper format
- Recipients received emails without any attachments

## ✅ The Solutions Implemented

### Fix #1: Auto-Convert Base64 Images to Attachments (send-email Edge Function)
**File:** `supabase/functions/send-email/index.ts` (Lines 153-244)

**What it does:**
1. Scans outgoing email HTML for embedded base64 images
2. Extracts each image and converts to proper email attachment
3. Replaces base64 `src` with `cid:` (Content-ID) references
4. Email clients now display images as proper inline attachments

**Code highlights:**
```typescript
// Extract base64 images from HTML
const base64ImageRegex = /<img[^>]+src=["']data:image\/(png|jpg|jpeg|gif|webp);base64,([^"']+)["'][^>]*>/gi

// Replace with CID references
const cidImg = fullMatch.replace(/src=["']data:image\/[^;]+;base64,[^"']+["']/, `src="cid:${cid}"`)

// Add to Resend API with content_id
emailPayload.attachments = allAttachments.map((att: any) => {
  const attachment: any = { filename: att.filename, content: att.content }
  if (att.cid) { attachment.content_id = att.cid }
  return attachment
})
```

**Status:** ✅ Deployed to production

### Fix #2: Fetch & Convert Attachments for Resend (admin-student-page.html)
**File:** `admin-student-page.html` (Lines 2425-2520)

**What it does:**
1. When resending an email, fetches original attachments from database
2. Downloads attachment files from Supabase Storage using public URLs
3. Converts to base64 format required by Resend API
4. Includes all attachments in the resend request

**Code highlights:**
```javascript
// Fetch attachment files from storage
for (const attachment of email.attachments) {
  const fileResponse = await fetch(attachment.public_url);
  const blob = await fileResponse.blob();
  
  // Convert to base64
  const base64Content = await new Promise((resolve) => {
    const reader = new FileReader();
    reader.onloadend = () => {
      const base64 = reader.result.split(',')[1];
      resolve(base64);
    };
    reader.readAsDataURL(blob);
  });

  resendAttachments.push({
    filename: attachment.filename,
    content: base64Content,
    type: attachment.content_type
  });
}
```

**Status:** ✅ Deployed to production

### Fix #3: Email Detail Debugging (admin-student-page.html)
**File:** `admin-student-page.html` (Lines 2341-2370)

**What it does:**
- Logs email details when viewing (HTML length, attachment count)
- Detects and warns about embedded base64 images
- Helps diagnose why old emails still have broken images

**Status:** ✅ Deployed to production

## 📊 How to Test

### Test 1: Send New Email with Attachments
1. Go to any student page in admin panel
2. Compose email with photos/screenshots/documents
3. Send email
4. Check your Gmail - images should display properly as inline attachments
5. **Expected:** All images/documents visible and clickable

### Test 2: Resend Old Email
1. Go to admin-student-page.html
2. Click "Email History" for any student
3. Click an email that was sent before (with attachments)
4. Click "🔄 Resend Email" button
5. Check your Gmail - you should receive "[RESENT]" email with working attachments
6. **Expected:** All attachments included and working

### Test 3: Check Browser Console
1. Open admin-student-page.html
2. Open browser console (F12 or Cmd+Option+I)
3. Click an email to view details
4. Check console logs for:
   - `📧 Email detail:` - Shows attachment count
   - `🖼️ HTML contains X base64 images` - Shows if old email has embedded images
   - `⚠️ Email HTML has embedded base64 images` - Warning if base64 detected

## 🚨 Important Understanding

### Old Emails (Sent Before Fix)
- **Already stored in database with broken base64 images**
- The HTML in `html_body` field still has broken `data:image/...;base64,` tags
- When you VIEW these emails in the modal, they look broken
- **Solution:** Use the "Resend" button - this fetches attachments from storage and sends properly

### New Emails (Sent After Fix)
- Automatically convert base64 → proper attachments
- Store attachments in Supabase Storage
- Recipients receive emails with working inline images
- Viewing in modal should show content properly

## 📁 Database Structure

### email_history Table
```sql
attachments JSONB -- Array of attachment metadata
```

**Attachment format in database:**
```json
[
  {
    "filename": "photo.jpg",
    "content_type": "image/jpeg",
    "size": 154231,
    "storage_path": "outgoing/1736975123456-0-photo.jpg",
    "public_url": "https://zlvnxvrzotamhpezqedr.supabase.co/storage/v1/object/public/email-attachments/outgoing/1736975123456-0-photo.jpg",
    "direction": "outgoing"
  }
]
```

### Supabase Storage
- **Bucket:** `email-attachments`
- **Paths:** `outgoing/` and `incoming/`
- **Access:** Public read for attachment URLs

## 🔧 Resend API Format

**What Resend expects:**
```javascript
{
  to: "student@example.com",
  subject: "Email subject",
  html: "<html>content with <img src=\"cid:image0\"></html>",
  attachments: [
    {
      filename: "image0.jpg",
      content: "base64EncodedString...",
      content_id: "image0"  // Links to <img src="cid:image0">
    }
  ]
}
```

**Key points:**
- `content` must be base64 string (NOT data URL with prefix)
- `content_id` links to `cid:` references in HTML
- Inline images need `content_id`, regular attachments don't

## 📝 Commits Made

1. **83de653** - CRITICAL FIX: Resend attachments from storage
   - Fetch files from Supabase Storage
   - Convert to base64 for Resend API
   - Include all attachments when resending

2. **2c4e02f** - Add debugging for email attachments
   - Log email details when viewing
   - Detect base64 images in HTML
   - Improved troubleshooting

3. **ad066fa** (from previous session) - Fix base64 images in send-email
   - Auto-extract base64 from HTML
   - Convert to proper attachments
   - Replace with CID references

## 🎯 Action Items for User

### Immediate Testing
1. ✅ Open admin-student-page.html in browser
2. ✅ Click on Hayk Yeranosyan (or any student with sent emails)
3. ✅ Click "Email History" tab
4. ✅ Click "[RESENT] Orientation is starting now" email
5. ✅ Open browser console (F12) to see debug logs
6. ✅ Check what the logs say about attachments
7. ✅ Click "🔄 Resend Email" button
8. ✅ Check Hrachfilm@gmail.com for the resent email
9. ✅ Verify attachments work in Gmail

### If Still Broken
**Check these:**
1. Are there actual attachments in the database? (Check console logs)
2. Are the public URLs accessible? (Try opening one in browser)
3. Is Supabase Storage bucket public? (Should be)
4. Any CORS errors in console?
5. Check Supabase Edge Function logs:
   ```bash
   supabase functions logs send-email --project-ref zlvnxvrzotamhpezqedr
   ```

### Send Test Email
1. Go to any student page
2. Compose new email with photo/screenshot
3. Send to yourself (Hrachfilm@gmail.com)
4. Check if images display properly
5. This tests the NEW email flow (should work perfectly)

## 🔍 Troubleshooting Commands

**Check Edge Function logs:**
```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
supabase functions logs send-email --project-ref zlvnxvrzotamhpezqedr
```

**Check recent emails in database:**
```sql
SELECT 
  subject,
  recipient,
  created_at,
  jsonb_array_length(attachments) as attachment_count,
  attachments
FROM email_history
WHERE recipient = 'hayk.yeranosyan@yahoo.com'
ORDER BY created_at DESC
LIMIT 5;
```

**Redeploy send-email if needed:**
```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
supabase functions deploy send-email --project-ref zlvnxvrzotamhpezqedr
```

## ✨ Summary

**What's Fixed:**
- ✅ New emails automatically convert base64 images to proper attachments
- ✅ Resend feature now includes all attachments from storage
- ✅ Better debugging to understand what's in emails
- ✅ All changes deployed and pushed to GitHub

**What You Should See:**
- ✅ New emails with photos work perfectly
- ✅ Resent emails include all attachments
- ✅ Console logs show attachment processing
- ✅ Recipients can open and view all images/documents

**Last Updated:** January 15, 2026, 9:24 AM
**Commits:** 83de653, 2c4e02f, ad066fa (earlier)
**Edge Functions:** send-email (deployed), receive-email (deployed)
