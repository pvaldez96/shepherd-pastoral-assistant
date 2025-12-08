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
/// - Each group is collapsible/expandable
/// - Filter tabs: Today, This Week, By Category, By Person, All
/// - Floating action button to create new task
/// - Empty state when no tasks exist
/// - Loading state with CircularProgressIndicator
/// - Error state with retry button
/// - Responsive layout for phone and tablet
///
/// Design:
/// - Background color: #F9FAFB
/// - Uses Material Design 3 components
/// - Follows Shepherd design system
/// - Accessible with proper semantics
///
/// Navigation:
/// - FAB opens quick capture: context.go('/quick-capture')
/// - Tapping task card opens detail: context.push('/tasks/${task.id}')
///
/// Usage:
/// This screen is displayed when navigating to '/tasks' via go_router.
/// It's wrapped in MainScaffold which provides the AppBar and navigation.
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
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(context),

          // Task list (with loading/error/empty states)
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              ),
              error: (error, stack) => ErrorTaskState(
                message: 'Failed to load tasks. Please try again.',
                onRetry: () {
                  // Refresh the provider
                  ref.invalidate(tasksProvider);
                },
              ),
              data: (tasks) {
                // Filter tasks based on current filter
                final filteredTasks = _filterTasks(tasks);

                // Show empty state if no tasks
                if (filteredTasks.isEmpty) {
                  return EmptyTaskState(
                    icon: Icons.inbox_outlined,
                    message: _getEmptyMessage(),
                    subtitle: _getEmptySubtitle(),
                    actionLabel: 'Add Task',
                    onActionPressed: () {
                      // TODO: Navigate to quick capture
                      // context.go('/quick-capture');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quick capture coming soon'),
                        ),
                      );
                    },
                  );
                }

                // Show grouped task list
                return _buildTaskList(filteredTasks);
              },
            ),
          ),
        ],
      ),

      // Floating action button to add new task
      floatingActionButton: Semantics(
        label: 'Add new task',
        button: true,
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to quick capture
            // context.go('/quick-capture');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quick capture coming soon'),
              ),
            );
          },
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  /// Build filter tabs at the top
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
  Widget _buildFilterChip(String label, TaskFilter filter) {
    final isSelected = _currentFilter == filter;

    return Semantics(
      label: '$label filter',
      button: true,
      selected: isSelected,
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

  /// Build task list with groups
  Widget _buildTaskList(List<TaskEntity> tasks) {
    // Group tasks by due date (for default view)
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
        // This is handled by TaskCard widget now
        return const SizedBox.shrink();
      },
    );
  }

  /// Build task list grouped by due date
  Widget _buildGroupedByDueDateList(List<TaskEntity> tasks) {
    final grouped = groupTasksByDueDate(tasks);

    // Sort tasks within each group
    final overdue = sortTasksByPriority(grouped['overdue'] ?? []);
    final today = sortTasksByPriority(grouped['today'] ?? []);
    final thisWeek = sortTasksByPriority(grouped['thisWeek'] ?? []);
    final noDueDate = sortTasksByPriority(grouped['noDueDate'] ?? []);
    final completed = sortTasksByPriority(grouped['completed'] ?? []);

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: [
        // OVERDUE section (red, always expanded if has tasks)
        TaskGroupSection(
          title: 'OVERDUE',
          tasks: overdue,
          accentColor: const Color(0xFFEF4444),
          initiallyExpanded: true,
        ),

        // TODAY section (orange, always expanded if has tasks)
        TaskGroupSection(
          title: 'TODAY',
          tasks: today,
          accentColor: const Color(0xFFF59E0B),
          initiallyExpanded: true,
        ),

        // THIS WEEK section (blue, default expanded)
        TaskGroupSection(
          title: 'THIS WEEK',
          tasks: thisWeek,
          accentColor: const Color(0xFF2563EB),
          initiallyExpanded: true,
        ),

        // NO DUE DATE section (gray, collapsed by default)
        TaskGroupSection(
          title: 'NO DUE DATE',
          tasks: noDueDate,
          accentColor: Colors.grey.shade600,
          initiallyExpanded: false,
        ),

        // COMPLETED section (green, collapsed by default, last 7 days)
        TaskGroupSection(
          title: 'COMPLETED',
          tasks: completed,
          accentColor: const Color(0xFF10B981),
          initiallyExpanded: false,
        ),
      ],
    );
  }

  /// Build task list grouped by category
  Widget _buildGroupedByCategoryList(List<TaskEntity> tasks) {
    // Filter out completed and deleted tasks
    final activeTasks = tasks
        .where((task) => task.status != 'done' && !task.isDeleted)
        .toList();

    final grouped = groupTasksByCategory(activeTasks);

    // Define category order and colors
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
  Widget _buildGroupedByPersonList(List<TaskEntity> tasks) {
    // Filter tasks that have a person assigned
    final tasksWithPerson =
        tasks.where((task) => task.personId != null).toList();

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
          title: 'PERSON: $personId', // TODO: Replace with actual person name
          tasks: personTasks,
          accentColor: const Color(0xFF2563EB),
          initiallyExpanded: true,
        );
      }).toList(),
    );
  }

  /// Get the appropriate provider based on current filter
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
  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    // Remove deleted tasks
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
// context.go('/tasks')
//
// Navigation from task card:
// context.push('/tasks/${task.id}')
//
// Navigation to quick capture:
// context.go('/quick-capture')
