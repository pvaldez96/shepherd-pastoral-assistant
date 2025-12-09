import '../entities/person.dart';
import '../entities/contact_log.dart';
import '../entities/household.dart';
import '../entities/person_milestone.dart';

/// Repository interface for Person/People operations
///
/// This defines the contract for people data access without specifying
/// implementation details. Following clean architecture, this allows
/// the domain layer to be independent of data sources.
abstract class PersonRepository {
  // ============================================================================
  // PERSON CRUD OPERATIONS
  // ============================================================================

  /// Get all people for the current user
  ///
  /// Returns list of people ordered by name.
  /// Uses local database (offline-first).
  Future<List<PersonEntity>> getAllPeople();

  /// Get a single person by ID
  ///
  /// Returns null if person not found.
  Future<PersonEntity?> getPersonById(String id);

  /// Create a new person
  ///
  /// - Generates client-side UUID if not provided
  /// - Saves to local database immediately (optimistic update)
  /// - Adds to sync queue for background sync
  /// - Returns the created person with generated ID
  Future<PersonEntity> createPerson(PersonEntity person);

  /// Update an existing person
  ///
  /// - Updates local database immediately (optimistic update)
  /// - Increments version for optimistic locking
  /// - Adds to sync queue for background sync
  /// - Throws if person not found
  Future<PersonEntity> updatePerson(PersonEntity person);

  /// Delete a person
  ///
  /// - Hard deletes from database
  /// - Also deletes related milestones
  /// - Adds to sync queue for background sync
  Future<void> deletePerson(String id);

  // ============================================================================
  // PERSON WATCH/STREAM OPERATIONS
  // ============================================================================

  /// Watch all people with real-time updates
  ///
  /// Returns a stream that emits updated people lists whenever
  /// local database changes. Perfect for reactive UI with Riverpod.
  Stream<List<PersonEntity>> watchPeople();

  /// Watch a single person by ID with real-time updates
  ///
  /// Returns a stream that emits updated person whenever it changes.
  /// Emits null if person is not found.
  Stream<PersonEntity?> watchPerson(String id);

  // ============================================================================
  // PERSON QUERY OPERATIONS
  // ============================================================================

  /// Get people by category
  ///
  /// Categories: 'elder', 'member', 'visitor', 'leadership', 'crisis', 'family', 'other'
  Future<List<PersonEntity>> getPeopleByCategory(String category);

  /// Watch people by category
  Stream<List<PersonEntity>> watchPeopleByCategory(String category);

  /// Get people needing attention (overdue contacts)
  ///
  /// Returns people whose last contact exceeds their category threshold.
  /// Uses default thresholds from user settings if not overridden per-person.
  Future<List<PersonEntity>> getPeopleNeedingAttention({
    int elderThreshold = 30,
    int memberThreshold = 90,
    int crisisThreshold = 3,
    int visitorThreshold = 14,
    int leadershipThreshold = 30,
    int familyThreshold = 7,
    int otherThreshold = 90,
  });

  /// Watch people needing attention
  Stream<List<PersonEntity>> watchPeopleNeedingAttention({
    int elderThreshold = 30,
    int memberThreshold = 90,
    int crisisThreshold = 3,
    int visitorThreshold = 14,
    int leadershipThreshold = 30,
    int familyThreshold = 7,
    int otherThreshold = 90,
  });

  /// Search people by name
  ///
  /// Returns people whose name contains the search query (case-insensitive)
  Future<List<PersonEntity>> searchPeople(String query);

  /// Get people by household
  Future<List<PersonEntity>> getPeopleByHousehold(String householdId);

  /// Get recently added people (last 30 days)
  Future<List<PersonEntity>> getRecentlyAddedPeople({int days = 30});

  /// Get people with upcoming milestones
  Future<List<PersonEntity>> getPeopleWithUpcomingMilestones({int daysAhead = 7});

  // ============================================================================
  // CONTACT LOG OPERATIONS
  // ============================================================================

  /// Log a contact with a person
  ///
  /// - Creates contact log entry
  /// - Updates person's last_contact_date automatically
  /// - Adds to sync queue for background sync
  Future<ContactLogEntity> logContact(ContactLogEntity contactLog);

  /// Get contact history for a person
  ///
  /// Returns contact logs ordered by date descending (most recent first)
  Future<List<ContactLogEntity>> getContactHistory(String personId, {int? limit});

  /// Watch contact history for a person
  Stream<List<ContactLogEntity>> watchContactHistory(String personId);

  /// Delete a contact log entry
  Future<void> deleteContactLog(String id);

  /// Get recent contacts across all people
  Future<List<ContactLogEntity>> getRecentContacts({int limit = 20});

  // ============================================================================
  // HOUSEHOLD OPERATIONS
  // ============================================================================

  /// Get all households
  Future<List<HouseholdEntity>> getAllHouseholds();

  /// Get a household by ID
  Future<HouseholdEntity?> getHouseholdById(String id);

  /// Create a household
  Future<HouseholdEntity> createHousehold(HouseholdEntity household);

  /// Update a household
  Future<HouseholdEntity> updateHousehold(HouseholdEntity household);

  /// Delete a household
  ///
  /// Note: Does not delete people, just removes their household association
  Future<void> deleteHousehold(String id);

  /// Watch all households
  Stream<List<HouseholdEntity>> watchHouseholds();

  // ============================================================================
  // MILESTONE OPERATIONS
  // ============================================================================

  /// Get milestones for a person
  Future<List<PersonMilestoneEntity>> getMilestones(String personId);

  /// Watch milestones for a person
  Stream<List<PersonMilestoneEntity>> watchMilestones(String personId);

  /// Create a milestone
  Future<PersonMilestoneEntity> createMilestone(PersonMilestoneEntity milestone);

  /// Update a milestone
  Future<PersonMilestoneEntity> updateMilestone(PersonMilestoneEntity milestone);

  /// Delete a milestone
  Future<void> deleteMilestone(String id);

  /// Get upcoming milestones across all people
  Future<List<PersonMilestoneEntity>> getUpcomingMilestones({int daysAhead = 7});

  /// Watch upcoming milestones
  Stream<List<PersonMilestoneEntity>> watchUpcomingMilestones({int daysAhead = 7});

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Get people that need sync
  ///
  /// Returns people with sync_status = 'pending'
  Future<List<PersonEntity>> getPendingPeople();

  /// Get contact logs that need sync
  Future<List<ContactLogEntity>> getPendingContactLogs();

  /// Get households that need sync
  Future<List<HouseholdEntity>> getPendingHouseholds();

  /// Get milestones that need sync
  Future<List<PersonMilestoneEntity>> getPendingMilestones();

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get people count by category
  Future<Map<String, int>> getPeopleCountByCategory();

  /// Get contact statistics
  ///
  /// Returns map with keys like 'total_contacts', 'contacts_this_week', etc.
  Future<Map<String, dynamic>> getContactStats();
}
