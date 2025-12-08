# Shepherd - Technical Specification Document
**Pastoral Assistant Application**

Version 1.0  
Date: December 10, 2024  
Author: Ruben (Product Owner)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Product Overview](#product-overview)
3. [Technical Architecture](#technical-architecture)
4. [Data Model](#data-model)
5. [Feature Specifications](#feature-specifications)
6. [UI/UX Specifications](#ui-ux-specifications)
7. [Algorithm Specifications](#algorithm-specifications)
8. [Offline Functionality](#offline-functionality)
9. [Notifications](#notifications)
10. [Performance Requirements](#performance-requirements)
11. [Development Roadmap](#development-roadmap)
12. [Testing Strategy](#testing-strategy)

---

## Executive Summary

### Product Vision
Shepherd is a mobile-first pastoral assistant app that helps solo pastors manage the administrative side of ministry. It combines calendar, tasks, pastoral care tracking, and sermon management into a single intelligent dashboard that suggests what to do and when to do it.

### Core Problem
Solo pastors juggle multiple responsibilities (sermon prep, pastoral care, admin work, personal life) without administrative support. Existing productivity apps don't understand pastoral work and require constant context switching between separate tools.

### Solution
A rule-based intelligent assistant that:
- Synthesizes calendar, tasks, and pastoral care into one view
- Suggests what to do based on available time and priorities
- Tracks pastoral care frequency automatically
- Warns about overload and conflicts
- Learns user patterns over time

### Target User
Solo pastors at small-to-medium churches (50-200 members) who:
- Preach regularly (weekly or bi-weekly)
- Handle pastoral care personally
- Have limited or no administrative staff
- Need mobile access on-the-go

### Success Metrics
- Daily active usage (pastor checks dashboard every morning)
- Time saved vs. multiple separate apps
- Pastoral care contact frequency improved
- Overload situations detected and prevented
- Sermon preparation kept on track

---

## Product Overview

### Key Features

**1. Smart Dashboard**
- Daily/weekly/monthly views
- Rule-based suggestions (what to do now)
- Available time block calculations
- Crisis mode for overload situations
- Pattern insights from learning algorithm

**2. Task Management**
- Create/edit/complete tasks with time estimates
- Categorize by ministry area (sermon prep, pastoral care, admin, personal)
- Link tasks to people, events, or sermons
- Time tracking (estimated vs. actual)
- Rich text descriptions

**3. Calendar**
- Standard calendar views (month/week/day)
- Event types (service, meeting, pastoral visit, blocked time, etc.)
- Travel time calculation
- Preparation task linkage
- Load indicators (color-coded by daily intensity)

**4. People Management**
- Contact database with categories (elder, member, visitor, etc.)
- Automatic pastoral care tracking (last contact date)
- Contact frequency thresholds (configurable per category)
- Contact logging (calls, visits, emails)
- Tags for flexible organization
- Milestone tracking (birthdays, surgeries, etc.)

**5. Sermon Management**
- Sermon series organization
- Individual sermon details with flexible templating
- Scripture reference tracking
- Prep progress tracking (hours logged vs. target)
- Rich text editor for outlines/notes
- Practice mode (full-screen with timer)

**6. Notes**
- Quick capture notes with rich text
- Link to people, tasks, events, or sermons
- Tags for organization
- Full-text search

**7. Quick Capture**
- Fast entry from persistent bottom nav button
- Type selection (task/event/note/contact log)
- Context-aware forms with smart defaults
- Voice input support

**8. Pattern Learning**
- Activity logging (task completion times, user behaviors)
- Pattern detection (productive hours, batching preferences)
- Insight generation with confidence scores
- Adaptive suggestions based on learned patterns

### User Personas

**Primary: Solo Pastor (Ruben)**
- Age: 29
- Church: 50-100 members, classical/nondenominational
- Schedule: Butcher shop mornings (7am-12pm), wrestling training (4:15-5:45am)
- Responsibilities: Preaching, pastoral care, worship oversight, admin
- Pain points: Scattered systems, context switching, difficult workload balance
- Technical comfort: High (IT background, developer)

**Secondary: Small Church Pastor**
- Age: 35-55
- Church: Similar size and structure
- Less technical comfort
- Similar juggling of responsibilities
- May have part-time administrative help

---

## Technical Architecture

### Technology Stack

**Frontend: Flutter**
- Cross-platform (iOS/Android) from single codebase
- Native performance
- Rich UI capabilities
- Offline-first architecture support

**Backend: Supabase**
- PostgreSQL database
- Row-level security (RLS)
- Real-time subscriptions
- Edge Functions (Deno/TypeScript)
- Authentication
- Storage for attachments

**Local Storage: SQLite (via Drift or Hive)**
- Complete offline functionality
- Mirrors Supabase schema
- Sync queue management

**State Management: Riverpod (recommended) or Provider**
- Reactive state updates
- Dependency injection
- Testing support

### Architecture Pattern

**Offline-First Hybrid Architecture**

```
┌─────────────────────────────────────────────┐
│           Flutter Application               │
│  ┌───────────────────────────────────────┐  │
│  │         Presentation Layer            │  │
│  │  (Widgets, Screens, UI Components)    │  │
│  └───────────────┬───────────────────────┘  │
│                  │                           │
│  ┌───────────────▼───────────────────────┐  │
│  │         Business Logic Layer          │  │
│  │     (Rule Engine, Scoring, State)     │  │
│  └───────────────┬───────────────────────┘  │
│                  │                           │
│  ┌───────────────▼───────────────────────┐  │
│  │          Data Layer                   │  │
│  │  ┌────────────────┐  ┌──────────────┐ │  │
│  │  │ Local Database │  │  Sync Queue  │ │  │
│  │  │    (SQLite)    │  │              │ │  │
│  │  └────────┬───────┘  └──────┬───────┘ │  │
│  └───────────┼──────────────────┼─────────┘  │
└──────────────┼──────────────────┼────────────┘
               │                  │
               │   ┌──────────────▼───────────┐
               └───►    Sync Engine           │
                   │  (Conflict Resolution)   │
                   └──────────┬───────────────┘
                              │
               ┌──────────────▼───────────────┐
               │        Supabase Backend      │
               │  ┌─────────────────────────┐ │
               │  │   PostgreSQL Database   │ │
               │  └─────────────────────────┘ │
               │  ┌─────────────────────────┐ │
               │  │     Edge Functions      │ │
               │  │  (Rule Evaluation,      │ │
               │  │   Pattern Analysis)     │ │
               │  └─────────────────────────┘ │
               │  ┌─────────────────────────┐ │
               │  │    Authentication       │ │
               │  └─────────────────────────┘ │
               └──────────────────────────────┘
```

**Key Architectural Principles:**

1. **Offline-First**: All operations work locally, sync in background
2. **Single Source of Truth**: Supabase is canonical, local is cache
3. **Optimistic Updates**: UI updates immediately, syncs asynchronously
4. **Automatic Conflict Resolution**: Merge non-conflicting changes, prompt for conflicts
5. **Rule Engine on Edge**: Complex calculations run server-side for consistency

### Data Flow

**Read Operations:**
```
User opens dashboard
  → Check local cache (< 5 min old?)
    → Yes: Show cached data immediately
         → Refresh in background
    → No: Fetch from Supabase
         → Update local cache
         → Display data
```

**Write Operations:**
```
User creates task
  → Generate UUID locally
  → Insert into local SQLite
  → Update UI immediately (optimistic)
  → Add to sync queue
  → Sync engine sends to Supabase (background)
    → Success: Mark synced
    → Failure: Retry with exponential backoff
```

**Dashboard Generation:**
```
User opens dashboard
  → Load local data (calendar, tasks, people, settings)
  → Call Edge Function: generate_daily_smart_view
    → Run 5 rule categories
    → Score all suggestions
    → Return prioritized list
  → Display suggestions with actions
  → Cache result (5 minutes)
```

### Network Strategy

**Sync Frequency:**
- Every 15 minutes when app active and online
- Immediately on app open
- Immediately on network reconnect
- After major changes (opportunistic)

**Connectivity Detection:**
- Monitor network state changes
- Adjust behavior based on connection quality:
  - Strong WiFi: Aggressive sync, downloads, pattern analysis
  - Weak WiFi/Strong Cellular: Standard sync
  - Weak Cellular: Minimal sync (critical only)
  - Offline: Queue everything

**Cellular Data:**
- Sync over cellular by default
- User can configure WiFi-only
- Show data usage warnings

---

## Data Model

### Database Schema

All tables include standard audit fields unless noted:
- `id` (UUID primary key, generated client-side)
- `created_at` (timestamp with timezone)
- `updated_at` (timestamp with timezone)

#### Core Tables

**users**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  church_name TEXT,
  timezone TEXT DEFAULT 'America/Chicago',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**user_settings**
```sql
CREATE TABLE user_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Contact frequency defaults (days)
  elder_contact_frequency_days INTEGER DEFAULT 30,
  member_contact_frequency_days INTEGER DEFAULT 90,
  crisis_contact_frequency_days INTEGER DEFAULT 3,
  
  -- Sermon prep
  weekly_sermon_prep_hours INTEGER DEFAULT 8,
  
  -- Workload
  max_daily_hours INTEGER DEFAULT 10,
  min_focus_block_minutes INTEGER DEFAULT 120,
  
  -- Focus time preferences
  preferred_focus_hours_start TIME DEFAULT '12:00',
  preferred_focus_hours_end TIME DEFAULT '17:00',
  
  -- Notification preferences (JSONB)
  notification_preferences JSONB DEFAULT '{}',
  
  -- Offline data scope
  offline_cache_days INTEGER DEFAULT 90,
  
  -- Archive settings
  auto_archive_enabled BOOLEAN DEFAULT TRUE,
  archive_tasks_after_days INTEGER DEFAULT 90,
  archive_events_after_days INTEGER DEFAULT 365,
  archive_logs_after_days INTEGER DEFAULT 730,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id)
);
```

**tasks**
```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  title TEXT NOT NULL,
  description TEXT,
  
  due_date DATE,
  due_time TIME,
  
  estimated_duration_minutes INTEGER,
  actual_duration_minutes INTEGER,
  
  category TEXT NOT NULL CHECK (category IN (
    'sermon_prep', 'pastoral_care', 'admin', 
    'personal', 'worship_planning'
  )),
  
  priority TEXT DEFAULT 'medium' CHECK (priority IN (
    'low', 'medium', 'high', 'urgent'
  )),
  
  status TEXT DEFAULT 'not_started' CHECK (status IN (
    'not_started', 'in_progress', 'done', 'deleted'
  )),
  
  requires_focus BOOLEAN DEFAULT FALSE,
  energy_level TEXT DEFAULT 'medium' CHECK (energy_level IN (
    'low', 'medium', 'high'
  )),
  
  -- Relationships
  person_id UUID REFERENCES people(id) ON DELETE SET NULL,
  calendar_event_id UUID REFERENCES calendar_events(id) ON DELETE SET NULL,
  sermon_id UUID REFERENCES sermons(id) ON DELETE SET NULL,
  parent_task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  
  completed_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_tasks_user_status_due ON tasks(user_id, status, due_date);
CREATE INDEX idx_tasks_user_category ON tasks(user_id, category);
CREATE INDEX idx_tasks_person ON tasks(person_id);
CREATE INDEX idx_tasks_sermon ON tasks(sermon_id);
CREATE INDEX idx_tasks_event ON tasks(calendar_event_id);
CREATE INDEX idx_tasks_title_gin ON tasks USING gin(to_tsvector('english', title));
```

**calendar_events**
```sql
CREATE TABLE calendar_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  
  start_datetime TIMESTAMPTZ NOT NULL,
  end_datetime TIMESTAMPTZ NOT NULL,
  
  event_type TEXT NOT NULL CHECK (event_type IN (
    'service', 'meeting', 'pastoral_visit', 'personal', 
    'work', 'family', 'blocked_time'
  )),
  
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_pattern JSONB,
  
  travel_time_minutes INTEGER,
  
  energy_drain TEXT DEFAULT 'medium' CHECK (energy_drain IN (
    'low', 'medium', 'high'
  )),
  
  is_moveable BOOLEAN DEFAULT TRUE,
  
  requires_preparation BOOLEAN DEFAULT FALSE,
  preparation_buffer_hours INTEGER,
  
  person_id UUID REFERENCES people(id) ON DELETE SET NULL,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_calendar_user_date ON calendar_events(user_id, start_datetime);
CREATE INDEX idx_calendar_person ON calendar_events(person_id);
```

**people**
```sql
CREATE TABLE people (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  
  category TEXT NOT NULL CHECK (category IN (
    'elder', 'member', 'visitor', 'leadership', 
    'crisis', 'family', 'other'
  )),
  
  household_id UUID REFERENCES households(id) ON DELETE SET NULL,
  
  last_contact_date DATE,
  contact_frequency_override_days INTEGER,
  
  notes TEXT,
  tags TEXT[] DEFAULT '{}',
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_people_user_category ON people(user_id, category);
CREATE INDEX idx_people_last_contact ON people(user_id, last_contact_date);
CREATE INDEX idx_people_name_gin ON people USING gin(to_tsvector('english', name));
CREATE INDEX idx_people_tags ON people USING gin(tags);
```

**households**
```sql
CREATE TABLE households (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  name TEXT NOT NULL,
  address TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**people_milestones**
```sql
CREATE TABLE people_milestones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  person_id UUID REFERENCES people(id) ON DELETE CASCADE,
  
  milestone_type TEXT NOT NULL CHECK (milestone_type IN (
    'birthday', 'anniversary', 'surgery', 'other'
  )),
  
  date DATE NOT NULL,
  description TEXT,
  notify_days_before INTEGER DEFAULT 2,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**contact_log**
```sql
CREATE TABLE contact_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  person_id UUID REFERENCES people(id) ON DELETE CASCADE,
  
  contact_date DATE NOT NULL,
  contact_type TEXT NOT NULL CHECK (contact_type IN (
    'visit', 'call', 'email', 'text', 'in_person', 'other'
  )),
  
  duration_minutes INTEGER,
  notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_contact_log_person ON contact_log(person_id);
CREATE INDEX idx_contact_log_date ON contact_log(user_id, contact_date DESC);

-- Trigger to update people.last_contact_date
CREATE OR REPLACE FUNCTION update_last_contact_date()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE people 
  SET last_contact_date = NEW.contact_date
  WHERE id = NEW.person_id 
    AND (last_contact_date IS NULL OR last_contact_date < NEW.contact_date);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER contact_log_update_last_contact
AFTER INSERT ON contact_log
FOR EACH ROW
EXECUTE FUNCTION update_last_contact_date();
```

**sermon_series**
```sql
CREATE TABLE sermon_series (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  title TEXT NOT NULL,
  description TEXT,
  
  start_date DATE,
  end_date DATE,
  
  target_weekly_prep_hours INTEGER,
  
  status TEXT DEFAULT 'planning' CHECK (status IN (
    'planning', 'active', 'completed'
  )),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX idx_series_user_status ON sermon_series(user_id, status);
```

**sermons**
```sql
CREATE TABLE sermons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  series_id UUID REFERENCES sermon_series(id) ON DELETE SET NULL,
  
  title TEXT NOT NULL,
  preaching_date DATE,
  
  scripture_references JSONB DEFAULT '[]',
  
  -- Flexible content area (rich text)
  content TEXT,
  
  status TEXT DEFAULT 'idea' CHECK (status IN (
    'idea', 'researching', 'outlining', 
    'drafting', 'practicing', 'ready', 'preached'
  )),
  
  prep_hours_logged DECIMAL(5,2) DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_sermons_user_date ON sermons(user_id, preaching_date DESC);
CREATE INDEX idx_sermons_series ON sermons(series_id);
CREATE INDEX idx_sermons_content_gin ON sermons USING gin(to_tsvector('english', title || ' ' || coalesce(content, '')));
```

**sermon_practice_runs**
```sql
CREATE TABLE sermon_practice_runs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sermon_id UUID REFERENCES sermons(id) ON DELETE CASCADE,
  
  run_number INTEGER NOT NULL,
  duration_seconds INTEGER NOT NULL,
  notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**notes**
```sql
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  title TEXT,
  content TEXT NOT NULL,
  
  person_id UUID REFERENCES people(id) ON DELETE SET NULL,
  task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
  calendar_event_id UUID REFERENCES calendar_events(id) ON DELETE SET NULL,
  sermon_id UUID REFERENCES sermons(id) ON DELETE SET NULL,
  
  tags TEXT[] DEFAULT '{}',
  is_pinned BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_notes_user_created ON notes(user_id, created_at DESC);
CREATE INDEX idx_notes_tags ON notes USING gin(tags);
```

**activity_log**
```sql
CREATE TABLE activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'task_completed', 'task_created', 'task_moved',
    'event_completed', 'event_created', 'event_moved',
    'contact_logged', 'app_opened', 'dashboard_viewed'
  )),
  
  activity_data JSONB NOT NULL,
  
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Index for pattern analysis
CREATE INDEX idx_activity_log_user_type_time ON activity_log(user_id, activity_type, timestamp DESC);
```

**user_insights**
```sql
CREATE TABLE user_insights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  insight_type TEXT NOT NULL CHECK (insight_type IN (
    'pattern_discovered', 'efficiency_warning', 
    'schedule_optimization', 'pastoral_care_insight',
    'workflow_suggestion'
  )),
  
  insight_data JSONB NOT NULL,
  confidence DECIMAL(3,2) CHECK (confidence BETWEEN 0 AND 1),
  
  is_dismissed BOOLEAN DEFAULT FALSE,
  is_applied BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX idx_insights_user_active ON user_insights(user_id, is_dismissed, created_at DESC);
```

**user_schedule_preferences**
```sql
CREATE TABLE user_schedule_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  preference_type TEXT NOT NULL,
  preference_value JSONB NOT NULL,
  
  is_manual BOOLEAN DEFAULT TRUE,
  confidence DECIMAL(3,2),
  
  last_updated TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, preference_type)
);
```

**daily_reviews**
```sql
CREATE TABLE daily_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  review_date DATE NOT NULL,
  completed_at TIMESTAMPTZ,
  
  task_accuracy_data JSONB,
  event_reflections JSONB,
  notes TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, review_date)
);
```

**memory_user_edits**
```sql
CREATE TABLE memory_user_edits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  line_number INTEGER NOT NULL,
  control_text TEXT NOT NULL CHECK (length(control_text) <= 500),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, line_number)
);
```

#### Archive Tables

**tasks_archive**, **calendar_events_archive**, **contact_log_archive**
- Same schema as primary tables
- Plus `archived_at TIMESTAMPTZ DEFAULT NOW()`
- Data moved here after retention period
- Still searchable, but not loaded by default

### Row Level Security (RLS)

All tables use RLS to ensure users only access their own data:

```sql
-- Example for tasks table
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tasks"
  ON tasks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks"
  ON tasks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks"
  ON tasks FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks"
  ON tasks FOR DELETE
  USING (auth.uid() = user_id);
```

Similar policies apply to all user-owned tables.

### Relationships Summary

```
users (1) ←→ (many) tasks, calendar_events, people, sermons, notes
people (1) ←→ (many) contact_log, tasks, calendar_events, notes
people (many) ←→ (1) households
sermons (many) ←→ (1) sermon_series
sermons (1) ←→ (many) tasks, notes, sermon_practice_runs
tasks (many) ←→ (1) person, calendar_event, sermon, parent_task
```

---

## Feature Specifications

### 1. Smart Dashboard

#### Overview
The dashboard is the primary interface - a synergistic view that combines calendar, tasks, and pastoral care into intelligent suggestions.

#### Views

**Daily View** (Default)
- Shows: Today's schedule + next 24 hours
- Fixed commitments in chronological order
- Available time blocks calculated
- Smart suggestions (max 5)
- Warnings (max 3)
- Tomorrow preview

**Weekly View**
- Shows: Current week (Monday-Sunday)
- Daily load distribution (visual bar chart or heatmap)
- Week-level warnings (sermon prep behind, overbooked days)
- Major deadlines highlighted
- Pattern insights (clustering, imbalance)

**Monthly View**
- Shows: Calendar grid with event count indicators
- Color-coded by daily load:
  - No circle: 0 items
  - Yellow ①-②: 1-2 items (light)
  - Orange ③-④: 3-4 items (medium)
  - Red ⑤+: 5+ items (heavy)
- Tap day to see detail
- Major milestones labeled

#### Smart Suggestions

Each suggestion includes:
- Icon indicating type (task, pastoral care, etc.)
- Title/description
- Context (why suggested now)
- Time estimate if task
- Priority indicator (color/badge)
- Action buttons (2-3 max)

**Example Suggestions:**

```
⚡ Finish sermon outline (2 hrs)
   Fits your 12-2:30pm block perfectly
   Due tomorrow - high priority
   
   [Start Task] [Reschedule] [Dismiss]

📞 Contact Elder John (15 min)
   Last contact: 35 days ago (5 days overdue)
   Quick call during lunch break
   
   [Call Now] [Create Task] [Log Contact] [Dismiss]

📋 Review notes: Thompson visit
   Visit in 2 hours - 5 min prep
   
   [View Notes] [Mark Done] [Dismiss]
```

#### Warnings

```
🔴 CRITICAL
   Sermon outline due in 3 hours - still 40% incomplete
   [Continue Work] [Request Help]

🟠 WARNING
   Tomorrow: 11 hours scheduled, 8 hours available
   Recommend rescheduling items
   [Fix Schedule] [View Tomorrow]

🟡 NOTICE
   You haven't contacted any elders this week
   3 elders now overdue for check-in
   [View Elders] [Dismiss]
```

#### Crisis Mode

Triggered when:
- Total critical tasks > available time × 1.5
- 3+ consecutive overload days
- Critical deadline <24hrs with <40% completion
- 5+ items scored 90+ simultaneously

Display changes:
- Red banner: "⚠️ CRISIS MODE ACTIVE"
- Triage sections:
  - "Cannot Defer" (must do today)
  - "Can Defer" (important but moveable)
  - "Need External Help" (delegation suggestions)
- One-tap defer actions
- Reschedule assistance
- Recovery planning suggestions

#### Algorithm Insights Button

- Floating action button or prominent card
- Badge indicates new insights
- Opens insights view showing:
  - Pattern discoveries
  - Efficiency warnings
  - Schedule optimizations
  - Pastoral care insights
  - Workflow suggestions
- Each insight has:
  - Description with data/evidence
  - Confidence level
  - Action buttons (apply, dismiss, learn more)

### 2. Task Management

#### Task List View

**Grouping:**
- OVERDUE (red)
- TODAY (high priority)
- THIS WEEK (default expanded)
- NO DUE DATE (collapsed)
- COMPLETED (last 7 days, collapsed)

**Filters/Views:**
- Today
- This Week
- By Category
- By Person
- By Priority
- All

**Sort Options:**
- Due date (default)
- Priority
- Category
- Created date

**Quick Actions (inline):**
- Checkbox to complete
- Star to toggle priority
- Three-dot menu (edit, delete, reschedule)

#### Task Detail/Edit

**Fields:**
- Title (required)
- Description (rich text)
- Due date & time
- Estimated duration
- Category (dropdown)
- Priority (low/medium/high/urgent)
- Status (not_started/in_progress/done)
- Requires focus (checkbox)
- Energy level (low/medium/high)
- Related to: Person, Event, Sermon (optional links)
- Subtasks (list)

**Time Tracking:**
- Start/stop timer button
- Displays elapsed time
- Logs actual duration on completion
- End-of-day review prompts accuracy feedback

**Actions:**
- Save
- Mark Complete
- Delete
- Duplicate
- Convert to recurring

#### Task Creation (Quick Capture)

Optimized form:
1. Title (auto-focus)
2. Due date/time (smart defaults)
3. Estimated time (quick select: 15/30/60/120 min)
4. Category (suggested based on title/context)
5. Optional: Link to person/event/sermon

Voice input option for title and description.

### 3. Calendar Management

#### Month View

Grid calendar with:
- Current day highlighted
- Event count indicators (colored circles with numbers)
- Color intensity by load (yellow→orange→red)
- Tap day to see events
- Swipe to change month

#### Week View

Horizontal layout showing 7 days:
- Time blocks for each day
- Events as colored blocks
- Load bar at bottom showing hours scheduled
- Visual indicators for overloaded days
- Scroll horizontally for other weeks

#### Day View

Vertical hourly view:
- Events as time blocks
- Available time blocks shown as empty
- Travel time indicators between events
- Scroll vertically through 24 hours

#### Event Detail/Edit

**Fields:**
- Title (required)
- Description
- Start date/time (required)
- End date/time (required)
- Location
- Event type (dropdown)
- Recurring pattern (if applicable)
- Travel time (minutes)
- Energy drain (low/medium/high)
- Is moveable (checkbox)
- Requires preparation (checkbox)
  - If yes: Preparation buffer (hours before)
- Related person

**Actions:**
- Save
- Delete
- Duplicate
- Mark complete (shows reflection prompt)

#### Event Reflection (after completion)

Prompt appears:
```
How did it go?
[Good] [Difficult] [Needs Follow-up]

Optional notes:
[Text area]

[Save] [Skip]
```

Feeds learning algorithm for energy drain patterns.

### 4. People Management

#### People List View

**Grouping:**
- NEEDS ATTENTION (overdue contacts, red)
- UP TO DATE (green)
- RECENTLY ADDED

**Filters:**
- All
- Elders
- Members
- Visitors
- Leadership
- Crisis
- Custom tags

**Sort:**
- Last contact (default)
- Alphabetical
- Category
- Upcoming milestones

**Display per person:**
- Name
- Category badge
- Last contact date
- Days since contact
- Overdue indicator (if applicable)
- Quick actions: Call, Log Contact, View Details

#### Person Detail

**Information:**
- Name, email, phone
- Category
- Household (if grouped)
- Tags (editable)
- Last contact date
- Target frequency
- Next recommended contact date
- Upcoming milestones

**Contact History:**
- Timeline of all logged contacts
- Type, date, notes preview
- Tap to expand full notes

**Related Items:**
- Tasks linked to this person
- Events (pastoral visits, meetings)
- Notes

**Quick Actions:**
- Call (opens phone)
- Email (opens email client)
- Text (opens messages)
- Log Contact (opens log form)
- Create Task
- Add Note

#### Contact Logging

Quick form:
```
Contact Type: [Call] [Visit] [Email] [Text] [In Person]
Date: [Date picker, defaults to today]
Duration: [Optional, minutes]
Notes: [Text area]

☑ Mark related tasks complete
☑ Create follow-up task
   Due: [Date picker, suggests based on frequency]

[Save]
```

Auto-updates last_contact_date on save.

#### Milestone Tracking

Add milestones:
- Type: Birthday, Anniversary, Surgery, Other
- Date
- Description
- Notify X days before

Shows on dashboard when approaching.

### 5. Sermon Management

#### Sermon List View

**Grouping:**
- ACTIVE SERIES (expanded)
  - Shows next sermon in series
  - Progress indicator
- UPCOMING SERMONS (next 4 weeks)
- PAST SERMONS (collapsed, searchable)

**Series View:**
- Series title and date range
- Progress bar (sermons preached / total)
- List of sermons in series
- Series stats (avg prep time, total hours)

**Individual Sermon Card:**
- Title and scripture
- Preaching date
- Status badge
- Prep progress bar
- Hours logged vs. target
- Quick actions: Continue, View Details

#### Sermon Detail/Edit

**Fixed Fields:**
- Title (required)
- Preaching date
- Series (dropdown, optional)
- Scripture references (add multiple)
- Status (dropdown)

**Flexible Content Area:**
- Rich text editor
- User creates own structure
- Common sections user might include:
  - Fallen Condition Focus
  - Main Point
  - Outline (with sub-points)
  - Illustrations
  - Application points
  - Research notes

**Prep Progress:**
- Visual progress bar
- Breakdown by stage:
  - Research (hours logged)
  - Outline (status)
  - Draft (status)
  - Practice (number of runs)
- Manual stage marking

**Related Items:**
- Tasks linked to this sermon
- Notes
- Practice runs

**Actions:**
- Save
- Practice Mode
- View Tasks
- Delete

#### Practice Mode

Full-screen view:
- Sermon outline (large, readable text)
- Timer controls:
  - Start/Stop/Reset
  - Current run time display
  - Target time indicator
- Previous run times listed
- Swipe/scroll to navigate outline
- Exit button

Saves practice run with duration on completion.

#### Series Management

Create/edit series:
- Title
- Description
- Start/end dates
- Target weekly prep hours
- Status (planning/active/completed)

View series:
- Timeline of sermons
- Overall progress
- Stats (avg time per sermon, total hours)
- Add sermon to series

### 6. Notes

#### Notes List

**Grouping:**
- Recent (last 30 days)
- Pinned (always at top)
- Archive (collapsed)

**Filters:**
- All
- People
- Sermons
- Events
- Tasks
- Unlinked
- By tag

**Sort:**
- Created date (default)
- Updated date
- Title

**Display per note:**
- Title (or first line if no title)
- Linked items icons
- Tags
- Preview (first 50 chars)
- Created date

#### Note Detail/Edit

**Fields:**
- Title (optional)
- Content (rich text, required)
- Linked to: (optional)
  - Person (dropdown)
  - Task (dropdown)
  - Event (dropdown)
  - Sermon (dropdown)
- Tags (multi-select or create new)
- Pin (checkbox)

**Actions:**
- Save
- Pin/Unpin
- Share (export as text/markdown)
- Delete

#### Quick Note Capture

Minimal form:
- Content (focus immediately)
- Optional: Quick link to person/sermon
- Voice input supported

Fast save, detailed editing later.

### 7. Quick Capture

Persistent button in bottom navigation (far right, + icon).

**Flow:**

Step 1: Type selection (large tappable cards)
```
[Task] [Event] [Note] [Contact Log]
```

Step 2: Context-aware form

**Task:**
- Title
- Due date/time
- Estimated time (quick select)
- Related to (optional)
- Category (auto-suggested)

**Event:**
- Title
- Date/time
- Duration
- Type
- Related person (optional)

**Note:**
- Content (voice input available)
- Link to (optional)

**Contact Log:**
- Person (searchable dropdown)
- Type (call/visit/email/text)
- Date (default today)
- Notes (optional)

All forms have:
- Smart defaults
- Voice input (where applicable)
- Save button
- Cancel button

### 8. Settings

**Personal Schedule:**
- Wrestling training time
- Work shift time
- Family protected time
- Preferred focus hours

**Contact Thresholds:**
- Elder frequency (days)
- Member frequency
- Crisis frequency
- Visitor frequency
- Custom categories (add new)

**Sermon Prep:**
- Weekly target hours
- Default prep stages
- Deadline warning threshold

**Workload Management:**
- Max daily hours
- Min focus block duration
- Overload warning threshold

**Learning & Insights:**
- Enable/disable pattern learning
- What to track (checkboxes)
- View learning data
- Clear learning history

**Notifications:**
- Master enable/disable
- Delivery times (morning/evening)
- Quiet hours
- Blocked times (auto-quiet)
- Per-type configuration
- Frequency limits
- Vacation mode

**Sync & Offline:**
- Auto-sync enabled
- Sync frequency
- Sync over cellular
- Offline cache duration (30/90/365/all days)
- Manual sync trigger
- View sync status

**Data Management:**
- Current storage usage
- Auto-archive settings
- Manual archive/cleanup
- View archived data
- Export all data
- Delete account

**About:**
- App version
- Give feedback
- Privacy policy
- Terms of service
- Help/documentation

### 9. Search

Global search accessible from:
- Side drawer
- Search icon in app bar (context-dependent)

**Features:**
- Searches across: Tasks, Events, People, Sermons, Notes
- Results grouped by type
- Relevance ranking
- Recent searches saved
- Search debouncing (300ms)

**Search query handling:**
```dart
void onSearchChanged(String query) {
  _searchDebounce?.cancel();
  _searchDebounce = Timer(Duration(milliseconds: 300), () {
    performSearch(query);
  });
}
```

**Results display:**
```
TASKS (3)
- Finish sermon outline
- Call Elder John
- Review Thompson notes

PEOPLE (2)
- John Miller
- Sarah Thompson

SERMONS (1)
- Hebrews 6:11-12 - Perseverance

[View All Results]
```

Tap any result to navigate to detail view.

---

## UI/UX Specifications

### Design System

**Typography:**
- Headlines: SF Pro Display / Roboto (system defaults)
- Body: SF Pro Text / Roboto
- Sizes: 
  - H1: 28pt
  - H2: 22pt
  - H3: 18pt
  - Body: 16pt
  - Caption: 14pt
  - Small: 12pt

**Colors:**

Primary palette:
- Primary: `#2563EB` (blue)
- Primary Light: `#60A5FA`
- Primary Dark: `#1E40AF`

Status colors:
- Success: `#10B981` (green)
- Warning: `#F59E0B` (orange)
- Error: `#EF4444` (red)
- Info: `#3B82F6` (blue)

Load indicators:
- Light: `#FCD34D` (yellow)
- Medium: `#FB923C` (orange)
- Heavy: `#EF4444` (red)

Neutrals:
- Background: `#F9FAFB`
- Surface: `#FFFFFF`
- Border: `#E5E7EB`
- Text Primary: `#111827`
- Text Secondary: `#6B7280`
- Text Tertiary: `#9CA3AF`

**Spacing:**
- Base unit: 4px
- Common: 8px, 12px, 16px, 24px, 32px, 48px

**Corner Radius:**
- Small: 4px (buttons, inputs)
- Medium: 8px (cards)
- Large: 12px (modals)
- Full: 999px (pills, badges)

**Shadows:**
```css
elevation-1: 0 1px 3px rgba(0,0,0,0.1)
elevation-2: 0 4px 6px rgba(0,0,0,0.1)
elevation-3: 0 10px 15px rgba(0,0,0,0.1)
```

### Navigation Structure

**Bottom Navigation (Always visible):**
```
┌────────────────────────────────────────────┐
│  [Daily] [Weekly] [Monthly]          [+]  │
└────────────────────────────────────────────┘
```

4 items:
1. Daily View (home icon)
2. Weekly View (week icon)
3. Monthly View (calendar icon)
4. Quick Capture (+ icon)

Active state: Primary color fill, inactive: gray

**Side Drawer (Hamburger top-right):**
```
┌─────────────────────┐
│ Shepherd           │
│ Ruben              │
├─────────────────────┤
│ 📋 Tasks           │
│ 📅 Calendar        │
│ 👥 People          │
│ 📖 Sermons         │
│ 📝 Notes           │
│ 🔍 Search          │
├─────────────────────┤
│ ⚙️ Settings        │
│ 💡 Insights        │
└─────────────────────┘
```

**App Bar (Top):**
- Varies by screen
- Typically: Back button (if nested), Title, Hamburger menu
- Some screens add: Search icon, Filter icon, etc.

### Screen Layouts

**Dashboard (Daily/Weekly/Monthly):**

Daily View wireframe:
```
┌─────────────────────────────────────┐
│ [☰] Today - Dec 10        [💡]     │
├─────────────────────────────────────┤
│ ⚡ 4 hours available                │
│                                     │
│ FIXED COMMITMENTS                   │
│ ┌─────────────────────────────────┐ │
│ │ 🏋️ 4:15am Wrestling            │ │
│ │ 🥩 7:00am Butcher Shop         │ │
│ │ 📅 2:30pm Thompson Visit       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ SMART SUGGESTIONS                   │
│ ┌─────────────────────────────────┐ │
│ │ 🔴 Finish sermon outline        │ │
│ │    Fits 12-2:30pm block         │ │
│ │    [Start] [Reschedule]         │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 📞 Contact Elder John           │ │
│ │    5 days overdue               │ │
│ │    [Call] [Create Task]         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ TOMORROW PREVIEW                    │
│ Wednesday: 5 tasks, 2 events       │
│                                     │
└─────────────────────────────────────┘
│  [Daily] [Weekly] [Monthly]    [+] │
└─────────────────────────────────────┘
```

**Task List:**
```
┌─────────────────────────────────────┐
│ [←] Tasks                    [+]   │
├─────────────────────────────────────┤
│ [Today] [Week] [Category] [All]    │
├─────────────────────────────────────┤
│ OVERDUE (2)                        │
│ ┌─────────────────────────────────┐ │
│ │ ⚠️ Review sermon outline        │ │
│ │    Due: Yesterday | 2 hrs       │ │
│ │    [☐] [⋮]                      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ TODAY (4)                          │
│ ┌─────────────────────────────────┐ │
│ │ ✍️ Finish intro                 │ │
│ │    Due: 3pm | 1 hr              │ │
│ │    [☐] [⋮]                      │ │
│ └─────────────────────────────────┘ │
│ ...                                 │
└─────────────────────────────────────┘
```

**Calendar Month:**
```
┌─────────────────────────────────────┐
│ [←] Calendar              [+]      │
├─────────────────────────────────────┤
│        December 2024                │
│ [<]                          [>]   │
├─────────────────────────────────────┤
│ Mo  Tu  We  Th  Fr  Sa  Su        │
│     26  27  28  29  30   1        │
│  2   3   4   5   6   7   8        │
│      🟡  🔴  🟡  🟠       🔴       │
│      ②   ⑤   ①   ③       ⑦        │
│  9  10  11  12  13  14  15        │
│ ...                                 │
└─────────────────────────────────────┘
```

**People List:**
```
┌─────────────────────────────────────┐
│ [←] People                   [+]   │
├─────────────────────────────────────┤
│ 🔍 Search people...                │
├─────────────────────────────────────┤
│ [All] [Elders] [Members] [Crisis]  │
├─────────────────────────────────────┤
│ NEEDS ATTENTION (3)                │
│ ┌─────────────────────────────────┐ │
│ │ ⚠️ John Miller [Elder]          │ │
│ │    35 days since contact        │ │
│ │    [📞] [📝]                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ UP TO DATE                         │
│ ┌─────────────────────────────────┐ │
│ │ ✓ David Chen [Elder]            │ │
│ │    12 days ago                  │ │
│ └─────────────────────────────────┘ │
│ ...                                 │
└─────────────────────────────────────┘
```

### Interaction Patterns

**Buttons:**

Primary button (main action):
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Start Task'),
)
```

Secondary button (alternative action):
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: primaryColor),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
  child: Text('Reschedule'),
)
```

Tertiary button (dismiss/cancel):
```dart
TextButton(
  child: Text('Dismiss'),
)
```

**Cards:**

Standard card with shadow:
```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: ...
  ),
)
```

**Input Fields:**
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Task Title',
    hintText: 'Enter task description',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    prefixIcon: Icon(Icons.task),
  ),
)
```

**Loading States:**

Skeleton screens while loading:
```dart
Shimmer.fromColors(
  baseColor: Colors.grey[300],
  highlightColor: Colors.grey[100],
  child: Container(...),
)
```

Or circular progress indicator:
```dart
Center(
  child: CircularProgressIndicator(),
)
```

**Empty States:**

Encouraging message with action:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('No tasks yet'),
      SizedBox(height: 8),
      Text('Create your first task to get started'),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () => openQuickCapture(),
        child: Text('Add Task'),
      ),
    ],
  ),
)
```

