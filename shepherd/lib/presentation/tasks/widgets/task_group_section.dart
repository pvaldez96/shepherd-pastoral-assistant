import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';
import 'task_card.dart';

/// Collapsible task group section widget
///
/// Displays a group of tasks with a collapsible header showing:
/// - Group title
/// - Task count
/// - Expand/collapse icon
/// - Optional color accent (for OVERDUE, etc.)
///
/// Features:
/// - Smooth expand/collapse animation
/// - Persists expanded state
/// - Shows task count in header
/// - Color-coded for different groups
/// - Accessible with proper semantics
///
/// Usage:
/// ```dart
/// TaskGroupSection(
///   title: 'OVERDUE',
///   tasks: overdueTasks,
///   accentColor: const Color(0xFFEF4444),
///   initiallyExpanded: true,
/// )
/// ```
class TaskGroupSection extends StatefulWidget {
  final String title;
  final List<TaskEntity> tasks;
  final Color? accentColor;
  final bool initiallyExpanded;
  final VoidCallback? onTaskTap;

  const TaskGroupSection({
    super.key,
    required this.title,
    required this.tasks,
    this.accentColor,
    this.initiallyExpanded = true,
    this.onTaskTap,
  });

  @override
  State<TaskGroupSection> createState() => _TaskGroupSectionState();
}

class _TaskGroupSectionState extends State<TaskGroupSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    // Don't render if no tasks
    if (widget.tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: '${widget.title} section, ${widget.tasks.length} tasks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          _buildHeader(context),

          // Task list (collapsible)
          AnimatedCrossFade(
            firstChild: _buildTaskList(),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),

          // Spacing after section
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build section header with title, count, and expand button
  Widget _buildHeader(BuildContext context) {
    return Semantics(
      button: true,
      label: _isExpanded
          ? 'Collapse ${widget.title} section'
          : 'Expand ${widget.title} section',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Expand/collapse icon
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: widget.accentColor ?? Colors.grey.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),

                // Title and count
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                      children: [
                        TextSpan(
                          text: widget.title,
                          style: TextStyle(
                            color: widget.accentColor ?? Colors.grey.shade700,
                          ),
                        ),
                        TextSpan(
                          text: ' (${widget.tasks.length})',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Optional accent indicator
                if (widget.accentColor != null)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build list of task cards
  Widget _buildTaskList() {
    return Column(
      children: [
        const SizedBox(height: 8),
        ...widget.tasks.map((task) => TaskCard(task: task)),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Helper function to group tasks by their category
///
/// Returns a map of category name to list of tasks.
///
/// Usage:
/// ```dart
/// final groupedTasks = groupTasksByCategory(allTasks);
/// ```
Map<String, List<TaskEntity>> groupTasksByCategory(List<TaskEntity> tasks) {
  final Map<String, List<TaskEntity>> grouped = {};

  for (final task in tasks) {
    if (!grouped.containsKey(task.category)) {
      grouped[task.category] = [];
    }
    grouped[task.category]!.add(task);
  }

  return grouped;
}

/// Helper function to group tasks by due date
///
/// Groups tasks into:
/// - Overdue
/// - Today
/// - This Week
/// - No Due Date
/// - Completed (last 7 days)
///
/// Usage:
/// ```dart
/// final groupedTasks = groupTasksByDueDate(allTasks);
/// ```
Map<String, List<TaskEntity>> groupTasksByDueDate(List<TaskEntity> tasks) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final weekFromNow = today.add(const Duration(days: 7));
  final sevenDaysAgo = today.subtract(const Duration(days: 7));

  final Map<String, List<TaskEntity>> grouped = {
    'overdue': [],
    'today': [],
    'thisWeek': [],
    'noDueDate': [],
    'completed': [],
  };

  for (final task in tasks) {
    // Completed tasks (last 7 days)
    if (task.status == 'done') {
      if (task.completedAt != null && task.completedAt!.isAfter(sevenDaysAgo)) {
        grouped['completed']!.add(task);
      }
      continue;
    }

    // Skip deleted tasks
    if (task.isDeleted) continue;

    // No due date
    if (task.dueDate == null) {
      grouped['noDueDate']!.add(task);
      continue;
    }

    final dueDate = task.dueDate!;

    // Overdue
    if (dueDate.isBefore(today)) {
      grouped['overdue']!.add(task);
    }
    // Today
    else if (dueDate.isAfter(today) && dueDate.isBefore(tomorrow)) {
      grouped['today']!.add(task);
    }
    // This week
    else if (dueDate.isAfter(tomorrow) && dueDate.isBefore(weekFromNow)) {
      grouped['thisWeek']!.add(task);
    }
    // No due date (future tasks beyond this week)
    else {
      grouped['noDueDate']!.add(task);
    }
  }

  return grouped;
}

/// Helper function to sort tasks by priority and due date
///
/// Priority order: urgent > high > medium > low
/// Within same priority, sort by due date (earliest first)
///
/// Usage:
/// ```dart
/// final sortedTasks = sortTasksByPriority(tasks);
/// ```
List<TaskEntity> sortTasksByPriority(List<TaskEntity> tasks) {
  final priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};

  final sorted = List<TaskEntity>.from(tasks);
  sorted.sort((a, b) {
    // First compare priority
    final aPriority = priorityOrder[a.priority] ?? 2;
    final bPriority = priorityOrder[b.priority] ?? 2;

    if (aPriority != bPriority) {
      return aPriority.compareTo(bPriority);
    }

    // If same priority, compare due dates
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return 1; // Tasks without due date go last
    if (b.dueDate == null) return -1;

    return a.dueDate!.compareTo(b.dueDate!);
  });

  return sorted;
}
