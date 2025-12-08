# Shepherd Project - Session Summary

**Date:** December 6-7, 2024
**Project:** Shepherd - Pastoral Assistant Application
**Status:** Foundation Complete, Ready for Feature Implementation

---

## Executive Summary

We've successfully established the complete foundation for the Shepherd pastoral assistant mobile app. The project uses an **offline-first architecture** with Flutter, Supabase (PostgreSQL), and Drift (SQLite) for seamless online/offline operation. Authentication, navigation, and database layers are fully implemented and production-ready.

---

## Project Vision

**Target User:** Solo pastors at small-to-medium churches (50-200 members) who handle:
- Regular preaching (weekly/bi-weekly)
- Personal pastoral care
- Administrative tasks
- Limited or no staff support

**Core Problem:** Pastors juggle multiple responsibilities without admin support and need a single tool that understands pastoral work patterns.

**Solution:** An intelligent assistant that:
- Synthesizes calendar, tasks, and pastoral care into one view
- Suggests what to do based on available time and priorities
- Tracks pastoral care frequency automatically
- Warns about overload and conflicts
- Learns user patterns over time

---

## Technical Architecture

### Stack Overview

```
┌─────────────────────────────────────────┐
│           Flutter Mobile App             │
│         (iOS/Android - Offline-First)    │
├─────────────────────────────────────────┤
│  UI Layer: Material Design 3 + Riverpod │
│  Navigation: go_router with ShellRoute  │
│  State: Riverpod (reactive)             │
├─────────────────────────────────────────┤
│  Local Database: Drift (SQLite)         │
│  - Offline storage with sync metadata   │
│  - Type-safe queries                    │
│  - Reactive streams                     │
├─────────────────────────────────────────┤
│  Sync Engine: Custom (Future)           │
│  - Queue-based operations               │
│  - Conflict resolution                  │
│  - Network state aware                  │
├─────────────────────────────────────────┤
│  Backend: Supabase                      │
│  - PostgreSQL database                  │
│  - Authentication (PKCE)                │
│  - Row Level Security                   │
│  - Real-time subscriptions              │
└─────────────────────────────────────────┘
```

### Key Architectural Decisions

1. **Offline-First**: All operations work locally first, sync happens in background
2. **Sync Metadata**: Every table has 4 sync fields (syncStatus, localUpdatedAt, serverUpdatedAt, version)
3. **Soft Deletes**: Use `deleted_at` timestamp instead of hard deletes for data preservation
4. **Client-Generated UUIDs**: Records created offline get UUIDs immediately (no server dependency)
5. **Multi-Tenant Isolation**: RLS policies ensure users only access their own data
6. **Material Design 3**: Modern UI with Shepherd color scheme

### Color Scheme

```dart
Primary:    #2563EB  (Blue-600)   - Main actions, navigation
Success:    #10B981  (Green-500)  - Positive actions, completion
Warning:    #F59E0B  (Orange-500) - Alerts, important items
Error:      #DC2626  (Red-600)    - Errors, destructive actions
Surface:    #F9FAFB  (Gray-50)    - Background
```

---

## Current Implementation Status

### ✅ Completed Components

#### 1. Project Infrastructure
- Flutter project initialized with `com.shepherd` organization
- Dependencies configured (Riverpod, go_router, Supabase, Drift, etc.)
- Material Design 3 theme with Shepherd colors
- Environment variable management (.env with Supabase credentials)

#### 2. Backend (Supabase)
- **Project URL**: `https://fykjzidpdnizvwpqzdnk.supabase.co`
- **Database Migrations**:
  - `0001_initial_schema.sql` - users, user_settings tables
  - `0002_tasks_table.sql` - complete task management schema
- **RLS Policies**: Multi-tenant isolation on all tables
- **Indexes**: Strategic indexes for common query patterns
- **Triggers**: Automatic `updated_at` timestamp updates
- **Documentation**: Comprehensive guides for SQL Editor setup

#### 3. Local Database (Drift/SQLite)
- **AppDatabase**: Singleton pattern, schema version 2
- **Tables Implemented**:
  - `users` - User profiles (mirrors Supabase)
  - `user_settings` - User preferences (15 config fields)
  - `sync_queue` - Queue for offline operations
  - `tasks` - Task management (28 columns with sync metadata)
- **TasksDao**: 47 methods for CRUD, querying, sync, and analytics
- **Build Runner**: Code generation working (46 outputs)

#### 4. Authentication System
- **Supabase Config**: PKCE flow with environment variables
- **Auth Service**: Complete operations (signUp, signIn, signOut, resetPassword, etc.)
- **UI Screens**:
  - Sign In screen with validation and loading states
  - Sign Up screen with profile fields