**Error States:**

User-friendly message with retry:
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.error_outline, size: 64, color: Colors.red),
      SizedBox(height: 16),
      Text('Oops! Something went wrong'),
      SizedBox(height: 8),
      Text('Unable to load dashboard'),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () => retry(),
        child: Text('Try Again'),
      ),
    ],
  ),
)
```

**Snackbars (Success/Error feedback):**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Task completed!'),
    backgroundColor: Colors.green,
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () => undoComplete(),
    ),
  ),
);
```

**Dialogs (Confirmations):**
```dart
AlertDialog(
  title: Text('Delete Task?'),
  content: Text('This cannot be undone.'),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel'),
    ),
    TextButton(
      onPressed: () {
        deleteTask();
        Navigator.pop(context);
      },
      child: Text('Delete', style: TextStyle(color: Colors.red)),
    ),
  ],
)
```

**Bottom Sheets (Quick actions):**
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        leading: Icon(Icons.edit),
        title: Text('Edit'),
        onTap: () => edit(),
      ),
      ListTile(
        leading: Icon(Icons.share),
        title: Text('Share'),
        onTap: () => share(),
      ),
      ListTile(
        leading: Icon(Icons.delete),
        title: Text('Delete'),
        onTap: () => delete(),
      ),
    ],
  ),
);
```

### Animations & Transitions

**Page transitions:**
```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NewPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(opacity: animation, child: child);
  },
  transitionDuration: Duration(milliseconds: 200),
)
```

**List item animations (when adding/removing):**
```dart
AnimatedList(
  initialItemCount: items.length,
  itemBuilder: (context, index, animation) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: Offset(1, 0), end: Offset.zero),
      ),
      child: ItemCard(item: items[index]),
    );
  },
)
```

**Loading skeleton shimmer effect**
**Smooth scroll physics**
**Haptic feedback on important actions (task complete, etc.)**

### Accessibility

**Requirements:**
- All interactive elements minimum 44×44 pt touch target
- Color contrast ratio ≥ 4.5:1 for text
- Screen reader support (Semantics widget)
- Dynamic text sizing support
- Keyboard navigation support (if applicable)
- Voice Over / TalkBack tested

**Example:**
```dart
Semantics(
  label: 'Complete task: Finish sermon outline',
  button: true,
  child: IconButton(
    icon: Icon(Icons.check_circle_outline),
    onPressed: () => completeTask(),
  ),
)
```

### Responsive Design

**Mobile-first approach**

Breakpoints (if tablet support added later):
- Phone: < 600dp width
- Tablet: 600-900dp width (consider split view)
- Desktop: > 900dp (future consideration)

Current focus: Phone optimization (portrait and landscape)

Landscape considerations:
- Maintain single-column layout (avoid cramming)
- Use extra width for breathing room, not more columns
- Keep navigation accessible

---

## Algorithm Specifications

### Rule Engine Architecture

The rule engine is the intelligence layer that generates dashboard suggestions. It runs server-side in a Supabase Edge Function.

#### Edge Function: `generate_daily_smart_view`

**Input:**
```typescript
interface DashboardRequest {
  userId: string;
  date: string; // ISO date (YYYY-MM-DD)
  timeHorizon: 'day' | 'week' | 'month';
}
```

**Output:**
```typescript
interface DashboardResponse {
  availableBlocks: TimeBlock[];
  suggestions: Suggestion[];
  warnings: Warning[];
  insights: Insight[];
  crisisMode: boolean;
}

