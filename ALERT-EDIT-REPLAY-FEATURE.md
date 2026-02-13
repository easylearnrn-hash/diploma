# Alert Edit & Replay Feature

## Overview
Added two powerful features to the Student Alert system:

1. **✏️ Edit Alert** - Modify existing alerts without creating new ones
2. **🔄 Replay Alert** - Clear impressions to show one-time alerts again

## Features Added

### 1. Edit Alert (✏️)
**Purpose:** Modify an existing alert's configuration

**How it works:**
- Click the **✏️ Edit** button on any alert in the Manage Alerts tab
- The Create Alert form loads with all existing values pre-filled
- Modify any fields (title, message, targeting, frequency, schedule)
- Click **💾 Update Alert** to save changes
- The alert is updated in the database (same ID, no new record)

**Use cases:**
- Fix typos in alert messages
- Adjust targeting rules (change which students see the alert)
- Modify schedule dates (extend or shorten alert window)
- Update frequency settings (change from one-time to recurring)
- Change severity level (info → critical)

**Technical details:**
- Form stores `dataset.editingAlertId` when editing
- Submit handler checks for this ID and does UPDATE instead of INSERT
- Button text changes from "🚀 Create Alert" to "💾 Update Alert"
- All form fields populated from database record
- After save, form resets and switches back to Manage tab

### 2. Replay Alert (🔄)
**Purpose:** Clear all impression records so alert shows again

**How it works:**
- Click the **🔄 Replay** button on any alert
- Confirmation dialog explains what will happen
- If confirmed:
  - Deletes ALL records from `portal_alert_impressions` for this alert
  - Reactivates the alert (sets `is_active = true`)
  - Refreshes alert list
- Students will see the alert again as if it's brand new

**Use cases:**
- Replay one-time alerts (e.g., payment reminders)
- Reset weekly alerts mid-week
- Clear testing impressions during development
- Re-broadcast important announcements
- Give students a second chance to respond

**Technical details:**
- Deletes from `portal_alert_impressions` WHERE `alert_id = ?`
- Updates `portal_alerts` SET `is_active = true`
- Does NOT modify alert configuration (title, message, rules)
- Students will see alert on next page load/login

## Button Layout
**Manage Alerts tab action buttons (left to right):**
1. 👁️ Preview - View alert preview with sample data
2. 📊 Analytics - View impressions and response data
3. **✏️ Edit** - Load alert into form for editing
4. **🔄 Replay** - Clear impressions and show again
5. ⏸️/▶️ Pause/Activate - Toggle active status
6. 🗑️ Delete - Permanently remove alert

## Database Impact

### Edit Alert
- **Table affected:** `portal_alerts`
- **Operation:** UPDATE
- **Records changed:** 1 (the specific alert)
- **Preserves:** Alert ID, creation date, impression history

### Replay Alert
- **Tables affected:** 
  - `portal_alert_impressions` (DELETE all for this alert)
  - `portal_alerts` (UPDATE is_active = true)
- **Records deleted:** All impressions for this alert
- **Preserves:** Alert configuration, response data (if any)

## User Experience

### Editing Flow
1. Admin sees alert needs changes
2. Clicks ✏️ Edit button
3. Form auto-fills with current values
4. Makes changes
5. Clicks "💾 Update Alert"
6. Success notification: "Alert updated successfully!"
7. Returns to Manage tab with updated alert

### Replay Flow
1. Admin wants to re-show one-time alert
2. Clicks 🔄 Replay button
3. Confirms: "Clear all impression records?"
4. Success notification: "Alert impressions cleared! Alert will show to all students again."
5. Students see alert on next login

## Security Notes
- Only admin users can access alert.html
- Edit maintains original `created_by` field
- Replay preserves all alert configuration
- No student-facing impact (students just see alerts)

## Testing Checklist
- [x] Edit button loads form with correct data
- [x] Editing updates existing record (no duplicate)
- [x] Replay clears impressions successfully
- [x] Alert shows to students after replay
- [x] Button styling (btn-info class added)
- [x] Functions exposed to global scope
- [x] Confirmation dialogs work correctly
- [x] Success notifications display

## Files Modified
- `alert.html` - Added edit/replay buttons, functions, and CSS

## CSS Added
```css
.btn-info {
  background: rgba(59, 130, 246, 0.2);
  color: var(--info);
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.btn-info:hover {
  background: rgba(59, 130, 246, 0.3);
}
```

## Functions Added
- `editAlert(alertId)` - Load alert data into form for editing
- `replayAlert(alertId)` - Clear impressions and reactivate
- Modified `createAlert()` - Check for edit mode, UPDATE vs INSERT

## Example Scenarios

### Scenario 1: Edit Payment Reminder Message
**Problem:** Payment deadline changed from Feb 15 to Feb 20

**Solution:**
1. Go to Manage Alerts tab
2. Find "Payment Reminder" alert
3. Click ✏️ Edit button
4. Change message: "February 15" → "February 20"
5. Click 💾 Update Alert
6. ✅ All future impressions show new date

### Scenario 2: Replay One-Time Alert
**Problem:** "Enrollment Opens" alert was one-time, some students missed it

**Solution:**
1. Go to Manage Alerts tab
2. Find "Enrollment Opens" alert (inactive, impressions exist)
3. Click 🔄 Replay button
4. Confirm: "Yes, show again to all students"
5. ✅ Alert resets - all students see it again on next login

### Scenario 3: Fix Targeting Error
**Problem:** Alert targeted "Group A" but should be "All Students"

**Solution:**
1. Go to Manage Alerts tab
2. Find alert with wrong targeting
3. Click ✏️ Edit button
4. Change targeting from "Group A" to "All Students"
5. Click 💾 Update Alert
6. Click 🔄 Replay to clear old impressions
7. ✅ Alert now shows to all students (not just Group A)

## Benefits
1. **No duplicate alerts** - Edit existing instead of create new
2. **Preserve analytics** - Keep impression history while editing
3. **Flexible replays** - Re-show important alerts easily
4. **Better workflow** - Quick fixes without deleting and recreating
5. **Testing friendly** - Clear test impressions without affecting config

## Future Enhancements
- Bulk replay (clear impressions for multiple alerts)
- Edit history/audit log (track who changed what)
- Schedule replay (auto-clear impressions on specific date)
- Conditional replay (only clear for specific students)
