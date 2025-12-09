import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/contact_log.dart';
import '../../domain/entities/household.dart';
import '../../domain/entities/person_milestone.dart';
import '../../domain/repositories/person_repository.dart';
import '../local/database.dart';
import '../local/daos/people_dao.dart';
import '../local/daos/contact_log_dao.dart';
import '../local/daos/households_dao.dart';
import '../local/daos/people_milestones_dao.dart';

/// Implementation of PersonRepository using Drift local database
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
class PersonRepositoryImpl implements PersonRepository {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  late final PeopleDao _peopleDao;
  late final ContactLogDao _contactLogDao;
  late final HouseholdsDao _householdsDao;
  late final PeopleMilestonesDao _milestonesDao;

  PersonRepositoryImpl(this._database) {
    _peopleDao = PeopleDao(_database);
    _contactLogDao = ContactLogDao(_database);
    _householdsDao = HouseholdsDao(_database);
    _milestonesDao = PeopleMilestonesDao(_database);
  }

  // TODO: Get actual userId from auth service
  static const String _userId = 'current-user-id';

  // ============================================================================
  // CONVERSION HELPERS - Person
  // ============================================================================

  /// Convert Drift Person to domain PersonEntity
  PersonEntity _personToDomain(Person person) {
    return PersonEntity(
      id: person.id,
      userId: person.userId,
      name: person.name,
      email: person.email,
      phone: person.phone,
      category: person.category,
      householdId: person.householdId,
      lastContactDate: person.lastContactDate,
      contactFrequencyOverrideDays: person.contactFrequencyOverrideDays,
      notes: person.notes,
      tags: person.tags != null ? _parseTagsFromJson(person.tags!) : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(person.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(person.updatedAt),
      syncStatus: person.syncStatus,
      localUpdatedAt: person.localUpdatedAt,
      serverUpdatedAt: person.serverUpdatedAt,
      version: person.version,
    );
  }

  /// Parse tags from JSON string stored in SQLite
  List<String> _parseTagsFromJson(String tagsJson) {
    try {
      // Tags are stored as JSON array string: '["tag1", "tag2"]'
      // For now, using simple parsing. Consider using dart:convert json
      if (tagsJson.isEmpty || tagsJson == '[]') return [];
      // Remove brackets and quotes, split by comma
      final cleaned = tagsJson.substring(1, tagsJson.length - 1);
      if (cleaned.isEmpty) return [];
      return cleaned.split(',').map((t) => t.trim().replaceAll('"', '')).toList();
    } catch (e) {
      return [];
    }
  }

  /// Convert tags list to JSON string for SQLite storage
  String _tagsToJson(List<String> tags) {
    if (tags.isEmpty) return '[]';
    return '["${tags.join('", "')}"]';
  }

  /// Convert domain PersonEntity to Drift Person (for updates)
  Person _personToData(PersonEntity person) {
    return Person(
      id: person.id,
      userId: person.userId,
      name: person.name,
      email: person.email,
      phone: person.phone,
      category: person.category,
      householdId: person.householdId,
      lastContactDate: person.lastContactDate,
      contactFrequencyOverrideDays: person.contactFrequencyOverrideDays,
      notes: person.notes,
      tags: _tagsToJson(person.tags),
      createdAt: person.createdAt.millisecondsSinceEpoch,
      updatedAt: person.updatedAt.millisecondsSinceEpoch,
      syncStatus: person.syncStatus,
      localUpdatedAt: person.localUpdatedAt,
      serverUpdatedAt: person.serverUpdatedAt,
      version: person.version,
    );
  }

  /// Convert domain PersonEntity to Drift PeopleCompanion (for inserts)
  PeopleCompanion _personToCompanion(PersonEntity person) {
    return PeopleCompanion.insert(
      id: Value(person.id),
      userId: person.userId,
      name: person.name,
      email: Value(person.email),
      phone: Value(person.phone),
      category: person.category,
      householdId: Value(person.householdId),
      lastContactDate: Value(person.lastContactDate),
      contactFrequencyOverrideDays: Value(person.contactFrequencyOverrideDays),
      notes: Value(person.notes),
      tags: Value(_tagsToJson(person.tags)),
      createdAt: Value(person.createdAt.millisecondsSinceEpoch),
      updatedAt: Value(person.updatedAt.millisecondsSinceEpoch),
      syncStatus: Value(person.syncStatus),
      localUpdatedAt: Value(person.localUpdatedAt),
      serverUpdatedAt: Value(person.serverUpdatedAt),
      version: Value(person.version),
    );
  }

  // ============================================================================
  // CONVERSION HELPERS - ContactLog
  // ============================================================================

  /// Convert Drift ContactLog to domain ContactLogEntity
  ContactLogEntity _contactLogToDomain(ContactLog log) {
    return ContactLogEntity(
      id: log.id,
      userId: log.userId,
      personId: log.personId,
      contactDate: log.contactDate,
      contactType: log.contactType,
      durationMinutes: log.durationMinutes,
      notes: log.notes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(log.createdAt),
      syncStatus: log.syncStatus,
      localUpdatedAt: log.localUpdatedAt,
      serverUpdatedAt: log.serverUpdatedAt,
      version: log.version,
    );
  }

  /// Convert domain ContactLogEntity to Drift ContactLogTableCompanion (for inserts)
  ContactLogTableCompanion _contactLogToCompanion(ContactLogEntity log) {
    return ContactLogTableCompanion.insert(
      id: Value(log.id),
      userId: log.userId,
      personId: log.personId,
      contactDate: log.contactDate,
      contactType: log.contactType,
      durationMinutes: Value(log.durationMinutes),
      notes: Value(log.notes),
      createdAt: Value(log.createdAt.millisecondsSinceEpoch),
      syncStatus: Value(log.syncStatus),
      localUpdatedAt: Value(log.localUpdatedAt),
      serverUpdatedAt: Value(log.serverUpdatedAt),
      version: Value(log.version),
    );
  }

  // ============================================================================
  // CONVERSION HELPERS - Household
  // ============================================================================

  /// Convert Drift Household to domain HouseholdEntity
  HouseholdEntity _householdToDomain(Household household) {
    return HouseholdEntity(
      id: household.id,
      userId: household.userId,
      name: household.name,
      address: household.address,
      createdAt: DateTime.fromMillisecondsSinceEpoch(household.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(household.updatedAt),
      syncStatus: household.syncStatus,
      localUpdatedAt: household.localUpdatedAt,
      serverUpdatedAt: household.serverUpdatedAt,
      version: household.version,
    );
  }

  /// Convert domain HouseholdEntity to Drift HouseholdsCompanion (for inserts)
  HouseholdsCompanion _householdToCompanion(HouseholdEntity household) {
    return HouseholdsCompanion.insert(
      id: Value(household.id),
      userId: household.userId,
      name: household.name,
      address: Value(household.address),
      createdAt: Value(household.createdAt.millisecondsSinceEpoch),
      updatedAt: Value(household.updatedAt.millisecondsSinceEpoch),
      syncStatus: Value(household.syncStatus),
      localUpdatedAt: Value(household.localUpdatedAt),
      serverUpdatedAt: Value(household.serverUpdatedAt),
      version: Value(household.version),
    );
  }

  /// Convert domain HouseholdEntity to Drift Household (for updates)
  Household _householdToData(HouseholdEntity household) {
    return Household(
      id: household.id,
      userId: household.userId,
      name: household.name,
      address: household.address,
      createdAt: household.createdAt.millisecondsSinceEpoch,
      updatedAt: household.updatedAt.millisecondsSinceEpoch,
      syncStatus: household.syncStatus,
      localUpdatedAt: household.localUpdatedAt,
      serverUpdatedAt: household.serverUpdatedAt,
      version: household.version,
    );
  }

  // ============================================================================
  // CONVERSION HELPERS - Milestone
  // ============================================================================

  /// Convert Drift PeopleMilestone to domain PersonMilestoneEntity
  PersonMilestoneEntity _milestoneToDomain(PeopleMilestone milestone) {
    return PersonMilestoneEntity(
      id: milestone.id,
      personId: milestone.personId,
      milestoneType: milestone.milestoneType,
      date: milestone.date,
      description: milestone.description,
      notifyDaysBefore: milestone.notifyDaysBefore,
      createdAt: DateTime.fromMillisecondsSinceEpoch(milestone.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(milestone.updatedAt),
      syncStatus: milestone.syncStatus,
      localUpdatedAt: milestone.localUpdatedAt,
      serverUpdatedAt: milestone.serverUpdatedAt,
      version: milestone.version,
    );
  }

  /// Convert domain PersonMilestoneEntity to Drift PeopleMilestonesCompanion
  PeopleMilestonesCompanion _milestoneToCompanion(PersonMilestoneEntity milestone) {
    return PeopleMilestonesCompanion.insert(
      id: Value(milestone.id),
      personId: milestone.personId,
      milestoneType: milestone.milestoneType,
      date: milestone.date,
      description: Value(milestone.description),
      notifyDaysBefore: Value(milestone.notifyDaysBefore),
      createdAt: Value(milestone.createdAt.millisecondsSinceEpoch),
      updatedAt: Value(milestone.updatedAt.millisecondsSinceEpoch),
      syncStatus: Value(milestone.syncStatus),
      localUpdatedAt: Value(milestone.localUpdatedAt),
      serverUpdatedAt: Value(milestone.serverUpdatedAt),
      version: Value(milestone.version),
    );
  }

  /// Convert domain PersonMilestoneEntity to Drift PeopleMilestone (for updates)
  PeopleMilestone _milestoneToData(PersonMilestoneEntity milestone) {
    return PeopleMilestone(
      id: milestone.id,
      personId: milestone.personId,
      milestoneType: milestone.milestoneType,
      date: milestone.date,
      description: milestone.description,
      notifyDaysBefore: milestone.notifyDaysBefore,
      createdAt: milestone.createdAt.millisecondsSinceEpoch,
      updatedAt: milestone.updatedAt.millisecondsSinceEpoch,
      syncStatus: milestone.syncStatus,
      localUpdatedAt: milestone.localUpdatedAt,
      serverUpdatedAt: milestone.serverUpdatedAt,
      version: milestone.version,
    );
  }

  // ============================================================================
  // PERSON CRUD OPERATIONS
  // ============================================================================

  @override
  Future<List<PersonEntity>> getAllPeople() async {
    final people = await _peopleDao.getAllPeople(_userId);
    return people.map(_personToDomain).toList();
  }

  @override
  Future<PersonEntity?> getPersonById(String id) async {
    final person = await _peopleDao.getPersonById(id);
    return person != null ? _personToDomain(person) : null;
  }

  @override
  Future<PersonEntity> createPerson(PersonEntity person) async {
    final now = DateTime.now();
    final id = person.id.isEmpty ? _uuid.v4() : person.id;

    final newPerson = PersonEntity(
      id: id,
      userId: _userId,
      name: person.name,
      email: person.email,
      phone: person.phone,
      category: person.category,
      householdId: person.householdId,
      lastContactDate: person.lastContactDate,
      contactFrequencyOverrideDays: person.contactFrequencyOverrideDays,
      notes: person.notes,
      tags: person.tags,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      serverUpdatedAt: null,
      version: 1,
    );

    await _peopleDao.insertPerson(_personToCompanion(newPerson));
    return newPerson;
  }

  @override
  Future<PersonEntity> updatePerson(PersonEntity person) async {
    final now = DateTime.now();

    final updatedPerson = person.copyWith(
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: person.version + 1,
    );

    final success = await _peopleDao.updatePerson(_personToData(updatedPerson));
    if (!success) {
      throw Exception('Person not found: ${person.id}');
    }

    return updatedPerson;
  }

  @override
  Future<void> deletePerson(String id) async {
    // Delete person (milestones should be handled by CASCADE)
    await _peopleDao.deletePerson(id);
  }

  // ============================================================================
  // PERSON WATCH/STREAM OPERATIONS
  // ============================================================================

  @override
  Stream<List<PersonEntity>> watchPeople() {
    return _peopleDao.watchAllPeople(_userId).map(
          (people) => people.map(_personToDomain).toList(),
        );
  }

  @override
  Stream<PersonEntity?> watchPerson(String id) {
    return _peopleDao.watchPerson(id).map(
          (person) => person != null ? _personToDomain(person) : null,
        );
  }

  // ============================================================================
  // PERSON QUERY OPERATIONS
  // ============================================================================

  @override
  Future<List<PersonEntity>> getPeopleByCategory(String category) async {
    final people = await _peopleDao.getPeopleByCategory(_userId, category);
    return people.map(_personToDomain).toList();
  }

  @override
  Stream<List<PersonEntity>> watchPeopleByCategory(String category) {
    return _peopleDao.watchPeopleByCategory(_userId, category).map(
          (people) => people.map(_personToDomain).toList(),
        );
  }

  @override
  Future<List<PersonEntity>> getPeopleNeedingAttention({
    int elderThreshold = 30,
    int memberThreshold = 90,
    int crisisThreshold = 3,
    int visitorThreshold = 14,
    int leadershipThreshold = 30,
    int familyThreshold = 7,
    int otherThreshold = 90,
  }) async {
    final people = await _peopleDao.getPeopleNeedingContact(
      _userId,
      elderFrequency: elderThreshold,
      memberFrequency: memberThreshold,
      crisisFrequency: crisisThreshold,
      visitorFrequency: visitorThreshold,
      leadershipFrequency: leadershipThreshold,
      familyFrequency: familyThreshold,
      otherFrequency: otherThreshold,
    );
    return people.map(_personToDomain).toList();
  }

  @override
  Stream<List<PersonEntity>> watchPeopleNeedingAttention({
    int elderThreshold = 30,
    int memberThreshold = 90,
    int crisisThreshold = 3,
    int visitorThreshold = 14,
    int leadershipThreshold = 30,
    int familyThreshold = 7,
    int otherThreshold = 90,
  }) {
    // Watch all people and filter on the client side
    return watchPeople().map((people) {
      return people.where((person) {
        return person.isOverdue(
          elderDefault: elderThreshold,
          memberDefault: memberThreshold,
          crisisDefault: crisisThreshold,
          visitorDefault: visitorThreshold,
          leadershipDefault: leadershipThreshold,
          familyDefault: familyThreshold,
          otherDefault: otherThreshold,
        );
      }).toList();
    });
  }

  @override
  Future<List<PersonEntity>> searchPeople(String query) async {
    final people = await _peopleDao.searchPeople(_userId, query);
    return people.map(_personToDomain).toList();
  }

  @override
  Future<List<PersonEntity>> getPeopleByHousehold(String householdId) async {
    final people = await _peopleDao.getPeopleByHousehold(householdId);
    return people.map(_personToDomain).toList();
  }

  @override
  Future<List<PersonEntity>> getRecentlyAddedPeople({int days = 30}) async {
    // Get all people and filter by created date
    final allPeople = await getAllPeople();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return allPeople.where((p) => p.createdAt.isAfter(cutoff)).toList();
  }

  @override
  Future<List<PersonEntity>> getPeopleWithUpcomingMilestones({int daysAhead = 7}) async {
    final milestones = await getUpcomingMilestones(daysAhead: daysAhead);
    final personIds = milestones.map((m) => m.personId).toSet();
    final people = await getAllPeople();
    return people.where((p) => personIds.contains(p.id)).toList();
  }

  // ============================================================================
  // CONTACT LOG OPERATIONS
  // ============================================================================

  @override
  Future<ContactLogEntity> logContact(ContactLogEntity contactLog) async {
    final now = DateTime.now();
    final id = contactLog.id.isEmpty ? _uuid.v4() : contactLog.id;

    final newLog = ContactLogEntity(
      id: id,
      userId: _userId,
      personId: contactLog.personId,
      contactDate: contactLog.contactDate,
      contactType: contactLog.contactType,
      durationMinutes: contactLog.durationMinutes,
      notes: contactLog.notes,
      createdAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      serverUpdatedAt: null,
      version: 1,
    );

    await _contactLogDao.insertContactLog(_contactLogToCompanion(newLog));

    // Update person's last contact date
    final person = await getPersonById(contactLog.personId);
    if (person != null) {
      await updatePerson(person.copyWith(lastContactDate: contactLog.contactDate));
    }

    return newLog;
  }

  @override
  Future<List<ContactLogEntity>> getContactHistory(String personId, {int? limit}) async {
    final logs = await _contactLogDao.getContactsForPerson(personId);
    // Apply limit client-side since DAO doesn't support limit parameter
    final limitedLogs = limit != null ? logs.take(limit).toList() : logs;
    return limitedLogs.map(_contactLogToDomain).toList();
  }

  @override
  Stream<List<ContactLogEntity>> watchContactHistory(String personId) {
    return _contactLogDao.watchContactsForPerson(personId).map(
          (logs) => logs.map(_contactLogToDomain).toList(),
        );
  }

  @override
  Future<void> deleteContactLog(String id) async {
    await _contactLogDao.deleteContactLog(id);
  }

  @override
  Future<List<ContactLogEntity>> getRecentContacts({int limit = 20}) async {
    final logs = await _contactLogDao.getAllContactLogs(_userId);
    // Already sorted by contactDate descending from DAO, just take limit
    return logs.take(limit).map(_contactLogToDomain).toList();
  }

  // ============================================================================
  // HOUSEHOLD OPERATIONS
  // ============================================================================

  @override
  Future<List<HouseholdEntity>> getAllHouseholds() async {
    final households = await _householdsDao.getAllHouseholds(_userId);
    return households.map(_householdToDomain).toList();
  }

  @override
  Future<HouseholdEntity?> getHouseholdById(String id) async {
    final household = await _householdsDao.getHouseholdById(id);
    return household != null ? _householdToDomain(household) : null;
  }

  @override
  Future<HouseholdEntity> createHousehold(HouseholdEntity household) async {
    final now = DateTime.now();
    final id = household.id.isEmpty ? _uuid.v4() : household.id;

    final newHousehold = HouseholdEntity(
      id: id,
      userId: _userId,
      name: household.name,
      address: household.address,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      serverUpdatedAt: null,
      version: 1,
    );

    await _householdsDao.insertHousehold(_householdToCompanion(newHousehold));
    return newHousehold;
  }

  @override
  Future<HouseholdEntity> updateHousehold(HouseholdEntity household) async {
    final now = DateTime.now();

    final updatedHousehold = household.copyWith(
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: household.version + 1,
    );

    final success = await _householdsDao.updateHousehold(_householdToData(updatedHousehold));
    if (!success) {
      throw Exception('Household not found: ${household.id}');
    }

    return updatedHousehold;
  }

  @override
  Future<void> deleteHousehold(String id) async {
    await _householdsDao.deleteHousehold(id);
  }

  @override
  Stream<List<HouseholdEntity>> watchHouseholds() {
    return _householdsDao.watchAllHouseholds(_userId).map(
          (households) => households.map(_householdToDomain).toList(),
        );
  }

  // ============================================================================
  // MILESTONE OPERATIONS
  // ============================================================================

  @override
  Future<List<PersonMilestoneEntity>> getMilestones(String personId) async {
    final milestones = await _milestonesDao.getMilestones(personId);
    return milestones.map(_milestoneToDomain).toList();
  }

  @override
  Stream<List<PersonMilestoneEntity>> watchMilestones(String personId) {
    return _milestonesDao.watchMilestones(personId).map(
          (milestones) => milestones.map(_milestoneToDomain).toList(),
        );
  }

  @override
  Future<PersonMilestoneEntity> createMilestone(PersonMilestoneEntity milestone) async {
    final now = DateTime.now();
    final id = milestone.id.isEmpty ? _uuid.v4() : milestone.id;

    final newMilestone = PersonMilestoneEntity(
      id: id,
      personId: milestone.personId,
      milestoneType: milestone.milestoneType,
      date: milestone.date,
      description: milestone.description,
      notifyDaysBefore: milestone.notifyDaysBefore,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      serverUpdatedAt: null,
      version: 1,
    );

    await _milestonesDao.insertMilestone(_milestoneToCompanion(newMilestone));
    return newMilestone;
  }

  @override
  Future<PersonMilestoneEntity> updateMilestone(PersonMilestoneEntity milestone) async {
    final now = DateTime.now();

    final updatedMilestone = milestone.copyWith(
      updatedAt: now,
      syncStatus: 'pending',
      localUpdatedAt: now.millisecondsSinceEpoch,
      version: milestone.version + 1,
    );

    final success = await _milestonesDao.updateMilestone(_milestoneToData(updatedMilestone));
    if (!success) {
      throw Exception('Milestone not found: ${milestone.id}');
    }

    return updatedMilestone;
  }

  @override
  Future<void> deleteMilestone(String id) async {
    await _milestonesDao.deleteMilestone(id);
  }

  @override
  Future<List<PersonMilestoneEntity>> getUpcomingMilestones({int daysAhead = 7}) async {
    final milestones = await _milestonesDao.getUpcomingMilestones(daysAhead);
    return milestones.map(_milestoneToDomain).toList();
  }

  @override
  Stream<List<PersonMilestoneEntity>> watchUpcomingMilestones({int daysAhead = 7}) {
    return _milestonesDao.watchUpcomingMilestones(daysAhead).map(
          (milestones) => milestones.map(_milestoneToDomain).toList(),
        );
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  @override
  Future<List<PersonEntity>> getPendingPeople() async {
    final people = await _peopleDao.getPendingPeople();
    return people.map(_personToDomain).toList();
  }

  @override
  Future<List<ContactLogEntity>> getPendingContactLogs() async {
    final logs = await _contactLogDao.getPendingContactLogs();
    return logs.map(_contactLogToDomain).toList();
  }

  @override
  Future<List<HouseholdEntity>> getPendingHouseholds() async {
    final households = await _householdsDao.getPendingHouseholds();
    return households.map(_householdToDomain).toList();
  }

  @override
  Future<List<PersonMilestoneEntity>> getPendingMilestones() async {
    final milestones = await _milestonesDao.getPendingMilestones();
    return milestones.map(_milestoneToDomain).toList();
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  @override
  Future<Map<String, int>> getPeopleCountByCategory() async {
    // DAO returns all counts in one call as Map<String, int>
    return await _peopleDao.countPeopleByCategory(_userId);
  }

  @override
  Future<Map<String, dynamic>> getContactStats() async {
    final allLogs = await _contactLogDao.getAllContactLogs(_userId);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final thisWeek = allLogs.where((l) => l.contactDate.isAfter(weekAgo)).length;
    final thisMonth = allLogs.where((l) => l.contactDate.isAfter(monthAgo)).length;

    // Count by type
    final byType = <String, int>{};
    for (final log in allLogs) {
      byType[log.contactType] = (byType[log.contactType] ?? 0) + 1;
    }

    return {
      'total_contacts': allLogs.length,
      'contacts_this_week': thisWeek,
      'contacts_this_month': thisMonth,
      'contacts_by_type': byType,
    };
  }
}
