# 📊 Portal Alerts System - Architecture & Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PORTAL ALERTS SYSTEM                      │
└─────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌──────────────────┐
│   ADMIN SIDE     │         │   STUDENT SIDE   │
└──────────────────┘         └──────────────────┘

     alert.html                 portal pages
         │                           │
         │                           │
         ├─── Create Alert          ├─── js/alerts.js
         ├─── Edit/Delete                  │
         ├─── View Analytics        ├─── Auto-detect student
         ├─── Use Templates         ├─── Fetch alerts
         └─── Preview               ├─── Check schedule rules
                                    ├─── Display modal
                                    └─── Track impressions/responses
         │                           │
         └───────────┬───────────────┘
                     │
                     ▼
            ┌─────────────────┐
            │   SUPABASE DB   │
            └─────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
  portal_alerts  impressions  responses
  templates
```

---

## Data Flow: Create Alert

```
┌──────────────┐
│ Admin Login  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ alert.html   │  1. Admin fills form
└──────┬───────┘     - Title, message
       │             - Targeting
       │             - Schedule rules
       │             - Response settings
       ▼
┌──────────────┐
│   Preview    │  2. Optional: Preview modal
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│ Create & Activate    │  3. Submit to Supabase
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│  portal_alerts table │  4. Alert stored
└──────────────────────┘
       │
       ▼
┌──────────────────────┐
│ Alert goes LIVE      │  5. Students start seeing it
└──────────────────────┘
```

---

## Data Flow: Student Views Alert

```
┌──────────────────┐
│ Student Portal   │
│   Page Load      │
└────────┬─────────┘
         │
         ▼
┌────────────────────┐
│  alerts.js Init    │  1. Engine starts
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│ Get Student Info   │  2. From sessionStorage
└────────┬───────────┘     or localStorage
         │
         ▼
┌────────────────────┐
│ Fetch Active       │  3. Query Supabase
│   Alerts           │     WHERE is_active = true
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│ Check Targeting    │  4. Is student targeted?
└────────┬───────────┘     - All students?
         │                 - In target_student_ids?
         ▼
┌────────────────────┐
│ Evaluate Schedule  │  5. Date/time rules
└────────┬───────────┘     - Date range OK?
         │                 - Monthly range OK?
         │                 - Custom date OK?
         ▼
┌────────────────────┐
│ Check Display Mode │  6. Should show now?
└────────┬───────────┘     - Once ever: Never shown?
         │                 - Daily: Not shown today?
         │                 - Times limit: < max?
         ▼
┌────────────────────┐
│   Show Modal!      │  7. Display alert
└────────┬───────────┘     Beautiful styled modal
         │
         ▼
┌────────────────────┐
│ Record Impression  │  8. Write to DB
└────────┬───────────┘     portal_alert_impressions
         │
         ▼
┌────────────────────┐
│ Student Interacts  │  9. Close or Answer
└────────┬───────────┘
         │
         ├─ Close ──────► Done
         │
         └─ Yes/No ─────► Record Response
                          portal_alert_responses
```

---

## Display Mode Logic

### Once Ever
```
First view:  ✅ Show
Second view: ❌ Don't show (already in impressions table)
```

### Daily
```
Day 1, View 1:  ✅ Show
Day 1, View 2:  ❌ Don't show (shown_date_local = today)
Day 2, View 1:  ✅ Show (new day)
```

### Times Limit (max = 3)
```
View 1: ✅ Show (impressions count = 1)
View 2: ✅ Show (impressions count = 2)
View 3: ✅ Show (impressions count = 3)
View 4: ❌ Don't show (reached max)
```

### Daily First Login
```
Day 1, Load 1:  ✅ Show (sessionStorage flag not set)
Day 1, Load 2:  ❌ Don't show (sessionStorage flag set)
Day 2, Load 1:  ✅ Show (new day, new session)
```

### Every Load
```
Load 1: ✅ Show
Load 2: ✅ Show
Load 3: ✅ Show
... (always shows)
```

---

## Date Rule Logic

### Always
```
Any date: ✅ Show
```

### Date Range
```
Alert: start_date = 2026-03-01, end_date = 2026-03-31

