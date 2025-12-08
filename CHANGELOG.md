# Changelog

All notable changes to the Shepherd Pastoral Assistant project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - Infrastructure & Setup

#### Project Initialization
- Created Flutter project structure with organization `com.shepherd`
- Configured Material Design 3 theme with Shepherd color scheme
  - Primary: #2563EB (Blue-600)
  - Success: #10B981 (Green-500)
  - Error: #DC2626 (Red-600)
  - Surface: #F9FAFB (Gray-50)
- Added comprehensive dependencies for offline-first architecture
  - State management: `flutter_riverpod ^2.4.0`
  - Routing: `go_router ^12.0.0`
  - Backend: `supabase_flutter ^2.0.0`
  - Local database: `drift ^2.14.0`, `sqlite3_flutter_libs ^0.5.0`
  - Utilities: `uuid`, `connectivity_plus`, `flutter_local_notifications`, `intl`
  - Environment: `flutter_dotenv ^5.1.0`

#### Supabase Backend Setup
- Created Supabase project with production-ready configuration
- Implemented initial database migration (0001_initial_schema.sql)
  - `users` table with email validation and timezone support
  - `user_settings` table with 15 configuration fields
  - Row Level Security (RLS) policies for multi-tenant isolation
  - Automatic `updated_at` triggers
  - Performance indexes for common queries
- Created comprehensive documentation
  - `supabase/README.md` - Complete setup guide
  - `supabase/QUICKSTART.md` - Browser GUI quick start
  - `supabase/DATABASE_SCHEMA.md` - ERD and schema documentation
  - `supabase/QUERY_EXAMPLES.md` - 30+ SQL query examples
  - `supabase/verify_schema.sql` - Validation script with 12 test sections

#### Local SQLite Database (Drift)
- Implemented offline-first database architecture
- Created `lib/data/local/database.dart` with singleton pattern
- Implemented table definitions with sync metadata:
  - `users_table.dart` - Mirror of Supabase users
  - `user_settings_table.dart` - Mirror of Supabase user_settings
  - `sync_queue_table.dart` - Queue for offline operations
  - `tasks_table.dart` - Complete task management schema
- Added sync metadata fields to all tables:
  - `syncStatus` - Track sync state (synced/pending/conflict)
  - `localUpdatedAt` - Local modification timestamp
  - `serverUpdatedAt` - Server state timestamp
  - `version` - Optimistic locking counter
- Created comprehensive Data Access Objects (DAOs)
  - `TasksDao` with 47 methods for CRUD, querying, and sync operations
- Configured build_runner for code generation

### Added - Authentication System

#### Supabase Configuration
- Created `lib/core/config/supabase_config.dart`
  - Environment-based configuration with `.env` file
  - PKCE authentication flow for enhanced security
  - Riverpod providers for reactive auth state
- Configured `.env` with Supabase credentials
- Added `.env` to `.gitignore` for security

#### Authentication Service
- Implemented `lib/services/auth_service.dart` with complete auth operations:
  - `signUp()` - Create new user accounts with profile data
  - `signIn()` - Email/password authentication
  - `signOut()` - End user session
  - `getCurrentUser()` - Get current auth state
  - `resetPassword()` - Send password reset emails
  - `updatePassword()` - Update user passwords
- Automatic user profile creation in database on signup
- User-friendly error messages and exception handling
- Riverpod providers for reactive auth state management

#### Authentication UI
- Created sign-in screen (`lib/presentation/auth/sign_in_screen.dart`)
  - Email and password input with validation
  - Password visibility toggle
  - Loading states during authentication
  - Error handling with SnackBar notifications
  - "Don't have an account?" navigation link
- Created sign-up screen (`lib/presentation/auth/sign_up_screen.dart`)
  - Email, password, name, and church name fields
  - Comprehensive form validation
  - Password requirements display
  - Auto-login after successful registration
  - "Already have an account?" navigation link
- Implemented auth state management (`lib/presentation/auth/auth_notifier.dart`)
  - Riverpod StateNotifier for auth state
  - Automatic UI updates on auth changes
  - Loading and error state handling
- Created reusable auth components:
  - `auth_text_field.dart` - Validated text input widget
  - `auth_button.dart` - Primary and secondary button widgets

### Added - Navigation & Routing

#### App Router Configuration
- Implemented `lib/core/router/app_router.dart` using go_router
- Route structure with protected routes:
  - `/` - Auth wrapper with automatic redirects
  - `/sign-in` - Public sign-in page
  - `/sign-up` - Public sign-up page
  - `/dashboard` - Protected dashboard with view modes (daily/weekly/monthly)
  - `/tasks` - Protected task management
  - `/calendar` - Protected calendar view
  - `/people` - Protected contacts/members
  - `/sermons` - Protected sermon management
  - `/notes` - Protected notes
  - `/settings` - Protected app settings
