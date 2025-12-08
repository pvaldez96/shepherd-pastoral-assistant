# Supabase Configuration Setup Guide

This guide explains the Supabase configuration that has been set up for the Shepherd app.

## Files Created

### 1. Configuration Files

#### `lib/core/config/supabase_config.dart`
- Handles Supabase initialization
- Provides global access to Supabase client
- Includes Riverpod providers for:
  - `supabaseClientProvider` - Access to Supabase client
  - `currentUserProvider` - Current authenticated user
  - `authStateProvider` - Stream of auth state changes

#### `.env` (Environment Variables)
Contains your Supabase credentials:
```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**⚠️ IMPORTANT:** Replace the placeholder values with your actual Supabase credentials!

#### `.env.example` (Template)
Template file showing required environment variables for other developers.

### 2. Authentication Service

#### `lib/services/auth_service.dart`
Complete authentication service with:
- `signUp()` - Create new user account
- `signIn()` - Authenticate existing user
- `signOut()` - End user session
- `getCurrentUser()` - Get current user
- `isAuthenticated()` - Check auth status
- `authStateChanges()` - Stream of auth events
- `resetPassword()` - Send password reset email
- `updatePassword()` - Update user password

Includes Riverpod providers:
- `authServiceProvider` - Access to auth service
- `currentUserStreamProvider` - Reactive current user
- `isAuthenticatedProvider` - Reactive auth status

### 3. Main App

#### `lib/main.dart`
Updated to:
- Load environment variables from `.env`
- Initialize Supabase before app starts
- Wrap app in `ProviderScope` for Riverpod
- Show connection status on home page

## Getting Your Supabase Credentials

### Option 1: From Supabase Dashboard (Recommended)

1. Go to [supabase.com](https://supabase.com)
2. Sign in and select your project
3. Go to **Project Settings** → **API**
4. Copy the following values:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

### Option 2: After Running Migration

If you've already created your Supabase project and applied the migration:
1. The URL will be in the format: `https://xxxxxxxxxxxxx.supabase.co`
2. The anon key is shown in the API settings

## Setup Steps

### 1. Update Environment Variables

Edit `shepherd/.env` and replace the placeholders:

```env
SUPABASE_URL=https://your-actual-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...your-actual-key
```

### 2. Run the App

```bash
cd shepherd
flutter run
```

The app will:
1. Load the `.env` file
2. Initialize Supabase with your credentials
3. Show connection status on the home screen

## Using Authentication in Your App

### Example: Sign Up

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shepherd/services/auth_service.dart';

class SignUpScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        try {
          await authService.signUp(
            email: 'pastor@church.com',
            password: 'securePassword123',
            name: 'John Doe',
            churchName: 'First Community Church',
          );
          // Navigate to home or show success
        } catch (e) {
          // Show error message
          print('Sign up failed: $e');
        }
      },
      child: Text('Sign Up'),
    );
  }
}
```

### Example: Sign In

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        try {
          await authService.signIn(
            email: 'pastor@church.com',
            password: 'securePassword123',
          );
          // Navigate to home
        } catch (e) {
          // Show error message
        }
      },
      child: Text('Sign In'),
    );
  }
}
```

### Example: Watch Auth State

```dart
class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (event) {
        if (event.session != null) {
          return Text('Logged in as: ${event.session?.user.email}');
        } else {
          return Text('Not logged in');
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### Example: Check If Authenticated

```dart
class AppRouter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (isAuthenticated) {
      return DashboardScreen();
    } else {
      return LoginScreen();
    }
  }
}
```

## Security Notes

### ✅ What's Secure

- `.env` file is in `.gitignore` - won't be committed to version control
- Environment variables are loaded at runtime
- Supabase anon key is safe for client-side use (with RLS policies)
- Authentication uses PKCE flow for enhanced security
- Sessions persist automatically and refresh tokens

### ⚠️ Important Security Practices

1. **Never commit `.env` to git** - Always use `.env.example` as template
2. **Enable RLS on all tables** - Already done in migration for users/user_settings
3. **Use Row Level Security policies** - Ensure users can only access their own data
4. **Rotate keys if exposed** - If you accidentally commit secrets, regenerate in Supabase dashboard

## Troubleshooting

### "SUPABASE_URL not found in .env file"

**Solution:** Make sure you've created the `.env` file and added your credentials.

### "Failed to initialize Supabase"

**Possible causes:**
1. Invalid URL or anon key
2. Network connectivity issues
3. Supabase project is paused (free tier)

**Solution:**
1. Verify credentials in Supabase dashboard
2. Check internet connection
3. Unpause project if needed

### App crashes on startup

**Solution:**
1. Check that `.env` file exists in `shepherd/` directory
2. Verify `.env` is listed in `pubspec.yaml` assets
3. Run `flutter clean && flutter pub get`

## Next Steps

1. **Update `.env`** with your actual Supabase credentials
2. **Apply the migration** to create tables (see `supabase/QUICKSTART.md`)
3. **Build authentication UI** (login, signup, forgot password screens)
4. **Implement routing** with go_router based on auth state
5. **Create protected routes** that require authentication

## Related Documentation

- [supabase/README.md](../supabase/README.md) - Database setup guide
- [supabase/QUICKSTART.md](../supabase/QUICKSTART.md) - Fast-track Supabase setup
- [shepherd_technical_specification.md](../shepherd_technical_specification.md) - Full app specification

## Dependencies Added

The following packages were added to `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.4.0      # State management
  riverpod_annotation: ^2.3.0   # Riverpod code generation
  supabase_flutter: ^2.0.0      # Supabase client
  flutter_dotenv: ^5.1.0        # Environment variables

dev_dependencies:
  riverpod_generator: ^2.3.0    # Riverpod code generation
```

## Code Generation (Future)

When you start using `riverpod_annotation`, run:

```bash
flutter pub run build_runner build
# Or for continuous generation:
flutter pub run build_runner watch
```

This will generate Riverpod providers from annotated classes.