interface TimeBlock {
  start: string; // ISO datetime
  end: string;
  durationMinutes: number;
  type: 'focus' | 'available' | 'fragmented';
}

interface Suggestion {
  id: string;
  type: 'task' | 'pastoral_care' | 'event_prep' | 'workflow';
  title: string;
  description: string;
  score: number; // 0-100
  urgency: number; // 0-100
  fit: number; // 0-100
  impact: number; // 0-100
  consequence: number; // 0-100
  actions: Action[];
  metadata: any; // Task/person/event details
}

interface Action {
  label: string;
  type: 'primary' | 'secondary' | 'dismiss';
  action: string; // Action identifier for client
  params?: any;
}

interface Warning {
  id: string;
  severity: 'critical' | 'high' | 'medium';
  title: string;
  description: string;
  actions: Action[];
}

interface Insight {
  id: string;
  type: 'pattern' | 'efficiency' | 'optimization';
  title: string;
  description: string;
  confidence: number; // 0-1
  data: any;
  actions: Action[];
}
```

**Algorithm Flow:**

```typescript
async function generateDailySmartView(req: DashboardRequest): Promise<DashboardResponse> {
  // 1. Load relevant data (optimized queries)
  const [tasks, events, people, settings] = await Promise.all([
    loadRelevantTasks(req.userId, req.date),
    loadTodayEvents(req.userId, req.date),
    loadPastoralCareNeeds(req.userId, req.date),
    loadUserSettings(req.userId)
  ]);
  
  // 2. Calculate available time blocks
  const availableBlocks = calculateAvailableBlocks(events, req.date);
  
  // 3. Run all rule categories
  const [
    taskSuggestions,
    pastoralCareSuggestions,
    eventPrepSuggestions,
    deadlineSuggestions,
    workloadWarnings
  ] = await Promise.all([
    evaluateTaskSchedulingRules(tasks, availableBlocks, settings),
    evaluateContactFrequencyRules(people, settings),
    evaluateEventPrepRules(events, tasks),
    evaluateDeadlineRules(tasks, events),
    evaluateWorkloadBalanceRules(events, tasks, settings)
  ]);
  
  // 4. Combine and score suggestions
  const allSuggestions = [
    ...taskSuggestions,
    ...pastoralCareSuggestions,
    ...eventPrepSuggestions,
    ...deadlineSuggestions
  ];
  
  const scoredSuggestions = scoreAndRankSuggestions(allSuggestions, settings);
  
  // 5. Filter and limit
  const topSuggestions = filterAndLimitSuggestions(scoredSuggestions, 5);
  
  // 6. Detect crisis mode
  const crisisMode = detectCrisisMode(scoredSuggestions, availableBlocks);
  
  // 7. Load recent insights
  const insights = await loadRecentInsights(req.userId);
  
  return {
    availableBlocks,
    suggestions: topSuggestions,
    warnings: workloadWarnings,
    insights,
    crisisMode
  };
}
```

#### Rule Category 1: Task Scheduling Rules

**Purpose:** Match tasks to available time blocks based on duration, context, and user patterns.

**Implementation:**

```typescript
function evaluateTaskSchedulingRules(
  tasks: Task[],
  availableBlocks: TimeBlock[],
  settings: UserSettings
): Suggestion[] {
  const suggestions: Suggestion[] = [];
  
  for (const task of tasks) {
    // Skip completed or far-future tasks
    if (task.status === 'done' || isTaskTooFarOut(task)) continue;
    
    // Find suitable time blocks
    const suitableBlocks = availableBlocks.filter(block => 
      block.durationMinutes >= task.estimatedDurationMinutes
    );
    
    if (suitableBlocks.length === 0) continue;
    
    // Calculate fit score for best block
    const bestBlock = suitableBlocks[0];
    const fitScore = calculateFitScore(task, bestBlock, settings);
    
    // Calculate other scores
    const urgencyScore = calculateTaskUrgency(task);
    const impactScore = calculateTaskImpact(task);
    const consequenceScore = calculateTaskConsequence(task);
    
    // Final score
    const finalScore = (
      urgencyScore * 0.35 +
      fitScore * 0.25 +
      impactScore * 0.25 +
      consequenceScore * 0.15
    );
    
    suggestions.push({
      id: `task-${task.id}`,
      type: 'task',
      title: task.title,
      description: `Fits ${formatTimeBlock(bestBlock)} block`,
      score: finalScore,
      urgency: urgencyScore,
      fit: fitScore,
      impact: impactScore,
      consequence: consequenceScore,
      actions: [
        { label: 'Start Task', type: 'primary', action: 'start_task', params: { taskId: task.id } },
        { label: 'Reschedule', type: 'secondary', action: 'reschedule_task', params: { taskId: task.id } },
        { label: 'Dismiss', type: 'dismiss', action: 'dismiss_suggestion' }
      ],
      metadata: { task, timeBlock: bestBlock }
    });
  }
  
  return suggestions;
}

