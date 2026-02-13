# Alert Rule Engine Upgrade - Implementation Guide

## Overview
Transform the basic alert system into an enterprise-grade targeting and scheduling engine with flexible JSON-based rules.

## Phase 1: Database Migration ✅

### Run This First
```sql
-- Execute in Supabase SQL Editor
UPGRADE-ALERTS-TO-RULE-ENGINE.sql
```

### New Schema Structure

**5 New JSON Columns:**
1. `targeting_rules` - Who sees the alert
2. `frequency_rules` - How often to show
3. `schedule_rules` - When to show (recurrence)
4. `trigger_rules` - What triggers display
5. `interaction_rules` - Response requirements

## Phase 2: Frontend UI (alert.html)

### Replace Simple Dropdowns with Rule Builders

#### 1. Targeting Builder (replaces "Target Audience")

```html
<div class="rule-builder" id="targeting-builder">
  <h4>🎯 Targeting Rules</h4>
  
  <!-- Basic Mode -->
  <div class="rule-section basic-mode">
    <label>Target</label>
    <select id="targeting-mode">
      <option value="all">All Students</option>
      <option value="include">Specific Students (Include)</option>
      <option value="exclude">All Except (Exclude)</option>
      <option value="complex">Advanced Targeting</option>
    </select>
  </div>

  <!-- Advanced Mode (hidden by default) -->
  <div class="rule-section advanced-mode" style="display:none;">
    <label>Include Students</label>
    <multi-select id="include-students"></multi-select>
    
    <label>Exclude Students (override)</label>
    <multi-select id="exclude-students"></multi-select>
    
    <label>Filter by Group</label>
    <checkbox-group id="target-groups">
      <input type="checkbox" value="group_a"> Group A
      <input type="checkbox" value="enrolled"> Enrolled
    </checkbox-group>
    
    <label>Filter by Status</label>
    <checkbox-group id="target-statuses">
      <input type="checkbox" value="active"> Active
      <input type="checkbox" value="paused"> Paused
    </checkbox-group>
    
    <label>Logic</label>
    <select id="targeting-logic">
      <option value="AND">Match ALL conditions (AND)</option>
      <option value="OR">Match ANY condition (OR)</option>
    </select>
  </div>
</div>
```

#### 2. Trigger Builder (replaces "Display Mode")

```html
<div class="rule-builder" id="trigger-builder">
  <h4>⚡ When to Show</h4>
  
  <label>Trigger Events</label>
  <checkbox-group id="trigger-when">
    <input type="checkbox" value="on_login" checked> On Login
    <input type="checkbox" value="on_page_load"> On Page Load
    <input type="checkbox" value="on_refresh"> On Refresh
    <input type="checkbox" value="every_page"> Every Page
  </checkbox-group>
  
  <label>Page Targeting</label>
  <select id="page-targeting-mode">
    <option value="all">All Pages</option>
    <option value="whitelist">Specific Pages Only</option>
    <option value="blacklist">All Pages Except</option>
  </select>
  
  <div id="page-list" style="display:none;">
    <input type="text" id="pages" placeholder="/student-portal.html, /grades.html">
  </div>
  
  <label>Time Window (optional)</label>
  <input type="time" id="time-start" placeholder="08:00">
  <span>to</span>
  <input type="time" id="time-end" placeholder="22:00">
</div>
```

#### 3. Frequency Builder

```html
<div class="rule-builder" id="frequency-builder">
  <h4>🔄 Frequency Cap</h4>
  
  <label>How Often to Show</label>
  <select id="frequency-cap-type">
    <option value="once_ever">Once Ever</option>
    <option value="times_limit">N Times Total</option>
    <option value="daily">Once Per Day</option>
    <option value="daily_first_login">Once Per Day (First Login)</option>
    <option value="weekly">Once Per Week</option>
    <option value="monthly">Once Per Month</option>
    <option value="cooldown">Every X Hours</option>
    <option value="until_response">Until Responded</option>
  </select>
  
  <div id="max-displays-input" style="display:none;">
    <label>Maximum Displays</label>
    <input type="number" id="max-displays" min="1" max="100">
  </div>
  
  <div id="cooldown-input" style="display:none;">
    <label>Cooldown (hours)</label>
    <input type="number" id="cooldown-hours" min="1" max="720">
  </div>
  
  <label>Stop Showing After</label>
  <input type="number" id="stop-after-days" placeholder="Optional: days">
  
  <checkbox id="stop-after-response">
    Stop showing after student responds
  </checkbox>
</div>
```

