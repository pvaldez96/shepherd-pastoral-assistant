import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_notifier.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_text_field.dart';

/// Sign In screen for existing users
///
/// Features:
/// - Email and password input with validation
/// - Loading state during authentication
/// - Error handling with user-friendly messages
/// - Navigation to sign up screen
/// - Auto-focus on email field
///
/// Navigation:
/// - Route: /sign-in
/// - On success: Navigate to /dashboard
/// - Link to: /sign-up
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    // Clear any previous errors
    ref.read(authNotifierProvider.notifier).clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    // Attempt sign in
    final success = await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      // Navigation is handled by the router listening to auth state
      // Just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome back!'),
          backgroundColor: Color(0xFF10B981), // Success green
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Show error message in snackbar when there's an error
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: const Color(0xFFDC2626), // Error red
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Background gray
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and title section
                const Icon(
                  Icons.church,
                  size: 64,
                  color: Color(0xFF2563EB), // Primary blue
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to Shepherd',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Sign in form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email field
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'pastor@church.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          enabled: !authState.isLoading,
                          validator: AuthValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Password',
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          enabled: !authState.isLoading,
                          validator: AuthValidators.validatePassword,
                          onSubmitted: (_) => _handleSignIn(),
                        ),
                        const SizedBox(height: 24),

                        // Sign in button
                        AuthButton(
                          text: 'Sign In',
                          onPressed: _handleSignIn,
                          isLoading: authState.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Navigation to sign up
                AuthTextButton(
                  text: "Don't have an account?",
                  linkText: 'Sign Up',
                  onPressed: () {
                    context.go('/sign-up');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Usage example:
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => const SignInScreen()),
// );
//
// Or with go_router:
// context.go('/sign-in');