function calculateFitScore(task: Task, block: TimeBlock, settings: UserSettings): number {
  let score = 100;
  
  // Duration fit
  if (task.estimatedDurationMinutes > block.durationMinutes) {
    score *= (block.durationMinutes / task.estimatedDurationMinutes);
  }
  
  // Context fit (focus work in focus time)
  if (task.requiresFocus) {
    const blockTime = new Date(block.start).getHours();
    const focusStart = parseInt(settings.preferredFocusHoursStart.split(':')[0]);
    const focusEnd = parseInt(settings.preferredFocusHoursEnd.split(':')[0]);
    
    if (blockTime >= focusStart && blockTime < focusEnd) {
      score *= 1.2; // Bonus for focus work in focus time
    } else {
      score *= 0.6; // Penalty for focus work outside focus time
    }
  }
  
  // Energy level match
  const blockTime = new Date(block.start).getHours();
  if (task.energyLevel === 'high' && blockTime < 12) {
    score *= 1.1; // Morning for high-energy tasks
  } else if (task.energyLevel === 'low' && blockTime > 16) {
    score *= 1.1; // Late afternoon for low-energy tasks
  }
  
  // Batching bonus (check if similar tasks exist)
  // Implementation depends on detecting similar category/context
  
  return Math.min(score, 100); // Cap at 100
}

function calculateTaskUrgency(task: Task): number {
  if (!task.dueDate) return 30; // Low urgency if no deadline
  
  const now = new Date();
  const due = new Date(task.dueDate);
  const hoursUntilDue = (due.getTime() - now.getTime()) / (1000 * 60 * 60);
  
  if (hoursUntilDue < 0) {
    // Overdue
    const daysOverdue = Math.abs(hoursUntilDue) / 24;
    return Math.min(90 + daysOverdue * 2, 100);
  } else if (hoursUntilDue < 3) {
    return 100; // Due in <3 hours
  } else if (hoursUntilDue < 24) {
    return 85; // Due today
  } else if (hoursUntilDue < 48) {
    return 70; // Due tomorrow
  } else if (hoursUntilDue < 168) {
    return 50; // Due this week
  } else {
    return 30; // Due later
  }
}

function calculateTaskImpact(task: Task): number {
  // Base impact by category
  const categoryImpact = {
    sermon_prep: 90,
    pastoral_care: 80,
    worship_planning: 70,
    admin: 40,
    personal: 30
  };
  
  let impact = categoryImpact[task.category] || 50;
  
  // Boost if blocks other tasks
  if (task.parentTaskId) {
    impact *= 1.5;
  }
  
  // Boost if in neglected area (hasn't been worked on in 7+ days)
  // Implementation requires checking recent activity logs
  
  return Math.min(impact, 100);
}

function calculateTaskConsequence(task: Task): number {
  // What happens if this is delayed?
  
  if (task.category === 'sermon_prep' && task.dueDate) {
    const due = new Date(task.dueDate);
    const sunday = getNextSunday(new Date());
    
    if (due <= sunday) {
      return 100; // Missing sermon deadline = catastrophic
    }
  }
  
  if (task.category === 'pastoral_care' && task.personId) {
    // Check if person is in crisis category
    // High consequence for pastoral care to crisis contacts
    return 95;
  }
  
  if (task.priority === 'urgent') {
    return 85;
  } else if (task.priority === 'high') {
    return 70;
  } else if (task.priority === 'medium') {
    return 50;
  } else {
    return 30;
  }
}
```

#### Rule Category 2: Contact Frequency Rules

**Purpose:** Identify people overdue for pastoral contact based on their category and last contact date.

**Implementation:**

```typescript
function evaluateContactFrequencyRules(
  people: Person[],
  settings: UserSettings
): Suggestion[] {
  const suggestions: Suggestion[] = [];
  const today = new Date();
  
  for (const person of people) {
    if (!person.lastContactDate) {
      // Never contacted - suggest for new people
      suggestions.push(createContactSuggestion(person, null, settings, 50));
      continue;
    }
    
    const lastContact = new Date(person.lastContactDate);
    const daysSinceContact = Math.floor((today.getTime() - lastContact.getTime()) / (1000 * 60 * 60 * 24));
    
    // Get threshold for this category
    const threshold = getContactThreshold(person.category, settings, person.contactFrequencyOverrideDays);
    
    if (daysSinceContact > threshold) {
      const daysOverdue = daysSinceContact - threshold;
      const urgency = calculateContactUrgency(person.category, daysOverdue);
      
      suggestions.push(createContactSuggestion(person, daysSinceContact, settings, urgency));
    }
  }
  
  return suggestions;
}

