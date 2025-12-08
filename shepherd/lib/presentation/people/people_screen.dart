import 'package:flutter/material.dart';

/// People & Contacts screen (placeholder)
///
/// This screen will manage church members and contacts.
/// Currently a placeholder - will be expanded with people management features.
///
/// Future features:
/// - Contact list with search and filtering
/// - Contact profiles with details (address, phone, email, etc.)
/// - Family grouping
/// - Contact categories (members, visitors, leaders, etc.)
/// - Interaction logging (visits, calls, emails)
/// - Birthday and anniversary reminders
/// - Prayer requests tracking
/// - Attendance tracking
///
/// Note: AppBar is provided by MainScaffold, not this screen
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

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
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.people_outline,
                size: 64,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'People & Contacts',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'People management is coming soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Feature list
            Text(
              'This feature will help you:\n\n'
              '• Manage church member directory\n'
              '• Track contact information\n'
              '• Log pastoral care interactions\n'
              '• Remember birthdays and anniversaries\n'
              '• Track prayer requests',
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
// context.go('/people')
