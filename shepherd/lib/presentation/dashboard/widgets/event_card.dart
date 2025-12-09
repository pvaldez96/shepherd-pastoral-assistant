import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/calendar_event.dart';

/// Event card for dashboard display
///
/// Shows a compact view of a calendar event including:
/// - Time range
/// - Title
/// - Location (if available)
/// - Icon based on event type
///
/// Design:
/// - 12px border radius
/// - Elevation 1 for subtle shadow
/// - Icon indicates event type
/// - Clean, scannable layout
class EventCard extends StatelessWidget {
  final CalendarEventEntity event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final timeRange = _formatTimeRange();
    final eventIcon = _getEventIcon();
    final eventColor = _getEventColor();
    final isHappeningNow = event.isHappeningNow;

    return Semantics(
      label: 'Event: ${event.title}, from ${timeRange.start} to ${timeRange.end}'
          '${event.location != null ? ', at ${event.location}' : ''}',
      child: Card(
        elevation: isHappeningNow ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isHappeningNow
              ? const BorderSide(color: Color(0xFF2563EB), width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            // TODO: Navigate to event detail
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: eventColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    eventIcon,
                    color: eventColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time range
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${timeRange.start} - ${timeRange.end}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          if (isHappeningNow) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NOW',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Title
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Location (if available)
                      if (event.location != null && event.location!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Travel time indicator (if present)
                      if (event.travelTimeMinutes != null && event.travelTimeMinutes! > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.travelTimeMinutes} min travel',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Duration indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatDuration(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get icon based on event type
  IconData _getEventIcon() {
    switch (event.eventType) {
      case 'service':
        return Icons.church;
      case 'meeting':
        return Icons.groups;
      case 'pastoral_visit':
        return Icons.home_outlined;
      case 'personal':
        return Icons.person;
      case 'work':
        return Icons.work_outline;
      case 'family':
        return Icons.family_restroom;
      case 'blocked_time':
        return Icons.block;
      default:
        return Icons.event;
    }
  }

  /// Get color based on event type
  Color _getEventColor() {
    switch (event.eventType) {
      case 'service':
        return const Color(0xFF2563EB); // Primary blue
      case 'meeting':
        return const Color(0xFF8B5CF6); // Purple
      case 'pastoral_visit':
        return const Color(0xFF10B981); // Success green
      case 'personal':
        return const Color(0xFF06B6D4); // Cyan
      case 'work':
        return const Color(0xFF6B7280); // Gray
      case 'family':
        return const Color(0xFFEC4899); // Pink
      case 'blocked_time':
        return const Color(0xFFEF4444); // Error red
      default:
        return const Color(0xFF2563EB); // Default primary
    }
  }

  /// Format time range for display
  ({String start, String end}) _formatTimeRange() {
    final timeFormat = DateFormat('h:mm a'); // e.g., "9:00 AM"
    return (
      start: timeFormat.format(event.startDateTime),
      end: timeFormat.format(event.endDateTime),
    );
  }

  /// Format duration for display
  String _formatDuration() {
    final minutes = event.durationMinutes;
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}

// Usage example:
//
// EventCard(
//   event: CalendarEventEntity(
//     id: '1',
//     userId: 'user1',
//     title: 'Sunday Morning Service',
//     startDateTime: DateTime(2025, 12, 10, 9, 0),
//     endDateTime: DateTime(2025, 12, 10, 10, 30),
//     eventType: 'service',
//     location: 'Main Sanctuary',
//     createdAt: DateTime.now(),
//     updatedAt: DateTime.now(),
//     localUpdatedAt: DateTime.now().millisecondsSinceEpoch,
//   ),
// )
