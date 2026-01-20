# Armenian Citizenship & Immigration Status Fields - Setup Guide

## Overview
Added new fields to the admission form to collect Armenian citizenship status, US immigration status, and Armenia travel history.

## New Form Fields

### 1. Are you an Armenian citizen? (Required)
- **Type:** Radio buttons (Yes/No)
- **Field name:** `armenianCitizen`
- **Database column:** `armenian_citizen`
- **Location:** Personal Information section (after Place of Birth)

### 2. What is your US immigration status? (Optional)
- **Type:** Text input
- **Field name:** `usImmigrationStatus`
- **Database column:** `us_immigration_status`
- **Placeholder:** "e.g., US Citizen, Green Card Holder, Visa Type, N/A"

### 3. When was the last time you have been in Armenia? (Optional)
- **Type:** Text input
- **Field name:** `lastTimeInArmenia`
- **Database column:** `last_time_in_armenia`
- **Placeholder:** "e.g., December 2024, Never visited"

### 4. When did you move out from Armenia? (Optional)
- **Type:** Date input
- **Field name:** `armeniaExitDate`
- **Database column:** `armenia_exit_date`
- **Label:** "Exact date you left Armenia"

## Database Setup

### Step 1: Run the SQL Migration
Execute the following file in Supabase SQL Editor:
```
ADD-ARMENIAN-CITIZENSHIP-FIELDS.sql
```

This will add four new columns to the `applications` table:
- `armenian_citizen` (TEXT)
- `us_immigration_status` (TEXT)
- `last_time_in_armenia` (TEXT)
- `armenia_exit_date` (TEXT)

### Step 2: Verify Columns Were Added
Run this query in Supabase:
```sql
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'applications'
  AND column_name IN (
    'armenian_citizen',
    'us_immigration_status',
    'last_time_in_armenia',
    'armenia_exit_date'
  )
ORDER BY column_name;
```

Expected output: 4 rows showing the new columns.

## Code Changes Made

### 1. Admission Form HTML (`admission-form.html`)
**Location:** After "Place of Birth (City)" field in Section 1

- Added 4 new form fields with proper styling
- Armenian citizen field is **required** (radio buttons)
- Other 3 fields are **optional** (text/date inputs)

### 2. Data Collection (`gatherAdmissionData()` function)
Added data extraction for new fields:
```javascript
armenianCitizen: getValue('armenianCitizen') || '—',
usImmigrationStatus: getValue('usImmigrationStatus') || 'Not provided',
lastTimeInArmenia: getValue('lastTimeInArmenia') || 'Not provided',
armeniaExitDate: getValue('armeniaExitDate') || 'Not provided',
```

### 3. PDF Receipt Template
**New Section Added:** "CITIZENSHIP & IMMIGRATION"
- Displays all 4 new fields in a professional layout
- Located between "Applicant Summary" and "Contact & Address" sections
- Uses same styling as other sections for consistency

### 4. PDF Population (`populateAdmissionDocument()` function)
Added field mappings:
```javascript
'armenian-citizen': data.armenianCitizen,
'us-immigration-status': data.usImmigrationStatus,
'last-time-armenia': data.lastTimeInArmenia,
'armenia-exit-date': data.armeniaExitDate,
```

## Data Flow

1. **User fills form** → Radio button + 3 text/date inputs
2. **JavaScript collects data** → `gatherAdmissionData()` function
3. **Data sent to Supabase** → New columns in `applications` table
4. **PDF receipt generated** → New section shows citizenship/immigration data
5. **Admin views data** → Available in admin dashboard (if admin pages query these fields)

## Admin Dashboard Integration

### To Display These Fields in Admin Views:
Add the following to your admin application queries:

```javascript
const { data, error } = await supabase
  .from('applications')
  .select(`
    *,
    armenian_citizen,
    us_immigration_status,
    last_time_in_armenia,
    armenia_exit_date
  `);
```

### Example Admin Display:
```html
<div class="info-section">
  <h3>Citizenship & Immigration</h3>
  <p><strong>Armenian Citizen:</strong> ${app.armenian_citizen || 'Not specified'}</p>
  <p><strong>US Immigration Status:</strong> ${app.us_immigration_status || 'Not provided'}</p>
  <p><strong>Last Visit to Armenia:</strong> ${app.last_time_in_armenia || 'Not provided'}</p>
  <p><strong>Date Left Armenia:</strong> ${app.armenia_exit_date || 'Not provided'}</p>
</div>
```

## Testing Checklist

- [ ] Run `ADD-ARMENIAN-CITIZENSHIP-FIELDS.sql` in Supabase
- [ ] Verify columns exist in database
- [ ] Open `admission-form.html` in browser
- [ ] Check that new fields appear after "Place of Birth"
- [ ] Test form validation (Armenian citizen field is required)
- [ ] Submit a test application
- [ ] Verify data saves to database
- [ ] Check PDF receipt shows new "Citizenship & Immigration" section
- [ ] Verify admin dashboard displays new fields (if applicable)

## Notes

- **Armenian Citizen field is REQUIRED** - form won't submit without selecting Yes/No
- **Other 3 fields are OPTIONAL** - users can leave them blank
- **Date field** (`armeniaExitDate`) uses native HTML5 date picker
- **Default values:** Empty optional fields show "Not provided" or "—" in PDF
- **Backward compatibility:** Existing applications won't have these fields (will show NULL in database)

## Rollback Instructions

If you need to remove these fields:

1. Remove the HTML fields from `admission-form.html` (lines added in Section 1)
2. Remove from `gatherAdmissionData()` function
3. Remove from PDF template
4. Remove from `populateAdmissionDocument()` function
5. Optionally drop database columns:
```sql
ALTER TABLE applications DROP COLUMN IF EXISTS armenian_citizen;
ALTER TABLE applications DROP COLUMN IF EXISTS us_immigration_status;
ALTER TABLE applications DROP COLUMN IF EXISTS last_time_in_armenia;
ALTER TABLE applications DROP COLUMN IF EXISTS armenia_exit_date;
```

## Questions?

Contact the development team if you encounter issues with:
- Database column errors during form submission
- PDF not showing new section
- Admin dashboard not displaying new fields
