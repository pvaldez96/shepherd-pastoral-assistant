import 'package:flutter/material.dart';

/// Sermons screen (placeholder)
///
/// This screen will manage sermon preparation and library.
/// Currently a placeholder - will be expanded with sermon management features.
///
/// Future features:
/// - Sermon library with search
/// - Sermon preparation workflow
/// - Scripture passage tracking
/// - Outline and notes
/// - Sermon series management
/// - Delivery date tracking
/// - Export to various formats
/// - Integration with calendar
///
/// Note: AppBar is provided by MainScaffold, not this screen
class SermonsScreen extends StatelessWidget {
  const SermonsScreen({super.key});

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
                Icons.mic_none,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Sermons',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Sermon management is coming soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Feature list
            Text(
              'This feature will help you:\n\n'
              '• Prepare and organize sermons\n'
              '• Track sermon series\n'
              '• Manage Scripture passages\n'
              '• Create outlines and notes\n'
              '• Build a searchable sermon library',
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
// context.go('/sermons')
