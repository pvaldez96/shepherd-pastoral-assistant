# Settings Screen - Quick Reference Guide

## Overview
Comprehensive settings management for the Shepherd pastoral assistant app.

## Navigation

### Access Settings
```dart
// From anywhere in the app
context.go('/settings');

// Already accessible from:
// - Side drawer (hamburger menu) → "Settings"
```

## File Structure

```
lib/presentation/settings/
├── settings_screen.dart              # Main settings screen
├── providers/
│   └── settings_provider.dart        # Riverpod providers & repository
└── widgets/
    ├── settings_section_card.dart    # Reusable section card
    └── time_range_field.dart         # Time range picker widget
```

## Usage Examples

### Load User Settings
```dart
// In a ConsumerWidget
final userId = ref.watch(authNotifierProvider).user?.id;
final settingsAsync = ref.watch(userSettingsProvider(userId!));

settingsAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
  data: (settings) {
    if (settings == null) {
      return Text('No settings found');
    }
    return Text('Max daily hours: ${settings.maxDailyHours}');
  },
);
```

### Update Settings
```dart
// Get repository
final repository = ref.read(settingsRepositoryProvider);

// Update contact frequencies
await repository.updateContactFrequencies(
  settingsId: settings.id,
  elderContactFrequencyDays: 30,
  memberContactFrequencyDays: 90,
  crisisContactFrequencyDays: 3,
);

// Update sermon prep
await repository.updateSermonPrepSettings(
  settingsId: settings.id,
  weeklySermonPrepHours: 10,
);

// Update workload settings
await repository.updateWorkloadSettings(
  settingsId: settings.id,
  maxDailyHours: 8,
  minFocusBlockMinutes: 90,
);

// Update focus hours
await repository.updateFocusHours(
  settingsId: settings.id,
  preferredFocusHoursStart: '08:00',
  preferredFocusHoursEnd: '12:00',
);
```

### Create/Get Settings
```dart
final repository = ref.read(settingsRepositoryProvider);

// Get existing settings or create with defaults
final settings = await repository.getOrCreateSettings(userId);

// Create default settings
final newSettings = await repository.createDefaultSettings(userId);
```

## Widget Examples

### Settings Section Card
```dart
SettingsSectionCard(
  title: 'Notifications',
  subtitle: 'Control how you receive updates',
  icon: Icons.notifications_outlined,
  children: [
    SwitchListTile(
      title: Text('Push Notifications'),
      value: true,
      onChanged: (value) {
        // Handle change
      },
    ),
    SwitchListTile(
      title: Text('Email Notifications'),
      value: false,
      onChanged: (value) {
        // Handle change
      },
    ),
  ],
)
```

### Time Range Field
```dart
TimeRangeField(
  label: 'Office Hours',
  icon: Icons.business,
  startTime: '09:00',
  endTime: '17:00',
  onChanged: (start, end) {
    print('Office hours: $start to $end');
    // Save to database
    repository.updateFocusHours(
      settingsId: settings.id,
      preferredFocusHoursStart: start,
      preferredFocusHoursEnd: end,
    );
  },
)
```

## Default Settings Values

When settings are first created, these defaults are used:

| Setting | Default Value | Description |
|---------|--------------|-------------|
| Elder Contact Frequency | 30 days | Monthly check-ins with elders |
| Member Contact Frequency | 90 days | Quarterly check-ins with members |
| Crisis Contact Frequency | 3 days | Frequent support during crisis |
| Weekly Sermon Prep Hours | 8 hours | One full workday for sermon prep |
| Max Daily Hours | 10 hours | Prevent overwork |
| Min Focus Block | 120 minutes | 2 hours for deep work |
| Preferred Focus Hours | null | User sets their optimal focus time |

## Database Schema

```sql
user_settings
├── id (TEXT, PRIMARY KEY)
├── user_id (TEXT, UNIQUE, NOT NULL)
├── elder_contact_frequency_days (INTEGER, DEFAULT 30)
├── member_contact_frequency_days (INTEGER, DEFAULT 90)
├── crisis_contact_frequency_days (INTEGER, DEFAULT 3)
├── weekly_sermon_prep_hours (INTEGER, DEFAULT 8)
├── max_daily_hours (INTEGER, DEFAULT 10)
├── min_focus_block_minutes (INTEGER, DEFAULT 120)
├── preferred_focus_hours_start (TEXT, NULL)
├── preferred_focus_hours_end (TEXT, NULL)
├── sync_status (TEXT, DEFAULT 'synced')
├── local_updated_at (INTEGER, NULL)
├── server_updated_at (INTEGER, NULL)
├── version (INTEGER, DEFAULT 1)
├── created_at (INTEGER, NOT NULL)
└── updated_at (INTEGER, NOT NULL)
```

## UI Components

### User Profile Section
- **Name** - Editable text field
- **Email** - Read-only from auth (locked icon)
- **Church Name** - Editable text field
- **Timezone** - Dropdown (Eastern, Central, Mountain, Pacific)

### Personal Schedule Section
- **Wrestling Training Time** - Time range picker (UI only)
- **Work Shift Time** - Time range picker (UI only)
- **Family Protected Time** - Time range picker (UI only)
- **Preferred Focus Hours** - Time range picker (saved to DB)

### Contact Thresholds Section
- **Elder Contact Frequency** - Number input (days)
- **Member Contact Frequency** - Number input (days)
- **Crisis Contact Frequency** - Number input (days)

### Sermon Prep Section
- **Weekly Target Hours** - Number input (hours)

### Workload Management Section
- **Max Daily Hours** - Number input (hours)
- **Min Focus Block** - Number input (minutes)

