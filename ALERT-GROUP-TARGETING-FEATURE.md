# Group Targeting Feature - Portal Alerts

## Overview
Added ability to target alerts to specific student groups in addition to "All Students" or "Individual Students".

## Changes Made

### 1. Database Schema (`ADD-ALERT-GROUP-TARGETING.sql`)
**New column:** `target_group TEXT`

**Updated constraint:** `target_type` now accepts:
- `'all'` - All students
- `'group'` - Specific group
- `'individual'` - Individual students

**Available groups:**
- `group_a` - Group A
- `group_b` - Group B  
- `group_c` - Group C
- `enrolled` - Enrolled Students
- `pending` - Pending Applications
- `accepted` - Accepted (Not Enrolled)

### 2. Frontend Changes (`alert.html`)

#### Target Audience Selector
Updated dropdown to include:
```html
<option value="all">All Students</option>
<option value="group">By Group</option>
<option value="individual">Specific Students</option>
```

#### New Group Selector UI
Added dropdown that appears when "By Group" is selected:
```html
<select id="alert-group-selector">
  <option value="">Choose a group...</option>
  <option value="group_a">Group A</option>
  <option value="group_b">Group B</option>
  <option value="group_c">Group C</option>
  <option value="enrolled">Enrolled Students</option>
  <option value="pending">Pending Applications</option>
  <option value="accepted">Accepted (Not Enrolled)</option>
</select>
```

#### JavaScript Updates
1. **toggleStudentSelector()** - Now shows/hides both group and student selectors based on selection
2. **getFormData()** - Captures `target_group` value when group targeting is selected
3. **loadAlerts()** - Displays friendly group names in alerts list instead of raw values

### 3. Display Logic
When viewing alerts list, the "Target" column now shows:
- "All Students" for `target_type='all'`
- "Group A", "Group B", etc. for `target_type='group'`
- "5 Students" for `target_type='individual'`

## Migration Instructions

1. **Run the SQL migration:**
   ```sql
   -- In Supabase SQL Editor, run:
   /Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA/ADD-ALERT-GROUP-TARGETING.sql
   ```

2. **Verify the migration:**
   ```sql
   SELECT column_name, data_type 
   FROM information_schema.columns
   WHERE table_name = 'portal_alerts' 
   AND column_name IN ('target_type', 'target_group');
   ```

3. **Test the feature:**
   - Open `alert.html`
   - Click "➕ New Alert"
   - Select "By Group" in Target Audience
   - Choose a group from dropdown
   - Create alert and verify it saves correctly

## Alert Engine Compatibility

The `js/alerts.js` engine will need updating to:
1. Filter alerts by group when student belongs to that group
2. Query `students` table for group membership (if `enrollment_group` column exists)
3. Handle group-based targeting logic in `shouldShowAlert()` function

## Future Enhancements

- Dynamic group loading from `students` table
- Custom group creation/management
- Multi-group targeting (student can belong to multiple groups)
- Group-based analytics (show stats per group)

## Testing Checklist

- [ ] SQL migration runs without errors
- [ ] Group selector appears when "By Group" is selected
- [ ] Group selector hides when other options selected
- [ ] Alert saves with correct `target_group` value
- [ ] Alert list displays friendly group name
- [ ] Individual student selector still works
- [ ] "All Students" option still works

## Notes

- Groups are currently hardcoded in the UI
- Backend alert engine (`alerts.js`) needs updating to filter by group
- Consider adding `enrollment_group` column to `students` table for group membership tracking
