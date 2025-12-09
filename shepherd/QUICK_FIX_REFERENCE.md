# Quick Fix Reference - Flutter Web Database

## The Problem
```
Could not access the sql.js javascript library
```

## The Solution (3 Steps)

### Step 1: Download Required Files

```bash
cd c:\Users\Valdez\pastorapp\shepherd\web

# Download sqlite3.wasm (MUST match your sqlite3 version in pubspec.lock)
curl -L -o sqlite3.wasm "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-2.9.4/sqlite3.wasm"

# Download drift_worker.dart.js
curl -L -o drift_worker.dart.js "https://github.com/simolus3/drift/raw/drift-v2.14.0/drift/web/drift_worker.dart.js"
```

### Step 2: Update database_connection_web.dart

Change the import and implementation:

```dart
// OLD - DON'T USE
import 'package:drift/web.dart';
DatabaseConnection openConnection() {
  return DatabaseConnection(
    WebDatabase.withStorage(DriftWebStorage.indexedDb(...))
  );
}

// NEW - USE THIS
import 'package:drift/wasm.dart';
DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      final database = await WasmDatabase.open(
        databaseName: 'shepherd_db_v3',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.dart.js'),
      );
      return database.resolvedExecutor;
    }),
  );
}
```

### Step 3: Rebuild and Run

```bash
cd c:\Users\Valdez\pastorapp\shepherd
flutter pub run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

## Expected Success Output

```
✅ Supabase initialized successfully
🔄 [Database] Initializing database and running migrations...
🌐 [Web DB] Initializing WASM database with IndexedDB persistence...
💡 [Web DB] Using IndexedDB fallback storage
✅ [Web DB] WASM database connection created successfully
🔨 [Database] Creating all tables...
✅ [Database] All tables created successfully
✅ [Database] Database initialized successfully
✅ [Main] Database initialized successfully
```

## Verification Checklist

- [ ] `sqlite3.wasm` exists in `web/` folder (714KB)
- [ ] `drift_worker.dart.js` exists in `web/` folder (286KB)
- [ ] `database_connection_web.dart` imports `drift/wasm.dart`
- [ ] `database_connection_web.dart` uses `WasmDatabase.open()`
- [ ] Console shows success messages
- [ ] Chrome DevTools → Application → IndexedDB shows `drift_db/shepherd_db_v3`
- [ ] Tables visible in IndexedDB: users, user_settings, sync_queue, tasks

## Troubleshooting

### Error: "LinkError: WebAssembly.instantiate()"
**Cause**: Version mismatch between sqlite3.wasm and drift
**Fix**: Check pubspec.lock for sqlite3 version, download matching wasm file

### Error: "Could not access the sql.js"
**Cause**: Missing sqlite3.wasm or drift_worker.dart.js files
**Fix**: Download both files to web/ directory

### Error: "404 Not Found" for wasm files
**Cause**: Files not in web/ directory or wrong file names
**Fix**: Verify exact filenames: `sqlite3.wasm` and `drift_worker.dart.js`

## File Locations (Absolute Paths)

- Web assets: `c:\Users\Valdez\pastorapp\shepherd\web\`
- Database connection: `c:\Users\Valdez\pastorapp\shepherd\lib\data\local\database_connection_web.dart`
- Generated code: `c:\Users\Valdez\pastorapp\shepherd\lib\data\local\database.g.dart`

## Important Notes

1. **Version matters**: sqlite3.wasm MUST match the sqlite3 package version in pubspec.lock
2. **Both files required**: You need BOTH sqlite3.wasm AND drift_worker.dart.js
3. **Import change critical**: Must use `drift/wasm.dart` not `drift/web.dart`
4. **IndexedDB is normal**: Using IndexedDB fallback is expected behavior
5. **No sql.js needed**: WASM approach doesn't require sql.js library

## Quick Test Command

```bash
cd c:\Users\Valdez\pastorapp\shepherd && flutter run -d chrome 2>&1 | grep -E "\[Web DB\]|\[Database\]|\[Main\]"
```

You should see all success messages (✅) with no errors (❌).

---

**Last verified**: December 8, 2024
**Flutter version**: 3.38.3
**Drift version**: 2.28.2
**SQLite3 version**: 2.9.4