### Account Section
- **Sign Out Button** - Red button with confirmation dialog

## State Management Flow

```
User Action
    ↓
onChange Handler
    ↓
setState (loading)
    ↓
Repository Method
    ↓
Database Update
    ↓
Mark as 'pending' sync
    ↓
Update timestamps
    ↓
StreamProvider detects change
    ↓
UI rebuilds with new data
    ↓
Show success SnackBar
    ↓
setState (not loading)
```

## Error Handling

### Load Errors
- Shows error icon and message
- Provides "Retry" button
- Logs error to console

### Save Errors
- Shows red SnackBar with error message
- Keeps previous values
- Allows retry

### Validation Errors
- Number fields: Ignores invalid input (negative, zero, text)
- Time ranges: Validates end after start, shows error SnackBar

## Sync Behavior

All settings changes are:
1. Saved to local database immediately
2. Marked as `sync_status = 'pending'`
3. Synced to Supabase in background (when online)
4. Marked as `sync_status = 'synced'` after successful sync

## Accessibility

- ✅ All touch targets are 44x44 minimum
- ✅ Proper semantic labels on all inputs
- ✅ Support for dynamic text sizing
- ✅ Screen reader compatible
- ✅ Clear visual feedback for all interactions
- ✅ High contrast text (4.5:1 ratio)

## Performance

- **Optimized**: StreamProvider watches database, minimal rebuilds
- **Auto-dispose**: Providers clean up when widget removed
- **Debounced**: Single save per field change, not per keystroke
- **Efficient**: Only updates changed fields, not entire record

## Common Tasks

### Add New Setting Field

1. **Update Database Schema** (if new column needed)
```dart
// In user_settings_table.dart
IntColumn get newSetting => integer().withDefault(const Constant(10))();
```

2. **Run Build Runner**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Add Repository Method**
```dart
// In settings_provider.dart
Future<void> updateNewSetting({
  required String settingsId,
  required int newSetting,
}) async {
  final companion = UserSettingsCompanion(
    newSetting: drift.Value(newSetting),
  );
  await updateSettings(settingsId, companion);
}
```

4. **Add UI Field**
```dart
// In settings_screen.dart
_buildNumberField(
  label: 'New Setting',
  icon: Icons.new_icon,
  initialValue: settings.newSetting,
  onChanged: (value) => _saveNewSetting(settings.id, value),
)
```

5. **Add Save Handler**
```dart
Future<void> _saveNewSetting(String settingsId, int value) async {
  setState(() => _isSaving = true);
  try {
    await ref.read(settingsRepositoryProvider)
      .updateNewSetting(settingsId: settingsId, newSetting: value);
    _showSnackBar('New setting saved');
  } catch (e) {
    _showSnackBar('Failed to save: $e', isError: true);
  } finally {
    setState(() => _isSaving = false);
  }
}
```

### Test Settings Screen

```bash
# Run the app
flutter run

# Or run on web
flutter run -d chrome

# Or run on specific device
flutter run -d <device-id>

# Navigate to settings via side drawer
```

## Troubleshooting

### Settings Not Loading
1. Check if user is authenticated
2. Verify database is initialized
3. Check console for error messages
4. Try invalidating provider: `ref.invalidate(userSettingsProvider(userId))`

### Settings Not Saving
1. Check if `_isSaving` is stuck at true
2. Verify network connection (for sync)
3. Check database write permissions
4. Review error messages in SnackBar

### Settings Reset to Defaults
1. Check if settings record exists in database
2. Verify userId is correct
3. Check if settings were archived/deleted
4. Review sync status and conflicts

## Integration Points

### Auth Integration
```dart
// Get current user
final authState = ref.watch(authNotifierProvider);
final userId = authState.user?.id;
final userEmail = authState.user?.email;

// Sign out
final authNotifier = ref.read(authNotifierProvider.notifier);
await authNotifier.signOut();
```

### Database Integration
```dart
// Direct database access (not recommended, use repository)
final database = ref.read(databaseProvider);
final settings = await database.getUserSettings(userId);
```

### Navigation Integration
```dart
// Navigate to settings
context.go('/settings');

// Navigate from settings
context.go('/dashboard');
context.pop(); // If pushed onto stack
```

## Best Practices

1. **Always use repository methods** - Don't access database directly
2. **Handle loading states** - Show indicators during async operations
3. **Provide feedback** - SnackBars for success/error
4. **Validate input** - Check ranges and formats
5. **Dispose controllers** - Prevent memory leaks
6. **Use const constructors** - Improve performance
7. **Follow design system** - Consistent UI/UX
8. **Add accessibility** - Screen reader support
9. **Document changes** - Clear comments for complex logic
10. **Test thoroughly** - All user flows and edge cases

## Related Files

- `lib/data/local/tables/user_settings_table.dart` - Database schema
- `lib/data/local/database.dart` - Database instance
- `lib/presentation/auth/auth_notifier.dart` - Authentication state
- `lib/core/router/app_router.dart` - Route configuration
- `shepherd_technical_specification.md` - Full requirements (Section 5.8)

## Next Steps

To extend the settings screen:
1. Add notification settings UI
2. Add sync & offline settings UI
3. Add data management UI
4. Add about section
5. Add learning & insights settings
6. Persist user profile changes (name, church, timezone)
7. Add personal schedule times to database schema
8. Implement timezone picker with search
9. Add settings import/export
10. Add settings backup/restore

---

**Questions or Issues?**
Refer to `SETTINGS_IMPLEMENTATION_SUMMARY.md` for detailed documentation.
