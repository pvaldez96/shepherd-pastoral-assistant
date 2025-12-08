import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

/// Authentication service for Shepherd app
///
/// Handles all authentication operations including sign up, sign in,
/// sign out, and user state management using Supabase Auth.
class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  /// Sign up a new user with email and password
  ///
  /// Creates a new user account in Supabase Auth and sends a confirmation email.
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (min 6 characters)
  /// - [name]: User's full name (optional)
  /// - [churchName]: Name of user's church (optional)
  ///
  /// Returns:
  /// - [AuthResponse] containing user data and session
  ///
  /// Throws:
  /// - [AuthException] if signup fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final response = await authService.signUp(
  ///     email: 'pastor@church.com',
  ///     password: 'securePassword123',
  ///     name: 'John Doe',
  ///     churchName: 'First Community Church',
  ///   );
  ///   print('User created: ${response.user?.email}');
  /// } catch (e) {
  ///   print('Signup failed: $e');
  /// }
  /// ```
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
    String? churchName,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 Attempting to sign up user: $email');
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (name != null) 'name': name,
          if (churchName != null) 'church_name': churchName,
        },
      );

      if (kDebugMode) {
        print('✅ Sign up successful: ${response.user?.email}');
      }

      // After successful signup, create user profile in users table
      if (response.user != null) {
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          name: name,
          churchName: churchName,
        );
      }

      return response;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('❌ Sign up failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Authenticates user and creates a new session.
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns:
  /// - [AuthResponse] containing user data and session
  ///
  /// Throws:
  /// - [AuthException] if sign in fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final response = await authService.signIn(
  ///     email: 'pastor@church.com',
  ///     password: 'securePassword123',
  ///   );
  ///   print('Logged in: ${response.user?.email}');
  /// } catch (e) {
  ///   print('Login failed: $e');
  /// }
  /// ```
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 Attempting to sign in user: $email');
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ Sign in successful: ${response.user?.email}');
      }

      return response;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('❌ Sign in failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Sign out the current user
  ///
  /// Ends the current session and clears all stored credentials.
  ///
  /// Throws:
  /// - [AuthException] if sign out fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.signOut();
  ///   print('User signed out successfully');
  /// } catch (e) {
  ///   print('Sign out failed: $e');
  /// }
  /// ```
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('🔐 Attempting to sign out user');
      }

      await _supabase.auth.signOut();

      if (kDebugMode) {
        print('✅ Sign out successful');
      }
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('❌ Sign out failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get the current authenticated user
  ///
  /// Returns:
  /// - [User] object if user is authenticated
  /// - `null` if no user is logged in
  ///
  /// Example:
  /// ```dart
  /// final user = authService.getCurrentUser();
  /// if (user != null) {
  ///   print('Current user: ${user.email}');
  /// } else {
  ///   print('No user logged in');
  /// }
  /// ```
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Check if a user is currently authenticated
  ///
  /// Returns:
  /// - `true` if user is logged in
  /// - `false` if no user is logged in
  ///
  /// Example:
  /// ```dart
  /// if (authService.isAuthenticated()) {
  ///   // Show authenticated UI
  /// } else {
  ///   // Show login screen
  /// }
  /// ```
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  /// Get a stream of authentication state changes
  ///
  /// Listen to this stream to reactively update UI based on auth state.
  ///
  /// Returns:
  /// - [Stream<AuthState>] that emits events when auth state changes
  ///
  /// Example:
  /// ```dart
  /// authService.authStateChanges().listen((event) {
  ///   if (event.session != null) {
  ///     print('User logged in: ${event.session?.user.email}');
  ///   } else {
  ///     print('User logged out');
  ///   }
  /// });
  /// ```
  Stream<AuthState> authStateChanges() {
    return _supabase.auth.onAuthStateChange;
  }

  /// Send password reset email
  ///
  /// Sends a password reset link to the user's email address.
  ///
  /// Parameters:
  /// - [email]: User's email address
  ///
  /// Throws:
  /// - [AuthException] if request fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.resetPassword(email: 'pastor@church.com');
  ///   print('Password reset email sent');
  /// } catch (e) {
  ///   print('Failed to send reset email: $e');
  /// }
  /// ```
  Future<void> resetPassword({required String email}) async {
    try {
      if (kDebugMode) {
        print('🔐 Sending password reset email to: $email');
      }

      await _supabase.auth.resetPasswordForEmail(email);

      if (kDebugMode) {
        print('✅ Password reset email sent');
      }
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('❌ Password reset failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Update user password
  ///
  /// Updates the password for the currently authenticated user.
  ///
  /// Parameters:
  /// - [newPassword]: New password (min 6 characters)
  ///
  /// Throws:
  /// - [AuthException] if update fails
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.updatePassword(newPassword: 'newSecurePassword123');
  ///   print('Password updated successfully');
  /// } catch (e) {
  ///   print('Failed to update password: $e');
  /// }
  /// ```
  Future<void> updatePassword({required String newPassword}) async {
    try {
      if (kDebugMode) {
        print('🔐 Updating user password');
      }

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (kDebugMode) {
        print('✅ Password updated successfully');
      }
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('❌ Password update failed: ${e.message}');
      }
      rethrow;
    }
  }

  /// Private helper to create user profile in users table
  ///
  /// This is called after successful sign up to create the user's profile
  /// in the users table with RLS policies.
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? name,
    String? churchName,
  }) async {
    try {
      if (kDebugMode) {
        print('📝 Creating user profile in database');
      }

      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'name': name ?? email.split('@')[0],
        'church_name': churchName,
      });

      // Create default user settings
      await _supabase.from('user_settings').insert({
        'user_id': userId,
      });

      if (kDebugMode) {
        print('✅ User profile created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to create user profile: $e');
      }
      // Don't rethrow - signup was successful, profile creation is secondary
      // The profile can be created later if needed
    }
  }
}

/// Riverpod provider for AuthService
///
/// Provides a singleton instance of AuthService throughout the app.
///
/// Example usage:
/// ```dart
/// final authService = ref.watch(authServiceProvider);
/// await authService.signIn(email: 'test@example.com', password: 'password');
/// ```
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase);
});

/// Riverpod provider for current user (reactive)
///
/// Automatically updates when auth state changes.
///
/// Example usage:
/// ```dart
/// final user = ref.watch(currentUserStreamProvider);
/// user.when(
///   data: (user) {
///     if (user != null) {
///       return Text('Hello ${user.email}');
///     } else {
///       return Text('Not logged in');
///     }
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final currentUserStreamProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges().map((event) => event.session?.user);
});

/// Riverpod provider to check if user is authenticated
///
/// Returns true if user is logged in, false otherwise.
///
/// Example usage:
/// ```dart
/// final isAuthenticated = ref.watch(isAuthenticatedProvider);
/// if (isAuthenticated) {
///   return HomePage();
/// } else {
///   return LoginPage();
/// }
/// ```
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated();
});
