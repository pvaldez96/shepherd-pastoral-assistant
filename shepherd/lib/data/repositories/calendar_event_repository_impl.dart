import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_event_repository.dart';
import '../local/database.dart';
import '../local/daos/calendar_events_dao.dart';

/// Implementation of CalendarEventRepository using Drift local database
///
/// Follows offline-first architecture:
/// 1. All operations work against local SQLite database
/// 2. Changes are queued for background sync to Supabase
/// 3. Optimistic updates - UI updates immediately
///
/// Pattern:
/// - Read from local DB (always fast, works offline)
/// - Write to local DB first (optimistic)
/// - Add to sync queue (background sync handles eventual consistency)
class CalendarEventRepositoryImpl implements CalendarEventRepository {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  late final CalendarEventsDao _eventsDao;

  CalendarEventRepositoryImpl(this._database) {
    _eventsDao = CalendarEventsDao(_database);
  }

  /// Helper: Convert Drift CalendarEvent to domain CalendarEventEntity
  CalendarEventEntity _toDomain(CalendarEvent event) {
    return CalendarEventEntity(
      id: event.id,
      userId: event.userId,
      title: event.title,
      description: event.description,
      location: event.location,
      startDateTime: DateTime.fromMillisecondsSinceEpoch(event.startDatetime),
      endDateTime: DateTime.fromMillisecondsSinceEpoch(event.endDatetime),
      eventType: event.eventType,
      isRecurring: event.isRecurring,
      recurrencePattern: event.recurrencePattern,
      travelTimeMinutes: event.travelTimeMinutes,
      energyDrain: event.energyDrain,
      isMoveable: event.isMoveable,
      requiresPreparation: event.requiresPreparation,
      preparationBufferHours: event.preparationBufferHours,
      personId: event.personId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(event.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(event.updatedAt),
      syncStatus: event.syncStatus,
      localUpdatedAt: event.localUpdatedAt,
      serverUpdatedAt: event.serverUpdatedAt,
      version: event.version,
    );
  }

  /// Helper: Convert domain CalendarEventEntity to Drift CalendarEvent
  CalendarEvent _toData(CalendarEventEntity event) {
    return CalendarEvent(
      id: event.id,
      userId: event.userId,
      title: event.title,
      description: event.description,
      location: event.location,
      startDatetime: event.startDateTime.millisecondsSinceEpoch,
      endDatetime: event.endDateTime.millisecondsSinceEpoch,
      eventType: event.eventType,
      isRecurring: event.isRecurring,
      recurrencePattern: event.recurrencePattern,
      travelTimeMinutes: event.travelTimeMinutes,
      energyDrain: event.energyDrain,
      isMoveable: event.isMoveable,
      requiresPreparation: event.requiresPreparation,
      preparationBufferHours: event.preparationBufferHours,
      personId: event.personId,
      createdAt: event.createdAt.millisecondsSinceEpoch,
      updatedAt: event.updatedAt.millisecondsSinceEpoch,
      syncStatus: event.syncStatus,
      localUpdatedAt: event.localUpdatedAt,
      serverUpdatedAt: event.serverUpdatedAt,
      version: event.version,
    );
  }

  /// Helper: Convert domain CalendarEventEntity to Drift CalendarEventsCompanion
  CalendarEventsCompanion _toCompanion(CalendarEventEntity event) {
    return CalendarEventsCompanion.insert(
      id: Value(event.id),
      userId: event.userId,
      title: event.title,
      description: Value(event.description),
      location: Value(event.location),
      startDatetime: event.startDateTime.millisecondsSinceEpoch,
      endDatetime: event.endDateTime.millisecondsSinceEpoch,
      eventType: event.eventType,
      isRecurring: Value(event.isRecurring),
      recurrencePattern: Value(event.recurrencePattern),
      travelTimeMinutes: Value(event.travelTimeMinutes),
      energyDrain: Value(event.energyDrain),
      isMoveable: Value(event.isMoveable),
      requiresPreparation: Value(event.requiresPreparation),
      preparationBufferHours: Value(event.preparationBufferHours),
      personId: Value(event.personId),
      createdAt: Value(event.createdAt.millisecondsSinceEpoch),
      updatedAt: Value(event.updatedAt.millisecondsSinceEpoch),
      syncStatus: Value(event.syncStatus),
      localUpdatedAt: Value(event.localUpdatedAt),
      serverUpdatedAt: Value(event.serverUpdatedAt),
      version: Value(event.version),
    );
  }

  @override
  Future<List<CalendarEventEntity>> getAllEvents() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getAllEvents(userId);
    return events.map(_toDomain).toList();
  }

  @override
  Future<CalendarEventEntity?> getEventById(String id) async {
    final event = await _eventsDao.getEventById(id);
    return event != null ? _toDomain(event) : null;
  }

  @override
  Future<CalendarEventEntity> createEvent(CalendarEventEntity event) async {
    final now = DateTime.now();

    // Generate UUID if not provided
    final id = event.id.isEmpty ? _uuid.v4() : event.id;

    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final newEvent = event.copyWith(
      id: id,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: 1,
    );

    final companion = _toCompanion(newEvent);

    // Insert into local database (optimistic update)
    await _eventsDao.insertEvent(companion);

    // TODO: Add to sync queue for background sync
    // await _addToSyncQueue('create', id);

    return newEvent;
  }

