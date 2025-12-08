import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

/// Authentication state managed by AuthNotifier
@immutable
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  // Helper to clear error
  AuthState clearError() {
    return copyWith(errorMessage: null);
  }
}

/// Auth state notifier for managing authentication operations
///
/// Handles sign in, sign up, sign out, and maintains current auth state.
/// Works with AuthService to perform actual authentication operations.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initialize();
  }

  /// Initialize by checking current auth state
  void _initialize() {
    final user = _authService.getCurrentUser();
    if (user != null) {
      state = AuthState(
        user: user,
        isAuthenticated: true,
      );
    }

    // Listen to auth state changes
    _authService.authStateChanges().listen((authState) {
      if (authState.session != null) {
        state = AuthState(
          user: authState.session!.user,
          isAuthenticated: true,
        );
      } else {
        state = const AuthState(
          user: null,
          isAuthenticated: false,
        );
      }
    });
  }

  /// Sign in with email and password
  ///
  /// Returns true if sign in was successful, false otherwise.
  /// Sets error message in state if sign in fails.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    // Set loading state
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AuthState(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sign in failed. Please try again.',
        );
        return false;
      }
    } on AuthException catch (e) {
      // Handle specific auth errors
      String errorMessage = _getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return false;
    } catch (e) {
      // Handle unexpected errors
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      if (kDebugMode) {
        print('Unexpected sign in error: $e');
      }
      return false;
    }
  }

  /// Sign up with email, password, and optional user details
  ///
  /// Returns true if sign up was successful, false otherwise.
  /// Sets error message in state if sign up fails.
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
    String? churchName,
  }) async {
    // Set loading state
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        churchName: churchName,
      );

      if (response.user != null) {
        state = AuthState(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sign up failed. Please try again.',
        );
        return false;
      }
    } on AuthException catch (e) {
      // Handle specific auth errors
      String errorMessage = _getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return false;
    } catch (e) {
      // Handle unexpected errors
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
      if (kDebugMode) {
        print('Unexpected sign up error: $e');
      }
      return false;
    }
  }

  /// Sign out the current user
  ///
  /// Returns true if sign out was successful, false otherwise.
  Future<bool> signOut() async {
    // Set loading state
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.signOut();
      state = const AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign out. Please try again.',
      );
      if (kDebugMode) {
        print('Sign out error: $e');
      }
      return false;
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.clearError();
  }

  /// Convert AuthException to user-friendly error message
  String _getErrorMessage(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password. Please try again.';
      case 'Email not confirmed':
        return 'Please confirm your email address before signing in.';
      case 'User already registered':
        return 'This email is already registered. Please sign in instead.';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';
      default:
        // Check if it's a network error
        if (e.message.toLowerCase().contains('network') ||
            e.message.toLowerCase().contains('connection')) {
          return 'No internet connection. Please check your network and try again.';
        }
        // Return the original message if we don't have a specific mapping
        return e.message.isNotEmpty
            ? e.message
            : 'Authentication failed. Please try again.';
    }
  }
}

/// Provider for AuthNotifier
///
/// This is the main provider to use throughout the app for authentication.
///
/// Example usage:
/// ```dart
/// // In a ConsumerWidget
/// final authState = ref.watch(authNotifierProvider);
///
/// if (authState.isLoading) {
///   return CircularProgressIndicator();
/// }
///
/// if (authState.errorMessage != null) {
///   return Text(authState.errorMessage!);
/// }
///
/// // To perform auth operations
/// ref.read(authNotifierProvider.notifier).signIn(
///   email: email,
///   password: password,
/// );
/// ```
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
