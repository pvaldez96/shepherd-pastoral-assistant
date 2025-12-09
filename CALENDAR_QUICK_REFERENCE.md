# Calendar Month View - Quick Reference Guide

## File Locations

```
shepherd/lib/presentation/calendar/
├── calendar_screen.dart                    # Main calendar screen
├── providers/
│   └── calendar_event_providers.dart       # Riverpod providers (existing)
└── widgets/
    ├── calendar_day_cell.dart              # Day cell with event indicator
    ├── event_list_tile.dart                # Event list item
    └── day_events_bottom_sheet.dart        # Bottom sheet for day's events
```

## Key Components

### 1. CalendarScreen
**Purpose:** Main monthly calendar view

**Usage:**
```dart
// Already integrated in router at /calendar
context.go('/calendar');
```

**Features:**
- Monthly grid (7×6 = 42 days)
- Event count indicators (color-coded by load)
- Swipe or arrows to navigate months
- Bottom tabs: Month/Week/Day (only Month active)
- FAB to add events
- "Today" button to jump to current date

### 2. CalendarDayCell
**Purpose:** Individual day in calendar grid

**Usage:**
```dart
CalendarDayCell(
  day: 15,
  eventCount: 3,
  isCurrentDay: true,
  isCurrentMonth: true,
  onTap: () => print('Day 15 tapped'),
)
```

**Load Indicators:**
```dart
0 events     → No indicator
1-2 events   → Yellow circle (#FCD34D)
3-4 events   → Orange circle (#FB923C)
5+ events    → Red circle (#EF4444)
```

### 3. EventListTile
**Purpose:** Display event in lists

**Usage:**
```dart
EventListTile(
  event: calendarEvent,
  onTap: () => navigateToDetail(event),
)
```

**Displays:**
- Title + event type badge
- Time range with clock icon
- Location with pin icon (if present)

### 4. DayEventsBottomSheet
**Purpose:** Show all events for a specific day

**Usage:**
```dart
// Helper function provided:
showDayEventsSheet(context, DateTime(2024, 12, 25));

// Or manually:
showModalBottomSheet(
  context: context,
  builder: (context) => DayEventsBottomSheet(date: date),
);
```

## State Management

### Load Events for Month
```dart
// In ConsumerWidget or ConsumerStatefulWidget:
final eventsAsync = ref.watch(
  eventsInRangeProvider(DateRange(startDate, endDate))
);

eventsAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorView(error: err),
  data: (events) => CalendarGrid(events: events),
);
```

### Load Events for Specific Day
```dart
final eventsAsync = ref.watch(
  eventsForDateProvider(DateTime(2024, 12, 25))
);
```

### Get Event Count Map
```dart
// Build a quick lookup map:
final eventCountMap = <DateTime, int>{};
for (final event in events) {
  final date = DateTime(
    event.startDateTime.year,
    event.startDateTime.month,
    event.startDateTime.day,
  );
  eventCountMap[date] = (eventCountMap[date] ?? 0) + 1;
}

// Use it:
final count = eventCountMap[normalizedDate] ?? 0;
```

## Common Tasks

### Navigate to Specific Month
```dart
// In CalendarScreen state:
setState(() {
  _currentMonth = DateTime(2024, 12, 1); // December 2024
});
```

### Jump to Today
```dart
// Already implemented in CalendarScreen:
_jumpToToday(); // Resets to current month
```

### Handle Day Tap
```dart
// Already implemented:
void _handleDayTap(DateTime date) {
  showDayEventsSheet(context, date);
}
```

### Change View (Month/Week/Day)
```dart
// In CalendarScreen state:
setState(() {
  _selectedViewIndex = 0; // 0=Month, 1=Week, 2=Day
});
```

## Event Type Colors

```dart
Color getEventTypeColor(String eventType) {
  switch (eventType) {
    case 'service':        return Color(0xFF2563EB); // Blue
    case 'meeting':        return Color(0xFF10B981); // Green
    case 'pastoral_visit': return Color(0xFF8B5CF6); // Purple
    case 'personal':       return Color(0xFFF59E0B); // Orange
    case 'work':           return Color(0xFF6B7280); // Gray
    case 'family':         return Color(0xFFEC4899); // Pink
    case 'blocked_time':   return Color(0xFFEF4444); // Red
    default:               return Color(0xFF6B7280); // Gray
  }
}
```

## Date Utilities

### Normalize Date (Remove Time)
```dart
final normalizedDate = DateTime(date.year, date.month, date.day);
```

### Get Month Start/End
```dart
final firstDay = DateTime(year, month, 1);
final lastDay = DateTime(year, month + 1, 0);
```

### Get Calendar Grid Start (First Monday)
```dart
int firstWeekday = firstDayOfMonth.weekday;
if (firstWeekday == DateTime.sunday) firstWeekday = 7;
final startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));
```