function getContactThreshold(category: string, settings: UserSettings, override?: number): number {
  if (override) return override;
  
  switch (category) {
    case 'elder':
      return settings.elderContactFrequencyDays;
    case 'member':
      return settings.memberContactFrequencyDays;
    case 'crisis':
      return settings.crisisContactFrequencyDays;
    default:
      return 90; // Default for uncategorized
  }
}

function calculateContactUrgency(category: string, daysOverdue: number): number {
  const baseUrgency = {
    crisis: 95,
    elder: 70,
    leadership: 70,
    member: 60,
    visitor: 50
  };
  
  const base = baseUrgency[category] || 50;
  const overdueBonus = daysOverdue * 2; // 2 points per day overdue
  
  return Math.min(base + overdueBonus, 100);
}

function createContactSuggestion(
  person: Person,
  daysSinceContact: number | null,
  settings: UserSettings,
  urgency: number
): Suggestion {
  const description = daysSinceContact !== null
    ? `Last contact: ${daysSinceContact} days ago`
    : 'No contact recorded';
  
  return {
    id: `contact-${person.id}`,
    type: 'pastoral_care',
    title: `Contact ${person.name}`,
    description: description,
    score: urgency, // For pastoral care, urgency heavily drives score
    urgency: urgency,
    fit: 100, // 15min call can fit anywhere
    impact: calculateContactImpact(person.category),
    consequence: calculateContactConsequence(person.category),
    actions: [
      { label: 'Call Now', type: 'primary', action: 'call_person', params: { personId: person.id } },
      { label: 'Create Task', type: 'secondary', action: 'create_contact_task', params: { personId: person.id } },
      { label: 'Log Contact', type: 'secondary', action: 'log_contact', params: { personId: person.id } },
      { label: 'Dismiss', type: 'dismiss', action: 'dismiss_suggestion' }
    ],
    metadata: { person }
  };
}
```

#### Rule Category 3: Event Preparation Rules

**Purpose:** Ensure events have necessary preparation tasks completed beforehand.

**Implementation:**

```typescript
function evaluateEventPrepRules(
  events: CalendarEvent[],
  tasks: Task[]
): Suggestion[] {
  const suggestions: Suggestion[] = [];
  const now = new Date();
  
  for (const event of events) {
    if (!event.requiresPreparation) continue;
    
    const eventTime = new Date(event.startDatetime);
    const hoursUntilEvent = (eventTime.getTime() - now.getTime()) / (1000 * 60 * 60);
    
    // Only suggest prep for events within next 48 hours
    if (hoursUntilEvent < 0 || hoursUntilEvent > 48) continue;
    
    // Check if prep tasks exist and are complete
    const prepTasks = tasks.filter(t => 
      t.calendarEventId === event.id && 
      t.status !== 'done'
    );
    
    if (prepTasks.length === 0 && event.preparationBufferHours) {
      // No prep task exists, suggest creating one
      const bufferMet = hoursUntilEvent > event.preparationBufferHours;
      
      if (!bufferMet) {
        // Preparation should have started already
        const urgency = hoursUntilEvent < 2 ? 90 : 75;
        
        suggestions.push({
          id: `prep-${event.id}`,
          type: 'event_prep',
          title: `Prepare for ${event.title}`,
          description: `Event in ${Math.floor(hoursUntilEvent)} hours`,
          score: urgency,
          urgency: urgency,
          fit: 100, // Assume prep is quick (5-15 min)
          impact: 70,
          consequence: 70,
          actions: [
            { label: 'Create Prep Task', type: 'primary', action: 'create_prep_task', params: { eventId: event.id } },
            { label: 'Mark Prepared', type: 'secondary', action: 'mark_event_prepared', params: { eventId: event.id } },
            { label: 'Dismiss', type: 'dismiss', action: 'dismiss_suggestion' }
          ],
          metadata: { event }
        });
      }
    } else if (prepTasks.length > 0) {
      // Prep tasks exist but aren't complete
      for (const task of prepTasks) {
        const urgency = hoursUntilEvent < 2 ? 95 : (hoursUntilEvent < 6 ? 80 : 65);
        
        suggestions.push({
          id: `prep-task-${task.id}`,
          type: 'event_prep',
          title: task.title,
          description: `Event in ${Math.floor(hoursUntilEvent)} hours`,
          score: urgency,
          urgency: urgency,
          fit: 100,
          impact: 70,
          consequence: 70,
          actions: [
            { label: 'Complete Task', type: 'primary', action: 'start_task', params: { taskId: task.id } },
            { label: 'Dismiss', type: 'dismiss', action: 'dismiss_suggestion' }
          ],
          metadata: { task, event }
        });
      }
    }
  }
  
  return suggestions;
}
```

#### Rule Category 4: Deadline Rules

**Purpose:** Elevate tasks as deadlines approach, especially sermon deadlines.

**Implementation:**

```typescript
function evaluateDeadlineRules(
  tasks: Task[],
  events: CalendarEvent[]
): Suggestion[] {
  const suggestions: Suggestion[] = [];
  const now = new Date();
  
  for (const task of tasks) {
    if (!task.dueDate || task.status === 'done') continue;
    
    const due = new Date(task.dueDate);
    const hoursUntilDue = (due.getTime() - now.getTime()) / (1000 * 60 * 60);
    
    // Escalate based on deadline proximity
    if (hoursUntilDue < 3) {
      // Less than 3 hours - critical
      suggestions.push(createDeadlineSuggestion(task, hoursUntilDue, 95));
    } else if (hoursUntilDue < 6) {
      // Less than 6 hours - urgent
      suggestions.push(createDeadlineSuggestion(task, hoursUntilDue, 85));
    } else if (hoursUntilDue < 24 && task.category === 'sermon_prep') {
      // Sermon due in <24 hours - very important
      suggestions.push(createDeadlineSuggestion(task, hoursUntilDue, 90));
    }
  }
  
  return suggestions;
}

function createDeadlineSuggestion(task: Task, hoursUntilDue: number, urgency: number): Suggestion {
  return {
    id: `deadline-${task.id}`,
    type: 'task',
    title: task.title,
    description: `Due in ${Math.floor(hoursUntilDue)} hours`,
    score: urgency,
    urgency: urgency,
    fit: 80,
    impact: task.category === 'sermon_prep' ? 95 : 70,
    consequence: task.category === 'sermon_prep' ? 100 : 70,
    actions: [
      { label: 'Start Now', type: 'primary', action: 'start_task', params: { taskId: task.id } },
      { label: 'Request Help', type: 'secondary', action: 'request_help', params: { taskId: task.id } },
      { label: 'Dismiss', type: 'dismiss', action: 'dismiss_suggestion' }
    ],
    metadata: { task }
  };
}
```

#### Rule Category 5: Workload Balance Rules

**Purpose:** Detect overloaded schedules and generate warnings.

**Implementation:**

```typescript
function evaluateWorkloadBalanceRules(
  events: CalendarEvent[],
  tasks: Task[],
  settings: UserSettings
): Warning[] {
  const warnings: Warning[] = [];
  
  // Calculate total scheduled hours for today
  const todayHours = calculateScheduledHours(events, tasks, new Date());
  
  if (todayHours > settings.maxDailyHours) {
    warnings.push({
      id: 'overload-today',
      severity: 'critical',
      title: 'Schedule overload today',
      description: `${todayHours} hours scheduled, ${settings.maxDailyHours} hour limit`,
      actions: [
        { label: 'Fix Schedule', type: 'primary', action: 'triage_schedule' },
        { label: 'View Details', type: 'secondary', action: 'view_schedule' },
        { label: 'Dismiss', type: 'dismiss', action: 'dismiss_warning' }
      ]
    });
  }
  
  // Check next 7 days for overload
  const overloadedDays = [];
  for (let i = 1; i <= 7; i++) {
    const checkDate = new Date();
    checkDate.setDate(checkDate.getDate() + i);
    
    const dayHours = calculateScheduledHours(events, tasks, checkDate);
    if (dayHours > settings.maxDailyHours) {
      overloadedDays.push({ date: checkDate, hours: dayHours });
    }
  }
  
  if (overloadedDays.length >= 3) {
    warnings.push({
      id: 'overload-week',
      severity: 'high',
      title: 'Unsustainable pace this week',
      description: `${overloadedDays.length} days overbooked - burnout risk`,
      actions: [
        { label: 'Reschedule Items', type: 'primary', action: 'reschedule_week' },
        { label: 'View Week', type: 'secondary', action: 'view_week' },
        { label: 'Dismiss', type: 'dismiss', action: 'dismiss_warning' }
      ]
    });
  }
  
  // Check sermon prep hours
  if (settings.weeklySermonPrepHours) {
    const sermonTasks = tasks.filter(t => t.category === 'sermon_prep' && t.status !== 'done');
    const prepHoursLogged = sermonTasks.reduce((sum, t) => sum + (t.actualDurationMinutes || t.estimatedDurationMinutes || 0), 0) / 60;
    
    const sunday = getNextSunday(new Date());
    const daysUntilSunday = Math.floor((sunday.getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24));
    
    if (prepHoursLogged < settings.weeklySermonPrepHours && daysUntilSunday <= 5) {
      const hoursShort = settings.weeklySermonPrepHours - prepHoursLogged;
      
      warnings.push({
        id: 'sermon-prep-behind',
        severity: daysUntilSunday <= 2 ? 'critical' : 'high',
        title: 'Sermon prep behind schedule',
        description: `${hoursShort} hours short of target`,
        actions: [
          { label: 'View Sermon', type: 'primary', action: 'view_current_sermon' },
          { label: 'Block Time', type: 'secondary', action: 'block_sermon_time' },
          { label: 'Dismiss', type: 'dismiss', action: 'dismiss_warning' }
        ]
      });
    }
  }
  
  return warnings;
}

function calculateScheduledHours(events: CalendarEvent[], tasks: Task[], date: Date): number {
  const dayStart = new Date(date);
  dayStart.setHours(0, 0, 0, 0);
  
  const dayEnd = new Date(date);
  dayEnd.setHours(23, 59, 59, 999);
  
  // Sum event durations for this day
  let hours = 0;
  
  for (const event of events) {
    const eventStart = new Date(event.startDatetime);
    const eventEnd = new Date(event.endDatetime);
    
    if (eventStart >= dayStart && eventStart < dayEnd) {
      hours += (eventEnd.getTime() - eventStart.getTime()) / (1000 * 60 * 60);
    }
  }
  
  // Add task estimates due this day
  for (const task of tasks) {
    if (task.dueDate && task.status !== 'done') {
      const dueDate = new Date(task.dueDate);
      
      if (dueDate >= dayStart && dueDate < dayEnd) {
        hours += (task.estimatedDurationMinutes || 0) / 60;
      }
    }
  }
  
  return hours;
}
```

#### Scoring & Ranking

**Final score calculation:**

```typescript
function scoreAndRankSuggestions(
  suggestions: Suggestion[],
  settings: UserSettings
): Suggestion[] {
  // Weight factors (configurable per user via settings)
  const weights = {
    urgency: settings.urgencyWeight || 0.35,
    fit: settings.fitWeight || 0.25,
    impact: settings.impactWeight || 0.25,
    consequence: settings.consequenceWeight || 0.15
  };
  
  // Calculate final scores
  for (const suggestion of suggestions) {
    suggestion.score = (
      suggestion.urgency * weights.urgency +
      suggestion.fit * weights.fit +
      suggestion.impact * weights.impact +
      suggestion.consequence * weights.consequence
    );
  }
  
  // Sort by score descending
  suggestions.sort((a, b) => b.score - a.score);
  
  return suggestions;
}

function filterAndLimitSuggestions(suggestions: Suggestion[], maxCount: number): Suggestion[] {
  // Filter out low-scoring suggestions (below threshold)
  const filtered = suggestions.filter(s => s.score >= 70);
  
  // Limit to max count
  return filtered.slice(0, maxCount);
}
```

#### Crisis Mode Detection

```typescript
function detectCrisisMode(suggestions: Suggestion[], availableBlocks: TimeBlock[]): boolean {
  // Count critical suggestions (score 85+)
  const criticalSuggestions = suggestions.filter(s => s.score >= 85);
  
  if (criticalSuggestions.length === 0) return false;
  
  // Calculate total time needed for critical items
  const totalMinutesNeeded = criticalSuggestions.reduce((sum, s) => {
    const task = s.metadata.task;
    return sum + (task?.estimatedDurationMinutes || 15); // Assume 15 min if not specified
  }, 0);
  
  // Calculate total available time
  const totalMinutesAvailable = availableBlocks.reduce((sum, block) => 
    sum + block.durationMinutes, 0
  );
  
  // Trigger crisis mode if:
  // 1. Critical time needed > 1.5x available time
  const timeRatio = totalMinutesNeeded / totalMinutesAvailable;
  if (timeRatio > 1.5) return true;
  
  // 2. 5+ critical suggestions simultaneously
  if (criticalSuggestions.length >= 5) return true;
  
  return false;
}
```

### Pattern Learning Algorithm

**Runs as scheduled job** (weekly on Fridays via cron job).

**Edge Function: `analyze_patterns`**

```typescript
async function analyzePatterns(userId: string): Promise<void> {
  // Load activity logs from past 2-4 weeks
  const activityLogs = await loadActivityLogs(userId, 28); // 28 days
  
  if (activityLogs.length < 50) {
    // Not enough data yet
    return;
  }
  
  const insights: Insight[] = [];
  
  // Pattern 1: Productive hours detection
  const productiveHours = detectProductiveHours(activityLogs);
  if (productiveHours.confidence > 0.7) {
    insights.push(productiveHours);
  }
  
  // Pattern 2: Task duration accuracy
  const durationAccuracy = analyzeDurationAccuracy(activityLogs);
  if (durationAccuracy.confidence > 0.7) {
    insights.push(durationAccuracy);
  }
  
  // Pattern 3: Scheduling patterns (batching, day preferences)
  const schedulingPatterns = detectSchedulingPatterns(activityLogs);
  insights.push(...schedulingPatterns.filter(p => p.confidence > 0.7));
  
  // Pattern 4: Pastoral care patterns
  const pastoralPatterns = analyzePastoralCarePatterns(activityLogs);
  insights.push(...pastoralPatterns.filter(p => p.confidence > 0.7));
  
  // Save insights to database
  for (const insight of insights) {
    await saveInsight(userId, insight);
  }
}

