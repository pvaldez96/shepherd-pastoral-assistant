import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../tasks/providers/task_providers.dart';

/// Compact task card for dashboard display
///
/// Shows essential task information:
/// - Checkbox for completion
/// - Title
/// - Due time (if set)
/// - Estimated duration
/// - Priority indicator (color-coded)
///
/// Features:
/// - Tap checkbox to mark complete with haptic feedback
/// - Visual priority indicators
/// - Compact design for dashboard view
/// - Overdue styling
///
/// Design:
/// - 12px border radius
/// - Priority color on left edge
/// - Clean, scannable layout
class TaskSummaryCard extends ConsumerStatefulWidget {
  final TaskEntity task;
  final bool isOverdue;

  const TaskSummaryCard({
    super.key,
    required this.task,
    this.isOverdue = false,
  });

  @override
  ConsumerState<TaskSummaryCard> createState() => _TaskSummaryCardState();
}

class _TaskSummaryCardState extends ConsumerState<TaskSummaryCard> {
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priorityColor = _getPriorityColor();
    final isCompleted = task.status == 'done';

    return Semantics(
      label: 'Task: ${task.title}'
          '${task.priority != 'medium' ? ', ${task.priority} priority' : ''}'
          '${task.dueTime != null ? ', due at ${task.dueTime}' : ''}'
          '${task.estimatedDurationMinutes != null ? ', estimated ${task.estimatedDurationMinutes} minutes' : ''}'
          '${widget.isOverdue ? ', overdue' : ''}'
          '${isCompleted ? ', completed' : ', not completed'}',
      button: true,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: widget.isOverdue
              ? const BorderSide(color: Color(0xFFEF4444), width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to task detail
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: priorityColor,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: _isCompleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Checkbox(
                              value: isCompleted,
                              onChanged: isCompleted ? null : (value) => _handleComplete(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: const Color(0xFF10B981),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Task details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey.shade500 : null,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Metadata row (time, duration)
                        if (task.dueTime != null || task.estimatedDurationMinutes != null) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              // Due time
                              if (task.dueTime != null)
                                _MetadataChip(
                                  icon: Icons.schedule,
                                  label: _formatTime(task.dueTime!),
                                  color: widget.isOverdue
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey.shade700,
                                ),

                              // Estimated duration
                              if (task.estimatedDurationMinutes != null)
                                _MetadataChip(
                                  icon: Icons.timer_outlined,
                                  label: _formatDuration(task.estimatedDurationMinutes!),
                                  color: Colors.grey.shade700,
                                ),

                              // Category badge
                              if (task.category != 'personal')
                                _CategoryChip(
                                  category: task.category,
                                ),
                            ],
                          ),
                        ],

                        // Focus indicator
                        if (task.requiresFocus) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.psychology_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Requires focus',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Priority indicator (visual only, color is on left border)
                  if (task.priority == 'high')
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.priority_high,
                        size: 20,
                        color: priorityColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get priority color
  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case 'high':
        return const Color(0xFFEF4444); // Error red
      case 'medium':
        return const Color(0xFFF59E0B); // Warning orange
      case 'low':
        return Colors.grey.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  /// Handle task completion
  Future<void> _handleComplete() async {
    if (_isCompleting) return;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _isCompleting = true;
    });

    try {
      final repository = ref.read(taskRepositoryProvider);
      await repository.completeTask(widget.task.id);

      // Success haptic
      HapticFeedback.lightImpact();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${widget.task.title}" completed'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Error haptic
      HapticFeedback.heavyImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete task: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  /// Format time string (e.g., "14:30" to "2:30 PM")
  String _formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return timeString;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return timeString;
    }
  }

  /// Format duration (e.g., 90 minutes to "1h 30m")
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}

/// Small metadata chip for task details
class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

/// Category chip with color coding
class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final categoryInfo = _getCategoryInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: categoryInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryInfo.icon,
            size: 12,
            color: categoryInfo.color,
          ),
          const SizedBox(width: 4),
          Text(
            categoryInfo.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: categoryInfo.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  ({Color color, IconData icon, String label}) _getCategoryInfo() {
    switch (category) {
      case 'sermon_prep':
        return (
          color: const Color(0xFF8B5CF6),
          icon: Icons.menu_book,
          label: 'Sermon',
        );
      case 'pastoral_care':
        return (
          color: const Color(0xFF10B981),
          icon: Icons.favorite_outline,
          label: 'Pastoral',
        );
      case 'admin':
        return (
          color: const Color(0xFF6B7280),
          icon: Icons.business_center,
          label: 'Admin',
        );
      case 'worship_planning':
        return (
          color: const Color(0xFF2563EB),
          icon: Icons.music_note,
          label: 'Worship',
        );
      case 'personal':
        return (
          color: const Color(0xFF06B6D4),
          icon: Icons.person,
          label: 'Personal',
        );
      default:
        return (
          color: Colors.grey.shade600,
          icon: Icons.label_outline,
          label: category,
        );
    }
  }
}

// Usage example:
//
// TaskSummaryCard(
//   task: TaskEntity(
//     id: '1',
//     userId: 'user1',
//     title: 'Prepare sermon outline',
//     category: 'sermon_prep',
//     priority: 'high',
//     dueDate: DateTime(2025, 12, 10),
//     dueTime: '14:00',
//     estimatedDurationMinutes: 90,
//     status: 'not_started',
//     requiresFocus: true,
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     localUpdatedAt: DateTime.now().millisecondsSinceEpoch,
//   ),
// )
//
// // For overdue tasks:
// TaskSummaryCard(
//   task: overdueTask,
//   isOverdue: true,
// )
