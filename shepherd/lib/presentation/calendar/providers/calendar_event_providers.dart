import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/repositories/calendar_event_repository_impl.dart';
import '../../../domain/entities/calendar_event.dart';
import '../../../domain/repositories/calendar_event_repository.dart';

/// Provider for the AppDatabase singleton
/// Note: This is shared with task_providers.dart - in production,
/// move to a central location to avoid duplication
final calendarDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider for CalendarEventRepository implementation
///
/// This is the main repository provider for calendar events.
/// Provides offline-first event operations with automatic sync queue integration.
final calendarEventRepositoryProvider = Provider<CalendarEventRepository>((ref) {
  final database = ref.watch(calendarDatabaseProvider);
  return CalendarEventRepositoryImpl(database);
});

/// Stream provider for all calendar events
///
/// Watches the local database for changes and automatically updates the UI.
/// Perfect for calendar list screens.
///
/// Usage:
/// ```dart
/// class CalendarScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final eventsAsync = ref.watch(calendarEventsProvider);
///
///     return eventsAsync.when(
///       data: (events) => ListView.builder(
///         itemCount: events.length,
///         itemBuilder: (context, index) => EventCard(event: events[index]),
///       ),
///       loading: () => CircularProgressIndicator(),
///       error: (err, stack) => Text('Error: $err'),
///     );
///   }
/// }
/// ```
final calendarEventsProvider = StreamProvider<List<CalendarEventEntity>>((ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.watchEvents();
});

/// Stream provider for a single event by ID
///
/// Watches a specific event and updates when it changes.
///
/// Usage:
/// ```dart
/// final eventAsync = ref.watch(calendarEventProvider(eventId));
/// ```
final calendarEventProvider = StreamProvider.family<CalendarEventEntity?, String>((ref, id) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.watchEvent(id);
});

/// Stream provider for today's events
///
/// Returns all events scheduled for today.
///
/// Usage:
/// ```dart
/// final todayEvents = ref.watch(todayEventsProvider);
/// ```
final todayEventsProvider = StreamProvider<List<CalendarEventEntity>>((ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.watchTodayEvents();
});

/// Stream provider for events on a specific date
///
/// Returns all events for a given date.
///
/// Usage:
/// ```dart
/// final dateEvents = ref.watch(eventsForDateProvider(DateTime(2024, 12, 25)));
/// ```
final eventsForDateProvider = StreamProvider.family<List<CalendarEventEntity>, DateTime>((ref, date) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.watchEventsForDate(date);
});

/// Stream provider for events in a date range
///
/// Returns all events within a date range (for week/month views).
///
/// Usage:
/// ```dart
/// final rangeEvents = ref.watch(eventsInRangeProvider(DateRange(start, end)));
/// ```
final eventsInRangeProvider = StreamProvider.family<List<CalendarEventEntity>, DateRange>((ref, range) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.watchEventsInRange(range.start, range.end);
});

/// Helper class for date range parameters
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

/// Stream provider for events by type
///
/// Filters events by type (service, meeting, pastoral_visit, etc.).
///
/// Usage:
/// ```dart
/// final services = ref.watch(eventsByTypeProvider('service'));
/// final pastoralVisits = ref.watch(eventsByTypeProvider('pastoral_visit'));
/// ```
final eventsByTypeProvider = StreamProvider.family<List<CalendarEventEntity>, String>((ref, eventType) {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.watchEventsByType(eventType);
});

/// Stream provider for upcoming events
///
/// Returns the next N events starting from now.
///
/// Usage:
/// ```dart
/// final upcomingEvents = ref.watch(upcomingEventsProvider);
/// ```
final upcomingEventsProvider = FutureProvider<List<CalendarEventEntity>>((ref) async {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.getUpcomingEvents(limit: 10);
});

/// Stream provider for this week's events
///
/// Returns all events for the current week.
///
/// Usage:
/// ```dart
/// final weekEvents = ref.watch(weekEventsProvider);
/// ```
final weekEventsProvider = FutureProvider<List<CalendarEventEntity>>((ref) async {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.getWeekEvents();
});

/// Provider for events by person
///
/// Returns all events linked to a specific person.
///
/// Usage:
/// ```dart
/// final personEvents = ref.watch(eventsByPersonProvider(personId));
/// ```
final eventsByPersonProvider = FutureProvider.family<List<CalendarEventEntity>, String>((ref, personId) async {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.getEventsByPerson(personId);
});

