import 'package:flutter/material.dart';

/// A single day cell in the calendar grid
///
/// Displays the day number and an optional event count indicator.
/// The indicator is a small colored dot that changes based on event load:
/// - No indicator: 0 events
/// - Yellow (#FCD34D): 1-2 events (light load)
/// - Orange (#FB923C): 3-4 events (medium load)
/// - Red (#EF4444): 5+ events (heavy load)
///
/// Current day is highlighted with primary color background.
/// Cells are optimized to be compact and fit the entire month on screen.
///
/// Usage:
/// ```dart
/// CalendarDayCell(
///   day: 15,
///   eventCount: 3,
///   isCurrentDay: true,
///   isCurrentMonth: true,
///   onTap: () => _handleDayTap(day),
/// )
/// ```
class CalendarDayCell extends StatelessWidget {
  /// The day number (1-31)
  final int day;

  /// Number of events scheduled for this day
  final int eventCount;

  /// Whether this is today's date
  final bool isCurrentDay;

  /// Whether this day belongs to the currently displayed month
  /// (false for days from previous/next month shown in grid)
  final bool isCurrentMonth;

  /// Callback when cell is tapped
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    this.eventCount = 0,
    this.isCurrentDay = false,
    this.isCurrentMonth = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine indicator color based on event count
    Color? indicatorColor;
    if (eventCount >= 5) {
      indicatorColor = const Color(0xFFEF4444); // Red - heavy load
    } else if (eventCount >= 3) {
      indicatorColor = const Color(0xFFFB923C); // Orange - medium load
    } else if (eventCount >= 1) {
      indicatorColor = const Color(0xFFFCD34D); // Yellow - light load
    }

    // Text color based on current month and current day
    Color textColor;
    if (isCurrentDay) {
      textColor = Colors.white;
    } else if (!isCurrentMonth) {
      textColor = Colors.grey.shade400;
    } else {
      textColor = theme.colorScheme.onSurface;
    }

    return InkWell(
      onTap: isCurrentMonth ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Semantics(
        label: _buildSemanticLabel(),
        button: true,
        enabled: isCurrentMonth,
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentDay ? theme.colorScheme.primary : null,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Day number
              Text(
                day.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 2),

              // Event count indicator (small dot)
              if (indicatorColor != null)
                _EventDotIndicator(color: indicatorColor)
              else
                // Small spacer to maintain alignment
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  /// Build semantic label for screen readers
  String _buildSemanticLabel() {
    final buffer = StringBuffer();
    buffer.write('Day $day');

    if (isCurrentDay) {
      buffer.write(', Today');
    }

    if (eventCount > 0) {
      buffer.write(', $eventCount event');
      if (eventCount > 1) buffer.write('s');
    }

    if (!isCurrentMonth) {
      buffer.write(', Not in current month');
    }

    return buffer.toString();
  }
}

/// Event indicator as a small colored dot
/// Compact design to fit in small calendar cells
class _EventDotIndicator extends StatelessWidget {
  final Color color;

  const _EventDotIndicator({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
