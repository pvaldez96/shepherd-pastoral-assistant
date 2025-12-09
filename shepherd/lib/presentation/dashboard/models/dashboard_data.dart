import '../../../domain/entities/calendar_event.dart';
import '../../../domain/entities/task.dart';
import 'time_block.dart';

/// Container for all dashboard data
///
/// Aggregates data from multiple sources for the daily dashboard view:
/// - Today's calendar events
/// - Tasks due today
/// - Overdue tasks
/// - Available time blocks (gaps between events)
///
/// This is a simple data class - no smart suggestions or AI scoring yet.
class DashboardData {
  /// Calendar events scheduled for today, sorted by start time
  final List<CalendarEventEntity> todayEvents;

  /// Tasks due today, sorted by priority then due time
  final List<TaskEntity> todayTasks;

  /// Tasks that are overdue (past due date, not completed)
  final List<TaskEntity> overdueTasks;

  /// Available time blocks (gaps between events)
  final List<TimeBlock> availableBlocks;

  const DashboardData({
    required this.todayEvents,
    required this.todayTasks,
    required this.overdueTasks,
    required this.availableBlocks,
  });

  /// Creates an empty dashboard data instance
  factory DashboardData.empty() {
    return const DashboardData(
      todayEvents: [],
      todayTasks: [],
      overdueTasks: [],
      availableBlocks: [],
    );
  }

  /// Total number of items requiring attention
  int get totalItemCount => todayEvents.length + todayTasks.length + overdueTasks.length;

  /// Whether there's any data to display
  bool get hasData => totalItemCount > 0;

  /// Whether there are overdue tasks (needs attention)
  bool get hasOverdueTasks => overdueTasks.isNotEmpty;

  /// Total available minutes in time blocks
  int get totalAvailableMinutes {
    return availableBlocks.fold(0, (sum, block) => sum + block.durationMinutes);
  }

  /// Formatted total available time (e.g., "2h 30m")
  String get formattedAvailableTime {
    final hours = totalAvailableMinutes ~/ 60;
    final minutes = totalAvailableMinutes % 60;

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

  /// High priority tasks due today
  List<TaskEntity> get highPriorityTasks {
    return todayTasks.where((task) => task.priority == 'high').toList();
  }

  /// Next upcoming event (first event that hasn't started yet)
  CalendarEventEntity? get nextEvent {
    final now = DateTime.now();
    try {
      return todayEvents.firstWhere((event) => event.startDateTime.isAfter(now));
    } catch (_) {
      return null;
    }
  }

  /// Current event (event happening right now)
  CalendarEventEntity? get currentEvent {
    final now = DateTime.now();
    try {
      return todayEvents.firstWhere(
        (event) => event.startDateTime.isBefore(now) && event.endDateTime.isAfter(now),
      );
    } catch (_) {
      return null;
    }
  }

  /// Current or next available time block
  TimeBlock? get currentOrNextBlock {
    final now = DateTime.now();
    try {
      // First check for current block
      return availableBlocks.firstWhere(
        (block) => block.startTime.isBefore(now) && block.endTime.isAfter(now),
      );
    } catch (_) {
      // Then find next block
      try {
        return availableBlocks.firstWhere((block) => block.startTime.isAfter(now));
      } catch (_) {
        return null;
      }
    }
  }

  @override
  String toString() {
    return 'DashboardData('
        'events: ${todayEvents.length}, '
        'tasks: ${todayTasks.length}, '
        'overdue: ${overdueTasks.length}, '
        'blocks: ${availableBlocks.length})';
  }
}