### Format Dates
```dart
import 'package:intl/intl.dart';

// Month and year: "December 2024"
DateFormat('MMMM yyyy').format(date);

// Full date: "Monday, December 9, 2024"
DateFormat('EEEE, MMMM d, yyyy').format(date);

// Time: "2:30 PM"
DateFormat('h:mm a').format(dateTime);

// Short date: "Dec 9, 2024"
DateFormat('MMM d, yyyy').format(date);
```

## Styling Constants

### Colors
```dart
const primaryColor = Color(0xFF2563EB);        // Blue
const successColor = Color(0xFF10B981);        // Green
const warningColor = Color(0xFFF59E0B);        // Orange
const errorColor = Color(0xFFEF4444);          // Red
const lightLoadColor = Color(0xFFFCD34D);      // Yellow
const mediumLoadColor = Color(0xFFFB923C);     // Orange
const heavyLoadColor = Color(0xFFEF4444);      // Red
```

### Spacing
```dart
const spacing4 = 4.0;
const spacing8 = 8.0;
const spacing12 = 12.0;
const spacing16 = 16.0;
const spacing24 = 24.0;
const spacing32 = 32.0;
```

### Border Radius
```dart
BorderRadius.circular(8);  // Buttons, cells
BorderRadius.circular(12); // Cards
BorderRadius.circular(16); // Bottom sheets
```

## TODOs (Future Implementation)

### Event Creation Integration
```dart
// In calendar_screen.dart line ~518:
void _handleAddEvent() {
  // TODO: Navigate to event creation screen
  context.push('/calendar/event/new');
}
```

### Event Detail Integration
```dart
// In day_events_bottom_sheet.dart line ~245:
void _handleEventTap(BuildContext context, CalendarEventEntity event) {
  // TODO: Navigate to event detail screen
  context.push('/calendar/event/${event.id}');
}
```

### Add Event with Pre-filled Date
```dart
// In day_events_bottom_sheet.dart line ~232:
void _handleAddEvent(BuildContext context, DateTime date) {
  // TODO: Navigate to event creation screen with pre-filled date
  context.push('/calendar/event/new', extra: {'date': date});
}
```

### Week View Implementation
```dart
// In calendar_screen.dart line ~138-139:
if (_selectedViewIndex == 1) {
  // TODO: Implement week view
  return WeekView(startDate: _getWeekStart());
}
```

### Day View Implementation
```dart
// In calendar_screen.dart line ~141-142:
if (_selectedViewIndex == 2) {
  // TODO: Implement day view
  return DayView(date: _currentMonth);
}
```

## Testing Examples

### Unit Test: Event Count Map
```dart
test('builds correct event count map', () {
  final events = [
    createEvent(date: DateTime(2024, 12, 25)),
    createEvent(date: DateTime(2024, 12, 25)),
    createEvent(date: DateTime(2024, 12, 26)),
  ];

  final map = buildEventCountMap(events);

  expect(map[DateTime(2024, 12, 25)], equals(2));
  expect(map[DateTime(2024, 12, 26)], equals(1));
});
```

### Widget Test: Day Cell
```dart
testWidgets('CalendarDayCell displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CalendarDayCell(
          day: 15,
          eventCount: 3,
          isCurrentDay: true,
          isCurrentMonth: true,
        ),
      ),
    ),
  );

  expect(find.text('15'), findsOneWidget);
  expect(find.text('3'), findsOneWidget);
});
```

### Widget Test: Month Navigation
```dart
testWidgets('navigates to next month', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: CalendarScreen(),
      ),
    ),
  );

  // Tap next month button
  await tester.tap(find.byIcon(Icons.chevron_right));
  await tester.pumpAndSettle();

  // Verify month changed (check header text)
  // expect(find.text(...), findsOneWidget);
});
```

## Performance Tips

1. **Use const constructors** wherever possible
2. **Efficient date range queries** - only load visible month
3. **Lazy rendering** - GridView.builder, ListView.builder
4. **Dispose controllers** - PageController in CalendarScreen
5. **Avoid rebuilding** - Use select() or Consumer for targeted rebuilds

## Accessibility Checklist

- [x] Semantic labels on all interactive elements
- [x] Touch targets ≥44×44 logical pixels
- [x] Color not sole indicator (text + color)
- [x] Screen reader support (TalkBack/VoiceOver)
- [x] Dynamic text scaling support
- [x] Keyboard navigation (future: arrow keys)

## Responsive Design

Current implementation:
- Phone portrait (primary)
- Phone landscape (works)
- Tablet (works, could be enhanced)

Grid automatically adjusts to screen width via GridView's flexible sizing.

## Summary

The calendar month view is fully functional and ready to use. The main screen provides excellent UX for viewing monthly schedules, and the bottom sheet gives detailed daily views. Integration points are clearly marked with TODOs for event creation and detail screens.

**Next Steps:**
1. Implement event creation screen
2. Implement event detail screen
3. Connect TODOs in calendar to new screens
4. Implement week view (optional)
5. Implement day view (optional)
