import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/auth_notifier.dart';
import '../../presentation/auth/sign_in_screen.dart';
import '../../presentation/auth/sign_up_screen.dart';
import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/main/main_scaffold.dart';
import '../../presentation/tasks/tasks_screen.dart';
import '../../presentation/calendar/calendar_screen.dart';
import '../../presentation/people/people_screen.dart';
import '../../presentation/sermons/sermons_screen.dart';
import '../../presentation/notes/notes_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../services/auth_service.dart';

/// Helper class to refresh GoRouter when auth state changes
///
/// This converts Riverpod state to a ChangeNotifier so GoRouter can listen to it
class GoRouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;
  StreamSubscription<bool>? _subscription;

  GoRouterRefreshNotifier(this._ref) {
    // Listen to auth state changes
    final authService = _ref.read(authServiceProvider);
    _subscription = authService
        .authStateChanges()
        .map((event) => event.session != null)
        .listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// App router configuration using go_router
///
/// Features:
/// - Route definitions for all screens
/// - Protected routes (require authentication)
/// - Auth state listener for automatic redirects
/// - Deep linking support
/// - ShellRoute for persistent navigation (bottom nav + drawer)
///
/// Routes:
/// - /sign-in: Sign in screen (public)
/// - /sign-up: Sign up screen (public)
/// - /dashboard: Dashboard screen (protected)
/// - /tasks: Tasks screen (protected)
/// - /calendar: Calendar screen (protected)
/// - /people: People directory screen (protected)
/// - /sermons: Sermons screen (protected)
/// - /notes: Notes screen (protected)
/// - /settings: Settings screen (protected)
/// - / : Redirects to /sign-in or /dashboard based on auth state
///
/// Protected routes are wrapped in MainScaffold via ShellRoute, which provides:
/// - Bottom navigation bar
/// - Side drawer (hamburger menu)
/// - Persistent navigation across screens
class AppRouter {
  final Ref ref;
  late final GoRouterRefreshNotifier _refreshNotifier;

  AppRouter(this.ref) {
    _refreshNotifier = GoRouterRefreshNotifier(ref);
  }

  /// Get the router configuration
  GoRouter get router => GoRouter(
        initialLocation: '/',
        debugLogDiagnostics: true,
        redirect: (context, state) {
          final authState = ref.read(authNotifierProvider);
          final isAuthenticated = authState.isAuthenticated;
          final isGoingToAuth = state.matchedLocation == '/sign-in' ||
              state.matchedLocation == '/sign-up';

          // If user is not authenticated and not going to auth screens,
          // redirect to sign in
          if (!isAuthenticated && !isGoingToAuth) {
            return '/sign-in';
          }

          // If user is authenticated and going to auth screens,
          // redirect to dashboard
          if (isAuthenticated && isGoingToAuth) {
            return '/dashboard';
          }

          // If at root, redirect based on auth state
          if (state.matchedLocation == '/') {
            return isAuthenticated ? '/dashboard' : '/sign-in';
          }

          // No redirect needed
          return null;
        },
        refreshListenable: _refreshNotifier,
        routes: [
          // Root route - redirects to appropriate screen
          GoRoute(
            path: '/',
            redirect: (context, state) => null, // Handled by global redirect
          ),

          // Sign in route (public)
          GoRoute(
            path: '/sign-in',
            name: 'sign-in',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const SignInScreen(),
            ),
          ),

          // Sign up route (public)
          GoRoute(
            path: '/sign-up',
            name: 'sign-up',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const SignUpScreen(),
            ),
          ),

          // Main app shell with persistent navigation (protected routes)
          ShellRoute(
            builder: (context, state, child) {
              return MainScaffold(child: child);
            },
            routes: [
              // Dashboard route (protected)
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                pageBuilder: (context, state) {
                  final view = state.uri.queryParameters['view'] ?? 'daily';
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: DashboardScreen(view: view),
                  );
                },
              ),

              // Tasks route (protected)
              GoRoute(
                path: '/tasks',
                name: 'tasks',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const TasksScreen(),
                ),
              ),

              // Calendar route (protected)
              GoRoute(
                path: '/calendar',
                name: 'calendar',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const CalendarScreen(),
                ),
              ),

              // People route (protected)
              GoRoute(
                path: '/people',
                name: 'people',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const PeopleScreen(),
                ),
              ),

              // Sermons route (protected)
              GoRoute(
                path: '/sermons',
                name: 'sermons',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SermonsScreen(),
                ),
              ),

              // Notes route (protected)
              GoRoute(
                path: '/notes',
                name: 'notes',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const NotesScreen(),
                ),
              ),

              // Settings route (protected)
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFFEF4444),
                ),
                const SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The page "${state.uri}" does not exist.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.go('/');
                  },
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Riverpod provider for the app router
///
/// Provides access to the GoRouter instance throughout the app.
///
/// Example usage in main.dart:
/// ```dart
/// return MaterialApp.router(
///   routerConfig: ref.watch(appRouterProvider),
///   // ...
/// );
/// ```
final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter(ref).router;
});

// Navigation Examples:
//
// 1. Navigate to a route:
//    context.go('/dashboard');
//    context.go('/tasks');
//    context.go('/calendar');
//
// 2. Navigate with query parameters:
//    context.go('/dashboard?view=weekly');
//    context.go('/dashboard?view=monthly');
//
// 3. Named routes:
//    context.goNamed('dashboard');
//    context.goNamed('tasks');
//
// 4. Push (adds to stack):
//    context.push('/settings');
//
// 5. Replace:
//    context.replace('/dashboard');
//
// 6. Go back:
//    context.pop();
//
// Testing Navigation:
//
// To test navigation in widget tests, you can create a mock router:
// ```dart
// final router = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => const DashboardScreen(),
//     ),
//   ],
// );
//
// await tester.pumpWidget(
//   MaterialApp.router(
//     routerConfig: router,
//   ),
// );
// ```
//
// To test protected routes, mock the auth state:
// ```dart
// final container = ProviderContainer(
//   overrides: [
//     authNotifierProvider.overrideWith((ref) => MockAuthNotifier()),
//   ],
// );
// ```