#### 4. Schedule Builder (recurrence)

```html
<div class="rule-builder" id="schedule-builder">
  <h4>📅 Schedule & Recurrence</h4>
  
  <label>Recurrence Type</label>
  <select id="recurrence-type">
    <option value="always">Always Active</option>
    <option value="one_time">One-Time Window</option>
    <option value="daily">Daily Recurrence</option>
    <option value="weekly">Weekly Recurrence</option>
    <option value="monthly">Monthly Recurrence</option>
    <option value="custom_dates">Custom Dates</option>
  </select>
  
  <!-- Start/End Dates -->
  <div class="date-range">
    <label>Start Date & Time</label>
    <input type="datetime-local" id="schedule-start">
    
    <label>End Date & Time (optional)</label>
    <input type="datetime-local" id="schedule-end">
  </div>
  
  <!-- Daily Pattern -->
  <div id="daily-pattern" style="display:none;">
    <label>Every</label>
    <input type="number" id="every-n-days" min="1" value="1">
    <span>day(s)</span>
  </div>
  
  <!-- Weekly Pattern -->
  <div id="weekly-pattern" style="display:none;">
    <label>Days of Week</label>
    <checkbox-group>
      <input type="checkbox" value="monday"> Mon
      <input type="checkbox" value="tuesday"> Tue
      <input type="checkbox" value="wednesday"> Wed
      <input type="checkbox" value="thursday"> Thu
      <input type="checkbox" value="friday"> Fri
      <input type="checkbox" value="saturday"> Sat
      <input type="checkbox" value="sunday"> Sun
    </checkbox-group>
    
    <label>Time Window</label>
    <input type="time" id="weekly-start"> to <input type="time" id="weekly-end">
  </div>
  
  <!-- Monthly Pattern -->
  <div id="monthly-pattern" style="display:none;">
    <label>Pattern Type</label>
    <select id="monthly-pattern-type">
      <option value="day_range">Day Range (e.g., 1-5)</option>
      <option value="nth_weekday">Nth Weekday (e.g., 1st Monday)</option>
    </select>
    
    <div id="day-range-inputs">
      <label>From Day</label>
      <input type="number" id="month-day-start" min="1" max="31">
      <label>To Day</label>
      <input type="number" id="month-day-end" min="1" max="31">
    </div>
    
    <div id="nth-weekday-inputs" style="display:none;">
      <select id="week-number">
        <option value="1">1st</option>
        <option value="2">2nd</option>
        <option value="3">3rd</option>
        <option value="4">4th</option>
        <option value="-1">Last</option>
      </select>
      <select id="weekday">
        <option value="monday">Monday</option>
        <option value="tuesday">Tuesday</option>
        <!-- ... -->
      </select>
    </div>
  </div>
  
  <!-- Custom Dates -->
  <div id="custom-dates-input" style="display:none;">
    <label>Specific Dates (comma-separated)</label>
    <input type="text" id="custom-dates" placeholder="2026-03-01, 2026-03-15">
  </div>
  
  <!-- Exclude Dates -->
  <label>Exclude Dates (optional)</label>
  <input type="text" id="exclude-dates" placeholder="Holidays, blackout dates">
  
  <label>Timezone</label>
  <select id="timezone">
    <option value="Asia/Yerevan">Armenia (Asia/Yerevan)</option>
    <option value="UTC">UTC</option>
    <!-- More timezones -->
  </select>
</div>
```

#### 5. Interaction Rules

```html
<div class="rule-builder" id="interaction-builder">
  <h4>💬 Interaction Rules</h4>
  
  <checkbox id="dismissible">
    <label>Allow dismissing without response</label>
  </checkbox>
  
  <checkbox id="required-response">
    <label>Require Yes/No response to dismiss</label>
  </checkbox>
  
  <div id="response-options" style="display:none;">
    <checkbox id="remind-on-no">
      Remind again if student answers "No"
    </checkbox>
    
    <label>Auto-dismiss after (seconds)</label>
    <input type="number" id="auto-dismiss" placeholder="Optional">
  </div>
</div>
```

### Basic/Advanced Toggle

