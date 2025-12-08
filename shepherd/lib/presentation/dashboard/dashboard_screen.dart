import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard screen with multiple view modes
///
/// This is the main screen shown after successful authentication.
/// Supports three view modes: Daily, Weekly, and Monthly.
///
/// Features:
/// - View parameter from route (daily|weekly|monthly)
/// - Different content based on view mode
/// - Welcome message with user info
/// - Quick actions section
/// - Placeholder for future dashboard widgets
///
/// Note: AppBar is provided by MainScaffold, not this screen
///
/// Future features:
/// - Daily view: Today's tasks and events
/// - Weekly view: Week overview with tasks and events
/// - Monthly view: Month calendar with key dates
/// - Quick access to modules
/// - Upcoming deadlines
/// - Recent activities
class DashboardScreen extends ConsumerWidget {
  final String view;

  const DashboardScreen({
    super.key,
    this.view = 'daily',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // View-specific content
          _buildViewContent(context),
        ],
      ),
    );
  }

  /// Build content based on the current view
  Widget _buildViewContent(BuildContext context) {
    switch (view) {
      case 'weekly':
        return _buildWeeklyView(context);
      case 'monthly':
        return _buildMonthlyView(context);
      case 'daily':
      default:
        return _buildDailyView(context);
    }
  }

  /// Build Daily View content
  Widget _buildDailyView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome card
        _buildWelcomeCard(
          context,
          title: 'Today',
          subtitle: _getFormattedDate(),
          icon: Icons.today,
        ),
        const SizedBox(height: 16),

        // Today's tasks section (placeholder)
        _buildSectionCard(
          context,
          title: 'Today\'s Tasks',
          icon: Icons.check_box_outlined,
          iconColor: const Color(0xFF2563EB),
          content: _buildPlaceholderContent(
            context,
            'No tasks for today',
            'Your tasks for today will appear here',
          ),
        ),
        const SizedBox(height: 16),

        // Today's events section (placeholder)
        _buildSectionCard(
          context,
          title: 'Today\'s Events',
          icon: Icons.event,
          iconColor: const Color(0xFF10B981),
          content: _buildPlaceholderContent(
            context,
            'No events today',
            'Your scheduled events will appear here',
          ),
        ),
        const SizedBox(height: 16),

        // Quick actions
        _buildQuickActionsCard(context),
      ],
    );
  }

  /// Build Weekly View content
  Widget _buildWeeklyView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome card
        _buildWelcomeCard(
          context,
          title: 'This Week',
          subtitle: _getWeekRange(),
          icon: Icons.view_week,
        ),
        const SizedBox(height: 16),

        // Week overview (placeholder)
        _buildSectionCard(
          context,
          title: 'Week Overview',
          icon: Icons.calendar_view_week,
          iconColor: const Color(0xFF2563EB),
          content: _buildPlaceholderContent(
            context,
            'Weekly view coming soon',
            'See your tasks and events for the entire week',
          ),
        ),
        const SizedBox(height: 16),

        // Upcoming deadlines
        _buildSectionCard(
          context,
          title: 'Upcoming Deadlines',
          icon: Icons.alarm,
          iconColor: const Color(0xFFF59E0B),
          content: _buildPlaceholderContent(
            context,
            'No upcoming deadlines',
            'Tasks with deadlines this week will appear here',
          ),
        ),
      ],
    );
  }

  /// Build Monthly View content
  Widget _buildMonthlyView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome card
        _buildWelcomeCard(
          context,
          title: 'This Month',
          subtitle: _getMonthName(),
          icon: Icons.calendar_month,
        ),
        const SizedBox(height: 16),

        // Month overview (placeholder)
        _buildSectionCard(
          context,
          title: 'Month Overview',
          icon: Icons.calendar_today,
          iconColor: const Color(0xFF2563EB),
          content: _buildPlaceholderContent(
            context,
            'Monthly view coming soon',
            'See your tasks and events for the entire month',
          ),
        ),
        const SizedBox(height: 16),

        // Key dates
        _buildSectionCard(
          context,
          title: 'Key Dates This Month',
          icon: Icons.star_outline,
          iconColor: const Color(0xFFF59E0B),
          content: _buildPlaceholderContent(
            context,
            'No key dates',
            'Important dates and events will appear here',
          ),
        ),
      ],
    );
  }

  /// Build welcome card
  Widget _buildWelcomeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
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

  /// Build section card
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  /// Build placeholder content
  Widget _buildPlaceholderContent(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build quick actions card
  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.add_task,
              label: 'Add Task',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task creation coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _QuickActionButton(
              icon: Icons.event,
              label: 'Add Event',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event creation coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _QuickActionButton(
              icon: Icons.person_add,
              label: 'Add Contact',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact creation coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Get formatted date (e.g., "Monday, December 7, 2025")
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];

    return '$weekday, $month ${now.day}, ${now.year}';
  }

  /// Get week range (e.g., "Dec 2 - Dec 8, 2025")
  String _getWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final startMonth = months[startOfWeek.month - 1];
    final endMonth = months[endOfWeek.month - 1];

    if (startOfWeek.month == endOfWeek.month) {
      return '$startMonth ${startOfWeek.day} - ${endOfWeek.day}, ${now.year}';
    } else {
      return '$startMonth ${startOfWeek.day} - $endMonth ${endOfWeek.day}, ${now.year}';
    }
  }

  /// Get month name (e.g., "December 2025")
  String _getMonthName() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${months[now.month - 1]} ${now.year}';
  }
}

/// Quick action button widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Usage with go_router:
//
// Navigate to different views:
// - context.go('/dashboard?view=daily')
// - context.go('/dashboard?view=weekly')
// - context.go('/dashboard?view=monthly')
//
// The view parameter is extracted in app_router.dart and passed to this widget
