# 📋 Quick Reference: Portal Alerts System

## 🚀 Quick Start (3 Steps)

### 1. Run SQL
```sql
-- In Supabase SQL Editor, run:
-- File: CREATE-PORTAL-ALERTS-SYSTEM.sql
```

### 2. Access Admin UI
```
http://localhost:8000/alert.html
(Must be logged in as hrachfilm@gmail.com)
```

### 3. Add to Portal Pages
```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="js/supabase-config.js"></script>
<script src="js/alerts.js"></script>
```

---

## 📊 Database Tables

| Table | Purpose |
|-------|---------|
| `portal_alerts` | Main alerts (scheduling, targeting, content) |
| `portal_alert_templates` | Reusable alert templates |
| `portal_alert_impressions` | Tracks when alerts are shown |
| `portal_alert_responses` | Stores Yes/No answers |

---

## 🎯 Display Modes

| Mode | Shows Alert... |
|------|---------------|
| `once_ever` | Once, never again |
| `times_limit` | N times, then stops |
| `daily` | Once per day |
| `daily_first_login` | Once on first page load per day |
| `every_load` | Every single page load |

---

## 📅 Date Rules

| Rule | Example |
|------|---------|
| `always` | Show indefinitely |
| `date_range` | March 1 - March 31 |
| `monthly_range` | Every month, days 1-5 |
| `custom_dates` | March 1, March 15, April 1 |

---

## 🎨 Severity Levels

- **info** (blue) - General announcements
- **success** (green) - Achievements, good news
- **warn** (yellow) - Important reminders
- **critical** (red) - Urgent action required

---

## 🔧 Admin Actions

### Create Alert
1. Go to "Create Alert" tab
2. Fill form
3. Preview (optional)
4. Click "Create & Activate"

### View Analytics
1. "Manage Alerts" tab
2. Click 📊 icon
3. See views + responses

### Use Template
1. "Templates" tab
2. Click ✨ on any template
3. Customize and create

---

## 🐛 Quick Troubleshooting

### Alert not showing?
```javascript
// Check in browser console:
console.log(sessionStorage.getItem('studentData'));
window.ACNHSAlerts.checkNow();
```

### Check if alert is active:
```sql
SELECT id, title, is_active, target_type 
FROM portal_alerts 
WHERE is_active = true;
```

### Verify impressions:
```sql
SELECT COUNT(*) FROM portal_alert_impressions;
```

---

## 📁 Key Files

- `alert.html` - Admin dashboard
- `js/alerts.js` - Alert engine (auto-loads on pages)
- `CREATE-PORTAL-ALERTS-SYSTEM.sql` - Database schema
- `PORTAL-ALERTS-SETUP.md` - Full documentation

---

## 🎓 Common Examples

### Monthly Payment Reminder
- **Date Rule:** Monthly Range (1-5)
- **Display Mode:** Daily
- **Target:** All Students

### Orientation RSVP
- **Requires Response:** Yes
- **Display Mode:** Once Ever
- **Target:** Specific Students

### Emergency Announcement
- **Severity:** Critical
- **Display Mode:** Every Load
- **Target:** All Students

---

## 🔐 Security Notes

- Only admin (`hrachfilm@gmail.com`) can manage alerts
- Students can only insert their own impressions/responses
- Students can only see alerts targeted to them
- RLS enforced at database level

---

## ✅ System Status

**Current Version:** 1.0.0  
**Status:** Production Ready ✅  
**Prebuilt Templates:** 10  
**Database Tables:** 4  

---

**Need Help?** See `PORTAL-ALERTS-SETUP.md` for full documentation.
