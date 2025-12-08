import 'package:flutter/material.dart';

/// Empty state widget for tasks list
///
/// Displays a friendly message when no tasks are available,
/// with an optional call-to-action button.
///
/// Features:
/// - Large icon (inbox or custom)
/// - Clear message
/// - Optional subtitle
/// - Optional action button
/// - Semantically labeled for accessibility
///
/// Usage:
/// ```dart
/// EmptyTaskState(
///   icon: Icons.inbox_outlined,
///   message: 'No tasks yet',
///   subtitle: 'Create your first task to get started',
///   actionLabel: 'Add Task',
///   onActionPressed: () => context.go('/quick-capture'),
/// )
/// ```
class EmptyTaskState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyTaskState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
    this.subtitle,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                size: 64,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 24),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
              textAlign: TextAlign.center,
            ),

            // Subtitle (optional)
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button (optional)
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              Semantics(
                label: actionLabel,
                button: true,
                child: ElevatedButton.icon(
                  onPressed: onActionPressed,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

