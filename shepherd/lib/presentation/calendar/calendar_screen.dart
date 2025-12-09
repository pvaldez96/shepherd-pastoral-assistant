import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/calendar_event_providers.dart';
import 'widgets/calendar_day_cell.dart';
import 'widgets/day_events_bottom_sheet.dart';

/// Calendar screen with month view
///
/// Displays a monthly calendar grid with event count indicators for each day.
/// Users can:
/// - View current month with all events
/// - Navigate between months using swipe or arrow buttons
/// - Tap a day to see detailed events in a bottom sheet
/// - Switch between Month/Week/Day views (Week/Day are placeholders for now)
///
/// Event load indicators:
/// - Yellow circle: 1-2 events (light load)
/// - Orange circle: 3-4 events (medium load)
/// - Red circle: 5+ events (heavy load)
///
/// Current day is highlighted with primary color background.
///
/// Design:
/// - Blue header contains view tabs (Month/Week/Day) and month navigation
/// - No FAB (action button handled by MainScaffold)
/// - No bottom tab bar
///
/// Note: AppBar is provided by MainScaffold, not this screen
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

/// Enum for calendar view types
enum CalendarView {
  month,
  week,
  day,
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// Currently displayed month
  late DateTime _currentMonth;

  /// Page controller for month swiping
  late PageController _pageController;

  /// Currently selected view (Month, Week, or Day)
  CalendarView _currentView = CalendarView.month;

