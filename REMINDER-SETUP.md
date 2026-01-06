# Setup Reminder Date Column

## Quick Setup (1 minute)

### Step 1: Add the Column
1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Go to **SQL Editor** → **New query**
3. Copy and paste content from `ADD-REMINDER-DATE-COLUMN.sql`
4. Click **Run**

### Step 2: Test It
1. Refresh your admin page
2. Set a reminder for today's date or a past date
3. **The row should immediately:**
   - Move to the top of the list
   - Highlight in light orange
   - Show a 🔔 bell icon

---

## How It Works

### Visual Indicators
- **🔔 Bell Icon**: Appears on rows with reminders due
- **Light Orange Background**: `rgba(251, 146, 60, 0.15)`
- **Orange Left Border**: `4px solid #fb923c`
- **Darker on Hover**: Enhanced visibility

### Sorting Logic
1. **Reminders due today or overdue** → Top of list
2. **Multiple reminders due** → Sorted by earliest date first
3. **No reminder** → Sorted by registration date (newest first)

### Reminder States
- **Due Today**: Shows at top with orange highlight
- **Overdue (past dates)**: Shows at top with orange highlight
- **Future dates**: Normal display, no highlight
- **No reminder**: Normal display

---

## Example

**If you set a reminder for:**
- `2026-01-05` (today) → Orange highlight, top position
- `2026-01-01` (past) → Orange highlight, top position
- `2026-02-01` (future) → Normal display, sorted normally

**Multiple reminders due:**
- Reminder for Jan 1 → Position #1
- Reminder for Jan 3 → Position #2
- Reminder for Jan 5 (today) → Position #3
- No reminder → Position #4+

---

## Database Changes

**New Column:** `reminder_date DATE`
- Stores the actual reminder date
- Indexed for fast sorting
- Nullable (can be empty)

**Before:** Reminder was just text in notes field
**After:** Reminder is proper date field that can be:
- Sorted
- Filtered
- Compared to today's date
- Highlighted when due

---

## Testing Checklist

✅ Set reminder for today → Row moves to top with orange highlight
✅ Set reminder for past date → Row moves to top with orange highlight
✅ Set reminder for future date → Row stays in normal position
✅ Refresh page → Highlighted rows stay highlighted
✅ Multiple reminders → Sorted by earliest first

All done! 🎉