  @override
  Future<CalendarEventEntity> updateEvent(CalendarEventEntity event) async {
    final now = DateTime.now();

    // Increment version for optimistic locking
    final updatedEvent = event.copyWith(
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: event.version + 1,
    );

    // Convert to Drift CalendarEvent object
    final driftEvent = _toData(updatedEvent);

    // Update in local database (optimistic update)
    final success = await _eventsDao.updateEvent(driftEvent);

    if (!success) {
      throw Exception('Calendar event not found: ${event.id}');
    }

    // TODO: Add to sync queue for background sync
    // await _addToSyncQueue('update', event.id);

    return updatedEvent;
  }

  @override
  Future<void> deleteEvent(String id) async {
    // Hard delete - removes from database
    await _eventsDao.deleteEvent(id);

    // TODO: Add to sync queue for background sync
    // await _addToSyncQueue('delete', id);
  }

  @override
  Stream<List<CalendarEventEntity>> watchEvents() {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    return _eventsDao.watchAllEvents(userId).map(
          (events) => events.map(_toDomain).toList(),
        );
  }

  @override
  Stream<CalendarEventEntity?> watchEvent(String id) {
    // Watch all and filter - DAO doesn't have watchEventById
    return watchEvents().map((events) {
      try {
        return events.firstWhere((e) => e.id == id);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<List<CalendarEventEntity>> getEventsForDate(DateTime date) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getEventsForDate(userId, date);
    return events.map(_toDomain).toList();
  }

  @override
  Stream<List<CalendarEventEntity>> watchEventsForDate(DateTime date) {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    return _eventsDao.watchEventsForDate(userId, date).map(
          (events) => events.map(_toDomain).toList(),
        );
  }

  @override
  Future<List<CalendarEventEntity>> getEventsInRange(DateTime start, DateTime end) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getEventsInRange(userId, start, end);
    return events.map(_toDomain).toList();
  }

  @override
  Stream<List<CalendarEventEntity>> watchEventsInRange(DateTime start, DateTime end) {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    return _eventsDao.watchEventsInRange(userId, start, end).map(
          (events) => events.map(_toDomain).toList(),
        );
  }

  @override
  Future<List<CalendarEventEntity>> getTodayEvents() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getTodayEvents(userId);
    return events.map(_toDomain).toList();
  }

  @override
  Stream<List<CalendarEventEntity>> watchTodayEvents() {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    return _eventsDao.watchTodayEvents(userId).map(
          (events) => events.map(_toDomain).toList(),
        );
  }

  @override
  Future<List<CalendarEventEntity>> getWeekEvents() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getWeekEvents(userId);
    return events.map(_toDomain).toList();
  }

  @override
  Future<List<CalendarEventEntity>> getMonthEvents(int year, int month) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getMonthEvents(userId, year, month);
    return events.map(_toDomain).toList();
  }

  @override
  Future<List<CalendarEventEntity>> getEventsByType(String eventType) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getEventsByType(userId, eventType);
    return events.map(_toDomain).toList();
  }

  @override
  Stream<List<CalendarEventEntity>> watchEventsByType(String eventType) {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    return _eventsDao.watchEventsByType(userId, eventType).map(
          (events) => events.map(_toDomain).toList(),
        );
  }

  @override
  Future<List<CalendarEventEntity>> getEventsByPerson(String personId) async {
    final events = await _eventsDao.getEventsByPerson(personId);
    return events.map(_toDomain).toList();
  }

  @override
  Future<List<CalendarEventEntity>> getUpcomingEvents({int limit = 10}) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getUpcomingEvents(userId, limit: limit);
    return events.map(_toDomain).toList();
  }

  @override
  Future<List<CalendarEventEntity>> getPendingEvents() async {
    final events = await _eventsDao.getPendingEvents();
    return events.map(_toDomain).toList();
  }

  @override
  Future<List<CalendarEventEntity>> findConflictingEvents(
    DateTime start,
    DateTime end, {
    String? excludeEventId,
  }) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.findConflictingEvents(
      userId,
      start,
      end,
      excludeEventId: excludeEventId,
    );
    return events.map(_toDomain).toList();
  }

  @override
  Future<double> getEventLoadForDate(DateTime date) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    return _eventsDao.getEventLoadForDate(userId, date);
  }

  @override
  Future<Map<DateTime, double>> getEventLoadForWeek(DateTime weekStart) async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    return _eventsDao.getEventLoadForWeek(userId, weekStart);
  }

  @override
  Future<List<CalendarEventEntity>> getRecurringEvents() async {
    // TODO: Get userId from auth service
    const String userId = 'current-user-id';

    final events = await _eventsDao.getRecurringEvents(userId);
    return events.map(_toDomain).toList();
  }

  @override
  Future<List<CalendarEventEntity>> getEventsRequiringPreparation() async {
    // Get events from watchEvents and filter
    final allEvents = await getAllEvents();
    return allEvents.where((e) => e.requiresPreparation).toList();
  }

  // TODO: Future implementation - add to sync queue
  // Future<void> _addToSyncQueue(String operation, String eventId) async {
  //   await _database.into(_database.syncQueue).insert(
  //     SyncQueueCompanion.insert(
  //       id: _uuid.v4(),
  //       userId: 'current-user-id',
  //       tableName: 'calendar_events',
  //       recordId: eventId,
  //       operation: operation,
  //       createdAt: DateTime.now(),
  //     ),
  //   );
  // }
}
