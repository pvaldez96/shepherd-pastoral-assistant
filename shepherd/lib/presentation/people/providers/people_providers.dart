import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/repositories/person_repository_impl.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/entities/contact_log.dart';
import '../../../domain/entities/household.dart';
import '../../../domain/entities/person_milestone.dart';
import '../../../domain/repositories/person_repository.dart';

/// Provider for the AppDatabase singleton
/// Note: This is shared with task_providers.dart - in production,
/// move to a central location to avoid duplication
final peopleDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider for PersonRepository implementation
///
/// This is the main repository provider for people operations.
/// Provides offline-first operations with automatic sync queue integration.
final personRepositoryProvider = Provider<PersonRepository>((ref) {
  final database = ref.watch(peopleDatabaseProvider);
  return PersonRepositoryImpl(database);
});

// ============================================================================
// PERSON PROVIDERS
// ============================================================================

/// Stream provider for all people
///
/// Watches the local database for changes and automatically updates the UI.
/// Perfect for people list screens.
///
/// Usage:
/// ```dart
/// class PeopleListScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final peopleAsync = ref.watch(peopleProvider);
///
///     return peopleAsync.when(
///       data: (people) => ListView.builder(
///         itemCount: people.length,
///         itemBuilder: (context, index) => PersonCard(person: people[index]),
///       ),
///       loading: () => CircularProgressIndicator(),
///       error: (err, stack) => Text('Error: $err'),
///     );
///   }
/// }
/// ```
final peopleProvider = StreamProvider<List<PersonEntity>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchPeople();
});

/// Stream provider for a single person by ID
///
/// Watches a specific person and updates when they change.
///
/// Usage:
/// ```dart
/// final personAsync = ref.watch(personProvider(personId));
/// ```
final personProvider = StreamProvider.family<PersonEntity?, String>((ref, id) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchPerson(id);
});

/// Stream provider for people by category
///
/// Filters people by their category (elder, member, visitor, etc.).
///
/// Usage:
/// ```dart
/// final elders = ref.watch(peopleByCategoryProvider('elder'));
/// ```
final peopleByCategoryProvider =
    StreamProvider.family<List<PersonEntity>, String>((ref, category) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchPeopleByCategory(category);
});

/// Stream provider for people needing attention (overdue contacts)
///
/// Returns people whose last contact exceeds their category threshold.
///
/// Usage:
/// ```dart
/// final needsAttention = ref.watch(peopleNeedingAttentionProvider);
/// ```
final peopleNeedingAttentionProvider = StreamProvider<List<PersonEntity>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchPeopleNeedingAttention();
});

/// Stream provider for people who are up to date on contacts
///
/// Returns people whose last contact is within their category threshold.
///
/// Usage:
/// ```dart
/// final upToDate = ref.watch(peopleUpToDateProvider);
/// ```
final peopleUpToDateProvider = StreamProvider<List<PersonEntity>>((ref) {
  final repository = ref.watch(personRepositoryProvider);

  return repository.watchPeople().map((people) {
    return people.where((person) => !person.isOverdue()).toList();
  });
});

/// Provider for searching people by name
///
/// Usage:
/// ```dart
/// final searchResults = ref.watch(peopleSearchProvider('John'));
/// ```
final peopleSearchProvider =
    FutureProvider.family<List<PersonEntity>, String>((ref, query) async {
  final repository = ref.watch(personRepositoryProvider);
  return repository.searchPeople(query);
});

/// Stream provider for recently added people
///
/// Returns people added in the last 30 days.
///
/// Usage:
/// ```dart
/// final recentPeople = ref.watch(recentlyAddedPeopleProvider);
/// ```
final recentlyAddedPeopleProvider = StreamProvider<List<PersonEntity>>((ref) {
  final repository = ref.watch(personRepositoryProvider);

  return repository.watchPeople().map((people) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return people.where((person) => person.createdAt.isAfter(thirtyDaysAgo)).toList();
  });
});

// ============================================================================
// CONTACT LOG PROVIDERS
// ============================================================================

/// Stream provider for contact history of a specific person
///
/// Returns contact logs ordered by date descending (most recent first).
///
/// Usage:
/// ```dart
/// final contactHistory = ref.watch(contactHistoryProvider(personId));
/// ```
final contactHistoryProvider =
    StreamProvider.family<List<ContactLogEntity>, String>((ref, personId) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchContactHistory(personId);
});

/// Future provider for recent contacts across all people
///
/// Usage:
/// ```dart
/// final recentContacts = ref.watch(recentContactsProvider);
/// ```
final recentContactsProvider = FutureProvider<List<ContactLogEntity>>((ref) async {
  final repository = ref.watch(personRepositoryProvider);
  return repository.getRecentContacts(limit: 20);
});

// ============================================================================
// HOUSEHOLD PROVIDERS
// ============================================================================

/// Stream provider for all households
///
/// Usage:
/// ```dart
/// final households = ref.watch(householdsProvider);
/// ```
final householdsProvider = StreamProvider<List<HouseholdEntity>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchHouseholds();
});

/// Stream provider for a single household by ID
///
/// Usage:
/// ```dart
/// final household = ref.watch(householdProvider(householdId));
/// ```
final householdProvider =
    FutureProvider.family<HouseholdEntity?, String>((ref, id) async {
  final repository = ref.watch(personRepositoryProvider);
  return repository.getHouseholdById(id);
});