- **State Management**: Riverpod providers for reactive auth state
- **Automatic Profile Creation**: Creates user record in database on signup

#### 5. Navigation & Routing
- **go_router Configuration**: 8 routes with auth guards
- **Main Scaffold**:
  - Bottom navigation (Daily, Weekly, Monthly, Quick Capture)
  - Right-side drawer with user profile and menu
  - Persistent across screens (ShellRoute)
- **Routes**:
  - `/` - Auth wrapper
  - `/sign-in`, `/sign-up` - Public auth pages
  - `/dashboard` - Protected (supports view query param)
  - `/tasks`, `/calendar`, `/people`, `/sermons`, `/notes`, `/settings` - Protected placeholders
- **Dashboard**: Three view modes implemented (daily/weekly/monthly)

#### 6. Documentation
- Technical specification (115 pages)
- Setup guides (Supabase, Auth, Drift)
- Quick reference documents
- Example code files
- CHANGELOG.md tracking all progress

---

## File Structure Overview

```
pastorapp/
├── shepherd_technical_specification.md    # Complete product spec
├── CHANGELOG.md                           # Project changelog
├── session_summary.md                     # This file
│
├── supabase/                              # Backend database
│   ├── migrations/
│   │   ├── 0001_initial_schema.sql       # Users & settings
│   │   ├── 0002_tasks_table.sql          # Tasks table
│   │   └── verify_0002_tasks.sql         # Verification script
│   ├── README.md                          # Setup guide
│   ├── QUICKSTART.md                      # Browser GUI guide
│   └── DATABASE_SCHEMA.md                 # Schema documentation
│
└── shepherd/                              # Flutter app
    ├── .env                               # Supabase credentials (gitignored)
    ├── pubspec.yaml                       # Dependencies
    │
    └── lib/
        ├── main.dart                      # App entry point
        │
        ├── core/
        │   ├── config/
        │   │   └── supabase_config.dart   # Supabase initialization
        │   └── router/
        │       └── app_router.dart        # go_router configuration
        │
        ├── services/
        │   └── auth_service.dart          # Authentication operations
        │
        ├── data/
        │   └── local/
        │       ├── database.dart          # Main AppDatabase (Drift)
        │       ├── tables/
        │       │   ├── users_table.dart
        │       │   ├── user_settings_table.dart
        │       │   ├── sync_queue_table.dart
        │       │   └── tasks_table.dart
        │       └── daos/
        │           └── tasks_dao.dart     # Task data access (47 methods)
        │
        └── presentation/
            ├── auth/
            │   ├── sign_in_screen.dart
            │   ├── sign_up_screen.dart
            │   ├── auth_notifier.dart
            │   └── widgets/
            │       ├── auth_text_field.dart
            │       └── auth_button.dart
            │
            ├── main/
            │   ├── main_scaffold.dart
            │   └── widgets/
            │       └── quick_capture_bottom_sheet.dart
            │
            └── [dashboard, tasks, calendar, people, sermons, notes, settings]/
                └── *_screen.dart          # Placeholder screens
```

---

## Database Schema

### Supabase (PostgreSQL)

#### users
- `id` (UUID PK) - User unique identifier
- `email` (TEXT UNIQUE) - Email for authentication
- `name` (TEXT) - Pastor's full name
- `church_name` (TEXT) - Church they serve
- `timezone` (TEXT) - IANA timezone (default: America/Chicago)
- `created_at`, `updated_at` (TIMESTAMPTZ)

#### user_settings
- `id` (UUID PK)
- `user_id` (UUID FK) - One-to-one with users
- Contact frequency defaults (elder, member, crisis)
- Sermon prep hours (default 8)
- Workload limits (max daily hours, min focus block)
- Focus time preferences (start/end times)
- Notification preferences (JSONB)
- Offline cache settings
- Auto-archive settings
- `created_at`, `updated_at`

#### tasks
- `id` (UUID PK)
- `user_id` (UUID FK) - Owner
- `title`, `description` - Task details
- `due_date`, `due_time` - When due
- `estimated_duration_minutes`, `actual_duration_minutes` - Time tracking
- `category` - sermon_prep, pastoral_care, admin, personal, worship_planning
- `priority` - low, medium, high, urgent
- `status` - not_started, in_progress, done, deleted
- `requires_focus` (BOOLEAN) - Needs uninterrupted time
- `energy_level` - low, medium, high
- `person_id`, `calendar_event_id`, `sermon_id`, `parent_task_id` - Relationships (FKs pending)
- `completed_at`, `deleted_at` - Soft delete timestamps
- `created_at`, `updated_at`
- **8 Indexes** including full-text search

### Drift/SQLite (Local)

