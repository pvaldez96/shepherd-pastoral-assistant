import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/calendar_event.dart';
import '../../../domain/entities/task.dart';
import '../../calendar/providers/calendar_event_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../models/dashboard_data.dart';
import '../models/time_block.dart';

/// Provider for aggregated dashboard data
///
/// Combines data from multiple sources:
/// - Today's calendar events (from calendarEventsProvider)
/// - Today's tasks (from tasksProvider)
/// - Overdue tasks (from tasksProvider)
/// - Available time blocks (calculated from events)
///
/// Automatically rebuilds when any underlying data changes.
///
/// Usage:
/// ```dart
/// class DashboardScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final dashboardAsync = ref.watch(dashboardDataProvider);
///
///     return dashboardAsync.when(
///       data: (data) => DashboardContent(data: data),
///       loading: () => CircularProgressIndicator(),
///       error: (err, stack) => Text('Error: $err'),
///     );
///   }
/// }
/// ```
final dashboardDataProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final eventsAsync = ref.watch(todayEventsProvider);
  final tasksAsync = ref.watch(tasksProvider);

  // If either is loading, show loading
  if (eventsAsync.isLoading || tasksAsync.isLoading) {
    return const AsyncValue.loading();
  }

  // If either has error, show error
  if (eventsAsync.hasError) {
    return AsyncValue.error(eventsAsync.error!, eventsAsync.stackTrace ?? StackTrace.current);
  }
  if (tasksAsync.hasError) {
    return AsyncValue.error(tasksAsync.error!, tasksAsync.stackTrace ?? StackTrace.current);
  }

  // Both have data - combine them
  final events = eventsAsync.value ?? [];
  final tasks = tasksAsync.value ?? [];

  return AsyncValue.data(_buildDashboardData(events, tasks));
});

/// Build DashboardData from events and tasks
DashboardData _buildDashboardData(
  List<CalendarEventEntity> events,
  List<TaskEntity> tasks,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  // Sort today's events by start time (already filtered by todayEventsProvider)
  final todayEvents = List<CalendarEventEntity>.from(events)
    ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

  // Filter today's tasks
  final todayTasks = tasks.where((task) {
    if (task.dueDate == null || task.isDeleted || task.status == 'done') {
      return false;
    }
    final dueDate = task.dueDate!;
    return dueDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
           dueDate.isBefore(tomorrow);
  }).toList()
    ..sort((a, b) {
      // Sort by priority (high first), then by due time
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      final aPriority = priorityOrder[a.priority] ?? 1;
      final bPriority = priorityOrder[b.priority] ?? 1;
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      // Then by due time if both have one
      if (a.dueTime != null && b.dueTime != null) {
        return a.dueTime!.compareTo(b.dueTime!);
      }
      return 0;
    });

  // Filter overdue tasks
  final overdueTasks = tasks.where((task) {
    if (task.dueDate == null || task.isDeleted || task.status == 'done') {
      return false;
    }
    return task.dueDate!.isBefore(today);
  }).toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

  // Calculate available time blocks
  final availableBlocks = _calculateAvailableBlocks(todayEvents, today);

  return DashboardData(
    todayEvents: todayEvents,
    todayTasks: todayTasks,
    overdueTasks: overdueTasks,
    availableBlocks: availableBlocks,
  );
}

/// Calculate available time blocks (gaps between events)
///
/// Parameters:
/// - events: List of today's events, must be sorted by start time
/// - today: Start of today (midnight)
///
/// Returns: List of TimeBlock representing available gaps
///
/// Algorithm:
/// 1. Define work day boundaries (default 8:00 AM - 6:00 PM)
/// 2. For each gap between events, create a TimeBlock
/// 3. Include gap before first event and after last event
/// 4. Filter out blocks shorter than 15 minutes
List<TimeBlock> _calculateAvailableBlocks(
  List<CalendarEventEntity> events,
  DateTime today,
) {
  // Define work day boundaries
  final workDayStart = DateTime(today.year, today.month, today.day, 8, 0); // 8:00 AM
  final workDayEnd = DateTime(today.year, today.month, today.day, 18, 0); // 6:00 PM

  final now = DateTime.now();
  final blocks = <TimeBlock>[];

  if (events.isEmpty) {
    // No events - entire work day is available
    // But only from now onwards if we're past work day start
    final blockStart = now.isAfter(workDayStart) ? now : workDayStart;
    if (blockStart.isBefore(workDayEnd)) {
      blocks.add(TimeBlock(startTime: blockStart, endTime: workDayEnd));
    }
    return blocks;
  }

  // Track current position (start from work day start or now, whichever is later)
  var currentTime = now.isAfter(workDayStart) ? now : workDayStart;

  for (final event in events) {
    // Skip events that have already ended
    if (event.endDateTime.isBefore(currentTime)) {
      continue;
    }

    // If event starts after current time, we have a gap
    if (event.startDateTime.isAfter(currentTime)) {
      // Cap the end time at event start or work day end
      final blockEnd = event.startDateTime.isBefore(workDayEnd)
          ? event.startDateTime
          : workDayEnd;

      if (blockEnd.isAfter(currentTime)) {
        final block = TimeBlock(startTime: currentTime, endTime: blockEnd);
        if (block.isUsable) {
          blocks.add(block);
        }
      }
    }

    // Move current time to event end (or now if event is ongoing)
    if (event.endDateTime.isAfter(currentTime)) {
      currentTime = event.endDateTime;
    }

    // Stop if we've passed work day end
    if (currentTime.isAfter(workDayEnd)) {
      break;
    }
  }

  // Add remaining time after last event (up to work day end)
  if (currentTime.isBefore(workDayEnd)) {
    final block = TimeBlock(startTime: currentTime, endTime: workDayEnd);
    if (block.isUsable) {
      blocks.add(block);
    }
  }

  return blocks;
}

/// Provider for just the available time blocks
///
/// Useful when you only need time block information.
final availableBlocksProvider = Provider<AsyncValue<List<TimeBlock>>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);

  return dashboardAsync.whenData((data) => data.availableBlocks);
});

/// Provider for dashboard summary statistics
///
/// Quick stats for dashboard header or summary cards.
final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);

  return dashboardAsync.whenData((data) => DashboardStats(
    eventCount: data.todayEvents.length,
    taskCount: data.todayTasks.length,
    overdueCount: data.overdueTasks.length,
    availableMinutes: data.totalAvailableMinutes,
    highPriorityCount: data.highPriorityTasks.length,
  ));
});

/// Simple stats container for dashboard summary
class DashboardStats {
  final int eventCount;
  final int taskCount;
  final int overdueCount;
  final int availableMinutes;
  final int highPriorityCount;

  const DashboardStats({
    required this.eventCount,
    required this.taskCount,
    required this.overdueCount,
    required this.availableMinutes,
    required this.highPriorityCount,
  });

  /// Total items requiring attention today
  int get totalItems => eventCount + taskCount;

  /// Whether there are items needing urgent attention
  bool get needsAttention => overdueCount > 0 || highPriorityCount > 0;

  /// Formatted available time
  String get formattedAvailableTime {
    final hours = availableMinutes ~/ 60;
    final minutes = availableMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return 'No free time';
    }
  }
}
