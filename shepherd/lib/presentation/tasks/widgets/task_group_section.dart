import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';
import 'task_card.dart';

/// Collapsible task group section widget
///
/// Displays a group of tasks with a collapsible header showing:
/// - Group title (e.g., "OVERDUE", "TODAY", "THIS WEEK")
/// - Task count badge
/// - Expand/collapse chevron icon
/// - Optional color accent for visual hierarchy
///
/// Features:
/// - Smooth expand/collapse animation (200ms duration)
/// - AnimatedCrossFade for content transitions
/// - Persists expanded state during session
/// - Shows task count in header
/// - Color-coded headers for different groups
/// - Auto-hides when no tasks (returns SizedBox.shrink)
/// - Accessible with proper semantics
///
/// Design:
/// - Header: 16px horizontal padding, 12px vertical padding
/// - Task cards: Rendered using TaskCard widget
/// - Animation: 200ms with easeInOut curve
/// - Touch target: Full header is tappable (minimum 44px height)
///
/// Usage:
/// ```dart
/// TaskGroupSection(
///   title: 'OVERDUE',
///   tasks: overdueTasks,
///   accentColor: const Color(0xFFEF4444), // Red
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
    // Don't render section if no tasks
    if (widget.tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: '${widget.title} section, ${widget.tasks.length} tasks',
      hint: _isExpanded ? 'Tap to collapse' : 'Tap to expand',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header (title, count, expand button)
          _buildHeader(context),

          // Task list (collapsible with animation)
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
  ///
  /// Header components:
  /// - Chevron icon (right-pointing when collapsed, down-pointing when expanded)
  /// - Title text (uppercase, bold)
  /// - Task count badge (gray, lighter font weight)
  /// - Optional accent indicator (small colored circle)
  ///
  /// Entire header is tappable to toggle expand/collapse.
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            // Minimum touch target height
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                // Expand/collapse chevron icon
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
                            fontSize: 13,
                          ),
                      children: [
                        // Title text
                        TextSpan(
                          text: widget.title,
                          style: TextStyle(
                            color: widget.accentColor ?? Colors.grey.shade700,
                          ),
                        ),
                        // Task count badge
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

                // Optional accent indicator (colored dot)
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
  ///
  /// Renders each task using the TaskCard widget.
  /// Adds spacing before and after the list.
  Widget _buildTaskList() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Render each task using TaskCard
        ...widget.tasks.map((task) => TaskCard(
              task: task,
              onTap: widget.onTaskTap,
            )),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Helper function to group tasks by their category
///
/// Returns a map of category name to list of tasks.
/// Useful for "Group by Category" view.
///
/// Categories:
/// - sermon_prep
/// - pastoral_care
/// - admin
/// - personal
/// - worship_planning
///
/// Usage:
/// ```dart
/// final groupedTasks = groupTasksByCategory(allTasks);
/// final sermonTasks = groupedTasks['sermon_prep'] ?? [];
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
/// Groups tasks into predefined buckets:
/// - **overdue**: Past due date, not completed
/// - **today**: Due today (between today 00:00 and tomorrow 00:00)
/// - **thisWeek**: Due within next 7 days (excluding today)
/// - **noDueDate**: No due date set, or future tasks beyond 7 days
/// - **completed**: Completed in last 7 days
///
/// Logic:
/// 1. Completed tasks go to 'completed' if completed within last 7 days
/// 2. Deleted tasks are skipped
/// 3. Tasks without due date go to 'noDueDate'
/// 4. Remaining tasks are bucketed by due date
///
/// Usage:
/// ```dart
/// final groupedTasks = groupTasksByDueDate(allTasks);
/// final overdueTasks = groupedTasks['overdue'] ?? [];
/// final todayTasks = groupedTasks['today'] ?? [];
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
    // Skip deleted tasks
    if (task.isDeleted) continue;

    // Completed tasks (last 7 days only)
    if (task.status == 'done') {
      if (task.completedAt != null && task.completedAt!.isAfter(sevenDaysAgo)) {
        grouped['completed']!.add(task);
      }
      continue;
    }

    // No due date
    if (task.dueDate == null) {
      grouped['noDueDate']!.add(task);
      continue;
    }

    final dueDate = task.dueDate!;

    // Overdue (past due, not completed)
    if (dueDate.isBefore(today)) {
      grouped['overdue']!.add(task);
    }
    // Today (due between today 00:00 and tomorrow 00:00)
    else if (dueDate.isAfter(today) && dueDate.isBefore(tomorrow)) {
      grouped['today']!.add(task);
    }
    // This week (due between tomorrow and 7 days from now)
    else if (dueDate.isAfter(tomorrow) && dueDate.isBefore(weekFromNow)) {
      grouped['thisWeek']!.add(task);
    }
    // Future tasks beyond this week
    else {
      grouped['noDueDate']!.add(task);
    }
  }

  return grouped;
}

/// Helper function to sort tasks by priority and due date
///
/// Sorting logic:
/// 1. **Primary sort**: Priority (urgent > high > medium > low)
/// 2. **Secondary sort**: Due date (earliest first)
/// 3. Tasks without due date go to the end
///
/// Priority order:
/// - urgent: 0 (highest)
/// - high: 1
/// - medium: 2
/// - low: 3 (lowest)
///
/// This ensures:
/// - Urgent tasks always appear first
/// - Within same priority, earliest due dates appear first
/// - Tasks without due dates appear last within their priority
///
/// Usage:
/// ```dart
/// final sortedTasks = sortTasksByPriority(tasks);
/// ```
List<TaskEntity> sortTasksByPriority(List<TaskEntity> tasks) {
  // Priority order mapping
  final priorityOrder = {
    'urgent': 0,
    'high': 1,
    'medium': 2,
    'low': 3,
  };

  // Create a mutable copy to sort
  final sorted = List<TaskEntity>.from(tasks);

  sorted.sort((a, b) {
    // Primary sort: Compare priority
    final aPriority = priorityOrder[a.priority] ?? 2; // Default to medium
    final bPriority = priorityOrder[b.priority] ?? 2;

    if (aPriority != bPriority) {
      return aPriority.compareTo(bPriority);
    }

    // Secondary sort: Compare due dates
    // Tasks without due date go last
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return 1; // a goes after b
    if (b.dueDate == null) return -1; // a goes before b

    // Both have due dates, compare them (earliest first)
    return a.dueDate!.compareTo(b.dueDate!);
  });

  return sorted;
}
