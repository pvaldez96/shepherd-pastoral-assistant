import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../providers/task_providers.dart';

/// Reusable task card widget that displays individual task information
///
/// Features:
/// - Task title (bold, prominent)
/// - Due date and time (if set)
/// - Estimated duration (e.g., "2 hrs")
/// - Category badge with color
/// - Priority indicator (color-coded left border)
/// - Checkbox on the left to mark complete
/// - Three-dot menu button on the right (edit, delete actions)
/// - Tap anywhere on card to open detail view
///
/// Design:
/// - Card elevation: 2
/// - Border radius: 12px
/// - Padding: 16px
/// - Internal spacing: 8px gaps
///
/// Usage:
/// ```dart
/// TaskCard(
///   task: task,
///   onTap: () => context.push('/tasks/${task.id}'),
/// )
/// ```
class TaskCard extends ConsumerWidget {
  final TaskEntity task;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(taskRepositoryProvider);

    return Semantics(
      label: 'Task: ${task.title}, ${_getStatusLabel()}, ${_getDueDateLabel()}',
      button: true,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getPriorityColor(),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap ?? () {
            // Default navigation to task detail (to be implemented)
            // context.push('/tasks/${task.id}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox for task completion
                _buildCheckbox(context, repository),
                const SizedBox(width: 12),

                // Main content (title, metadata)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: task.status == 'done'
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.status == 'done'
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade900,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Metadata row (due date, duration, category)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Due date and time
                          if (task.dueDate != null) _buildDueDateChip(context),

                          // Estimated duration
                          if (task.estimatedDurationMinutes != null)
                            _buildDurationChip(context),

                          // Category badge
                          _buildCategoryBadge(context),
                        ],
                      ),

                      // Description preview (if available)
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          task.description!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Three-dot menu
                _buildMenuButton(context, repository),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build checkbox for task completion
  Widget _buildCheckbox(BuildContext context, repository) {
    final isCompleted = task.status == 'done';

    return Semantics(
      label: isCompleted ? 'Mark as incomplete' : 'Mark as complete',
      child: Checkbox(
        value: isCompleted,
        onChanged: (value) async {
          // Toggle task completion
          final newStatus = value == true ? 'done' : 'not_started';
          final updatedTask = task.copyWith(
            status: newStatus,
            completedAt: value == true ? DateTime.now() : null,
          );

          try {
            await repository.updateTask(updatedTask);
          } catch (e) {
            // Show error snackbar
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update task: $e'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            }
          }
        },
        activeColor: const Color(0xFF10B981), // Success green
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Build due date chip
  Widget _buildDueDateChip(BuildContext context) {
    final dueDate = task.dueDate!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Determine date label
    String dateLabel;
    if (dueDate.isBefore(now) && task.status != 'done') {
      dateLabel = 'Overdue';
    } else if (dueDate.isAfter(today) && dueDate.isBefore(tomorrow)) {
      dateLabel = 'Today';
    } else if (dueDate.isAfter(tomorrow) &&
        dueDate.isBefore(tomorrow.add(const Duration(days: 1)))) {
      dateLabel = 'Tomorrow';
    } else {
      dateLabel = DateFormat('MMM d').format(dueDate);
    }

    // Add time if available
    if (task.dueTime != null && task.dueTime!.isNotEmpty) {
      dateLabel += ' ${task.dueTime}';
    }

    // Determine color
    Color backgroundColor;
    Color textColor;
    if (dueDate.isBefore(now) && task.status != 'done') {
      backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
      textColor = const Color(0xFFEF4444);
    } else if (dueDate.isBefore(tomorrow)) {
      backgroundColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
      textColor = const Color(0xFFF59E0B);
    } else {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade700;
    }

    return Chip(
      label: Text(dateLabel),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Build estimated duration chip
  Widget _buildDurationChip(BuildContext context) {
    final minutes = task.estimatedDurationMinutes!;
    String durationLabel;

    if (minutes < 60) {
      durationLabel = '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        durationLabel = '${hours}h';
      } else {
        durationLabel = '${hours}h ${remainingMinutes}m';
      }
    }

    return Chip(
      label: Text(durationLabel),
      avatar: const Icon(Icons.schedule, size: 16),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
      backgroundColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Build category badge with color
  Widget _buildCategoryBadge(BuildContext context) {
    final categoryInfo = _getCategoryInfo(task.category);

    return Chip(
      label: Text(categoryInfo.label),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
      backgroundColor: categoryInfo.color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Build three-dot menu button
  Widget _buildMenuButton(BuildContext context, repository) {
    return Semantics(
      label: 'Task options menu',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        onPressed: () {
          _showTaskMenu(context, repository);
        },
      ),
    );
  }

  /// Show bottom sheet with task options
  void _showTaskMenu(BuildContext context, repository) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Edit option
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF2563EB)),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
                // context.push('/tasks/${task.id}/edit');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit task feature coming soon'),
                  ),
                );
              },
            ),

            // Delete option
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
              title: const Text('Delete'),
              onTap: () async {
                Navigator.pop(context);

                // Show confirmation dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: Text(
                      'Are you sure you want to delete "${task.title}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  try {
                    await repository.deleteTask(task.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task deleted'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete task: $e'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                }
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Get priority color for card border
  Color _getPriorityColor() {
    switch (task.priority) {
      case 'urgent':
        return const Color(0xFFEF4444); // Red
      case 'high':
        return const Color(0xFFF59E0B); // Orange
      case 'low':
        return Colors.grey.shade300; // Gray
      case 'medium':
      default:
        return Colors.transparent; // No border for medium priority
    }
  }

  /// Get category information (label and color)
  ({String label, Color color}) _getCategoryInfo(String category) {
    switch (category) {
      case 'sermon_prep':
        return (label: 'Sermon Prep', color: const Color(0xFF2563EB)); // Blue
      case 'pastoral_care':
        return (
          label: 'Pastoral Care',
          color: const Color(0xFF10B981)
        ); // Green
      case 'admin':
        return (label: 'Admin', color: const Color(0xFFF59E0B)); // Orange
      case 'personal':
        return (label: 'Personal', color: const Color(0xFF8B5CF6)); // Purple
      case 'worship_planning':
        return (label: 'Worship', color: const Color(0xFF14B8A6)); // Teal
      default:
        return (label: category, color: Colors.grey); // Default
    }
  }

  /// Get status label for accessibility
  String _getStatusLabel() {
    switch (task.status) {
      case 'done':
        return 'completed';
      case 'in_progress':
        return 'in progress';
      case 'not_started':
      default:
        return 'not started';
    }
  }

  /// Get due date label for accessibility
  String _getDueDateLabel() {
    if (task.dueDate == null) return 'no due date';

    final now = DateTime.now();
    final dueDate = task.dueDate!;

    if (dueDate.isBefore(now) && task.status != 'done') {
      return 'overdue';
    } else if (dueDate.day == now.day &&
        dueDate.month == now.month &&
        dueDate.year == now.year) {
      return 'due today';
    } else {
      return 'due ${DateFormat('MMMM d').format(dueDate)}';
    }
  }
}
