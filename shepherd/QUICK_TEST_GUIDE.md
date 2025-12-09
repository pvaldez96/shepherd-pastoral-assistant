# Quick Test Guide - Database Web Fix

## 🚀 Quick Verification (30 seconds)

### 1. Clear Browser Data
```
Chrome DevTools (F12) → Application → Storage → "Clear site data"
```

### 2. Run the App
```bash
cd shepherd
flutter run -d chrome
```

### 3. Check Console Output
Look for these logs in order:
```
✅ [Web DB] IndexedDB connection created successfully
✅ [Database] All tables created successfully
✅ [Main] Database initialized successfully
```

### 4. Verify IndexedDB Created
```
Chrome DevTools → Application → IndexedDB → shepherd_db_v3
```

Should see:
- `users` table
- `user_settings` table
- `sync_queue` table
- `tasks` table

### 5. Test Tasks Screen
- Navigate to Tasks
- Should load without "Failed to load tasks" error
- Create a test task
- Verify it appears in the list

## ✅ Success = All 5 Steps Pass

## 🔧 If It Fails

Run the test script:
```bash
# Add this to your test file or run directly
import 'package:shepherd/data/local/database_test_verification.dart';

void main() async {
  await testDatabaseInitialization();
}
```

Check console for detailed error messages.

## 📋 What Changed

### `lib/data/local/database.dart`
- Added `ensureInitialized()` method

### `lib/main.dart`
- Added database initialization call before `runApp()`

## 🎯 Key Fix

**Before**: Database connection created, but onCreate never called on web

**After**: Explicit `ensureInitialized()` call triggers onCreate migration

**Why**: Drift on web uses lazy migration - only runs on first query

## 🔍 Quick Debug Commands

### Check if database exists:
```javascript
// In browser console
indexedDB.databases().then(dbs => console.log(dbs))
```

### Delete database manually:
```javascript
// In browser console
indexedDB.deleteDatabase('shepherd_db_v3')
```

### Check current schema:
```dart
// In Dart
final db = AppDatabase();
await db.customSelect('PRAGMA user_version').getSingle();
```

## 📊 Expected Timeline

| Action | Time |
|--------|------|
| Clear browser data | 5 sec |
| `flutter run -d chrome` | 20-30 sec |
| Database initialization | <1 sec |
| Verify in DevTools | 5 sec |
| **Total** | **~35 sec** |

## 🎉 Done!

If all 5 steps pass, the database is working correctly on web.