2026-02-28: ❌ Before start
2026-03-15: ✅ Within range
2026-04-01: ❌ After end
```

### Monthly Range
```
Alert: monthly_start_day = 1, monthly_end_day = 5

Day of month = 3:  ✅ Show (within 1-5)
Day of month = 10: ❌ Don't show (outside 1-5)
Day of month = 1:  ✅ Show (on boundary)
```

### Custom Dates
```
Alert: custom_dates = ["2026-03-01", "2026-03-15", "2026-04-01"]

2026-03-01: ✅ Show (in list)
2026-03-10: ❌ Don't show (not in list)
2026-03-15: ✅ Show (in list)
```

---

## Response Tracking Flow

```
┌────────────────────┐
│ Alert with         │
│ requires_response  │
│ = true             │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│ Check if student   │  Query portal_alert_responses
│ already responded  │  WHERE alert_id + student_id
└────────┬───────────┘
         │
         ├─ Yes ─────► ❌ Don't show (already answered)
         │
         └─ No ──────► ✅ Show with Yes/No buttons
                       │
                       ▼
                ┌──────────────┐
                │ Student clicks│
                │  Yes or No   │
                └──────┬───────┘
                       │
                       ▼
                ┌──────────────────────┐
                │ Write to             │
                │ portal_alert_        │
                │ responses            │
                └──────┬───────────────┘
                       │
                       ▼
                ┌──────────────────────┐
                │ Alert dismisses      │
                │ Never shows again    │
                └──────────────────────┘
```

---

## Analytics Flow

```
┌────────────────────┐
│ Admin clicks       │
│ Analytics (📊)     │
└────────┬───────────┘
         │
         ▼
┌────────────────────────────────┐
│ Query portal_alert_impressions │  Count total views
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Query portal_alert_responses   │  Get Yes/No breakdown
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Join with students table       │  Get student details
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Display Stats:                 │
│ - Total Views                  │
│ - Yes Count                    │
│ - No Count                     │
│ - Response Details Table       │
└────────────────────────────────┘
```

---

## Template System Flow

```
┌────────────────────┐
│ Admin uses         │
│ template           │
└────────┬───────────┘
         │
         ▼
┌────────────────────────────────┐
│ Query portal_alert_templates   │  Fetch template
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Pre-fill form with:            │
│ - Title                        │
│ - Message                      │
│ - Severity                     │
│ - Response settings            │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Admin customizes               │  Edit as needed
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Create alert                   │  Save to portal_alerts
└────────────────────────────────┘
```

---

## Security Layers

```
┌─────────────────────────────────────────────┐
│              SECURITY LAYERS                │
└─────────────────────────────────────────────┘

Layer 1: JavaScript Check (alert.html)
┌────────────────────────────────────┐
│ sessionStorage.isAdmin = 'true'    │  Frontend check
│ adminEmail = hrachfilm@gmail.com   │  Prevents UI access
└────────────────────────────────────┘

Layer 2: Row Level Security (RLS)
┌────────────────────────────────────┐
│ portal_alerts:                     │
│   - Admin: ALL operations          │
│   - Student: NO access             │
│                                    │
│ portal_alert_impressions:          │
│   - Admin: SELECT all              │
│   - Student: INSERT own only       │
│                                    │
│ portal_alert_responses:            │
│   - Admin: SELECT all              │
│   - Student: INSERT own only       │
└────────────────────────────────────┘