/// Stream provider for people in a household
///
/// Usage:
/// ```dart
/// final familyMembers = ref.watch(peopleByHouseholdProvider(householdId));
/// ```
final peopleByHouseholdProvider =
    FutureProvider.family<List<PersonEntity>, String>((ref, householdId) async {
  final repository = ref.watch(personRepositoryProvider);
  return repository.getPeopleByHousehold(householdId);
});

// ============================================================================
// MILESTONE PROVIDERS
// ============================================================================

/// Stream provider for milestones of a specific person
///
/// Usage:
/// ```dart
/// final milestones = ref.watch(personMilestonesProvider(personId));
/// ```
final personMilestonesProvider =
    StreamProvider.family<List<PersonMilestoneEntity>, String>((ref, personId) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchMilestones(personId);
});

/// Stream provider for upcoming milestones across all people
///
/// Returns milestones occurring within the next 7 days.
///
/// Usage:
/// ```dart
/// final upcomingMilestones = ref.watch(upcomingMilestonesProvider);
/// ```
final upcomingMilestonesProvider = StreamProvider<List<PersonMilestoneEntity>>((ref) {
  final repository = ref.watch(personRepositoryProvider);
  return repository.watchUpcomingMilestones(daysAhead: 7);
});

// ============================================================================
// STATISTICS PROVIDERS
// ============================================================================

/// Stream provider for people statistics
///
/// Returns counts by category and status for dashboard widgets.
///
/// Usage:
/// ```dart
/// final stats = ref.watch(peopleStatsProvider);
/// stats.when(
///   data: (stats) => Text('${stats['needs_attention']} need attention'),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error loading stats'),
/// );
/// ```
final peopleStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final repository = ref.watch(personRepositoryProvider);

  return repository.watchPeople().map((people) {
    final needsAttention = people.where((p) => p.isOverdue()).length;
    final upToDate = people.length - needsAttention;

    return {
      'total': people.length,
      'needs_attention': needsAttention,
      'up_to_date': upToDate,
      'elders': people.where((p) => p.category == 'elder').length,
      'members': people.where((p) => p.category == 'member').length,
      'visitors': people.where((p) => p.category == 'visitor').length,
      'leadership': people.where((p) => p.category == 'leadership').length,
      'crisis': people.where((p) => p.category == 'crisis').length,
      'family': people.where((p) => p.category == 'family').length,
      'other': people.where((p) => p.category == 'other').length,
    };
  });
});

/// Provider for people count by category
///
/// Usage:
/// ```dart
/// final countByCategory = ref.watch(peopleCategoryCountsProvider);
/// ```
final peopleCategoryCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(personRepositoryProvider);
  return repository.getPeopleCountByCategory();
});

// ============================================================================
// SYNC PROVIDERS
// ============================================================================

/// Stream provider for people needing sync
///
/// Returns people with sync_status = 'pending' that need to be synced to Supabase.
/// Useful for sync status indicators.
///
/// Usage:
/// ```dart
/// final pendingSync = ref.watch(pendingPeopleProvider);
/// if (pendingSync.value?.isNotEmpty == true) {
///   // Show sync indicator
/// }
/// ```
final pendingPeopleProvider = StreamProvider<List<PersonEntity>>((ref) {
  final repository = ref.watch(personRepositoryProvider);

  return repository.watchPeople().map(
        (people) => people.where((person) => person.needsSync).toList(),
      );
});

// ============================================================================
// GROUPED LIST PROVIDERS (for UI)
// ============================================================================

/// Provider that returns people grouped by contact status
///
/// Returns a map with keys:
/// - 'needs_attention': List of people overdue for contact
/// - 'up_to_date': List of people contacted within threshold
/// - 'recently_added': List of people added in last 30 days
///
/// Usage:
/// ```dart
/// final groupedPeople = ref.watch(groupedPeopleProvider);
/// ```
final groupedPeopleProvider = StreamProvider<Map<String, List<PersonEntity>>>((ref) {
  final repository = ref.watch(personRepositoryProvider);

  return repository.watchPeople().map((people) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final needsAttention = people.where((p) => p.isOverdue()).toList()
      ..sort((a, b) {
        // Sort by days overdue (most overdue first)
        final aDays = a.daysSinceLastContact ?? 999;
        final bDays = b.daysSinceLastContact ?? 999;
        return bDays.compareTo(aDays);
      });

    final upToDate = people.where((p) => !p.isOverdue()).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final recentlyAdded = people
        .where((p) => p.createdAt.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return {
      'needs_attention': needsAttention,
      'up_to_date': upToDate,
      'recently_added': recentlyAdded,
    };
  });
});

/// Provider for filtering people by category with search
///
/// Helper class to hold filter state
class PeopleFilter {
  final String? category;
  final String? searchQuery;

  const PeopleFilter({this.category, this.searchQuery});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeopleFilter &&
        other.category == category &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => Object.hash(category, searchQuery);
}

/// Provider for filtered people
///
/// Filters by category and/or search query.
///
/// Usage:
/// ```dart
/// final filter = PeopleFilter(category: 'elder', searchQuery: 'John');
/// final filteredPeople = ref.watch(filteredPeopleProvider(filter));
/// ```
final filteredPeopleProvider =
    StreamProvider.family<List<PersonEntity>, PeopleFilter>((ref, filter) {
  final repository = ref.watch(personRepositoryProvider);

  return repository.watchPeople().map((people) {
    var filtered = people;

    // Filter by category if specified
    if (filter.category != null && filter.category!.isNotEmpty) {
      filtered = filtered.where((p) => p.category == filter.category).toList();
    }

    // Filter by search query if specified
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    return filtered;
  });
});
