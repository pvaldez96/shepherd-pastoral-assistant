import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization
///
/// This class handles the initialization of the Supabase client with
/// credentials from environment variables and provides global access
/// to the Supabase client instance.
class SupabaseConfig {
  /// Private constructor to prevent instantiation
  SupabaseConfig._();

  /// Get Supabase URL from environment variables
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in .env file');
    }
    return url;
  }

  /// Get Supabase anon key from environment variables
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in .env file');
    }
    return key;
  }

  /// Initialize Supabase with environment configuration
  ///
  /// This should be called once during app startup, before runApp().
  ///
  /// Example:
  /// ```dart
  /// await SupabaseConfig.initialize();
  /// ```
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
        print('📍 URL: $supabaseUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Supabase: $e');
      }
      rethrow;
    }
  }

  /// Get the Supabase client instance
  ///
  /// This provides access to the initialized Supabase client.
  /// Make sure [initialize] has been called first.
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current auth state
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}

/// Riverpod provider for Supabase client
///
/// Provides access to the Supabase client throughout the app using Riverpod.
///
/// Example usage:
/// ```dart
/// final supabase = ref.watch(supabaseClientProvider);
/// final response = await supabase.from('users').select();
/// ```
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseConfig.client;
});

/// Riverpod provider for current user
///
/// Provides reactive access to the current authenticated user.
/// Returns null if no user is logged in.
///
/// Example usage:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   print('Logged in as: ${user.email}');
/// }
/// ```
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseConfig.currentUser;
});

/// Riverpod provider for auth state stream
///
/// Provides a stream of authentication state changes.
/// Use this to reactively update UI based on auth state.
///
/// Example usage:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   data: (event) {
///     if (event?.session != null) {
///       // User is logged in
///     } else {
///       // User is logged out
///     }
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});