Layer 3: Database Constraints
┌────────────────────────────────────┐
│ - Foreign key checks               │
│ - Unique constraints               │
│ - Check constraints (severity)     │
│ - NOT NULL requirements            │
└────────────────────────────────────┘
```

---

## Performance Considerations

### Client-Side (alerts.js)
- Checks every 30 seconds for new alerts (configurable)
- Only fetches active alerts
- Caches student data in memory
- Shows max 1 alert at a time
- Debounces rapid checks

### Database Queries
- Indexed on: `is_active`, `target_type`, `alert_id`, `student_id`
- Uses JSONB for efficient array checks
- Unique constraints prevent duplicates
- Efficient date filtering

### Modal Rendering
- CSS injected once on page load
- Minimal DOM manipulation
- Smooth animations (300ms)
- No external dependencies (except Supabase)

---

## Scaling Considerations

### Current Capacity
- Handles 1000+ students easily
- Unlimited alerts
- Efficient impression tracking
- Fast analytics queries

### If You Grow Beyond 10,000 Students
- Add pagination to admin UI
- Add search/filter to student selector
- Consider archiving old impressions
- Add database query caching

---

## Integration Points

### Existing Systems
```
Student Portal Pages
        │
        ├─── alerts.js ──► Supabase
        │
        ├─── supabase-config.js ──► Configuration
        │
        └─── sessionStorage/localStorage ──► Student auth
```

### Future Integration Possibilities
- Email system (send email when alert created)
- SMS system (critical alerts via Twilio)
- Calendar integration (add event deadlines)
- Notification center (persistent alert history)
- Mobile app (push notifications)

---

## Maintenance Tasks

### Daily
- ✅ Automatic (none required)

### Weekly
- Review analytics for popular alerts
- Check response rates

### Monthly
- Archive old impressions (optional)
- Review template effectiveness
- Update seasonal alerts

### Yearly
- Database cleanup (old impressions)
- Review security policies
- Update templates

---

## Success Metrics

Track these to measure system effectiveness:

1. **Alert Views** - Are students seeing alerts?
2. **Response Rate** - Are they answering Yes/No questions?
3. **Time to Respond** - How quickly do they react?
4. **Completion Rate** - Do they read full message?
5. **Admin Usage** - How often creating alerts?

Query:
```sql
-- Get alert effectiveness
SELECT 
    a.title,
    COUNT(DISTINCT i.student_id) AS unique_views,
    COUNT(r.id) AS responses,
    ROUND(COUNT(r.id)::decimal / NULLIF(COUNT(DISTINCT i.student_id), 0) * 100, 2) AS response_rate
FROM portal_alerts a
LEFT JOIN portal_alert_impressions i ON a.id = i.alert_id
LEFT JOIN portal_alert_responses r ON a.id = r.alert_id
WHERE a.created_at > NOW() - INTERVAL '30 days'
GROUP BY a.id, a.title
ORDER BY unique_views DESC;
```

---

## Visual: Alert Lifecycle

```
  Created (inactive)
        │
        ▼
  Activated (is_active = true)
        │
        ├──► Shown to students
        │         │
        │         ├──► Impression recorded
        │         │
        │         └──► Response recorded (if required)
        │
        ├──► Deactivated (is_active = false)
        │         │
        │         └──► Stops showing (existing data preserved)
        │
        └──► Deleted
                  │
                  └──► Cascade deletes impressions + responses
```

---

## Complete System Map

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│  ADMIN                        STUDENT                    │
│                                                           │
│  ┌──────────┐                ┌──────────┐               │
│  │alert.html│◄───────────────┤ Login    │               │
│  └────┬─────┘  session        └──────────┘               │
│       │        check                                     │
│       │                        ┌──────────┐               │
│       │                        │Portal    │               │
│       │                        │Pages     │               │
│       │                        └────┬─────┘               │
│       │                             │                     │
│       │                        ┌────▼─────┐               │
│       │                        │alerts.js │               │
│       │                        └────┬─────┘               │
│       │                             │                     │
│       └─────────────┬───────────────┘                     │
│                     │                                     │
│              ┌──────▼──────┐                              │
│              │  SUPABASE   │                              │
│              └──────┬──────┘                              │
│                     │                                     │
│     ┌───────────────┼───────────────┐                     │
│     │               │               │                     │
│ ┌───▼────┐    ┌────▼─────┐   ┌────▼─────┐                │
│ │alerts  │    │templates │   │impressions│               │
│ │        │    │          │   │responses  │               │
│ └────────┘    └──────────┘   └──────────┘                │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

**System Ready for Production! 🚀**

All flows tested, all components integrated, all documentation complete.
