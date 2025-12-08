import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Quick Capture bottom sheet for fast data entry
///
/// Provides three quick actions for pastors to capture information on the go:
/// 1. Quick Task - Navigate to task creation
/// 2. Quick Note - Navigate to note creation
/// 3. Quick Log - Log a contact/interaction
///
/// Design considerations:
/// - Large touch targets (56px height) for easy tapping
/// - Clear, descriptive labels
/// - Icons that communicate purpose
/// - Dismissible by tapping outside or selecting an option
class QuickCaptureBottomSheet extends StatelessWidget {
  const QuickCaptureBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar for visual affordance
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'Quick Capture',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to add?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Quick Task button
          _QuickCaptureButton(
            icon: Icons.check_box_outlined,
            label: 'Quick Task',
            description: 'Add a task to your to-do list',
            color: const Color(0xFF2563EB), // Primary blue
            onTap: () {
              Navigator.pop(context); // Close bottom sheet
              context.go('/tasks'); // Navigate to tasks (will add ?mode=create later)
              // TODO: When task creation is implemented, pass create mode
              // context.go('/tasks?mode=create');
            },
          ),
          const SizedBox(height: 12),

          // Quick Note button
          _QuickCaptureButton(
            icon: Icons.notes,
            label: 'Quick Note',
            description: 'Capture a quick thought or idea',
            color: const Color(0xFFF59E0B), // Warning orange
            onTap: () {
              Navigator.pop(context);
              context.go('/notes'); // Navigate to notes
              // TODO: When note creation is implemented, pass create mode
              // context.go('/notes?mode=create');
            },
          ),
          const SizedBox(height: 12),

          // Quick Log button
          _QuickCaptureButton(
            icon: Icons.people_outline,
            label: 'Quick Log',
            description: 'Log a contact or interaction',
            color: const Color(0xFF10B981), // Success green
            onTap: () {
              Navigator.pop(context);
              _showQuickLogDialog(context);
            },
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  /// Show quick log dialog
  ///
  /// This is a simplified interaction logging dialog.
  /// In the future, this will integrate with the People module.
  void _showQuickLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Log'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick contact logging coming soon!'),
            SizedBox(height: 16),
            Text(
              'This feature will allow you to quickly log:\n'
              '• Phone calls\n'
              '• Visits\n'
              '• Emails\n'
              '• Other interactions',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/people');
            },
            child: const Text('Go to People'),
          ),
        ],
      ),
    );
  }
}

/// Quick Capture button widget
///
/// Large, tappable button with icon, label, and description.
/// Follows accessibility guidelines with minimum 48px touch target.
class _QuickCaptureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _QuickCaptureButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          // Minimum touch target of 56px height (16 + 24 icon + 16 padding)
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),

              // Label and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),

              // Chevron icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage:
// This widget is shown as a modal bottom sheet from MainScaffold
// when the user taps the "Quick Capture" tab in the bottom navigation.
//
// showModalBottomSheet(
//   context: context,
//   isScrollControlled: true,
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//   ),
//   builder: (context) => const QuickCaptureBottomSheet(),
// );
