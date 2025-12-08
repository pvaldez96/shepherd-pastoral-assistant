import 'package:flutter/material.dart';

/// Calendar screen (placeholder)
///
/// This screen will display events and schedule for the pastor.
/// Currently a placeholder - will be expanded with calendar features.
///
/// Future features:
/// - Month/week/day calendar views
/// - Event creation and editing
/// - Event categories (services, meetings, visits, etc.)
/// - Recurring events
/// - Event reminders
/// - Integration with tasks
/// - Export to external calendars (Google Calendar, etc.)
///
/// Note: AppBar is provided by MainScaffold, not this screen
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 64,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Calendar',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Calendar and events are coming soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Feature list
            Text(
              'This feature will help you:\n\n'
              '• View monthly, weekly, and daily schedules\n'
              '• Create and manage events\n'
              '• Set recurring events\n'
              '• Get event reminders\n'
              '• Sync with external calendars',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Usage with go_router:
// context.go('/calendar')