/// Provider for events needing sync
///
/// Returns events with sync_status = 'pending'.
/// Useful for sync status indicators.
///
/// Usage:
/// ```dart
/// final pendingSync = ref.watch(pendingEventsProvider);
/// if (pendingSync.value?.isNotEmpty == true) {
///   // Show sync indicator
/// }
/// ```
final pendingEventsProvider = StreamProvider<List<CalendarEventEntity>>((ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);

  return repository.watchEvents().map(
        (events) => events.where((event) => event.needsSync).toList(),
      );
});

/// Provider for event load for a specific date
///
/// Returns total scheduled hours for a date.
/// Useful for workload indicators.
///
/// Usage:
/// ```dart
/// final load = ref.watch(eventLoadForDateProvider(DateTime.now()));
/// // load.value == 6.5 (6.5 hours scheduled)
/// ```
final eventLoadForDateProvider = FutureProvider.family<double, DateTime>((ref, date) async {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.getEventLoadForDate(date);
});

/// Provider for weekly event load
///
/// Returns Map of date -> hours scheduled for a week.
/// Useful for weekly workload charts.
///
/// Usage:
/// ```dart
/// final weekStart = DateTime(2024, 12, 9); // Monday
/// final weekLoad = ref.watch(eventLoadForWeekProvider(weekStart));
/// ```
final eventLoadForWeekProvider = FutureProvider.family<Map<DateTime, double>, DateTime>((ref, weekStart) async {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.getEventLoadForWeek(weekStart);
});

/// Provider for conflicting events
///
/// Returns events that overlap with a given time range.
/// Useful for conflict detection when creating/editing events.
///
/// Usage:
/// ```dart
/// final conflicts = ref.watch(conflictingEventsProvider(ConflictCheckParams(
///   start: DateTime(2024, 12, 10, 10, 0),
///   end: DateTime(2024, 12, 10, 11, 30),
///   excludeEventId: currentEventId, // Optional - exclude current event when editing
/// )));
/// ```
final conflictingEventsProvider = FutureProvider.family<List<CalendarEventEntity>, ConflictCheckParams>((ref, params) async {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.findConflictingEvents(
    params.start,
    params.end,
    excludeEventId: params.excludeEventId,
  );
});

/// Helper class for conflict check parameters
class ConflictCheckParams {
  final DateTime start;
  final DateTime end;
  final String? excludeEventId;

  const ConflictCheckParams({
    required this.start,
    required this.end,
    this.excludeEventId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConflictCheckParams &&
        other.start == start &&
        other.end == end &&
        other.excludeEventId == excludeEventId;
  }

  @override
  int get hashCode => Object.hash(start, end, excludeEventId);
}

/// Provider for calendar statistics
///
/// Returns event counts by type and other stats for dashboard widgets.
///
/// Usage:
/// ```dart
/// final stats = ref.watch(calendarStatsProvider);
/// stats.when(
///   data: (stats) => Text('${stats['total']} events this week'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error loading stats'),
/// );
/// ```
final calendarStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final repository = ref.watch(calendarEventRepositoryProvider);

  return repository.watchEvents().map((events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekFromNow = today.add(const Duration(days: 7));

    return {
      'total': events.length,
      'today': events.where((e) {
        return e.startDateTime.isAfter(today) && e.startDateTime.isBefore(tomorrow);
      }).length,
      'this_week': events.where((e) {
        return e.startDateTime.isAfter(today) && e.startDateTime.isBefore(weekFromNow);
      }).length,
      'services': events.where((e) => e.eventType == 'service').length,
      'meetings': events.where((e) => e.eventType == 'meeting').length,
      'pastoral_visits': events.where((e) => e.eventType == 'pastoral_visit').length,
      'personal': events.where((e) => e.eventType == 'personal').length,
      'high_energy': events.where((e) => e.isHighEnergy).length,
      'requires_prep': events.where((e) => e.requiresPreparation).length,
    };
  });
});

/// Provider for recurring events
///
/// Returns all recurring events for management.
///
/// Usage:
/// ```dart
/// final recurring = ref.watch(recurringEventsProvider);
/// ```
final recurringEventsProvider = FutureProvider<List<CalendarEventEntity>>((ref) async {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.getRecurringEvents();
});

/// Provider for events requiring preparation
///
/// Returns events that need preparation time.
/// Useful for prep reminders.
///
/// Usage:
/// ```dart
/// final prepEvents = ref.watch(eventsRequiringPreparationProvider);
/// ```
final eventsRequiringPreparationProvider = FutureProvider<List<CalendarEventEntity>>((ref) async {
  final repository = ref.watch(calendarEventRepositoryProvider);
  return repository.getEventsRequiringPreparation();
});