function detectProductiveHours(logs: ActivityLog[]): Insight | null {
  // Group task completions by hour of day
  const completionsByHour: { [hour: number]: number } = {};
  
  for (const log of logs) {
    if (log.activityType === 'task_completed') {
      const hour = new Date(log.timestamp).getHours();
      completionsByHour[hour] = (completionsByHour[hour] || 0) + 1;
    }
  }
  
  // Find peak hours (top 20% of activity)
  const hours = Object.keys(completionsByHour).map(Number);
  const sorted = hours.sort((a, b) => completionsByHour[b] - completionsByHour[a]);
  const peakHours = sorted.slice(0, Math.max(2, Math.floor(sorted.length * 0.2)));
  
  // Calculate confidence based on consistency
  const totalCompletions = Object.values(completionsByHour).reduce((a, b) => a + b, 0);
  const peakCompletions = peakHours.reduce((sum, h) => sum + completionsByHour[h], 0);
  const confidence = peakCompletions / totalCompletions; // >0.7 means 70%+ of work done in peak hours
  
  if (confidence < 0.7 || peakHours.length === 0) return null;
  
  // Format time range
  const start = Math.min(...peakHours);
  const end = Math.max(...peakHours) + 1;
  
  return {
    id: 'productive-hours',
    type: 'pattern',
    title: 'Productive hours detected',
    description: `You complete ${Math.round(confidence * 100)}% of tasks between ${start}:00-${end}:00`,
    confidence: confidence,
    data: { peakHours, start, end },
    actions: [
      { 
        label: 'Protect This Time', 
        type: 'primary', 
        action: 'update_focus_hours', 
        params: { start: `${start}:00`, end: `${end}:00` } 
      },
      { label: 'Dismiss', type: 'dismiss', action: 'dismiss_insight' }
    ]
  };
}

function analyzeDurationAccuracy(logs: ActivityLog[]): Insight | null {
  // Compare estimated vs actual task durations
  const comparisons: { estimated: number; actual: number }[] = [];
  
  for (const log of logs) {
    if (log.activityType === 'task_completed') {
      const data = log.activityData as any;
      if (data.estimatedMinutes && data.actualMinutes) {
        comparisons.push({
          estimated: data.estimatedMinutes,
          actual: data.actualMinutes
        });
      }
    }
  }
  
  if (comparisons.length < 10) return null; // Need at least 10 data points
  
  // Calculate average ratio
  const ratios = comparisons.map(c => c.actual / c.estimated);
  const avgRatio = ratios.reduce((a, b) => a + b, 0) / ratios.length;
  
  // Confidence based on consistency of ratios
  const variance = ratios.reduce((sum, r) => sum + Math.pow(r - avgRatio, 2), 0) / ratios.length;
  const stdDev = Math.sqrt(variance);
  const confidence = Math.max(0, 1 - (stdDev / avgRatio)); // Lower variance = higher confidence
  
  if (confidence < 0.7) return null;
  
  // Determine if user consistently over or underestimates
  if (avgRatio > 1.2) {
    // Consistently takes longer than estimated
    return {
      id: 'duration-accuracy',
      type: 'efficiency',
      title: 'Tasks take longer than estimated',
      description: `On average, tasks take ${Math.round((avgRatio - 1) * 100)}% longer than you estimate`,
      confidence: confidence,
      data: { avgRatio, comparisons: comparisons.length },
      actions: [
        { 
          label: 'Adjust Estimates', 
          type: 'primary', 
          action: 'apply_time_multiplier', 
          params: { multiplier: avgRatio } 
        },
        { label: 'View Details', type: 'secondary', action: 'view_time_analysis' },
        { label: 'Dismiss', type: 'dismiss', action: 'dismiss_insight' }
      ]
    };
  } else if (avgRatio < 0.8) {
    // Consistently faster than estimated
    return {
      id: 'duration-accuracy',
      type: 'efficiency',
      title: 'You work faster than estimated',
      description: `Tasks typically complete ${Math.round((1 - avgRatio) * 100)}% faster than estimated`,
      confidence: confidence,
      data: { avgRatio, comparisons: comparisons.length },
      actions: [
        { 
          label: 'Adjust Estimates', 
          type: 'primary', 
          action: 'apply_time_multiplier', 
          params: { multiplier: avgRatio } 
        },
        { label: 'Dismiss', type: 'dismiss', action: 'dismiss_insight' }
      ]
    };
  }
  
  return null; // Estimates are accurate
}

function detectSchedulingPatterns(logs: ActivityLog[]): Insight[] {
  const insights: Insight[] = [];
  
  // Pattern: Preferred days for pastoral visits
  const visitsByDay: { [day: number]: number } = {};
  
  for (const log of logs) {
    if (log.activityType === 'event_completed') {
      const data = log.activityData as any;
      if (data.eventType === 'pastoral_visit') {
        const day = new Date(log.timestamp).getDay(); // 0=Sunday, 1=Monday, etc.
        visitsByDay[day] = (visitsByDay[day] || 0) + 1;
      }
    }
  }
  
  const totalVisits = Object.values(visitsByDay).reduce((a, b) => a + b, 0);
  if (totalVisits >= 10) {
    // Find days with >40% of visits
    const preferredDays = Object.keys(visitsByDay)
      .map(Number)
      .filter(day => visitsByDay[day] / totalVisits > 0.4);
    
    if (preferredDays.length > 0) {
      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const confidence = preferredDays.reduce((sum, day) => sum + visitsByDay[day], 0) / totalVisits;
      
      insights.push({
        id: 'pastoral-visit-days',
        type: 'pattern',
        title: 'Pastoral visit pattern detected',
        description: `${Math.round(confidence * 100)}% of visits on ${preferredDays.map(d => dayNames[d]).join(' and ')}`,
        confidence: confidence,
        data: { preferredDays, visitsByDay },
        actions: [
          { 
            label: 'Block These Days', 
            type: 'primary', 
            action: 'set_preferred_visit_days', 
            params: { days: preferredDays } 
          },
          { label: 'Dismiss', type: 'dismiss', action: 'dismiss_insight' }
        ]
      });
    }
  }
  
  return insights;
}
```

**Applying Learned Patterns:**

Insights stored in `user_insights` table are applied in two ways:

1. **User accepts insight** → Updates `user_schedule_preferences` with `is_manual = false`
2. **Automatic application** → Scoring algorithm checks preferences and adjusts weights/suggestions

Example:
```typescript
// In scoring algorithm
const preferences = await loadUserPreferences(userId);

const focusTimePreference = preferences.find(p => p.preferenceType === 'focus_time');
if (focusTimePreference && !focusTimePreference.isManual) {
  // User accepted learned pattern for focus time
  settings.preferredFocusHoursStart = focusTimePreference.preferenceValue.start;
  settings.preferredFocusHoursEnd = focusTimePreference.preferenceValue.end;
}
```

---

## Offline Functionality

### Architecture

**Offline-first approach:**
- All operations execute against local SQLite database first
- Sync engine pushes changes to Supabase in background
- Conflict resolution happens automatically (auto-merge)
- User experience identical whether online or offline

### Local Database (SQLite)

**Schema mirrors Supabase** with additional sync metadata:

```sql
-- Example: tasks table with sync metadata
CREATE TABLE tasks (
  -- All standard fields from Supabase schema
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  -- ... all other fields ...
  
  -- Sync metadata
  _sync_status TEXT DEFAULT 'synced', -- 'synced', 'pending', 'conflict'
  _local_updated_at INTEGER, -- Unix timestamp
  _server_updated_at INTEGER, -- Unix timestamp
  _version INTEGER DEFAULT 1 -- For conflict detection
);

-- Sync queue table
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_name TEXT NOT NULL,
  record_id TEXT NOT NULL,
  operation TEXT NOT NULL, -- 'insert', 'update', 'delete'
  payload TEXT, -- JSON serialized record
  created_at INTEGER NOT NULL,
  retry_count INTEGER DEFAULT 0,
  last_error TEXT
);
```

### Sync Engine

**Sync frequency:**
- Every 15 minutes when app active and online
- Immediately on app open
- Immediately on network reconnect
- After major changes (opportunistic sync)

**Sync algorithm:**

```dart
class SyncEngine {
  Timer? _syncTimer;
  final Supabase _supabase;
  final Database _localDb;
  
  void startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 15), (_) {
      if (_isOnline()) {
        syncAll();
      }
    });
  }
  
  Future<void> syncAll() async {
    try {
      // 1. Pull changes from server
      await pullFromServer();
      
      // 2. Push local changes to server
      await pushToServer();
      
      // 3. Update last sync timestamp
      await _localDb.setLastSyncTime(DateTime.now());
      
    } catch (e) {
      // Log error, will retry on next sync
      print('Sync error: $e');
    }
  }
  
  Future<void> pullFromServer() async {
    final lastSync = await _localDb.getLastSyncTime();
    
    // Fetch changes since last sync
    final changes = await _supabase
      .from('tasks')
      .select()
      .gt('updated_at', lastSync.toIso8601String())
      .execute();
    
    for (final record in changes.data) {
      await mergeServerRecord('tasks', record);
    }
    
    // Repeat for other tables: calendar_events, people, etc.
  }
  
  Future<void> mergeServerRecord(String table, Map<String, dynamic> serverRecord) async {
    final localRecord = await _localDb.getRecord(table, serverRecord['id']);
    
    if (localRecord == null) {
      // Server has record, local doesn't → Insert locally
      await _localDb.insert(table, serverRecord);
      return;
    }
    
    // Both have record → Check for conflicts
    if (localRecord['_sync_status'] == 'pending') {
      // Local has unsynced changes → Conflict
      final merged = await _resolveConflict(table, localRecord, serverRecord);
      await _localDb.update(table, merged);
    } else {
      // Local is synced → Server wins
      await _localDb.update(table, serverRecord);
    }
  }
  
  Future<Map<String, dynamic>> _resolveConflict(
    String table,
    Map<String, dynamic> local,
    Map<String, dynamic> server
  ) async {
    // Auto-merge strategy
    final merged = Map<String, dynamic>.from(server); // Start with server version
    
    // Merge non-conflicting fields from local
    for (final key in local.keys) {
      if (key.startsWith('_')) continue; // Skip metadata
      
      if (local[key] != server[key]) {
        // Field differs - determine which to keep
        
        if (_isTimestamp(key)) {
          // Timestamp fields: keep more recent
          merged[key] = _max(local[key], server[key]);
        } else if (_isAccumulator(key)) {
          // Accumulator fields (e.g., prep_hours_logged): sum
          merged[key] = local[key] + server[key];
        } else {
          // Regular field: last-write-wins (server timestamp)
          if (local['_local_updated_at'] > server['updated_at']) {
            merged[key] = local[key]; // Local is newer
          }
          // else server already in merged
        }
      }
    }
    
    return merged;
  }
  
  Future<void> pushToServer() async {
    // Get all pending changes from sync queue
    final pendingChanges = await _localDb.getPendingChanges();
    
    for (final change in pendingChanges) {
      try {
        switch (change.operation) {
          case 'insert':
            await _supabase.from(change.tableName).insert(change.payload).execute();
            break;
          case 'update':
            await _supabase.from(change.tableName).update(change.payload).eq('id', change.recordId).execute();
            break;
          case 'delete':
            await _supabase.from(change.tableName).delete().eq('id', change.recordId).execute();
            break;
        }
        
        // Success - remove from queue
        await _localDb.removeSyncQueueItem(change.id);
        
      } catch (e) {
        // Failure - increment retry count
        await _localDb.incrementRetryCount(change.id, e.toString());
        
        // After 5 retries, flag for manual resolution
        if (change.retryCount >= 5) {
          await _localDb.flagSyncError(change.id);
        }
      }
    }
  }
}
```

**Optimistic Updates:**

```dart
// Example: Completing a task
Future<void> completeTask(String taskId) async {
  // 1. Update local database immediately
  await _localDb.updateTask(taskId, {
    'status': 'done',
    'completed_at': DateTime.now().toIso8601String(),
    '_sync_status': 'pending',
    '_local_updated_at': DateTime.now().millisecondsSinceEpoch,
  });
  
  // 2. Update UI immediately (shows as complete)
  _taskController.refresh();
  
  // 3. Queue for sync
  await _localDb.addToSyncQueue(
    tableName: 'tasks',
    recordId: taskId,
    operation: 'update',
    payload: { 'status': 'done', 'completed_at': DateTime.now().toIso8601String() }
  );
  
  // 4. Opportunistic sync (don't wait)
  _syncEngine.syncAll().catchError((e) {
    // Sync failed, but user already sees update
    // Will retry on next sync cycle
  });
}
```

### Offline Caching Strategy

**Data scope:**

```dart
class OfflineCacheManager {
  // Settings determine how much data to keep offline
  static const DEFAULT_CACHE_DAYS = 90;
  
