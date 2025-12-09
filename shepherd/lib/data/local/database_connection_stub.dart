// lib/data/local/database_connection_stub.dart

import 'package:drift/drift.dart';

/// Platform-agnostic database connection interface
///
/// This stub declares the openConnection function signature.
/// Actual implementations are provided by:
/// - database_connection_native.dart (mobile/desktop)
/// - database_connection_web.dart (web)
///
/// The correct implementation is selected at compile time using conditional imports.
DatabaseConnection openConnection() {
  throw UnimplementedError(
    'Database connection not implemented for this platform. '
    'Expected either native or web implementation.',
  );
}