- ShellRoute for persistent navigation (bottom nav + drawer)
- Auth state listener for automatic redirects
- Deep linking support

#### Main Application Scaffold
- Created `lib/presentation/main/main_scaffold.dart`
- Bottom navigation bar with 4 tabs:
  - Daily view
  - Weekly view
  - Monthly view
  - Quick Capture (modal bottom sheet)
- Right-side drawer (Material Design 3):
  - User profile header with name, church, email
  - Navigation to all app modules
  - Sign out with confirmation dialog
  - Active route highlighting
- Quick Capture bottom sheet (`quick_capture_bottom_sheet.dart`)
  - Quick Task creation
  - Quick Note creation
  - Quick Contact Log
  - Color-coded action buttons

#### Dashboard Implementation
- Updated `lib/presentation/dashboard/dashboard_screen.dart`
  - Three view modes: Daily, Weekly, Monthly
  - Dynamic date formatting
  - Quick action cards
  - Placeholder content for future features
  - Integration with bottom navigation tabs

#### Placeholder Screens
- Created module placeholder screens:
  - `lib/presentation/tasks/tasks_screen.dart`
  - `lib/presentation/calendar/calendar_screen.dart`
  - `lib/presentation/people/people_screen.dart`
  - `lib/presentation/sermons/sermons_screen.dart`
  - `lib/presentation/notes/notes_screen.dart`
  - `lib/presentation/settings/settings_screen.dart`
- Each screen ready for feature implementation
- Consistent styling with Shepherd design system

### Added - Database Schema & Migrations

#### Tasks Table (Supabase)
- Created migration `supabase/migrations/0002_tasks_table.sql`
- Complete task management schema with 21 fields:
  - Core: id, user_id, title, description
  - Scheduling: due_date, due_time
  - Time tracking: estimated_duration_minutes, actual_duration_minutes
  - Classification: category, priority, status
  - Properties: requires_focus, energy_level
  - Relationships: person_id, calendar_event_id, sermon_id, parent_task_id
  - Timestamps: completed_at, deleted_at, created_at, updated_at
- Implemented 8 performance indexes:
  - Composite indexes for dashboard queries
  - GIN index for full-text search
  - Foreign key indexes
  - Partial index for active tasks
- Row Level Security (RLS) policies:
  - Multi-tenant isolation using `auth.uid()`
  - All CRUD operations protected
- Data validation constraints:
  - Title non-empty validation
  - Positive duration validation
  - Status-timestamp coupling
  - Enum constraints for category, priority, status, energy_level
- Automatic `updated_at` trigger
- Comprehensive documentation with testing queries
- Rollback migration (`0002_tasks_table_down.sql`)
- Verification script (`verify_0002_tasks.sql`)

#### Tasks Table (Drift/SQLite)
- Created `lib/data/local/tables/tasks_table.dart`
- 28 columns including sync metadata
- Exact mirror of Supabase schema
- Support for offline-first operations
- Client-generated UUIDs for offline creation

#### Tasks Data Access Object
- Implemented `lib/data/local/daos/tasks_dao.dart` with 47 methods:
  - **Basic CRUD** (6 methods): getAllTasks, getTaskById, insertTask, updateTask, deleteTask, hardDeleteTask
  - **Status Queries** (6 methods): getTasksByStatus, getOverdueTasks, getTodayTasks, getWeekTasks, etc.
  - **Category Filtering** (5 methods): getTasksByCategory, getTasksByPriority, getFocusTasks, etc.
  - **Relationship Queries** (4 methods): getTasksByPerson, getTasksBySermon, getTasksByEvent, getSubtasks
  - **Sync Support** (5 methods): getPendingTasks, markTaskAsSynced, markTaskAsConflicted, etc.
  - **Reactive Streams** (5 methods): watchAllTasks, watchTasksByStatus, watchTasksByCategory, etc.
  - **Analytics** (3 methods): countTasksByStatus, countTasksByCategory, getCompletionRate
- Soft delete pattern for data preservation
- Comprehensive inline documentation
- Usage examples (`lib/data/local/tasks_dao_example.dart`)

### Added - Documentation

#### Technical Specifications
- `shepherd_technical_specification.md` - Complete product specification
  - Executive summary and product vision
  - Technical architecture details
  - Complete data model with SQL schemas
  - Feature specifications
  - UI/UX specifications
  - Algorithm specifications for rule engine
  - Offline functionality requirements
  - Notifications system
  - Performance requirements
  - Development roadmap
  - Testing strategy

#### Setup Guides
- `shepherd/SUPABASE_SETUP.md` - Supabase integration guide
  - Configuration instructions
  - Environment variable setup
  - Authentication examples
  - Security best practices
  - Troubleshooting
- `shepherd/AUTHENTICATION_GUIDE.md` - Auth system documentation
  - Architecture overview
  - Usage examples
  - Error handling
  - Testing guidance