  Future<void> pruneOldData() async {
    final settings = await _getOfflineSettings();
    final cutoffDate = DateTime.now().subtract(Duration(days: settings.cacheDays));
    
    // Remove old calendar events (keep if not completed)
    await _localDb.execute('''
      DELETE FROM calendar_events 
      WHERE start_datetime < ? 
        AND user_id = ?
    ''', [cutoffDate.toIso8601String(), userId]);
    
    // Remove old completed tasks
    await _localDb.execute('''
      DELETE FROM tasks 
      WHERE status = 'done' 
        AND completed_at < ?
        AND user_id = ?
    ''', [cutoffDate.toIso8601String(), userId]);
    
    // Keep all active people (never remove)
    // Keep all sermons (reference material)
    // Remove old contact logs
    await _localDb.execute('''
      DELETE FROM contact_log 
      WHERE contact_date < ?
        AND user_id = ?
    ''', [cutoffDate.toIso8601String(), userId]);
  }
}
```

**Always cached:**
- All incomplete tasks (regardless of age)
- All active people
- All sermons in active series
- User settings
- Last 7 days of calendar events (minimum)

**Conditionally cached:**
- Calendar events (based on cache days setting)
- Completed tasks (based on cache days setting)
- Contact logs (last 2 years typically)
- Archived sermons (on-demand)

### Offline UI Indicators

**Sync status banner:**
```dart
Widget buildSyncStatusBanner(SyncStatus status) {
  if (status == SyncStatus.synced) {
    // Don't show anything - all good
    return SizedBox.shrink();
  }
  
  Color color;
  IconData icon;
  String message;
  
  switch (status) {
    case SyncStatus.offline:
      color = Colors.red;
      icon = Icons.cloud_off;
      message = 'Offline - Changes will sync when connected';
      break;
    case SyncStatus.syncing:
      color = Colors.orange;
      icon = Icons.cloud_sync;
      message = 'Syncing... (${status.pendingCount} changes)';
      break;
    case SyncStatus.error:
      color = Colors.red;
      icon = Icons.error;
      message = 'Sync error - Tap to retry';
      break;
  }
  
  return Container(
    padding: EdgeInsets.all(8),
    color: color.withOpacity(0.1),
    child: Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 8),
        Text(message, style: TextStyle(color: color)),
        if (status == SyncStatus.error)
          TextButton(
            onPressed: () => _syncEngine.syncAll(),
            child: Text('Retry'),
          ),
      ],
    ),
  );
}
```

**Tap banner for details:**
```dart
void showSyncDetails() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Sync Status'),
          subtitle: Text('Last synced: 2 minutes ago'),
        ),
        Divider(),
        ListTile(
          title: Text('Pending Changes (${pendingChanges.length})'),
        ),
        ...pendingChanges.map((change) => ListTile(
          leading: _getChangeIcon(change.operation),
          title: Text(change.description),
          subtitle: Text('${change.tableName} - ${change.operation}'),
        )),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _syncEngine.syncAll(),
          child: Text('Sync Now'),
        ),
        SizedBox(height: 16),
      ],
    ),
  );
}
```

### Network State Handling

```dart
class NetworkMonitor {
  Stream<NetworkStatus> get statusStream => _statusController.stream;
  final _statusController = StreamController<NetworkStatus>.broadcast();
  
  void startMonitoring() {
    Connectivity().onConnectivityChanged.listen((result) {
      final status = _determineStatus(result);
      _statusController.add(status);
      
      if (status == NetworkStatus.online) {
        // Network reconnected - trigger sync
        _syncEngine.syncAll();
      }
    });
  }
  
  NetworkStatus _determineStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkStatus.wifi;
      case ConnectivityResult.mobile:
        return NetworkStatus.cellular;
      case ConnectivityResult.none:
        return NetworkStatus.offline;
      default:
        return NetworkStatus.unknown;
    }
  }
}

