import '../entities/calendar_event.dart';

/// Repository interface for CalendarEvent operations
///
/// This defines the contract for calendar event data access without specifying
/// implementation details. Following clean architecture, this allows
/// the domain layer to be independent of data sources.
abstract class CalendarEventRepository {
  /// Get all calendar events for the current user
  ///
  /// Returns list of events ordered by start date.
  /// Uses local database (offline-first).
  Future<List<CalendarEventEntity>> getAllEvents();

  /// Get a single event by ID
  ///
  /// Returns null if event not found.
  Future<CalendarEventEntity?> getEventById(String id);

  /// Create a new calendar event
  ///
  /// - Generates client-side UUID if not provided
  /// - Saves to local database immediately (optimistic update)
  /// - Adds to sync queue for background sync
  /// - Returns the created event with generated ID
  Future<CalendarEventEntity> createEvent(CalendarEventEntity event);

  /// Update an existing calendar event
  ///
  /// - Updates local database immediately (optimistic update)
  /// - Increments version for optimistic locking
  /// - Adds to sync queue for background sync
  /// - Throws if event not found
  Future<CalendarEventEntity> updateEvent(CalendarEventEntity event);

  /// Delete a calendar event
  ///
  /// - Removes from local database
  /// - Adds to sync queue for background sync
  Future<void> deleteEvent(String id);

  /// Watch all events with real-time updates
  ///
  /// Returns a stream that emits updated event lists whenever
  /// local database changes. Perfect for reactive UI with Riverpod.
  Stream<List<CalendarEventEntity>> watchEvents();

  /// Watch a single event by ID with real-time updates
  ///
  /// Returns a stream that emits updated event whenever it changes.
  /// Emits null if event is not found.
  Stream<CalendarEventEntity?> watchEvent(String id);

  /// Get events for a specific date
  ///
  /// Returns all events that occur on the given date
  Future<List<CalendarEventEntity>> getEventsForDate(DateTime date);

  /// Watch events for a specific date
  ///
  /// Stream of events for a specific date with real-time updates
  Stream<List<CalendarEventEntity>> watchEventsForDate(DateTime date);

  /// Get events in a date range
  ///
  /// Returns all events that overlap with the given date range
  Future<List<CalendarEventEntity>> getEventsInRange(DateTime start, DateTime end);

  /// Watch events in a date range
  ///
  /// Stream of events in range with real-time updates
  Stream<List<CalendarEventEntity>> watchEventsInRange(DateTime start, DateTime end);

  /// Get today's events
  Future<List<CalendarEventEntity>> getTodayEvents();

  /// Watch today's events
  Stream<List<CalendarEventEntity>> watchTodayEvents();

  /// Get this week's events
  Future<List<CalendarEventEntity>> getWeekEvents();

  /// Get events for a specific month
  Future<List<CalendarEventEntity>> getMonthEvents(int year, int month);

  /// Get events by type
  ///
  /// Event types: 'service', 'meeting', 'pastoral_visit', 'personal',
  /// 'work', 'family', 'blocked_time'
  Future<List<CalendarEventEntity>> getEventsByType(String eventType);

  /// Watch events by type
  Stream<List<CalendarEventEntity>> watchEventsByType(String eventType);

  /// Get events for a specific person
  ///
  /// Returns events linked to a person (pastoral visits, meetings, etc.)
  Future<List<CalendarEventEntity>> getEventsByPerson(String personId);

  /// Get upcoming events
  ///
  /// Returns next N events starting from now
  Future<List<CalendarEventEntity>> getUpcomingEvents({int limit = 10});

  /// Get events needing sync
  ///
  /// Returns events with sync_status = 'pending'
  Future<List<CalendarEventEntity>> getPendingEvents();

  /// Get conflicting events
  ///
  /// Returns events that overlap with the given time range
  Future<List<CalendarEventEntity>> findConflictingEvents(
    DateTime start,
    DateTime end, {
    String? excludeEventId,
  });

  /// Get total scheduled hours for a date
  ///
  /// Useful for workload calculations
  Future<double> getEventLoadForDate(DateTime date);

  /// Get scheduled hours per day for a week
  ///
  /// Returns Map of date -> hours scheduled
  Future<Map<DateTime, double>> getEventLoadForWeek(DateTime weekStart);

  /// Get recurring events
  Future<List<CalendarEventEntity>> getRecurringEvents();

  /// Get events requiring preparation
  Future<List<CalendarEventEntity>> getEventsRequiringPreparation();
}