// lib/data/local/database_connection_web.dart

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web database connection using WASM with IndexedDB persistence
///
/// For web platforms, we use sqlite3 compiled to WebAssembly (WASM) which
/// provides full SQLite functionality in the browser. Data is persisted using
/// IndexedDB or the File System Access API (when available).
///
/// Database name: shepherd_db_v3
///
/// Architecture:
/// 1. sqlite3.wasm provides the SQLite engine compiled to WebAssembly
/// 2. WasmDatabase manages the WASM module and database connection
/// 3. IndexedDB provides persistent storage (fallback when OPFS unavailable)
/// 4. File System Access API (OPFS) provides better performance when available
///
/// Reference: https://drift.simonbinder.eu/platforms/web/
DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      try {
        print('🌐 [Web DB] Initializing WASM database with IndexedDB persistence...');

        // Open database using WASM backend
        // This automatically selects the best storage implementation:
        // - File System Access API (OPFS) if available (better performance)
        // - IndexedDB as fallback (universal browser support)
        //
        // Note: The drift_worker.dart.js file is not currently available, but the database
        // still works in fallback mode. The console error about the worker is non-blocking.
        // TODO: Add proper drift_worker.dart.js file for optimized performance
        final database = await WasmDatabase.open(
          databaseName: 'shepherd_db_v3',
          sqlite3Uri: Uri.parse('sqlite3.wasm'),
          driftWorkerUri: Uri.parse('drift_worker.dart.js'), // Currently unavailable, using fallback
        );

        if (database.missingFeatures.isNotEmpty) {
          print('⚠️ [Web DB] Missing features: ${database.missingFeatures}');
          print('💡 [Web DB] Using IndexedDB fallback storage');
        } else {
          print('✅ [Web DB] Using OPFS (File System Access API) storage');
        }

        print('✅ [Web DB] WASM database connection created successfully');
        return database.resolvedExecutor;
      } catch (e, stackTrace) {
        print('❌ [Web DB] ERROR creating database connection: $e');
        print('❌ [Web DB] Stack trace: $stackTrace');
        rethrow;
      }
    }),
  );
}