enum NetworkStatus {
  wifi,        // Strong connection
  cellular,    // Mobile data
  offline,     // No connection
  unknown
}
```

**Adapt behavior by network:**

```dart
void handleNetworkChange(NetworkStatus status) {
  switch (status) {
    case NetworkStatus.wifi:
      // Aggressive sync
      _syncEngine.setSyncInterval(Duration(minutes: 15));
      _syncEngine.enableBackgroundDownloads();
      break;
      
    case NetworkStatus.cellular:
      // Standard sync (check user setting)
      if (_settings.syncOverCellular) {
        _syncEngine.setSyncInterval(Duration(minutes: 15));
      } else {
        _syncEngine.pauseSync();
      }
      _syncEngine.disableBackgroundDownloads();
      break;
      
    case NetworkStatus.offline:
      // Pause sync, queue changes
      _syncEngine.pauseSync();
      break;
  }
}
```

---

## Notifications

### Implementation: Flutter Local Notifications + Firebase Cloud Messaging

**Packages:**
- `flutter_local_notifications` - Local/scheduled notifications
- `firebase_messaging` - Push notifications (optional, for future features)

### Notification Types & Timing

**1. Event Reminders**
```dart
void scheduleEventReminder(CalendarEvent event) {
  final notifyTime = event.startDatetime.subtract(Duration(minutes: 30));
  
  _notifications.zonedSchedule(
    event.id.hashCode,
    'Event Starting Soon',
    '${event.title} in 30 minutes',
    tz.TZDateTime.from(notifyTime, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'event_reminders',
        'Event Reminders',
        channelDescription: 'Reminders for upcoming events',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

**2. Morning Digest** (7am daily)
```dart
void scheduleMorningDigest() {
  final now = DateTime.now();
  final scheduledTime = DateTime(now.year, now.month, now.day, 7, 0);
  
  // If already past 7am today, schedule for tomorrow
  if (now.isAfter(scheduledTime)) {
    scheduledTime.add(Duration(days: 1));
  }
  
  _notifications.zonedSchedule(
    'morning_digest'.hashCode,
    '☀️ Good morning, Ruben',
    'You have 4 tasks and 3 events today',
    tz.TZDateTime.from(scheduledTime, tz.local),
    _getDigestNotificationDetails(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
  );
}
```

**3. Evening Review** (7:30pm daily)
```dart
void scheduleEveningReview() {
  final scheduledTime = DateTime(now.year, now.month, now.day, 19, 30);
  
  _notifications.zonedSchedule(
    'evening_review'.hashCode,
    '📊 Time to review your day',
    '5 tasks completed, 2 events finished',
    tz.TZDateTime.from(scheduledTime, tz.local),
    _getReviewNotificationDetails(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
```

**4. Critical Alerts** (bypass Do Not Disturb)
```dart
void sendCriticalAlert(String title, String body) {
  _notifications.show(
    'critical'.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'critical_alerts',
        'Critical Alerts',
        channelDescription: 'Important alerts that bypass Do Not Disturb',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical, // iOS critical alert
      ),
    ),
  );
}
```

### Notification Actions

**Android Action Buttons:**
```dart
AndroidNotificationDetails(
  'pastoral_care',
  'Pastoral Care',
  actions: [
    AndroidNotificationAction(
      'call',
      'Call Now',
      icon: DrawableResourceAndroidBitmap('ic_call'),
    ),
    AndroidNotificationAction(
      'create_task',
      'Create Task',
    ),
    AndroidNotificationAction(
      'dismiss',
      'Dismiss',
      cancelNotification: true,
    ),
  ],
)
```

**Handle action taps:**
```dart
void setupNotificationHandling() {
  // Handle notification tap (opens app)
  _notifications.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (response) {
      handleNotificationAction(response);
    },
  );
}

void handleNotificationAction(NotificationResponse response) {
  final payload = jsonDecode(response.payload ?? '{}');
  
  switch (response.actionId) {
    case 'call':
      _makePhoneCall(payload['phoneNumber']);
      break;
    case 'create_task':
      _navigateToQuickCapture(type: 'task', params: payload);
      break;
    case 'start_task':
      _navigateToTask(payload['taskId']);
      break;
    // etc.
  }
}
```

### Smart Batching

```dart
class NotificationManager {
  final List<PendingNotification> _pendingBatch = [];
  Timer? _batchTimer;
  
  void queueNotification(PendingNotification notification) {
    _pendingBatch.add(notification);
    
    // Start 5-minute batch timer if not already running
    _batchTimer ??= Timer(Duration(minutes: 5), () {
      _sendBatchedNotifications();
    });
  }
  
  void _sendBatchedNotifications() {
    if (_pendingBatch.isEmpty) return;
    
    if (_pendingBatch.length == 1) {
      // Single notification - send as-is
      _sendNotification(_pendingBatch.first);
    } else {
      // Multiple notifications - batch into one
      _sendBatchNotification(_pendingBatch);
    }
    
    _pendingBatch.clear();
    _batchTimer = null;
  }
  
  void _sendBatchNotification(List<PendingNotification> notifications) {
    // Group by category
    final pastoralCare = notifications.where((n) => n.category == 'pastoral_care').toList();
    final tasks = notifications.where((n) => n.category == 'task').toList();
    
    String title;
    String body;
    
    if (pastoralCare.isNotEmpty && tasks.isNotEmpty) {
      title = 'Multiple reminders';
      body = '${pastoralCare.length} pastoral care, ${tasks.length} tasks';
    } else if (pastoralCare.isNotEmpty) {
      title = 'Pastoral care reminders';
      body = '${pastoralCare.length} people need contact';
    } else {
      title = 'Task reminders';
      body = '${tasks.length} tasks due soon';
    }
    
    _notifications.show(
      'batch'.hashCode,
      title,
      body,
      _getBatchNotificationDetails(),
      payload: jsonEncode({
        'type': 'batch',
        'notifications': notifications.map((n) => n.toJson()).toList(),
      }),
    );
  }
}
```

### User Preferences

**Settings UI:**
```dart
class NotificationSettings extends StatelessWidget {
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: Text('Notifications'),
          subtitle: Text('Enable all notifications'),
          value: settings.notificationsEnabled,
          onChanged: (val) => settings.setNotificationsEnabled(val),
        ),
        
        Divider(),
        
        ListTile(
          title: Text('Morning Digest'),
          subtitle: Text('7:00 AM'),
          trailing: Switch(
            value: settings.morningDigestEnabled,
            onChanged: (val) => settings.setMorningDigestEnabled(val),
          ),
          onTap: () => _showTimePicker(context, 'morning'),
        ),
        
        ListTile(
          title: Text('Evening Review'),
          subtitle: Text('7:30 PM'),
          trailing: Switch(
            value: settings.eveningReviewEnabled,
            onChanged: (val) => settings.setEveningReviewEnabled(val),
          ),
          onTap: () => _showTimePicker(context, 'evening'),
        ),
        
        Divider(),
        
        ListTile(
          title: Text('Quiet Hours'),
          subtitle: Text('9:00 PM - 6:00 AM'),
          onTap: () => _configureQuietHours(context),
        ),
        
        SwitchListTile(
          title: Text('Allow critical alerts during quiet hours'),
          value: settings.criticalAlertsAllowed,
          onChanged: (val) => settings.setCriticalAlertsAllowed(val),
        ),
        
        Divider(),
        
        ListTile(
          title: Text('Notification Types'),
          subtitle: Text('Configure by type'),
          onTap: () => Navigator.push(context, 
            MaterialPageRoute(builder: (_) => NotificationTypesSettings())),
        ),
      ],
    );
  }
}
```

### Quiet Hours & Do Not Disturb

```dart
bool shouldSendNotification(NotificationType type) {
  // Check if notifications globally disabled
  if (!settings.notificationsEnabled) return false;
  
  // Check quiet hours
  final now = DateTime.now();
  final quietStart = _parseTime(settings.quietHoursStart);
  final quietEnd = _parseTime(settings.quietHoursEnd);
  
  if (_isInQuietHours(now, quietStart, quietEnd)) {
    // In quiet hours - only allow if critical and user allows
    if (type.isCritical && settings.criticalAlertsAllowed) {
      return true;
    }
    return false;
  }
  
  // Check blocked times
  if (_isInBlockedTime(now)) {
    // Same logic as quiet hours
    if (type.isCritical && settings.criticalAlertsAllowed) {
      return true;
    }
    return false;
  }
  
  return true;
}

bool _isInBlockedTime(DateTime time) {
  // Check if time falls during user's blocked commitments
  // e.g., wrestling (4:15-5:45am), family dinner (5-7pm)
  for (final block in settings.blockedTimes) {
    if (time.hour >= block.startHour && time.hour < block.endHour) {
      return true;
    }
  }
  return false;
}
```

---

## Performance Requirements

### Target Metrics

**Dashboard:**
- Initial load (cold start): <2 seconds
- Refresh: <500ms
- Rule evaluation (Edge Function): <1 second

**Module Views:**
- Task list: <500ms
- Calendar month: <300ms
- People list: <500ms

**Search:**
- Full-text search: <1 second (for 1000+ items)

**Sync:**
- Background: Invisible to user
- Manual: Complete <5 seconds for typical data (~50 changes)

**Memory:**
- Average: <100 MB
- Peak: <200 MB

**Battery:**
- Background (hourly avg): <2%
- Active use (hourly avg): <5%

### Optimization Strategies

**Database Indexing:**
- All foreign keys indexed
- Full-text search indexes on title/content fields
- Composite indexes for common query patterns

**Query Optimization:**
- Use CTEs and joins to reduce round trips
- Pagination (50 items per page)
- Cursor-based pagination for large lists

**Caching:**
- In-memory: Current session data
- SQLite: 90 days default (configurable)
- Dashboard cached 5 minutes

**Asset Optimization:**
- Compress images (80% JPEG quality)
- Lazy load images
- Use vector icons (no PNGs for UI)

**Code Splitting:**
- Lazy load module screens
- Dashboard loads first, modules on-demand

### Performance Monitoring

```dart
// Track dashboard load time
final stopwatch = Stopwatch()..start();

final dashboard = await _loadDashboard();

stopwatch.stop();
analytics.logPerformance('dashboard_load', stopwatch.elapsedMilliseconds);

if (stopwatch.elapsedMilliseconds > 2000) {
  // Slow load - log for investigation
  logger.warning('Slow dashboard load: ${stopwatch.elapsedMilliseconds}ms');
}
```

**Crashlytics integration for production monitoring.**

---

## Development Roadmap

### Phase 1: Foundation (Weeks 1-4)

**Week 1: Infrastructure**
- Supabase project setup
- Database tables created
- RLS policies configured
- Flutter project initialized
- Authentication (sign up/in/out)
- Basic navigation structure

**Week 2: Core CRUD**
- Tasks module (create/edit/delete/list)
- Calendar module (create/edit/delete/month view)
- People module (create/edit/list)
- Local SQLite database
- Basic sync framework

**Week 3: Dashboard v1**
- Simple dashboard (list events & tasks)
- Quick Capture (task/event creation)
- Settings screen
- Basic UI polish

**Week 4: Sync & Offline**
- 15-minute background sync
- Conflict resolution (auto-merge)
- Offline functionality
- Sync status indicators

**Deliverable:** Functional app with basic CRUD, sync, offline support. Usable but not intelligent yet.

### Phase 2: Intelligence (Weeks 5-8)

**Week 5: Rule Engine**
- Edge Function: generate_daily_smart_view
- All 5 rule categories implemented
- Scoring algorithm
- Dashboard v2 (shows suggestions)

**Week 6: Pastoral Care**
- Contact frequency tracking
- Contact logging
- Last contact date updates
- Pastoral care suggestions on dashboard

**Week 7: Sermon Management**
- Sermons module (create/edit)
- Series management
- Rich text editor (basic)
- Link tasks to sermons

**Week 8: Workload & Deadlines**
- Workload balance rules
- Crisis mode implementation
- Event preparation rules
- Enhanced notifications (all types)

**Deliverable:** Smart assistant that suggests what to do and warns about problems.

### Phase 3: Learning & Polish (Weeks 9-12)

**Week 9: Activity Logging**
- Activity log system
- End-of-day review
- Time tracking (actual vs. estimated)
- Event reflections

**Week 10: Pattern Analysis**
- Learning algorithm (Edge Function)
- Pattern detection
- Insight generation
- Insights UI (lightbulb button)

**Week 11: Adaptive Behavior**
- Apply learned patterns
- Adjust time estimates
- Personalize suggestions
- User preference learning

**Week 12: UI/UX Polish**
- Animations & transitions
- Empty states
- Error handling
- Accessibility improvements

**Deliverable:** Adaptive smart assistant that learns and feels polished.

### Phase 4: Advanced Features (Weeks 13-16)

**Week 13: Rich Text & Practice**
- Enhanced RTF editor
- Practice mode (sermons)
- Timer integration

**Week 14: Import & Migration**
- Google Calendar import
- Contact import
- Task import
- CSV upload

**Week 15: Search & Tags**
- Full-text search
- Search index
- Tags system
- Tag-based filtering

**Week 16: Advanced Settings & Export**
- Vacation mode
- Advanced preferences
- Data export
- Analytics dashboard

**Deliverable:** Feature-complete app ready for broader use.

### Testing Per Phase

**Unit Tests:**
- Write alongside feature development
- Focus on business logic (rules, scoring, sync)
- Target: >70% coverage on critical paths

**Integration Tests:**
- Per-phase testing of major flows
- Dashboard generation end-to-end
- Sync scenarios (online/offline/conflict)

**Manual Testing:**
- Checklist per phase (provided in roadmap doc)
- Device testing (iOS + Android)
- Network condition testing

**Beta Testing:**
- After Phase 3: Recruit 3-5 pastors
- Gather feedback on relevance and usability
- Iterate based on real usage

### Launch Strategy

**Soft Launch** (After Phase 3):
- Limited release to beta testers
- 2-4 weeks of real usage
- Bug fixes and refinement
- Validate core value proposition

**Public Launch** (After Phase 4):
- App Store & Google Play submission
- Marketing to pastors
- Documentation & tutorials
- Support channels established

---

## Testing Strategy

### Test Pyramid

**Unit Tests (70%):**
- Rule evaluation logic
- Scoring algorithm
- Sync engine
- Data transformations
- Utility functions

**Integration Tests (20%):**
- Dashboard generation end-to-end
- Sync scenarios
- Offline functionality
- Module workflows

**Manual/UI Tests (10%):**
- User flows
- Visual regression
- Device-specific issues
- Performance validation

### Critical Test Cases

**Rule Engine:**
```dart
group('Contact Frequency Rules', () {
  test('Detects overdue elder contact', () {
    final person = Person(
      category: PersonCategory.elder,
      lastContactDate: DateTime.now().subtract(Duration(days: 35))
    );
    final settings = UserSettings(elderContactFrequencyDays: 30);
    
    final suggestion = evaluateContactFrequency(person, settings);
    
    expect(suggestion, isNotNull);
    expect(suggestion.urgency, greaterThan(70));
  });
  
  test('Does not flag recent contacts', () {
    final person = Person(
      category: PersonCategory.elder,
      lastContactDate: DateTime.now().subtract(Duration(days: 15))
    );
    final settings = UserSettings(elderContactFrequencyDays: 30);
    
    final suggestion = evaluateContactFrequency(person, settings);
    
    expect(suggestion, isNull);
  });
});
```

**Sync Engine:**
```dart
group('Sync Engine', () {
  test('Merges non-conflicting changes', () async {
    final local = Task(id: '1', title: 'Local', dueDate: DateTime(2024, 12, 10));
    final server = Task(id: '1', title: 'Server', priority: 'high');
    
    final merged = await syncEngine.mergeRecords(local, server);
    
    // Should keep both changes
    expect(merged.title, 'Server'); // Server title
    expect(merged.dueDate, DateTime(2024, 12, 10)); // Local due date
    expect(merged.priority, 'high'); // Server priority
  });
  
  test('Queues offline changes for sync', () async {
    // Simulate offline
    syncEngine.setOffline(true);
    
    await taskRepository.createTask(Task(title: 'New Task'));
    
    final queue = await syncEngine.getPendingChanges();
    expect(queue.length, 1);
    expect(queue.first.operation, 'insert');
  });
});
```

**Offline Functionality:**
```dart
group('Offline Mode', () {
  testWidgets('Dashboard works offline', (tester) async {
    // Set up offline mode
    mockNetworkState(NetworkStatus.offline);
    
    await tester.pumpWidget(ShepherdApp());
    await tester.pumpAndSettle();
    
    // Verify dashboard loads from local data
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    
    // Verify can create task offline
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextField), 'Test Task');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    
    // Verify task appears in list
    expect(find.text('Test Task'), findsOneWidget);
  });
});
```

### Performance Testing

```dart
test('Dashboard loads in under 2 seconds', () async {
  // Set up realistic data volume
  await seedDatabase(
    tasks: 100,
    events: 50,
    people: 30
  );
  
  final stopwatch = Stopwatch()..start();
  
  final dashboard = await dashboardService.loadDashboard();
  
  stopwatch.stop();
  
  expect(stopwatch.elapsedMilliseconds, lessThan(2000));
});
```

### Manual Testing Checklist

**Phase 1 Checklist:**
- [ ] Create task → syncs to server
- [ ] Edit task offline → syncs when online
- [ ] Create event → appears in calendar
- [ ] Mark task complete → moves to completed
- [ ] Delete item → removed from all views
- [ ] Conflict resolution → merges correctly
- [ ] Offline mode → full functionality
- [ ] Sync queue → processes correctly

**Phase 2 Checklist:**
- [ ] Dashboard loads suggestions
- [ ] Suggestions are relevant
- [ ] Action buttons work
- [ ] Crisis mode triggers correctly
- [ ] Pastoral care warnings appear
- [ ] Sermon deadline warnings appear
- [ ] Workload warnings accurate
- [ ] Event prep reminders timely

**Phase 3 Checklist:**
- [ ] Activity logging captures data
- [ ] Pattern detection works
- [ ] Insights are meaningful
- [ ] Learned preferences apply
- [ ] Time estimates improve
- [ ] Notification timing adapts

**Phase 4 Checklist:**
- [ ] Imports work correctly
- [ ] Search finds relevant results
- [ ] Tags organize effectively
- [ ] Export preserves data
- [ ] Advanced settings functional

---

## Appendix

### Glossary

**Terms:**
- **Rule Engine**: Server-side algorithm that evaluates user data and generates suggestions
- **Smart Dashboard**: Main interface showing synthesized view of calendar, tasks, and suggestions
- **Suggestion**: Actionable recommendation from the rule engine (e.g., "Call Elder John")
- **Crisis Mode**: Special dashboard state when workload is impossible, requires triage
- **Pattern Learning**: Algorithm that analyzes user behavior and generates insights
- **Sync Queue**: Local queue of changes waiting to be synced to server
- **Optimistic Update**: UI updates immediately before server confirmation
- **Batching**: Grouping similar notifications or tasks together

### Tech Stack Summary

**Frontend:**
- Flutter (Dart)
- Riverpod/Provider (state management)
- SQLite/Drift (local database)
- flutter_local_notifications

**Backend:**
- Supabase (PostgreSQL)
- Edge Functions (Deno/TypeScript)
- Row-level security (RLS)

**Third-party:**
- Google Calendar API (optional)
- Phone contacts (iOS/Android APIs)

### Code Structure

```
shepherd/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── errors/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── datasources/
│   │   │   ├── local/ (SQLite)
│   │   │   └── remote/ (Supabase)
│   │   └── sync/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── presentation/
│   │   ├── dashboard/
│   │   ├── tasks/
│   │   ├── calendar/
│   │   ├── people/
│   │   ├── sermons/
│   │   ├── notes/
│   │   ├── settings/
│   │   └── widgets/ (shared)
│   └── services/
│       ├── auth_service.dart
│       ├── notification_service.dart
│       ├── sync_service.dart
│       └── analytics_service.dart
├── supabase/
│   ├── migrations/
│   ├── functions/
│   │   ├── generate-daily-smart-view/
│   │   └── analyze-patterns/
│   └── config.toml
└── test/
    ├── unit/
    ├── integration/
    └── widget/
```

### Environment Variables

```
# .env.development
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# .env.production
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Deployment

**Flutter (Mobile Apps):**
- iOS: App Store via TestFlight → Production
- Android: Google Play via Internal Testing → Production

**Supabase:**
- Hosted on Supabase cloud
- Database migrations via Supabase CLI
- Edge Functions deployed via CLI

### Monitoring & Analytics

**Production Monitoring:**
- Sentry/Firebase Crashlytics for crash reporting
- Firebase Analytics for usage metrics
- Supabase logs for backend errors

**Key Metrics:**
- Daily Active Users (DAU)
- Dashboard load time (P50, P95, P99)
- Sync success rate
- Notification engagement rate
- Crash-free users %

---

## Contact & Support

**Product Owner:** Ruben  
**Project Start:** Q1 2025  
**Timeline:** 16-20 weeks to feature-complete MVP

**Questions?** Refer to this document first, then reach out to Ruben for clarification.

---

**Document Version:** 1.0  
**Last Updated:** December 10, 2024
