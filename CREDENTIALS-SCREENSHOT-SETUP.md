# Credentials Screenshot Setup

## What This Does
This feature captures a screenshot of the credentials modal when applicants submit their application. The screenshot shows the exact username and password that was displayed to them, allowing admins to help users who lost their credentials.

## Setup Steps

### 1. Add Database Column
Run this SQL in your Supabase SQL Editor:

```sql
-- Run this in Supabase SQL Editor
-- File: ADD-CREDENTIALS-SCREENSHOT-COLUMN.sql

DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'applications' 
    AND column_name = 'credentials_screenshot'
  ) THEN
    ALTER TABLE applications 
    ADD COLUMN credentials_screenshot TEXT;
    
    RAISE NOTICE 'Added credentials_screenshot column';
  ELSE
    RAISE NOTICE 'credentials_screenshot column already exists';
  END IF;
END $$;
```

### 2. Test the Feature

1. **Submit a new application** through the admission form
2. When the credentials modal appears, the system will automatically capture a screenshot
3. The screenshot is saved to the database as base64 image data

### 3. View in Admin Panel

1. Open `admin-applications.html`
2. Click on any application to open the drawer
3. In the "🔐 Applicant Portal Access" section, you'll see:
   - The screenshot of the credentials modal (if available)
   - Username and password fields
   - Copy buttons for each credential
   - Download button for the screenshot

### 4. Features

- **View Full Size**: Click the screenshot to view it in full size
- **Download**: Click "💾 Download Screenshot" to save it as a PNG file
- **Copy Credentials**: Use the copy buttons to copy username/password
- **Portal Link**: Direct link to the student portal

## How It Works

1. When form is submitted → `showCredentialsModal()` is called
2. Modal displays credentials to user
3. After 500ms → `captureCredentialsScreenshot()` runs
4. html2canvas captures the modal content as an image
5. Image is converted to base64 and saved to database
6. Admin panel loads and displays the screenshot

## Notes

- Screenshot is stored as base64 TEXT in the database
- Only new applications (after this update) will have screenshots
- Existing applications will show username field but no screenshot
- The password shown is still hashed for security in text form
- The screenshot shows the ACTUAL plain-text password that was displayed to the user

## Security Considerations

⚠️ **Important**: The screenshot contains the plain-text password. Make sure:
- Only authorized admins can access the admin panel
- Supabase RLS policies are properly configured
- Admin access is properly authenticated
