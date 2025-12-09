import 'package:flutter/material.dart';
import '../../domain/entities/person.dart';
import 'widgets/person_card.dart';
import 'widgets/contact_log_bottom_sheet.dart';

/// People list screen - main people management interface
///
/// Features:
/// - People grouped by sections: NEEDS ATTENTION, UP TO DATE, RECENTLY ADDED
/// - Filter tabs: All, Elders, Members, Visitors, Leadership, Crisis
/// - Search bar at top
/// - Each person card shows name, category, last contact, status
/// - Quick actions: Call, Log Contact
/// - Pull to refresh
/// - Empty state when no people
/// - Loading state with CircularProgressIndicator
/// - Error state with retry button
///
/// Design:
/// - Background color: #F9FAFB (Shepherd design system)
/// - Uses Material Design 3 components
/// - Card-based layout with 12px border radius
/// - Proper touch targets (44x44 minimum)
/// - No Scaffold (wrapped by MainScaffold)
///
/// Navigation:
/// - Tapping person card opens detail: context.push('/people/${person.id}')
///
/// State Management:
/// - TODO: Use Riverpod providers for real-time updates
/// - For now, uses placeholder mock data
///
/// Usage:
/// This screen is displayed when navigating to '/people' via go_router.
/// It's typically wrapped in MainScaffold which provides AppBar and navigation.
class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  // Current filter selection
  PeopleFilter _currentFilter = PeopleFilter.all;

  // Search query
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual Riverpod provider
    // final peopleAsync = ref.watch(peopleProvider);

    return Column(
      children: [
        // Search bar and filter tabs
        _buildSearchAndFilters(context),

        // People list with loading/error/empty states
        Expanded(
          child: _buildPeopleList(),
        ),
      ],
    );
  }

  /// Build search bar and filter tabs
  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          if (_isSearching) _buildSearchBar() else _buildSearchButton(),

          // Filter tabs
          _buildFilterTabs(),
        ],
      ),
    );
  }

  /// Build collapsed search button
  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _isSearching = true;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(
                'Search people...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build expanded search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            tooltip: 'Close search',
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  /// Build filter tabs
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('All', PeopleFilter.all),
          const SizedBox(width: 8),
          _buildFilterChip('Elders', PeopleFilter.elders),
          const SizedBox(width: 8),
          _buildFilterChip('Members', PeopleFilter.members),
          const SizedBox(width: 8),
          _buildFilterChip('Visitors', PeopleFilter.visitors),
          const SizedBox(width: 8),
          _buildFilterChip('Leadership', PeopleFilter.leadership),
          const SizedBox(width: 8),
          _buildFilterChip('Crisis', PeopleFilter.crisis),
        ],
      ),
    );
  }

  /// Build individual filter chip
  Widget _buildFilterChip(String label, PeopleFilter filter) {
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

  /// Build people list with appropriate grouping
  Widget _buildPeopleList() {
    // TODO: Replace with actual data from Riverpod provider
    // For now, show placeholder

    return _buildPlaceholderView();
  }

  /// Build placeholder view when no data/providers yet
  Widget _buildPlaceholderView() {
    final theme = Theme.of(context);

    return Container(
      color: const Color(0xFFF9FAFB),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.people_outline,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'People Module',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'UI components created!\nData providers and repository coming next.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Filter: ${_getFilterLabel(_currentFilter)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Search: "$_searchQuery"',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build grouped people list by status
  ///
  /// Groups:
  /// - NEEDS ATTENTION (red) - overdue contacts
  /// - UP TO DATE (green) - recent contacts
  /// - RECENTLY ADDED - newly added people
  Widget _buildGroupedPeopleList(List<PersonEntity> people) {
    // Filter by category first
    final filteredPeople = _filterPeopleByCategory(people);

    // Filter by search query
    final searchedPeople = _filterPeopleBySearch(filteredPeople);

    // Group by status
    final grouped = _groupPeopleByStatus(searchedPeople);

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        children: [
          // NEEDS ATTENTION section (red, always expanded)
          if (grouped['needsAttention']!.isNotEmpty)
            _buildPeopleSection(
              title: 'NEEDS ATTENTION',
              people: grouped['needsAttention']!,
              accentColor: const Color(0xFFEF4444), // Red
              initiallyExpanded: true,
            ),

          // UP TO DATE section (green, expanded)
          if (grouped['upToDate']!.isNotEmpty)
            _buildPeopleSection(
              title: 'UP TO DATE',
              people: grouped['upToDate']!,
              accentColor: const Color(0xFF10B981), // Green
              initiallyExpanded: true,
            ),

          // RECENTLY ADDED section (blue, collapsed)
          if (grouped['recentlyAdded']!.isNotEmpty)
            _buildPeopleSection(
              title: 'RECENTLY ADDED',
              people: grouped['recentlyAdded']!,
              accentColor: const Color(0xFF2563EB), // Blue
              initiallyExpanded: false,
            ),

          // Empty state if no people in any group
          if (searchedPeople.isEmpty) _buildEmptyState(),
        ],
      ),
    );
  }

  /// Build collapsible section with people cards
  Widget _buildPeopleSection({
    required String title,
    required List<PersonEntity> people,
    required Color accentColor,
    required bool initiallyExpanded,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${people.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        initiallyExpanded: initiallyExpanded,
        children: people.map((person) {
          return PersonCard(
            person: person,
            onTap: () {
              // TODO: Navigate to person detail
              // context.push('/people/${person.id}');
            },
            onLogContact: () {
              showContactLogBottomSheet(
                context: context,
                person: person,
                onSave: (contactData) async {
                  // TODO: Save to repository
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.person_add_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No people found' : 'No people yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Add your first person to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Filter people by category based on current filter
  List<PersonEntity> _filterPeopleByCategory(List<PersonEntity> people) {
    switch (_currentFilter) {
      case PeopleFilter.elders:
        return people.where((p) => p.category == 'elder').toList();
      case PeopleFilter.members:
        return people.where((p) => p.category == 'member').toList();
      case PeopleFilter.visitors:
        return people.where((p) => p.category == 'visitor').toList();
      case PeopleFilter.leadership:
        return people.where((p) => p.category == 'leadership').toList();
      case PeopleFilter.crisis:
        return people.where((p) => p.category == 'crisis').toList();
      case PeopleFilter.all:
      default:
        return people;
    }
  }

  /// Filter people by search query
  List<PersonEntity> _filterPeopleBySearch(List<PersonEntity> people) {
    if (_searchQuery.isEmpty) return people;

    return people.where((person) {
      return person.name.toLowerCase().contains(_searchQuery) ||
          person.email?.toLowerCase().contains(_searchQuery) == true;
    }).toList();
  }

  /// Group people by status
  Map<String, List<PersonEntity>> _groupPeopleByStatus(List<PersonEntity> people) {
    final needsAttention = <PersonEntity>[];
    final upToDate = <PersonEntity>[];
    final recentlyAdded = <PersonEntity>[];

    final now = DateTime.now();
    final recentlyAddedThreshold = now.subtract(const Duration(days: 7));

    for (final person in people) {
      // Check if recently added (within last 7 days)
      if (person.createdAt.isAfter(recentlyAddedThreshold)) {
        recentlyAdded.add(person);
        continue;
      }

      // Check if overdue
      if (person.isOverdue()) {
        needsAttention.add(person);
      } else {
        upToDate.add(person);
      }
    }

    // Sort each group
    needsAttention.sort((a, b) {
      final aDays = a.daysSinceLastContact ?? 999999;
      final bDays = b.daysSinceLastContact ?? 999999;
      return bDays.compareTo(aDays); // Most overdue first
    });

    upToDate.sort((a, b) {
      final aDays = a.daysSinceLastContact ?? 999999;
      final bDays = b.daysSinceLastContact ?? 999999;
      return aDays.compareTo(bDays); // Most recent first
    });

    recentlyAdded.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first

    return {
      'needsAttention': needsAttention,
      'upToDate': upToDate,
      'recentlyAdded': recentlyAdded,
    };
  }

  /// Get filter label for display
  String _getFilterLabel(PeopleFilter filter) {
    switch (filter) {
      case PeopleFilter.all:
        return 'All';
      case PeopleFilter.elders:
        return 'Elders';
      case PeopleFilter.members:
        return 'Members';
      case PeopleFilter.visitors:
        return 'Visitors';
      case PeopleFilter.leadership:
        return 'Leadership';
      case PeopleFilter.crisis:
        return 'Crisis';
    }
  }
}

/// Enum for people filter options
enum PeopleFilter {
  all,
  elders,
  members,
  visitors,
  leadership,
  crisis,
}

// Usage with go_router:
// ```dart
// GoRoute(
//   path: '/people',
//   builder: (context, state) => const PeopleScreen(),
// )
// ```
