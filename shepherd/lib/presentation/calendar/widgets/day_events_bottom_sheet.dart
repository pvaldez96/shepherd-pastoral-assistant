import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/calendar_event.dart';
import '../event_form_screen.dart';
import '../providers/calendar_event_providers.dart';
import 'event_list_tile.dart';

/// Bottom sheet displaying events for a specific day
///
/// Shows a list of events scheduled for the selected date.
/// Includes option to add a new event for that day.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => DayEventsBottomSheet(date: selectedDate),
/// );
/// ```
class DayEventsBottomSheet extends ConsumerWidget {
  /// The date to display events for
  final DateTime date;

  const DayEventsBottomSheet({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy'); // e.g., "Monday, December 9, 2024"

    // Normalize date to midnight for consistent comparison
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Watch events for the selected date
    final eventsAsync = ref.watch(eventsForDateProvider(normalizedDate));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with date
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(date),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      eventsAsync.when(
                        data: (events) => Text(
                          events.isEmpty
                              ? 'No events scheduled'
                              : '${events.length} event${events.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                // Add event button
                IconButton(
                  onPressed: () => _handleAddEvent(context, date),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add event',
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Events list
          Flexible(
            child: eventsAsync.when(
              data: (events) => _buildEventsList(context, events),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _buildErrorView(context, error),
            ),
          ),

          // Safe area padding at bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Build the events list
  Widget _buildEventsList(BuildContext context, List<CalendarEventEntity> events) {
    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort events by start time
    final sortedEvents = List<CalendarEventEntity>.from(events)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedEvents.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 32,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return EventListTile(
          event: event,
          onTap: () => _handleEventTap(context, event),
        );
      },
    );
  }

  /// Build empty state when no events
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No events scheduled',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add an event',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build error view
  Widget _buildErrorView(BuildContext context, Object error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle adding a new event for this date
  void _handleAddEvent(BuildContext context, DateTime date) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(initialDate: date),
      ),
    );
  }

  /// Handle tapping on an event
  void _handleEventTap(BuildContext context, CalendarEventEntity event) {
    // TODO: Navigate to event detail screen
    // For now, show a placeholder snackbar
    Navigator.pop(context); // Close bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event detail screen coming soon! (Event: ${event.title})'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Helper function to show the day events bottom sheet
void showDayEventsSheet(BuildContext context, DateTime date) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DayEventsBottomSheet(date: date),
  );
}
