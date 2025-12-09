# People Module - Quick Reference Guide

## File Structure

```
lib/presentation/people/
├── people_screen.dart              # Main list screen
├── person_detail_screen.dart       # Detail view screen
├── person_form_screen.dart         # Create/edit form screen
└── widgets/
    ├── person_card.dart            # List item card
    ├── person_category_badge.dart  # Category badge widget
    ├── contact_history_tile.dart   # Contact log timeline entry
    └── contact_log_bottom_sheet.dart # Quick contact logging form
```

## Key Components

### PersonCard
```dart
PersonCard(
  person: personEntity,
  onTap: () => context.push('/people/${person.id}'),
  onLogContact: () => showContactLogBottomSheet(context, person),
)
```

### PersonCategoryBadge
```dart
PersonCategoryBadge(category: 'elder')
// Colors: elder(blue), member(purple), visitor(teal),
//         leadership(orange), crisis(red), family(pink), other(gray)
```

### ContactHistoryTile
```dart
ContactHistoryTile(
  contactLog: contactLogEntity,
  isFirst: index == 0,
  isLast: index == logs.length - 1,
)
```

### Contact Log Bottom Sheet
```dart
final result = await showContactLogBottomSheet(
  context: context,
  person: person,
  onSave: (contactData) async {
    // Save to repository
  },
);
```

## Category Colors

| Category   | Color Code | Visual         |
|-----------|------------|----------------|
| Elder     | #2563EB    | Blue           |
| Member    | #8B5CF6    | Purple         |
| Visitor   | #14B8A6    | Teal           |
| Leadership| #F59E0B    | Orange         |
| Crisis    | #EF4444    | Red            |
| Family    | #EC4899    | Pink           |
| Other     | #6B7280    | Gray           |

## Status Colors

| Status         | Color Code | Usage                    |
|---------------|------------|--------------------------|
| Overdue       | #EF4444    | Needs attention          |
| Up to Date    | #10B981    | Recent contact           |
| Recently Added| #2563EB    | New within 7 days        |

## Contact Type Icons

| Type      | Icon         | Color   |
|-----------|-------------|---------|
| Visit     | home        | Blue    |
| Call      | phone       | Green   |
| Email     | email       | Purple  |
| Text      | message     | Teal    |
| In Person | person      | Orange  |
| Other     | chat        | Gray    |

## Person Entity Helper Methods

```dart
// Days since last contact
final days = person.daysSinceLastContact; // int? (null if never contacted)

// Check if overdue
final isOverdue = person.isOverdue(); // bool

// Get contact threshold (days)
final threshold = person.getContactThreshold(); // int

// Get days until due (negative = overdue)
final daysUntil = person.getDaysUntilDue(); // int?
```

## Navigation

```dart
// To people list
context.go('/people');

// To person detail
context.push('/people/${personId}');

// To create person
context.push('/people/new');

// To edit person
context.push('/people/${personId}/edit');
```

## Common Patterns

### Loading State
```dart
final peopleAsync = ref.watch(peopleProvider);
peopleAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorView(error: err),
  data: (people) => PeopleList(people: people),
);
```

### Filtering
```dart
// By category
final eldersPeople = people.where((p) => p.category == 'elder').toList();

// By search
final searchResults = people.where((p) =>
  p.name.toLowerCase().contains(query) ||
  p.email?.toLowerCase().contains(query) == true
).toList();
```

### Grouping by Status
```dart
final needsAttention = people.where((p) => p.isOverdue()).toList();
final upToDate = people.where((p) => !p.isOverdue()).toList();
final recentlyAdded = people.where((p) =>
  p.createdAt.isAfter(DateTime.now().subtract(Duration(days: 7)))
).toList();
```

## Form Validation Examples

```dart
// Name (required)
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter a name';
  }
  return null;
}

// Email (optional, but must be valid if provided)
validator: (value) {
  if (value != null && value.isNotEmpty) {
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
  }
  return null;
}

// Contact frequency (optional, must be positive if provided)
validator: (value) {
  if (value != null && value.isNotEmpty) {
    final days = int.tryParse(value);
    if (days == null || days <= 0) {
      return 'Please enter a valid number of days';
    }
  }
  return null;
}
```

## TODO Integration Points

All screens have TODO comments marking where to connect data:

1. **people_screen.dart**: Line 60 - Add peopleProvider
2. **person_detail_screen.dart**: Line 54 - Add personProvider and contactLogsProvider
3. **person_form_screen.dart**: Line 731 - Add repository save/update calls
4. **person_card.dart**: Line 237 - Add phone dialer (url_launcher)

## Testing URLs

Use these for manual testing once integrated:

```
/people                    # People list
/people/new                # Create person
/people/123e4567-...       # Person detail
/people/123e4567-.../edit  # Edit person
```

## Shepherd Design System Reference

- Primary: #2563EB (blue)
- Success: #10B981 (green)
- Warning: #F59E0B (orange)
- Error: #EF4444 (red)
- Background: #F9FAFB
- Surface: #FFFFFF
- Card radius: 12px
- Button radius: 8px
- Input radius: 8px
- Base spacing: 4px (use 8, 12, 16, 24)
