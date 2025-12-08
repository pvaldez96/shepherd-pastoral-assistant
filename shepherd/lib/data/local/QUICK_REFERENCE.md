# Drift Database - Quick Reference Card

## 🚀 Getting Started

```dart
import 'package:shepherd/data/local/database.dart';

final db = AppDatabase();  // Singleton - same instance everywhere
```

---

## 📦 Generated Classes

| Table | Data Class | Companion Class | Purpose |
|-------|------------|-----------------|---------|
| `users` | `User` | `UsersCompanion` | User profiles |
| `user_settings` | `UserSetting` | `UserSettingsCompanion` | User preferences |
| `sync_queue` | `SyncQueueEntry` | `SyncQueueCompanion` | Sync queue |

---

## ✏️ Create (INSERT)

```dart
// Users
final userCompanion = UsersCompanion.insert(
  email: 'pastor@church.com',
  name: 'John Smith',
  churchName: const Value('First Baptist'),  // Optional field
);
await db.into(db.users).insert(userCompanion);

// User Settings
final settingsCompanion = UserSettingsCompanion.insert(
  userId: userId,
  elderContactFrequencyDays: const Value(30),
  weeklySermonPrepHours: const Value(10),
);
await db.into(db.userSettings).insert(settingsCompanion);

// Sync Queue
final queueCompanion = SyncQueueCompanion.insert(
  affectedTable: 'users',
  recordId: userId,
  operation: 'update',
  payload: Value(jsonEncode({'name': 'Updated'})),
);
await db.into(db.syncQueue).insert(queueCompanion);
```

---

## 🔍 Read (SELECT)

```dart
// By ID (convenience method)
final user = await db.getUserById(userId);
final settings = await db.getUserSettings(userId);

// By email (convenience method)
final user = await db.getUserByEmail('pastor@church.com');

// Custom query
final user = await (db.select(db.users)
  ..where((u) => u.email.equals('pastor@church.com'))
).getSingleOrNull();

// Get all users
final allUsers = await db.select(db.users).get();

// Filtered query
final pendingUsers = await (db.select(db.users)
  ..where((u) => u.syncStatus.equals('pending'))
).get();

// Join query
final query = db.select(db.users).join([
  innerJoin(
    db.userSettings,
    db.userSettings.userId.equalsExp(db.users.id),
  ),
]);
final results = await query.get();
```

---

## 🔄 Update (UPDATE)

```dart
// Update specific fields
await (db.update(db.users)..where((u) => u.id.equals(userId))).write(
  UsersCompanion(
    name: const Value('Updated Name'),
    churchName: const Value('New Church'),
    syncStatus: const Value('pending'),
    localUpdatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ),
);

// Mark as pending sync (convenience method)
await db.markUserAsPending(userId);
await db.markUserSettingsAsPending(settingsId);

// Update user settings
await (db.update(db.userSettings)..where((s) => s.userId.equals(userId))).write(
  UserSettingsCompanion(
    elderContactFrequencyDays: const Value(21),
    syncStatus: const Value('pending'),
  ),
);
```

---

## ❌ Delete (DELETE)

```dart
// Delete user (cascade deletes settings automatically)
await (db.delete(db.users)..where((u) => u.id.equals(userId))).go();

// Delete sync queue entry
await db.removeSyncQueueEntry(queueEntryId);

// Clear all data (logout)
await db.clearAllData();
```

---

## 🔄 Transactions

```dart
await db.transaction(() async {
  // All operations succeed or all rollback
  await db.into(db.users).insert(userCompanion);
  await db.into(db.userSettings).insert(settingsCompanion);
  await db.into(db.syncQueue).insert(queueCompanion);
});
```

---

## 🔄 Sync Queue Operations

```dart
// Get all pending operations (FIFO order)
final queue = await db.getPendingSyncQueue();

// Get pending ops for specific table
final userOps = await db.getSyncQueueForTable('users');

// Update sync failure
await db.updateSyncQueueFailure(
  queueEntryId,
  'Network error: Unable to reach server',
);

// Remove successful operation
await db.removeSyncQueueEntry(queueEntryId);

// Get pending sync counts
final counts = await db.getPendingSyncCounts();
// Returns: {'users': 3, 'user_settings': 1}
```

---

## 📊 Common Query Patterns

