import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import 'providers/task_providers.dart';
import 'widgets/empty_task_state.dart';
import 'widgets/error_task_state.dart';
import 'widgets/task_group_section.dart';

/// Tasks screen - main task management interface
///
/// Features:
/// - Tasks grouped by sections: OVERDUE, TODAY, THIS WEEK, NO DUE DATE, COMPLETED
/// - Each group is collapsible/expandable with smooth animations
/// - Filter tabs: All, Today, This Week, By Category, By Person
/// - Empty state when no tasks exist
/// - Loading state with CircularProgressIndicator
/// - Error state with retry button
/// - Responsive layout for phone and tablet
/// - Full accessibility support
///
/// Design:
/// - Background color: #F9FAFB (Shepherd design system)
/// - Uses Material Design 3 components
/// - Follows Shepherd design system for colors, typography, spacing
/// - Card-based layout with 12px border radius
/// - Proper touch targets (44x44 minimum)
/// - No FAB (action button handled by MainScaffold)
///
/// Navigation:
/// - Tapping task card opens detail: context.push('/tasks/${task.id}')
///
/// State Management:
/// - Uses Riverpod StreamProvider for real-time task updates
/// - Automatic UI refresh when tasks change in database
/// - Optimistic updates for task completion
///
/// Usage:
/// This screen is displayed when navigating to '/tasks' via go_router.
/// It's typically wrapped in MainScaffold which provides AppBar and navigation.
///
/// Example:
/// ```dart
/// GoRoute(
///   path: '/tasks',
///   builder: (context, state) => const TasksScreen(),
/// )
/// ```
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  // Current filter selection
  TaskFilter _currentFilter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    // Watch the appropriate provider based on current filter
    final tasksAsync = _getTasksProvider();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Shepherd background color
      body: Column(
        children: [
          // Filter tabs at the top
          _buildFilterTabs(context),

          // Task list with loading/error/empty states
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB), // Shepherd primary blue
                  strokeWidth: 3,
                ),
              ),
              error: (error, stack) => ErrorTaskState(
                message: 'Failed to load tasks. Please try again.',
                onRetry: () {
                  // Invalidate provider to trigger reload
                  ref.invalidate(tasksProvider);
                },
              ),
              data: (tasks) {
                // Filter tasks based on current filter
                final filteredTasks = _filterTasks(tasks);

                // Show empty state if no tasks
                if (filteredTasks.isEmpty) {
                  return EmptyTaskState(
                    icon: _getEmptyIcon(),
                    message: _getEmptyMessage(),
                    subtitle: _getEmptySubtitle(),
                    // No action button - handled by MainScaffold
                  );
                }

                // Show grouped task list
                return _buildTaskList(filteredTasks);
              },
            ),
          ),
        ],
      ),
      // No FAB - action button is handled by MainScaffold
    );
  }

  /// Build filter tabs at the top
  ///
  /// Displays horizontal scrollable filter chips:
  /// - All
  /// - Today
  /// - This Week
  /// - By Category
  /// - By Person
  Widget _buildFilterTabs(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildFilterChip('All', TaskFilter.all),
            const SizedBox(width: 8),
            _buildFilterChip('Today', TaskFilter.today),
            const SizedBox(width: 8),
            _buildFilterChip('This Week', TaskFilter.thisWeek),
            const SizedBox(width: 8),
            _buildFilterChip('By Category', TaskFilter.byCategory),
            const SizedBox(width: 8),
            _buildFilterChip('By Person', TaskFilter.byPerson),
          ],
        ),
      ),
    );
  }

  /// Build individual filter chip
  ///
  /// Shows selected state with primary blue color.
  /// Unselected chips have gray background.
  Widget _buildFilterChip(String label, TaskFilter filter) {
    final isSelected = _currentFilter == filter;

    return Semantics(
      label: '$label filter',
      button: true,
      selected: isSelected,
      hint: isSelected ? 'Currently selected' : 'Tap to filter by $label',
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _currentFilter = filter;
          });
        },
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
        backgroundColor: Colors.grey.shade100,
        selectedColor: const Color(0xFF2563EB),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Build task list with appropriate grouping
  ///
  /// Groups tasks differently based on the current filter:
  /// - All/Today/This Week: Group by due date
  /// - By Category: Group by category
  /// - By Person: Group by person
  Widget _buildTaskList(List<TaskEntity> tasks) {
    // Group tasks by due date (for default/date-based views)
    if (_currentFilter == TaskFilter.all ||
        _currentFilter == TaskFilter.today ||
        _currentFilter == TaskFilter.thisWeek) {
      return _buildGroupedByDueDateList(tasks);
    }

    // Group by category
    if (_currentFilter == TaskFilter.byCategory) {
      return _buildGroupedByCategoryList(tasks);
    }

    // Group by person
    if (_currentFilter == TaskFilter.byPerson) {
      return _buildGroupedByPersonList(tasks);
    }

    // Fallback: simple list
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return const SizedBox.shrink();
      },
    );
  }

  /// Build task list grouped by due date
  ///
  /// Groups:
  /// - OVERDUE (red) - past due date, not completed, always expanded
  /// - TODAY (orange) - due today, always expanded
  /// - THIS WEEK (blue) - due within 7 days, default expanded
  /// - NO DUE DATE (gray) - no due date set, collapsed by default
  /// - COMPLETED (green) - completed in last 7 days, collapsed by default
  Widget _buildGroupedByDueDateList(List<TaskEntity> tasks) {
    final grouped = groupTasksByDueDate(tasks);

    // Sort tasks within each group by priority
    final overdue = sortTasksByPriority(grouped['overdue'] ?? []);
    final today = sortTasksByPriority(grouped['today'] ?? []);
    final thisWeek = sortTasksByPriority(grouped['thisWeek'] ?? []);
    final noDueDate = sortTasksByPriority(grouped['noDueDate'] ?? []);
    final completed = sortTasksByPriority(grouped['completed'] ?? []);

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: [
        // OVERDUE section (red, high priority, always expanded)
        TaskGroupSection(
          title: 'OVERDUE',
          tasks: overdue,
          accentColor: const Color(0xFFEF4444), // Shepherd error red
          initiallyExpanded: true,
        ),

        // TODAY section (orange, high priority, always expanded)
        TaskGroupSection(
          title: 'TODAY',
          tasks: today,
          accentColor: const Color(0xFFF59E0B), // Shepherd warning orange
          initiallyExpanded: true,
        ),

        // THIS WEEK section (blue, default expanded)
        TaskGroupSection(
          title: 'THIS WEEK',
          tasks: thisWeek,
          accentColor: const Color(0xFF2563EB), // Shepherd primary blue
          initiallyExpanded: true,
        ),

        // NO DUE DATE section (gray, collapsed by default)
        TaskGroupSection(
          title: 'NO DUE DATE',
          tasks: noDueDate,
          accentColor: Colors.grey.shade600,
          initiallyExpanded: false,
        ),

        // COMPLETED section (green, collapsed by default)
        // Shows tasks completed in the last 7 days
        TaskGroupSection(
          title: 'COMPLETED',
          tasks: completed,
          accentColor: const Color(0xFF10B981), // Shepherd success green
          initiallyExpanded: false,
        ),
      ],
    );
  }

  /// Build task list grouped by category
  ///
  /// Shows tasks organized by:
  /// - Sermon Prep (blue)
  /// - Pastoral Care (green)
  /// - Admin (orange)
  /// - Personal (purple)
  /// - Worship Planning (teal)
  ///
  /// Only shows non-completed, non-deleted tasks.
  Widget _buildGroupedByCategoryList(List<TaskEntity> tasks) {
    // Filter out completed and deleted tasks for category view
    final activeTasks = tasks
        .where((task) => task.status != 'done' && !task.isDeleted)
        .toList();

    final grouped = groupTasksByCategory(activeTasks);

    // Define category order and display info
    final categoryInfo = {
      'sermon_prep': (label: 'Sermon Prep', color: const Color(0xFF2563EB)),
      'pastoral_care':
          (label: 'Pastoral Care', color: const Color(0xFF10B981)),
      'admin': (label: 'Admin', color: const Color(0xFFF59E0B)),
      'personal': (label: 'Personal', color: const Color(0xFF8B5CF6)),
      'worship_planning': (label: 'Worship', color: const Color(0xFF14B8A6)),
    };

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: categoryInfo.entries.map((entry) {
        final category = entry.key;
        final info = entry.value;
        final categoryTasks = sortTasksByPriority(grouped[category] ?? []);

        return TaskGroupSection(
          title: info.label.toUpperCase(),
          tasks: categoryTasks,
          accentColor: info.color,
          initiallyExpanded: true,
        );
      }).toList(),
    );
  }

  /// Build task list grouped by person
  ///
  /// Shows tasks assigned to specific people.
  /// Displays empty state if no tasks are assigned to people.
  Widget _buildGroupedByPersonList(List<TaskEntity> tasks) {
    // Filter tasks that have a person assigned
    final tasksWithPerson =
        tasks.where((task) => task.personId != null && !task.isDeleted).toList();

    if (tasksWithPerson.isEmpty) {
      return const EmptyTaskState(
        icon: Icons.person_outline,
        message: 'No tasks assigned to people',
        subtitle: 'Link tasks to people from the task detail screen',
      );
    }

    // Group by person ID
    final Map<String, List<TaskEntity>> grouped = {};
    for (final task in tasksWithPerson) {
      final personId = task.personId!;
      if (!grouped.containsKey(personId)) {
        grouped[personId] = [];
      }
      grouped[personId]!.add(task);
    }

    // Build sections for each person
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: grouped.entries.map((entry) {
        final personId = entry.key;
        final personTasks = sortTasksByPriority(entry.value);

        return TaskGroupSection(
          // TODO: Replace with actual person name when People module is implemented
          title: 'PERSON: $personId',
          tasks: personTasks,
          accentColor: const Color(0xFF2563EB),
          initiallyExpanded: true,
        );
      }).toList(),
    );
  }

  /// Get the appropriate provider based on current filter
  ///
  /// Returns different StreamProviders for optimal performance:
  /// - Today: Pre-filtered provider for today's tasks
  /// - This Week: Pre-filtered provider for this week's tasks
  /// - All/Category/Person: All tasks provider, filtered in UI
  AsyncValue<List<TaskEntity>> _getTasksProvider() {
    switch (_currentFilter) {
      case TaskFilter.today:
        return ref.watch(todayTasksProvider);
      case TaskFilter.thisWeek:
        return ref.watch(weekTasksProvider);
      case TaskFilter.all:
      case TaskFilter.byCategory:
      case TaskFilter.byPerson:
        return ref.watch(tasksProvider);
    }
  }

  /// Filter tasks based on current filter
  ///
  /// Removes deleted tasks and applies additional filters.
  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    // Always remove deleted tasks
    final activeTasks = tasks.where((task) => !task.isDeleted).toList();

    switch (_currentFilter) {
      case TaskFilter.today:
      case TaskFilter.thisWeek:
        // Already filtered by provider
        return activeTasks;

      case TaskFilter.byCategory:
        // Show only non-completed tasks for category view
        return activeTasks.where((task) => task.status != 'done').toList();

      case TaskFilter.byPerson:
        // Show only tasks with person assigned
        return activeTasks.where((task) => task.personId != null).toList();

      case TaskFilter.all:
        return activeTasks;
    }
  }

  /// Get empty state icon based on current filter
  IconData _getEmptyIcon() {
    switch (_currentFilter) {
      case TaskFilter.today:
        return Icons.wb_sunny_outlined;
      case TaskFilter.thisWeek:
        return Icons.calendar_today_outlined;
      case TaskFilter.byCategory:
        return Icons.category_outlined;
      case TaskFilter.byPerson:
        return Icons.person_outline;
      case TaskFilter.all:
        return Icons.inbox_outlined;
    }
  }

  /// Get empty state message based on current filter
  String _getEmptyMessage() {
    switch (_currentFilter) {
      case TaskFilter.today:
        return 'No tasks due today';
      case TaskFilter.thisWeek:
        return 'No tasks this week';
      case TaskFilter.byCategory:
        return 'No tasks in any category';
      case TaskFilter.byPerson:
        return 'No tasks assigned to people';
      case TaskFilter.all:
        return 'No tasks yet';
    }
  }

  /// Get empty state subtitle based on current filter
  String _getEmptySubtitle() {
    switch (_currentFilter) {
      case TaskFilter.today:
        return 'Great! You have a clear schedule for today.';
      case TaskFilter.thisWeek:
        return 'Your week is looking clear.';
      case TaskFilter.byCategory:
        return 'Create tasks and assign them to categories.';
      case TaskFilter.byPerson:
        return 'Link tasks to people from the task detail screen.';
      case TaskFilter.all:
        return 'Create your first task to get started.';
    }
  }
}

/// Enum for task filter options
enum TaskFilter {
  all,
  today,
  thisWeek,
  byCategory,
  byPerson,
}

// Usage with go_router:
// ```dart
// GoRoute(
//   path: '/tasks',
//   builder: (context, state) => const TasksScreen(),
// )
// ```
//
// Navigation from task card:
// ```dart
// onTap: () => context.push('/tasks/${task.id}')
// ```
//
// Navigation to quick capture:
// ```dart
// onPressed: () => context.go('/quick-capture')
// ```
