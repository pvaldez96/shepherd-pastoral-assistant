// lib/data/local/database_connection_native.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Native database connection for mobile and desktop platforms
///
/// Uses SQLite via dart:ffi for high-performance local storage.
/// Platform-specific database file location:
/// - iOS: Application Documents Directory
/// - Android: Application Documents Directory
/// - Desktop: Application Documents Directory
///
/// File name: shepherd.sqlite
DatabaseConnection openConnection() {
  return DatabaseConnection(
    LazyDatabase(() async {
      // Get platform-specific documents directory
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'shepherd.sqlite'));

      // Log database location for debugging
      print('Database location: ${file.path}');

      // Create NativeDatabase with platform-specific file
      return NativeDatabase(file);
    }),
  );
}