```html
<div class="mode-toggle">
  <button id="basic-mode-btn" class="active">Basic Mode</button>
  <button id="advanced-mode-btn">Advanced Mode</button>
</div>
```

## Phase 3: JavaScript Rule Engine

### Data Structure Functions

```javascript
// Build targeting rules JSON
function getTargetingRules() {
  return {
    mode: document.getElementById('targeting-mode').value,
    include_students: getSelectedStudents('include-students'),
    exclude_students: getSelectedStudents('exclude-students'),
    groups: getCheckedValues('target-groups'),
    statuses: getCheckedValues('target-statuses'),
    tags: [], // Future feature
    logic: document.getElementById('targeting-logic').value
  };
}

// Build frequency rules JSON
function getFrequencyRules() {
  const capType = document.getElementById('frequency-cap-type').value;
  return {
    cap_type: capType,
    max_displays: capType === 'times_limit' ? parseInt(document.getElementById('max-displays').value) : null,
    cooldown_hours: capType === 'cooldown' ? parseInt(document.getElementById('cooldown-hours').value) : null,
    per_period: capType.includes('daily') ? 'day' : capType.includes('weekly') ? 'week' : null,
    stop_after_response: document.getElementById('stop-after-response').checked,
    stop_after_days: document.getElementById('stop-after-days').value || null
  };
}

// Build schedule rules JSON
function getScheduleRules() {
  const recurrenceType = document.getElementById('recurrence-type').value;
  const rules = {
    recurrence_type: recurrenceType,
    start_datetime: document.getElementById('schedule-start').value || null,
    end_datetime: document.getElementById('schedule-end').value || null,
    timezone: document.getElementById('timezone').value,
    daily_pattern: null,
    weekly_pattern: null,
    monthly_pattern: null,
    custom_dates: [],
    exclude_dates: parseCommaSeparatedDates('exclude-dates')
  };
  
  if (recurrenceType === 'daily') {
    rules.daily_pattern = {
      every_n_days: parseInt(document.getElementById('every-n-days').value)
    };
  } else if (recurrenceType === 'weekly') {
    rules.weekly_pattern = {
      days: getCheckedValues('weekly-days'),
      start_time: document.getElementById('weekly-start').value,
      end_time: document.getElementById('weekly-end').value
    };
  } else if (recurrenceType === 'monthly') {
    const patternType = document.getElementById('monthly-pattern-type').value;
    if (patternType === 'day_range') {
      rules.monthly_pattern = {
        day_range: [
          parseInt(document.getElementById('month-day-start').value),
          parseInt(document.getElementById('month-day-end').value)
        ]
      };
    } else {
      rules.monthly_pattern = {
        nth_weekday: {
          week: parseInt(document.getElementById('week-number').value),
          day: document.getElementById('weekday').value
        }
      };
    }
  } else if (recurrenceType === 'custom_dates') {
    rules.custom_dates = parseCommaSeparatedDates('custom-dates');
  }
  
  return rules;
}

// Build trigger rules JSON
function getTriggerRules() {
  const pageMode = document.getElementById('page-targeting-mode').value;
  const pages = document.getElementById('pages').value.split(',').map(p => p.trim()).filter(p => p);
  
  return {
    when: getCheckedValues('trigger-when'),
    pages_whitelist: pageMode === 'whitelist' ? pages : [],
    pages_blacklist: pageMode === 'blacklist' ? pages : [],
    time_window: {
      start: document.getElementById('time-start').value || null,
      end: document.getElementById('time-end').value || null
    }
  };
}

// Build interaction rules JSON
function getInteractionRules() {
  return {
    dismissible: document.getElementById('dismissible').checked,
    required_response: document.getElementById('required-response').checked,
    remind_on_no: document.getElementById('remind-on-no').checked,
    auto_dismiss_seconds: parseInt(document.getElementById('auto-dismiss').value) || null
  };
}

// Master function to build complete alert data
function getCompleteAlertData() {
  return {
    title: document.getElementById('alert-title').value,
    message_html: document.getElementById('alert-message').value,
    severity: document.getElementById('alert-severity').value,
    is_active: true,
    created_by: userEmail,
    targeting_rules: getTargetingRules(),
    frequency_rules: getFrequencyRules(),
    schedule_rules: getScheduleRules(),
    trigger_rules: getTriggerRules(),
    interaction_rules: getInteractionRules()
  };
}
```

### Human-Readable Summary Generator

