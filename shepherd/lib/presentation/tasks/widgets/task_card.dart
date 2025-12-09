import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../providers/task_providers.dart';

/// Reusable task card widget that displays individual task information
///
/// Features:
/// - Task title with strikethrough for completed tasks
/// - Due date chip with contextual colors (overdue=red, today=orange)
/// - Estimated duration display (formatted as "X hrs" or "X min")
/// - Category badge with color coding (sermon_prep, pastoral_care, etc.)
/// - Priority indicator as colored left border (urgent=red, high=orange)
/// - Description preview (2 lines max with ellipsis)
/// - Checkbox for task completion with optimistic update
/// - Three-dot menu button (edit, delete options)
/// - Tap card to navigate to detail view
/// - Delete confirmation dialog
///
/// Design:
/// - Card elevation: 2
/// - Border radius: 12px
/// - Padding: 16px
/// - Priority border: 2px left border
/// - InkWell ripple effect for touch feedback
/// - Minimum 44x44 touch targets
///
/// Accessibility:
/// - Semantic labels for screen readers
/// - Proper button hints
/// - Touch target size compliance
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
      hint: 'Tap to view task details',
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Priority indicator as left border
          side: BorderSide(
            color: _getPriorityBorderColor(),
            width: task.priority == 'urgent' || task.priority == 'high' ? 3 : 0,
          ),
        ),
        child: InkWell(
          onTap: onTap ??
              () {
                // Default behavior: show placeholder message
                // TODO: Navigate to task detail when implemented
                // context.push('/tasks/${task.id}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task detail screen coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox for task completion (left side)
                _buildCheckbox(context, repository),
                const SizedBox(width: 12),

                // Main content area (title, metadata, description)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task title
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              // Strikethrough for completed tasks
                              decoration: task.status == 'done'
                                  ? TextDecoration.lineThrough
                                  : null,
                              // Muted color for completed tasks
                              color: task.status == 'done'
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade900,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Metadata row (due date, duration, category)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Due date and time chip
                          if (task.dueDate != null) _buildDueDateChip(context),

                          // Estimated duration chip
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

                // Three-dot menu button (right side)
                _buildMenuButton(context, repository),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build checkbox for task completion
  ///
  /// Features:
  /// - Optimistic update (UI updates immediately)
  /// - Success green color when checked
  /// - Error handling with snackbar
  /// - Accessibility labels
  Widget _buildCheckbox(BuildContext context, repository) {
    final isCompleted = task.status == 'done';

    return Semantics(
      label: isCompleted ? 'Mark as incomplete' : 'Mark as complete',
      hint: 'Checkbox',
      child: SizedBox(
        width: 44, // Minimum touch target size
        height: 44,
        child: Checkbox(
          value: isCompleted,
          onChanged: (value) async {
            // Optimistic update - UI updates immediately
            final newStatus = value == true ? 'done' : 'not_started';
            final updatedTask = task.copyWith(
              status: newStatus,
              completedAt: value == true ? DateTime.now() : null,
            );

            try {
              // Update task in repository
              await repository.updateTask(updatedTask);
            } catch (e) {
              // Show error snackbar on failure
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update task: $e'),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: () async {
                        await repository.updateTask(updatedTask);
                      },
                    ),
                  ),
                );
              }
            }
          },
          activeColor: const Color(0xFF10B981), // Shepherd success green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Build due date chip with contextual colors
  ///
  /// Colors:
  /// - Red background: Overdue tasks
  /// - Orange background: Due today
  /// - Gray background: Future tasks
  ///
  /// Displays:
  /// - "Overdue" for past due tasks
  /// - "Today" for tasks due today
  /// - "Tomorrow" for tasks due tomorrow
  /// - Date format "MMM d" for other dates
  /// - Time if available (e.g., "Today 2:00 PM")
  Widget _buildDueDateChip(BuildContext context) {
    final dueDate = task.dueDate!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = tomorrow.add(const Duration(days: 1));

    // Determine date label
    String dateLabel;
    if (dueDate.isBefore(today) && task.status != 'done') {
      dateLabel = 'Overdue';
    } else if (dueDate.isAfter(today) && dueDate.isBefore(tomorrow)) {
      dateLabel = 'Today';
    } else if (dueDate.isAfter(tomorrow) && dueDate.isBefore(dayAfterTomorrow)) {
      dateLabel = 'Tomorrow';
    } else {
      dateLabel = DateFormat('MMM d').format(dueDate);
    }

    // Add time if available
    if (task.dueTime != null && task.dueTime!.isNotEmpty) {
      dateLabel += ' ${task.dueTime}';
    }

    // Determine contextual colors
    Color backgroundColor;
    Color textColor;
    if (dueDate.isBefore(today) && task.status != 'done') {
      // Overdue: Red
      backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
      textColor = const Color(0xFFEF4444);
    } else if (dueDate.isBefore(tomorrow)) {
      // Today: Orange
      backgroundColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
      textColor = const Color(0xFFF59E0B);
    } else {
      // Future: Gray
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade700;
    }

    return Chip(
      label: Text(dateLabel),
      avatar: Icon(
        Icons.calendar_today,
        size: 14,
        color: textColor,
      ),
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
  ///
  /// Formats duration as:
  /// - "30m" for durations under 1 hour
  /// - "2h" for exact hours
  /// - "2h 30m" for hours + minutes
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
      avatar: Icon(
        Icons.schedule,
        size: 14,
        color: Colors.grey.shade700,
      ),
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

  /// Build category badge with color coding
  ///
  /// Category colors (Shepherd design system):
  /// - Sermon Prep: Blue (#2563EB)
  /// - Pastoral Care: Green (#10B981)
  /// - Admin: Orange (#F59E0B)
  /// - Personal: Purple (#8B5CF6)
  /// - Worship Planning: Teal (#14B8A6)
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
  ///
  /// Features:
  /// - Opens bottom sheet with edit/delete options
  /// - Minimum 44x44 touch target
  /// - Accessibility labels
  Widget _buildMenuButton(BuildContext context, repository) {
    return Semantics(
      label: 'Task options menu',
      button: true,
      hint: 'Opens menu with edit and delete options',
      child: IconButton(
        icon: const Icon(Icons.more_vert),
        iconSize: 20,
        color: Colors.grey.shade600,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 44, // Minimum touch target
          minHeight: 44,
        ),
        onPressed: () {
          _showTaskMenu(context, repository);
        },
      ),
    );
  }

  /// Show bottom sheet with task options
  ///
  /// Options:
  /// - Edit: Navigate to edit screen (placeholder for now)
  /// - Delete: Show confirmation dialog, then delete
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
            // Header with task title
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
                // TODO: Navigate to edit screen when implemented
                // context.push('/tasks/${task.id}/edit');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit task feature coming soon'),
                    behavior: SnackBarBehavior.floating,
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
                      'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
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

                // Delete task if confirmed
                if (confirm == true && context.mounted) {
                  try {
                    await repository.deleteTask(task.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task deleted'),
                          backgroundColor: Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete task: $e'),
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
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
  ///
  /// Priority colors:
  /// - Urgent: Red (#EF4444) - 3px border
  /// - High: Orange (#F59E0B) - 3px border
  /// - Medium: Transparent (no border)
  /// - Low: Light gray (#E5E7EB) - no border
  Color _getPriorityBorderColor() {
    switch (task.priority) {
      case 'urgent':
        return const Color(0xFFEF4444); // Red
      case 'high':
        return const Color(0xFFF59E0B); // Orange
      case 'low':
        return Colors.grey.shade300; // Light gray
      case 'medium':
      default:
        return Colors.transparent; // No border for medium priority
    }
  }

  /// Get category information (label and color)
  ///
  /// Returns a record with label and color for each category.
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
        return (label: category, color: Colors.grey); // Default gray
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
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = task.dueDate!;

    if (dueDate.isBefore(today) && task.status != 'done') {
      return 'overdue';
    } else if (dueDate.day == today.day &&
        dueDate.month == today.month &&
        dueDate.year == today.year) {
      return 'due today';
    } else {
      return 'due ${DateFormat('MMMM d').format(dueDate)}';
    }
  }
}