```dart
// Count records
final count = await db.users.count().getSingle();

// Limit results
final recentUsers = await (db.select(db.users)
  ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
  ..limit(10)
).get();

// Pagination
final page2 = await (db.select(db.users)
  ..limit(20, offset: 20)
).get();

// Multiple conditions (AND)
final filtered = await (db.select(db.users)
  ..where((u) => u.syncStatus.equals('pending'))
  ..where((u) => u.email.like('%@church.com'))
).get();

// OR conditions
final filtered = await (db.select(db.users)
  ..where((u) => u.syncStatus.equals('pending') | u.syncStatus.equals('conflict'))
).get();

// NULL checks
final withoutChurch = await (db.select(db.users)
  ..where((u) => u.churchName.isNull())
).get();

// Ordering
final sorted = await (db.select(db.users)
  ..orderBy([
    (u) => OrderingTerm.asc(u.name),
    (u) => OrderingTerm.desc(u.createdAt),
  ])
).get();
```

---

## 🔧 Companion Classes

```dart
// Companion for INSERT (required fields only)
final insertCompanion = UsersCompanion.insert(
  email: 'required@example.com',  // Required
  name: 'Required Name',          // Required
  churchName: const Value('Optional Church'),  // Optional
);

// Companion for UPDATE (all fields optional)
final updateCompanion = UsersCompanion(
  name: const Value('New Name'),      // Only update name
  updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
);

// Value.absent() - Don't update this field
final partial = UsersCompanion(
  name: const Value('New Name'),
  email: const Value.absent(),  // Don't change email
);
```

---

## 🛠️ Build Runner Commands

```bash
# Generate code (run after schema changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean
```

---

## 🧪 Testing

```dart
import 'package:drift/native.dart';

// In-memory database for testing
final testDb = AppDatabase.testConstructor(NativeDatabase.memory());

// Add test constructor to database.dart:
// AppDatabase.testConstructor(QueryExecutor e) : super(e);
```

---

## 📝 Sync Metadata (on every table)

```dart
TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
IntColumn get localUpdatedAt => integer().nullable()();
IntColumn get serverUpdatedAt => integer().nullable()();
IntColumn get version => integer().withDefault(const Constant(1))();
```

**Values:**
- `syncStatus`: `'synced'`, `'pending'`, or `'conflict'`
- `localUpdatedAt`: Unix timestamp (ms) when locally modified
- `serverUpdatedAt`: Unix timestamp (ms) of last server state
- `version`: Incremented on each update (optimistic locking)

---

## 🎯 Best Practices

### ✅ DO

```dart
// Use transactions for related operations
await db.transaction(() async {
  await db.into(db.users).insert(user);
  await db.into(db.userSettings).insert(settings);
});

// Filter in SQL, not in Dart
final filtered = await (db.select(db.users)
  ..where((u) => u.name.like('J%'))
).get();

// Use convenience methods
final user = await db.getUserById(userId);

// Mark records as pending after local changes
await db.markUserAsPending(userId);
```

### ❌ DON'T

```dart
// Don't filter in Dart (loads entire table!)
final allUsers = await db.select(db.users).get();
final filtered = allUsers.where((u) => u.name.startsWith('J'));

// Don't forget to mark as pending
await (db.update(db.users)..where(...)).write(...);
// Missing: await db.markUserAsPending(userId);

// Don't hardcode UUIDs
final user = UsersCompanion.insert(
  id: Value('hardcoded-uuid'),  // ❌ Bad
);
// Let clientDefault generate it automatically
```

---

## 🔐 Foreign Keys

```dart
// Enabled automatically in migration:
await customStatement('PRAGMA foreign_keys = ON');

// Cascade delete configured on user_settings:
TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();

// When user deleted, settings automatically deleted
```

---

## 📍 Database Location

```
Android: /data/data/com.shepherd.app/app_flutter/shepherd.sqlite
iOS: <App Documents>/shepherd.sqlite
Desktop: <User Documents>/shepherd.sqlite
```

Check logs for exact path:
```
Database location: /data/data/...
```

---

## 🐛 Debugging

```dart
// Print query results
final users = await db.select(db.users).get();
print('Users: ${users.map((u) => u.email).join(', ')}');

// Check sync status
final counts = await db.getPendingSyncCounts();
print('Pending sync: $counts');

// View sync queue
final queue = await db.getPendingSyncQueue();
for (final entry in queue) {
  print('${entry.operation} ${entry.affectedTable}/${entry.recordId}');
}
```

---

## 📚 Resources

- Full guide: `lib/data/local/README.md`
- Complete setup: `DRIFT_DATABASE_SETUP.md`
- Test examples: `lib/data/local/database_test_example.dart`
- Drift docs: https://drift.simonbinder.eu/

---

**Quick tip:** All IDE errors before running `build_runner` are expected. They disappear after code generation.