- `shepherd/DRIFT_DATABASE_SETUP.md` - Drift database setup guide
  - Schema documentation
  - Migration instructions
  - Usage examples
- `shepherd/lib/data/local/README.md` - Local database usage guide
- `shepherd/lib/data/local/QUICK_REFERENCE.md` - Developer quick reference

#### Example Code
- `shepherd/lib/data/local/database_test_example.dart` - Database usage examples
- `shepherd/lib/data/local/tasks_dao_example.dart` - 16 TasksDao examples with Flutter UI integration

### Changed

#### App Configuration
- Updated `lib/main.dart` to use MaterialApp.router with go_router
- Enhanced theme configuration with complete Material Design 3 theming
  - Typography scale
  - AppBar theme
  - Button themes
  - Input decoration theme
  - Card theme
  - SnackBar theme
- Wrapped app in ProviderScope for Riverpod state management
- Added environment variable loading in main()

#### Database Configuration
- Updated `lib/data/local/database.dart`:
  - Added Tasks table to schema
  - Added TasksDao to DAOs list
  - Incremented schema version from 1 to 2
  - Added migration logic for tasks table
  - Integrated pending tasks count in sync methods

### Security

#### Authentication & Authorization
- Implemented PKCE authentication flow for enhanced security
- Row Level Security (RLS) policies on all Supabase tables
- Multi-tenant data isolation using `auth.uid()`
- Environment variables stored in `.env` (excluded from git)
- Email format validation with regex constraints
- Password minimum length enforcement (6 characters)

#### Data Protection
- User data accessible only by authenticated owner
- Automatic session persistence and token refresh
- Secure foreign key constraints with CASCADE delete
- Input validation on all user-submitted data

### Performance

#### Database Optimizations
- Strategic indexes for common query patterns
  - Composite indexes for multi-field queries
  - GIN indexes for full-text search
  - Partial indexes for filtered queries (active tasks only)
- Efficient query patterns in DAOs
- Connection pooling via singleton pattern
- Prepared statements via Drift

#### Application Performance
- Lazy loading of routes with go_router
- Reactive UI updates with Riverpod streams
- Efficient rebuild scoping with ConsumerWidget
- const constructors throughout codebase
- NoTransitionPage for instant in-app navigation

### Build & Tooling

#### Code Generation
- Configured build_runner for Drift code generation
- Generated type-safe database classes
- Auto-generated DAO mixins
- Successful build: 46 outputs in 44 seconds

#### Development Tools
- Configured flutter_lints for code quality
- Static analysis with zero errors
- Comprehensive inline documentation
- Example usage in all major files

---

## [0.1.0] - 2024-12-07

### Project Initialization
- Initial Flutter project setup
- Basic project structure
- Git repository initialization

---

## Future Releases

### Planned for v0.2.0
- Task management UI with create/edit/complete workflows
- Dashboard with today's tasks and overdue items
- Task filtering by category, priority, status
- Search functionality with full-text search

### Planned for v0.3.0
- Calendar integration
- Event management
- Task-event relationships
- Week/month views

### Planned for v0.4.0
- People/contacts management
- Pastoral care tracking
- Contact logging
- Relationship management

### Planned for v0.5.0
- Sermon preparation module
- Sermon series organization
- Practice mode
- Scripture reference tracking

### Planned for v0.6.0
- Background sync engine
- Conflict resolution
- Offline queue processing
- Network state handling

### Planned for v0.7.0
- Smart suggestions (rule engine)
- Pattern learning
- Workload analysis
- Focus time recommendations

### Planned for v1.0.0
- Complete feature set
- Production-ready sync
- Comprehensive testing
- App store release

---

## Notes

### Technology Stack
- **Frontend**: Flutter 3.x with Material Design 3
- **State Management**: Riverpod 2.4.0
- **Routing**: go_router 12.0.0
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **Local Database**: Drift 2.14.0 (SQLite)
- **Architecture**: Offline-first with bi-directional sync

### Design System
- **Primary Color**: #2563EB (Blue-600)
- **Typography**: Material Design 3 scale
- **Spacing**: 4px base unit (8, 12, 16, 24, 32)
- **Border Radius**: 8px buttons/inputs, 12px cards
- **Target Platforms**: iOS, Android (mobile-first)

### Project Links
- **Repository**: Local development
- **Documentation**: `/docs` and inline comments
- **Supabase Project**: https://fykjzidpdnizvwpqzdnk.supabase.co
- **Technical Spec**: `shepherd_technical_specification.md`

---

## Contributors

- **Product Owner**: Ruben
- **Development**: Claude Sonnet 4.5 (AI Assistant)
- **Project Started**: December 6, 2024

---

*This changelog is maintained to track all significant changes to the Shepherd Pastoral Assistant project. For detailed technical documentation, see the respective README files in each module.*