  @override
  void initState() {
    super.initState();
    // Initialize to current month
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _pageController = PageController(initialPage: 1000); // Start at middle to allow infinite scrolling
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Blue header with view tabs and month navigation
        _buildBlueHeader(),

        // Calendar view content
        Expanded(
          child: _buildCalendarView(),
        ),
      ],
    );
  }

  /// Build blue header with view selector tabs and month navigation
  ///
  /// Contains:
  /// - Row 1: Segmented button for Month/Week/Day selection
  /// - Row 2: [<] Month Year [>] navigation
  Widget _buildBlueHeader() {
    final monthFormat = DateFormat('MMMM yyyy'); // e.g., "December 2024"

    return Container(
      color: const Color(0xFF2563EB), // Primary blue
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // View selector tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SegmentedButton<CalendarView>(
                segments: const [
                  ButtonSegment(
                    value: CalendarView.month,
                    label: Text('Month'),
                    icon: Icon(Icons.calendar_month, size: 16),
                  ),
                  ButtonSegment(
                    value: CalendarView.week,
                    label: Text('Week'),
                    icon: Icon(Icons.view_week, size: 16),
                  ),
                  ButtonSegment(
                    value: CalendarView.day,
                    label: Text('Day'),
                    icon: Icon(Icons.view_day, size: 16),
                  ),
                ],
                selected: {_currentView},
                onSelectionChanged: (selection) {
                  setState(() {
                    _currentView = selection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.white.withValues(alpha: 0.2);
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Color(0xFF2563EB);
                    }
                    return Colors.white;
                  }),
                  side: WidgetStateProperty.all(
                    BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Month navigation row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous month button
                  Semantics(
                    label: 'Previous month',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: _goToPreviousMonth,
                      tooltip: 'Previous month',
                      iconSize: 28,
                    ),
                  ),

                  // Month and year
                  Text(
                    monthFormat.format(_currentMonth),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // Next month button
                  Semantics(
                    label: 'Next month',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: _goToNextMonth,
                      tooltip: 'Next month',
                      iconSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the calendar grid view based on selected view
  Widget _buildCalendarView() {
    switch (_currentView) {
      case CalendarView.week:
        // Week view - TODO
        return _buildPlaceholderView('Week View', Icons.view_week);
      case CalendarView.day:
        // Day view - TODO
        return _buildPlaceholderView('Day View', Icons.view_day);
      case CalendarView.month:
        // Month view
        return _buildMonthView();
    }
  }

  /// Build the month calendar grid
  Widget _buildMonthView() {
    final theme = Theme.of(context);

    // Get the date range for the current month (including days from prev/next month)
    final firstDayOfMonth = _currentMonth;
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    // Calculate the start date (may be in previous month)
    // Start from the first Monday before or on the first day of the month
    int firstWeekday = firstDayOfMonth.weekday;
    if (firstWeekday == DateTime.sunday) firstWeekday = 7;
    final startDate = firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));

    // Calculate the end date (may be in next month)
    // We need enough rows to show all days (typically 5-6 weeks)
    final endDate = startDate.add(const Duration(days: 42)); // 6 weeks = 42 days

    // Load events for the entire range
    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    final eventsAsync = ref.watch(eventsInRangeProvider(DateRange(rangeStart, rangeEnd)));

    return eventsAsync.when(
      loading: () => _buildLoadingSkeleton(),
      error: (error, stack) => _buildErrorView(error),
      data: (events) {
        // Create a map of date -> event count for quick lookup
        final eventCountMap = <DateTime, int>{};
        for (final event in events) {
          final eventDate = DateTime(
            event.startDateTime.year,
            event.startDateTime.month,
            event.startDateTime.day,
          );
          eventCountMap[eventDate] = (eventCountMap[eventDate] ?? 0) + 1;
        }

        return Column(
          children: [
            // Weekday headers (Mon, Tue, Wed, etc.)
            _buildWeekdayHeaders(theme),

            const Divider(height: 1),

            // Calendar grid
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  // Swipe to change months
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < 0) {
                      // Swiped left - next month
                      _goToNextMonth();
                    } else if (details.primaryVelocity! > 0) {
                      // Swiped right - previous month
                      _goToPreviousMonth();
                    }
                  }
                },
                child: _buildCalendarGrid(
                  startDate,
                  firstDayOfMonth,
                  lastDayOfMonth,
                  eventCountMap,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build weekday headers (Mon, Tue, Wed, etc.)
  Widget _buildWeekdayHeaders(ThemeData theme) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build the calendar grid with day cells
  Widget _buildCalendarGrid(
    DateTime startDate,
    DateTime firstDayOfMonth,
    DateTime lastDayOfMonth,
    Map<DateTime, int> eventCountMap,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build day cells
    final dayCells = List.generate(42, (index) {
      final date = startDate.add(Duration(days: index));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final eventCount = eventCountMap[normalizedDate] ?? 0;
      final isCurrentMonth = date.month == _currentMonth.month;
      final isCurrentDay = normalizedDate == today;

      return CalendarDayCell(
        day: date.day,
        eventCount: eventCount,
        isCurrentDay: isCurrentDay,
        isCurrentMonth: isCurrentMonth,
        onTap: () => _handleDayTap(normalizedDate),
      );
    });

    // Use LayoutBuilder to calculate cell size based on available space
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell dimensions
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Cell width: divide by 7 columns with small gaps
        final horizontalPadding = 8.0;
        final cellSpacing = 2.0;
        final totalHorizontalSpace = availableWidth - (horizontalPadding * 2);
        final cellWidth = (totalHorizontalSpace - (cellSpacing * 6)) / 7;

        // Cell height: divide by 6 rows with small gaps
        final verticalPadding = 4.0;
        final totalVerticalSpace = availableHeight - (verticalPadding * 2);
        final cellHeight = (totalVerticalSpace - (cellSpacing * 5)) / 6;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (weekIndex) {
              // Build each week row
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (dayIndex) {
                  final cellIndex = weekIndex * 7 + dayIndex;
                  return SizedBox(
                    width: cellWidth,
                    height: cellHeight,
                    child: dayCells[cellIndex],
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }

  /// Build loading skeleton while events are loading
  Widget _buildLoadingSkeleton() {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildWeekdayHeaders(theme),
        const Divider(height: 1),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading calendar...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build error view when loading fails
  Widget _buildErrorView(Object error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load calendar',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh by rebuilding the widget
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder view for Week/Day views (not yet implemented)
  Widget _buildPlaceholderView(String title, IconData icon) {
    final theme = Theme.of(context);

    return Center(
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
                icon,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming soon!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to previous month
  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  /// Navigate to next month
  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  /// Jump to today's date
  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month, 1);
    });
  }

  /// Handle day cell tap - show bottom sheet with day's events
  void _handleDayTap(DateTime date) {
    showDayEventsSheet(context, date);
  }

  /// Public method to jump to today (called from MainScaffold action button)
  void jumpToToday() {
    _jumpToToday();
  }
}
