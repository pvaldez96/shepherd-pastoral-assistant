import 'package:flutter/material.dart';

/// Tasks screen (placeholder)
///
/// This screen will manage all tasks for the pastor.
/// Currently a placeholder - will be expanded with task management features.
///
/// Future features:
/// - Task list with filtering and sorting
/// - Task creation and editing
/// - Task categories (sermon prep, pastoral care, admin, etc.)
/// - Due dates and reminders
/// - Task completion tracking
/// - Recurring tasks
/// - Integration with calendar
///
/// Note: AppBar is provided by MainScaffold, not this screen
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

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
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.check_box_outlined,
                size: 64,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Tasks',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Task management is coming soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Feature list
            Text(
              'This feature will help you:\n\n'
              '• Create and organize tasks\n'
              '• Set due dates and reminders\n'
              '• Track task completion\n'
              '• Categorize by ministry area\n'
              '• Set recurring tasks',
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
// context.go('/tasks')