```javascript
function generateRuleSummary(alertData) {
  let summary = [];
  
  // Targeting
  const target = alertData.targeting_rules;
  if (target.mode === 'all') {
    summary.push('Show to ALL students');
  } else if (target.mode === 'include') {
    summary.push(`Show to ${target.include_students.length} specific students`);
  } else if (target.mode === 'exclude') {
    summary.push(`Show to all EXCEPT ${target.exclude_students.length} students`);
  } else {
    const conditions = [];
    if (target.groups.length) conditions.push(`groups: ${target.groups.join(', ')}`);
    if (target.statuses.length) conditions.push(`statuses: ${target.statuses.join(', ')}`);
    summary.push(`Show to students matching ${target.logic}: ${conditions.join(' + ')}`);
  }
  
  // Trigger
  const triggers = alertData.trigger_rules.when.join(', ');
  summary.push(`on ${triggers}`);
  
  // Frequency
  const freq = alertData.frequency_rules;
  if (freq.cap_type === 'once_ever') {
    summary.push('once ever');
  } else if (freq.cap_type === 'daily') {
    summary.push('once per day');
  } else if (freq.cap_type === 'times_limit') {
    summary.push(`maximum ${freq.max_displays} times`);
  } else if (freq.cap_type === 'cooldown') {
    summary.push(`every ${freq.cooldown_hours} hours`);
  }
  
  // Schedule
  const sched = alertData.schedule_rules;
  if (sched.recurrence_type === 'always') {
    summary.push('always active');
  } else if (sched.recurrence_type === 'monthly' && sched.monthly_pattern?.day_range) {
    const [start, end] = sched.monthly_pattern.day_range;
    summary.push(`only days ${start}-${end} of each month`);
  }
  
  // Interaction
  if (alertData.interaction_rules.required_response) {
    summary.push('requires response to dismiss');
  }
  
  return summary.join(', ');
}
```

## Phase 4: Backend Alert Engine (js/alerts.js)

### Update shouldShowAlert() function

```javascript
async function shouldShowAlert(alert, student) {
  // 1. Check targeting rules
  if (!matchesTargetingRules(alert.targeting_rules, student)) {
    return false;
  }
  
  // 2. Check schedule rules
  if (!matchesScheduleRules(alert.schedule_rules)) {
    return false;
  }
  
  // 3. Check frequency rules
  if (!await matchesFrequencyRules(alert.frequency_rules, alert.id, student.id)) {
    return false;
  }
  
  // 4. Check trigger rules
  if (!matchesTriggerRules(alert.trigger_rules)) {
    return false;
  }
  
  return true;
}

function matchesTargetingRules(rules, student) {
  const { mode, include_students, exclude_students, groups, statuses, logic } = rules;
  
  // Exclusions override everything
  if (exclude_students.includes(student.id)) {
    return false;
  }
  
  if (mode === 'all') return true;
  if (mode === 'include') return include_students.includes(student.id);
  
  // Complex targeting with AND/OR logic
  const checks = [];
  if (groups.length) checks.push(groups.includes(student.enrollment_group));
  if (statuses.length) checks.push(statuses.includes(student.status));
  
  return logic === 'AND' ? checks.every(Boolean) : checks.some(Boolean);
}

function matchesScheduleRules(rules) {
  const now = new Date();
  const { recurrence_type, start_datetime, end_datetime, monthly_pattern, exclude_dates } = rules;
  
  // Check date exclusions
  const dateStr = now.toISOString().split('T')[0];
  if (exclude_dates.includes(dateStr)) return false;
  
  // Check start/end window
  if (start_datetime && now < new Date(start_datetime)) return false;
  if (end_datetime && now > new Date(end_datetime)) return false;
  
  if (recurrence_type === 'always') return true;
  
  if (recurrence_type === 'monthly' && monthly_pattern?.day_range) {
    const day = now.getDate();
    const [start, end] = monthly_pattern.day_range;
    return day >= start && day <= end;
  }
  
  // ... more recurrence logic
  return true;
}

async function matchesFrequencyRules(rules, alertId, studentId) {
  const { cap_type, max_displays, cooldown_hours, stop_after_response } = rules;
  
  // Get impression history
  const { data: impressions } = await supabase
    .from('portal_alert_impressions')
    .select('shown_at')
    .eq('alert_id', alertId)
    .eq('student_id', studentId)
    .order('shown_at', { ascending: false });
  
  if (cap_type === 'once_ever') {
    return !impressions || impressions.length === 0;
  }
  
  if (cap_type === 'times_limit') {
    return impressions.length < max_displays;
  }
  
  if (cap_type === 'cooldown') {
    if (!impressions || impressions.length === 0) return true;
    const lastShown = new Date(impressions[0].shown_at);
    const hoursSince = (Date.now() - lastShown) / (1000 * 60 * 60);
    return hoursSince >= cooldown_hours;
  }
  
  // ... more frequency logic
  return true;
}

function matchesTriggerRules(rules) {
  const currentPage = window.location.pathname;
  const { pages_whitelist, pages_blacklist, time_window } = rules;
  
  // Check page targeting
  if (pages_whitelist.length && !pages_whitelist.includes(currentPage)) {
    return false;
  }
  if (pages_blacklist.length && pages_blacklist.includes(currentPage)) {
    return false;
  }
  
  // Check time window
  if (time_window && time_window.start) {
    const now = new Date();
    const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    if (currentTime < time_window.start || currentTime > time_window.end) {
      return false;
    }
  }
  
  return true;
}
```

