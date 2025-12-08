import 'package:flutter/material.dart';

/// Notes screen (placeholder)
///
/// This screen will manage notes and quick thoughts.
/// Currently a placeholder - will be expanded with notes features.
///
/// Future features:
/// - Note creation and editing
/// - Rich text formatting
/// - Note categories and tags
/// - Search functionality
/// - Pin important notes
/// - Share notes
/// - Voice-to-text notes
/// - Integration with other modules (link notes to people, sermons, etc.)
///
/// Note: AppBar is provided by MainScaffold, not this screen
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

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
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.notes,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Notes',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Notes feature is coming soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Feature list
            Text(
              'This feature will help you:\n\n'
              '• Capture quick thoughts and ideas\n'
              '• Organize notes by category\n'
              '• Search through your notes\n'
              '• Format text with rich editing\n'
              '• Link notes to people and events',
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
// context.go('/notes')
