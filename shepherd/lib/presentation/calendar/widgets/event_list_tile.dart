import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/calendar_event.dart';

/// A list tile displaying calendar event information
///
/// Shows event title, time range, location, and a colored badge for event type.
/// Used in the day events bottom sheet and other event lists.
///
/// Usage:
/// ```dart
/// EventListTile(
///   event: event,
///   onTap: () => _navigateToEventDetail(event),
/// )
/// ```
class EventListTile extends StatelessWidget {
  /// The calendar event to display
  final CalendarEventEntity event;

  /// Callback when tile is tapped
  final VoidCallback? onTap;

  const EventListTile({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a'); // e.g., "2:30 PM"
    final startTime = timeFormat.format(event.startDateTime);
    final endTime = timeFormat.format(event.endDateTime);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event type badge (colored vertical bar)
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: _getEventTypeColor(event.eventType),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(width: 12),

            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and type badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _EventTypeBadge(eventType: event.eventType),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Time range
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$startTime - $endTime',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),

                  // Location (if available)
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Chevron icon
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for event type
  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'service':
        return const Color(0xFF2563EB); // Blue
      case 'meeting':
        return const Color(0xFF10B981); // Green
      case 'pastoral_visit':
        return const Color(0xFF8B5CF6); // Purple
      case 'personal':
        return const Color(0xFFF59E0B); // Orange
      case 'work':
        return const Color(0xFF6B7280); // Gray
      case 'family':
        return const Color(0xFFEC4899); // Pink
      case 'blocked_time':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Default gray
    }
  }
}

/// Small badge showing event type
class _EventTypeBadge extends StatelessWidget {
  final String eventType;

  const _EventTypeBadge({required this.eventType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _getEventTypeLabel(eventType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getEventTypeColor(eventType).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getEventTypeColor(eventType),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Get display label for event type
  String _getEventTypeLabel(String eventType) {
    switch (eventType) {
      case 'service':
        return 'SERVICE';
      case 'meeting':
        return 'MEETING';
      case 'pastoral_visit':
        return 'VISIT';
      case 'personal':
        return 'PERSONAL';
      case 'work':
        return 'WORK';
      case 'family':
        return 'FAMILY';
      case 'blocked_time':
        return 'BLOCKED';
      default:
        return eventType.toUpperCase();
    }
  }

  /// Get color for event type
  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'service':
        return const Color(0xFF2563EB); // Blue
      case 'meeting':
        return const Color(0xFF10B981); // Green
      case 'pastoral_visit':
        return const Color(0xFF8B5CF6); // Purple
      case 'personal':
        return const Color(0xFFF59E0B); // Orange
      case 'work':
        return const Color(0xFF6B7280); // Gray
      case 'family':
        return const Color(0xFFEC4899); // Pink
      case 'blocked_time':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Default gray
    }
  }
}
