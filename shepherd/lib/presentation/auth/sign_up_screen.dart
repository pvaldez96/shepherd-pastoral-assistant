import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_notifier.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_text_field.dart';

/// Sign Up screen for new users
///
/// Features:
/// - Name, email, password, and church name input
/// - Form validation with inline error messages
/// - Password requirements (min 6 characters)
/// - Loading state during registration
/// - Error handling with user-friendly messages
/// - Auto sign in after successful registration
/// - Navigation to sign in screen
///
/// Navigation:
/// - Route: /sign-up
/// - On success: Auto sign in and navigate to /dashboard
/// - Link to: /sign-in
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _churchNameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _churchNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Clear any previous errors
    ref.read(authNotifierProvider.notifier).clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    // Attempt sign up
    final success = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          churchName: _churchNameController.text.trim().isEmpty
              ? null
              : _churchNameController.text.trim(),
        );

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Welcome to Shepherd.'),
          backgroundColor: Color(0xFF10B981), // Success green
          duration: Duration(seconds: 3),
        ),
      );
      // Navigation is handled by the router listening to auth state
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
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Shepherd to manage your pastoral work',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Sign up form card
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
                        // Name field
                        AuthTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'John Doe',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          enabled: !authState.isLoading,
                          validator: AuthValidators.validateName,
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'pastor@church.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !authState.isLoading,
                          validator: AuthValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'At least 6 characters',
                          isPassword: true,
                          textInputAction: TextInputAction.next,
                          enabled: !authState.isLoading,
                          validator: AuthValidators.validatePassword,
                        ),
                        const SizedBox(height: 16),

                        // Church name field (optional)
                        AuthTextField(
                          controller: _churchNameController,
                          label: 'Church Name (Optional)',
                          hint: 'First Community Church',
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          enabled: !authState.isLoading,
                          onSubmitted: (_) => _handleSignUp(),
                        ),
                        const SizedBox(height: 8),

                        // Password requirements info
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Password must be at least 6 characters',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sign up button
                        AuthButton(
                          text: 'Create Account',
                          onPressed: _handleSignUp,
                          isLoading: authState.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Navigation to sign in
                AuthTextButton(
                  text: 'Already have an account?',
                  linkText: 'Sign In',
                  onPressed: () {
                    context.go('/sign-in');
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
//   MaterialPageRoute(builder: (context) => const SignUpScreen()),
// );
//
// Or with go_router:
// context.go('/sign-up');
