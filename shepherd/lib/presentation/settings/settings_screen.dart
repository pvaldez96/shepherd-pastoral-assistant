import 'package:flutter/material.dart';

/// Settings screen (placeholder)
///
/// This screen will manage app settings and user preferences.
/// Currently a placeholder - will be expanded with settings features.
///
/// Future features:
/// - User profile editing
/// - Church information
/// - Notification preferences
/// - Theme settings (dark mode)
/// - Sync settings
/// - Backup and restore
/// - Data export
/// - Privacy settings
/// - About and help
///
/// Note: AppBar is provided by MainScaffold, not this screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 64,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Settings are coming soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Feature list
            Text(
              'This feature will help you:\n\n'
              '• Manage your profile\n'
              '• Configure notifications\n'
              '• Customize app preferences\n'
              '• Backup and restore data\n'
              '• Manage privacy settings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Usage with go_router:
// context.go('/settings')