**Same schemas as Supabase PLUS 4 sync metadata fields:**
- `syncStatus` (TEXT) - 'synced', 'pending', 'conflict'
- `localUpdatedAt` (INTEGER) - Unix milliseconds
- `serverUpdatedAt` (INTEGER) - Unix milliseconds (nullable)
- `version` (INTEGER) - Optimistic locking counter

---

## Key Implementation Details

### Authentication Flow

1. User opens app → Check auth state
2. Not authenticated → Show `/sign-in`
3. User signs in → AuthService.signIn()
4. Creates session in Supabase Auth
5. Router detects auth change → Redirects to `/dashboard`
6. All subsequent API calls use auth.uid() for RLS

### Task Creation Flow (Future)

1. User taps "Quick Capture" → Bottom sheet opens
2. User selects "Quick Task" → Task form appears
3. User fills title, category, priority → Taps "Save"
4. **Offline-first sequence**:
   - Generate UUID for task
   - Insert into Drift with `syncStatus='pending'`
   - Add to `sync_queue` table
   - UI updates immediately (optimistic)
5. **Background sync**:
   - Sync engine detects pending task
   - Uploads to Supabase
   - Updates `syncStatus='synced'` with `serverUpdatedAt`

### Conflict Resolution Strategy (To Implement)

1. Detect conflict: `localUpdatedAt` > `serverUpdatedAt` AND server has newer version
2. Mark as `syncStatus='conflict'`
3. Present conflict resolution UI to user
4. User chooses: Keep Local, Use Server, or Merge
5. Apply resolution and increment version

---

## Development Workflow

### Running the App

```bash
cd shepherd
flutter run
# Choose Chrome (option 2) for quick testing
# Or choose Windows/Android/iOS for full experience
```

### Applying Supabase Migrations

**Via Browser (Current Method):**
1. Go to Supabase Dashboard: https://app.supabase.com
2. Open SQL Editor
3. Copy migration file contents
4. Paste and Execute

### Generating Drift Code

```bash
cd shepherd
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing Authentication

1. Run app → Shows Sign In screen
2. Click "Sign up" → Fill registration form
3. Creates account → Auto-redirects to Dashboard
4. Open drawer → Click "Sign Out" → Confirms → Back to Sign In

---

## Important Configuration

### Environment Variables (.env)

```env
SUPABASE_URL=https://fykjzidpdnizvwpqzdnk.supabase.co
SUPABASE_ANON_KEY=eyJhbGci... (full key in file)
```

**Security Notes:**
- `.env` is in `.gitignore` - NEVER commit to git
- Use `.env.example` for team members
- Rotate keys if accidentally exposed

### Database Versions

- **Supabase Schema**: Version 2 (users, user_settings, tasks)
- **Drift Schema**: Version 2 (matches Supabase + sync metadata)

---

## Next Steps & Roadmap

### Immediate Next Steps (v0.2.0)

1. **Task Management UI**
   - Task list screen with filtering (status, category, priority)
   - Task detail/edit screen
   - Task creation from Quick Capture
   - Mark tasks as complete
   - Swipe actions (complete, delete)

2. **Dashboard Enhancements**
   - Show actual tasks (not placeholders)
   - Overdue tasks section
   - Today's tasks section
   - Quick stats (# tasks due today, overdue count)

3. **Search & Filtering**
   - Full-text search using GIN index
   - Filter by multiple criteria
   - Sort by due date, priority, category

### Future Milestones

**v0.3.0 - Calendar Integration**
- Calendar events table (migration 0003)
- Week/month views
- Event creation and editing
- Task-event relationships

**v0.4.0 - People/Contacts**
- People table (migration 0004)
- Contact categories (elder, member, visitor, crisis)
- Pastoral care tracking
- Contact frequency monitoring
- Milestone tracking (birthdays, anniversaries)

**v0.5.0 - Sermon Preparation**
- Sermon series and sermons tables (migration 0005)
- Sermon prep workflow
- Scripture reference tracking
- Practice mode with timer
- Prep progress tracking

**v0.6.0 - Background Sync**
- Sync engine implementation
- Network state detection
- Conflict resolution UI
- Batch sync operations
- Sync status indicators

**v0.7.0 - Smart Suggestions**
- Rule engine implementation
- Pattern learning from user behavior
- Workload analysis
- Focus time recommendations
- Pastoral care suggestions

**v1.0.0 - Production Release**
- Complete feature set
- Comprehensive testing
- Performance optimization
- App store deployment (iOS + Android)

---

## Dependencies & Versions

### Core Dependencies

```yaml
flutter: SDK
flutter_riverpod: ^2.4.0      # State management
riverpod_annotation: ^2.3.0
go_router: ^12.0.0             # Routing
supabase_flutter: ^2.0.0       # Backend
drift: ^2.14.0                 # Local database
sqlite3_flutter_libs: ^0.5.0
path_provider: ^2.1.0
uuid: ^4.0.0                   # Client-generated IDs
connectivity_plus: ^5.0.0      # Network detection
flutter_dotenv: ^5.1.0         # Environment variables
intl: ^0.18.0                  # Date formatting
```

### Dev Dependencies

```yaml
build_runner: ^2.4.0
riverpod_generator: ^2.3.0
drift_dev: ^2.14.0
mockito: ^5.4.0
flutter_lints: ^6.0.0
```

---

## Testing Strategy (Planned)

### Unit Tests
- DAO methods (TasksDao, etc.)
- Auth service operations
- Data models and converters

### Widget Tests
- Auth screens
- Task list and detail screens
- Dashboard views

### Integration Tests
- Auth flow (sign up → sign in → sign out)
- Task CRUD operations
- Sync scenarios (create offline → sync online)

### Golden Tests
- Visual regression testing
- Component library screenshots

---

## Common Commands

```bash
# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Generate Drift code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (Drift)
flutter pub run build_runner watch

