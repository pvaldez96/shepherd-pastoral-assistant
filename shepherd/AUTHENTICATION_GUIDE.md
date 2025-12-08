# Shepherd Authentication System

## Overview

This guide documents the complete authentication system for the Shepherd pastoral assistant app, including sign in, sign up, routing, and state management.

## Architecture

### State Management: Riverpod
- **AuthNotifier**: Manages authentication state (sign in, sign up, sign out)
- **AuthService**: Handles Supabase authentication operations
- **Router**: Listens to auth state changes for automatic navigation

### Routing: go_router
- **Protected routes**: Dashboard and future features require authentication
- **Public routes**: Sign in and sign up screens are publicly accessible
- **Automatic redirects**: Users are redirected based on authentication state

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── supabase_config.dart          # Supabase initialization
│   └── router/
│       └── app_router.dart               # Route configuration
├── presentation/
│   ├── auth/
│   │   ├── auth_notifier.dart            # Auth state management
│   │   ├── sign_in_screen.dart           # Sign in UI
│   │   ├── sign_up_screen.dart           # Sign up UI
│   │   └── widgets/
│   │       ├── auth_button.dart          # Reusable button widget
│   │       └── auth_text_field.dart      # Reusable text field widget
│   └── dashboard/
│       └── dashboard_screen.dart         # Main dashboard (placeholder)
├── services/
│   └── auth_service.dart                 # Authentication service
└── main.dart                             # App entry point with theme
```

## Features

### 1. Sign In Screen (`sign_in_screen.dart`)
- **Route**: `/sign-in`
- **Features**:
  - Email and password input with validation
  - Auto-focus on email field
  - Password visibility toggle
  - Loading state during authentication
  - Error handling with SnackBar notifications
  - Link to sign up screen
  - Automatic navigation to dashboard on success

**Usage**:
```dart
context.go('/sign-in');
```

### 2. Sign Up Screen (`sign_up_screen.dart`)
- **Route**: `/sign-up`
- **Features**:
  - Full name input (required, min 2 characters)
  - Email input with format validation
  - Password input (min 6 characters)
  - Church name input (optional)
  - Password requirements info display
  - Loading state during registration
  - Error handling with SnackBar notifications
  - Link to sign in screen
  - Auto sign in and navigate to dashboard on success

**Usage**:
```dart
context.go('/sign-up');
```

### 3. Dashboard Screen (`dashboard_screen.dart`)
- **Route**: `/dashboard` (protected)
- **Features**:
  - Welcome message with user email
  - Sign out button with confirmation dialog
  - Placeholder for future dashboard widgets
  - Quick action buttons (placeholder)

**Usage**:
```dart
context.go('/dashboard');
```

## Authentication Flow

### Sign Up Flow
1. User fills out registration form (name, email, password, church name)
2. Form validation runs on submission
3. `AuthNotifier.signUp()` called with user data
4. `AuthService.signUp()` creates account in Supabase
5. User profile created in `users` table
6. Default settings created in `user_settings` table
7. User automatically signed in
8. Router detects auth state change
9. User redirected to `/dashboard`
10. Success message shown

### Sign In Flow
1. User enters email and password
2. Form validation runs on submission
3. `AuthNotifier.signIn()` called
4. `AuthService.signIn()` authenticates with Supabase
5. Router detects auth state change
6. User redirected to `/dashboard`
7. Success message shown

### Sign Out Flow
1. User clicks sign out button in dashboard
2. Confirmation dialog shown
3. User confirms sign out
4. `AuthNotifier.signOut()` called
5. `AuthService.signOut()` ends Supabase session
6. Router detects auth state change
7. User redirected to `/sign-in`
8. Success message shown

## State Management

### AuthState
```dart
class AuthState {
  final User? user;              // Current user (null if not authenticated)
  final bool isLoading;          // Loading state for operations
  final String? errorMessage;    // Error message to display
  final bool isAuthenticated;    // True if user is logged in
}
```

### AuthNotifier Methods
- `signIn({email, password})` - Sign in existing user
- `signUp({email, password, name, churchName})` - Create new account
- `signOut()` - Sign out current user
- `clearError()` - Clear error message

### Usage in Widgets
```dart
// Watch auth state
final authState = ref.watch(authNotifierProvider);

if (authState.isLoading) {
  return CircularProgressIndicator();
}

if (authState.errorMessage != null) {
  return Text(authState.errorMessage!);
}

// Perform auth operations
ref.read(authNotifierProvider.notifier).signIn(
  email: email,
  password: password,
);
```

## Routing

### Route Configuration
- `/` - Root (redirects based on auth state)
- `/sign-in` - Sign in screen (public)
- `/sign-up` - Sign up screen (public)
- `/dashboard` - Dashboard (protected)

### Navigation Examples
```dart
// Navigate to sign in
context.go('/sign-in');

// Navigate to sign up
context.go('/sign-up');

// Navigate to dashboard (requires authentication)
context.go('/dashboard');

// Go back
context.pop();

// Push route (adds to stack)
context.push('/sign-up');

// Replace current route
context.replace('/dashboard');
```

### Protected Routes
Protected routes automatically redirect unauthenticated users to `/sign-in`. The router listens to auth state changes and performs redirects automatically.

## Design System

### Colors
- **Primary**: `#2563EB` (blue-600) - Main actions, headers
- **Secondary**: `#10B981` (green-500) - Success messages
- **Error**: `#DC2626` (red-600) - Errors, validation
- **Surface**: `#F9FAFB` (gray-50) - Background
- **On Surface**: `#FFFFFF` (white) - Cards, forms