## Phase 5: UI/UX Enhancements

### Live Preview Summary Box

```html
<div class="rule-summary-box">
  <h4>📋 Rule Summary</h4>
  <p id="live-summary">Configure rules to see summary...</p>
</div>
```

### CSS for Rule Builders

```css
.rule-builder {
  background: rgba(45, 212, 191, 0.05);
  border: 1px solid rgba(45, 212, 191, 0.2);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
}

.rule-builder h4 {
  margin: 0 0 16px 0;
  color: var(--primary);
  font-size: 16px;
  font-weight: 600;
}

.rule-section {
  margin-bottom: 16px;
}

.advanced-mode {
  border-top: 1px solid rgba(148, 163, 184, 0.2);
  padding-top: 16px;
  margin-top: 16px;
}

.mode-toggle {
  display: flex;
  gap: 8px;
  margin-bottom: 20px;
}

.mode-toggle button {
  flex: 1;
  padding: 12px;
  background: rgba(148, 163, 184, 0.1);
  border: 1px solid rgba(148, 163, 184, 0.3);
  border-radius: 8px;
  color: var(--text);
  cursor: pointer;
  transition: all 0.2s;
}

.mode-toggle button.active {
  background: var(--primary);
  color: white;
  border-color: var(--primary);
}

.rule-summary-box {
  background: rgba(59, 130, 246, 0.1);
  border: 2px solid rgba(59, 130, 246, 0.3);
  border-radius: 12px;
  padding: 16px;
  margin-top: 20px;
}

.rule-summary-box h4 {
  margin: 0 0 8px 0;
  color: #3b82f6;
}

.rule-summary-box p {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
}
```

## Testing Checklist

### Database
- [ ] Run UPGRADE-ALERTS-TO-RULE-ENGINE.sql
- [ ] Verify 5 new JSON columns exist
- [ ] Check existing alerts migrated correctly
- [ ] Test validation trigger

### Frontend
- [ ] Basic mode shows simple dropdowns
- [ ] Advanced mode reveals rule builders
- [ ] All inputs capture correct values
- [ ] Live summary updates on change
- [ ] Variable buttons still work
- [ ] Preview shows sample data

### Backend
- [ ] shouldShowAlert() respects all rules
- [ ] Targeting logic works (include/exclude)
- [ ] Frequency caps prevent over-showing
- [ ] Schedule recurrence works correctly
- [ ] Monthly day-range tested (1-5)
- [ ] Page targeting filters properly

### Analytics
- [ ] View shows rule summaries
- [ ] Can filter by targeting mode
- [ ] Performance acceptable with indexes

## Migration Path

1. **Week 1:** Database migration + data verification
2. **Week 2:** Build new UI components (rule builders)
3. **Week 3:** Update JavaScript logic + alert engine
4. **Week 4:** Testing + refinement + documentation

## Future Enhancements

- Tags system for student segmentation
- A/B testing (show version A to 50%, version B to 50%)
- Priority/ordering (if multiple alerts, which shows first)
- Snooze functionality (remind me in X hours)
- Email/SMS fallback if not seen in portal
- Analytics dashboard with charts
- Template variables in rules (e.g., "Show 3 days before {due_date}")