# Get dependencies
flutter pub get

# Check outdated packages
flutter pub outdated

# Clean build
flutter clean
```

---

## Known Issues & TODOs

### Current Limitations

1. **Foreign Keys Pending**: Tasks table has person_id, sermon_id, calendar_event_id columns but FK constraints not added yet (waiting for those tables)
2. **Sync Engine Not Implemented**: Tasks marked as 'pending' but no background sync yet
3. **Network Detection Not Active**: connectivity_plus installed but not integrated
4. **Notifications Not Configured**: flutter_local_notifications installed but not set up

### Technical Debt

- Add migration to enable foreign key constraints when missing tables are created
- Implement proper error boundaries in UI
- Add retry logic for failed operations
- Implement exponential backoff for sync retries

---

## Design Patterns Used

### Architecture Patterns
- **Repository Pattern**: DAOs abstract database operations
- **Singleton Pattern**: AppDatabase single instance
- **Observer Pattern**: Riverpod streams for reactive UI
- **Command Pattern**: Sync queue for offline operations

### UI Patterns
- **Scaffold + Navigation**: Consistent layout with bottom nav + drawer
- **Provider Pattern**: Riverpod for dependency injection
- **Stream Builder**: Reactive UI updates from database
- **Form Validation**: Reusable validators in auth widgets

### Data Patterns
- **Soft Delete**: Use timestamps, never hard delete
- **Optimistic Locking**: Version field prevents lost updates
- **Event Sourcing**: Sync queue tracks all operations
- **CQRS**: Separate read/write paths in DAOs

---

## Important Links & Resources

### Project Resources
- **Technical Spec**: `shepherd_technical_specification.md`
- **Changelog**: `CHANGELOG.md`
- **Supabase Dashboard**: https://app.supabase.com
- **Supabase Docs**: https://supabase.com/docs

### Learning Resources
- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod**: https://riverpod.dev
- **go_router**: https://pub.dev/packages/go_router
- **Drift**: https://drift.simonbinder.eu

---

## Contact & Collaboration

**Product Owner**: Ruben
**Development**: Claude Sonnet 4.5 (AI Assistant)
**Project Start**: December 6, 2024
**Current Status**: Foundation complete, ready for feature development

---

## Session Context for Future Work

### What's Working
✅ Authentication (sign up, sign in, sign out)
✅ Navigation (all routes, bottom nav, drawer)
✅ Database setup (Supabase + Drift with sync metadata)
✅ Task schema (Supabase migration applied, Drift table ready)
✅ TasksDao (47 methods for all task operations)
✅ Theme and design system

### What's Next
🎯 Build task list UI with TasksDao
🎯 Implement task creation and editing
🎯 Add search and filtering
🎯 Build Quick Capture bottom sheet functionality
🎯 Show real data in dashboard (not placeholders)

### Quick Start for Next Session

1. **Continue from here**:
   ```bash
   cd shepherd
   flutter run
   ```

2. **Check current state**:
   - Sign in works? ✅
   - Dashboard loads? ✅
   - Navigation works? ✅
   - Database connected? ✅

3. **Start building features**:
   - Use `TasksDao` from `AppDatabase.instance.tasksDao`
   - Use `StreamBuilder` with `watchTasksByStatus()`
   - Reference `tasks_dao_example.dart` for usage patterns

4. **Reference files**:
   - Technical spec for requirements
   - CHANGELOG.md for what's been done
   - This file for architecture decisions

---

**Last Updated**: December 7, 2024
**Ready for**: Task Management UI Implementation (v0.2.0)