### Typography
- **Headline Medium**: 24px, bold - Screen titles
- **Title Medium**: 16px, semibold - Section headers
- **Body Large**: 16px, regular - Input fields, body text
- **Body Medium**: 14px, regular - Helper text

### Spacing
- Form padding: 24px
- Input field spacing: 16px between fields
- Section spacing: 24px, 48px for major sections
- Card padding: 24px
- Button height: 48px

### Components
- **Border radius**: 8px for buttons/inputs, 12px for cards
- **Input fields**: Outlined style with focus state
- **Buttons**: Filled primary style, full width
- **Cards**: White with subtle shadow
- **SnackBars**: Floating with rounded corners

## Error Handling

### Common Errors
The `AuthNotifier` converts technical Supabase errors into user-friendly messages:

| Supabase Error | User-Friendly Message |
|---|---|
| Invalid login credentials | Invalid email or password. Please try again. |
| Email not confirmed | Please confirm your email address before signing in. |
| User already registered | This email is already registered. Please sign in instead. |
| Password should be at least 6 characters | Password must be at least 6 characters long. |
| Network errors | No internet connection. Please check your network and try again. |

### Error Display
Errors are displayed in:
1. **Form validation**: Inline below input fields
2. **SnackBar**: After submission attempts
3. **Red color**: Error messages use `#DC2626`

## Validation

### Email Validation
```dart
AuthValidators.validateEmail(value)
```
- Checks for non-empty value
- Validates email format with regex
- Returns error message or null

### Password Validation
```dart
AuthValidators.validatePassword(value)
```
- Checks for non-empty value
- Requires minimum 6 characters
- Returns error message or null

### Name Validation
```dart
AuthValidators.validateName(value)
```
- Checks for non-empty value
- Requires minimum 2 characters
- Returns error message or null

## Accessibility

### Features
- **Semantic labels**: All inputs have proper labels for screen readers
- **Touch targets**: Minimum 44x44 logical pixels
- **Keyboard support**: Proper tab order and keyboard types
- **Focus management**: Auto-focus on first field
- **Error announcements**: Screen readers announce errors
- **High contrast**: Sufficient color contrast ratios

### Keyboard Types
- Email: `TextInputType.emailAddress`
- Password: `TextInputType.text` (obscured)
- Name: `TextInputType.name`

### Input Actions
- Email → Next
- Password → Done (sign in) or Next (sign up)
- Submit on "Done" action

## Testing

### Widget Testing
```dart
testWidgets('Sign in screen shows email and password fields', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: SignInScreen(),
      ),
    ),
  );

  expect(find.byType(AuthTextField), findsNWidgets(2));
  expect(find.text('Email'), findsOneWidget);
  expect(find.text('Password'), findsOneWidget);
});
```

### Integration Testing
```dart
// Test sign in flow
final emailField = find.byType(AuthTextField).first;
final passwordField = find.byType(AuthTextField).last;
final signInButton = find.byType(AuthButton);

await tester.enterText(emailField, 'test@example.com');
await tester.enterText(passwordField, 'password123');
await tester.tap(signInButton);
await tester.pumpAndSettle();

// Verify navigation to dashboard
expect(find.byType(DashboardScreen), findsOneWidget);
```

## Future Enhancements

### Planned Features
1. **Password reset**: Forgot password flow
2. **Email verification**: Verify email after sign up
3. **Social auth**: Google, Apple sign in
4. **Biometric auth**: Face ID, Touch ID
5. **Remember me**: Persistent sessions
6. **Multi-factor auth**: 2FA support
7. **Profile editing**: Update user info
8. **Account deletion**: Delete account flow

### Routes to Add
```dart
// Password reset
GoRoute(path: '/forgot-password', ...),
GoRoute(path: '/reset-password', ...),

// Profile
GoRoute(path: '/profile', ...),
GoRoute(path: '/settings', ...),
```

## Troubleshooting

### Issue: User stays on sign in screen after successful auth
**Solution**: Check that `authNotifierProvider` is properly updating state and router is listening to auth changes.

### Issue: Validation errors not showing
**Solution**: Ensure `_formKey.currentState!.validate()` is called before submission.

### Issue: Router not redirecting
**Solution**: Verify `GoRouterRefreshNotifier` is properly subscribed to auth state changes.

### Issue: SnackBar not showing
**Solution**: Make sure `ref.listen()` is called in the build method and context is mounted.

## Security Best Practices

1. **Never log passwords**: Passwords are not logged even in debug mode
2. **Secure storage**: Supabase handles token storage securely
3. **HTTPS only**: All API calls use HTTPS
4. **Input sanitization**: Email trimmed, validated
5. **Session timeout**: Handled by Supabase
6. **Error messages**: Don't reveal sensitive info (e.g., "user exists")

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0      # State management
  go_router: ^12.0.0            # Routing
  supabase_flutter: ^2.0.0      # Authentication backend
```

## Additional Resources

- [Riverpod Documentation](https://riverpod.dev)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Material Design 3](https://m3.material.io)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)

## Support

For issues or questions about the authentication system:
1. Check this guide first
2. Review the code comments
3. Check Supabase dashboard for auth logs
4. Enable debug logging in router (`debugLogDiagnostics: true`)
