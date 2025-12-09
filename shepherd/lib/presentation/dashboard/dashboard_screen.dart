import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'models/dashboard_data.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/event_card.dart';
import 'widgets/task_summary_card.dart';

/// Dashboard screen with multiple view modes
///
/// This is the main screen shown after successful authentication.
/// Supports three view modes: Daily, Weekly, and Monthly.
///
/// Features:
/// - Daily view: Today's schedule with events and tasks
/// - Available time summary
/// - Overdue tasks section
/// - Tomorrow preview
/// - Proper loading, error, and empty states
///
/// Note: AppBar is provided by MainScaffold, not this screen
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
          _buildViewContent(context, ref),
        ],
      ),
    );
  }

  /// Build content based on the current view
  Widget _buildViewContent(BuildContext context, WidgetRef ref) {
    switch (view) {
      case 'weekly':
        return _buildWeeklyView(context);
      case 'monthly':
        return _buildMonthlyView(context);
      case 'daily':
      default:
        return _buildDailyView(context, ref);
    }
  }

  /// Build Daily View content
  Widget _buildDailyView(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error, ref),
      data: (data) => _buildDailyContent(context, ref, data),
    );
  }

  /// Build the main daily content
  Widget _buildDailyContent(BuildContext context, WidgetRef ref, DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with date
        _buildDateHeader(context),
        const SizedBox(height: 16),

        // Available time summary
        _buildAvailableTimeSummary(context, data),
        const SizedBox(height: 16),

        // Overdue tasks (if any)
        if (data.hasOverdueTasks) ...[
          _buildOverdueSection(context, ref, data),
          const SizedBox(height: 16),
        ],

        // Fixed Commitments section
        _buildFixedCommitmentsSection(context, data),
        const SizedBox(height: 16),

        // Today's tasks section
        _buildTodayTasksSection(context, ref, data),
        const SizedBox(height: 16),

        // Tomorrow preview
        _buildTomorrowPreview(context, ref),
      ],
    );
  }

  /// Build date header
  Widget _buildDateHeader(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMM d').format(now);

    return Semantics(
      label: 'Today is $formattedDate',
      child: Text(
        'Today - $formattedDate',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2563EB),
            ),
      ),
    );
  }

  /// Build available time summary card
  Widget _buildAvailableTimeSummary(BuildContext context, DashboardData data) {
    final availableTime = data.formattedAvailableTime;
    final hasTime = data.totalAvailableMinutes > 0;

    return Semantics(
      label: 'Available time today: $availableTime',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: hasTime ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasTime ? const Color(0xFF10B981) : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      availableTime,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: hasTime ? const Color(0xFF10B981) : Colors.grey.shade700,
                          ),
                    ),
                    Text(
                      'available today',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build overdue tasks section
  Widget _buildOverdueSection(BuildContext context, WidgetRef ref, DashboardData data) {
    return Semantics(
      label: 'Overdue tasks: ${data.overdueTasks.length} tasks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 8),
              Text(
                'OVERDUE (${data.overdueTasks.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...data.overdueTasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskSummaryCard(
                  task: task,
                  isOverdue: true,
                ),
              )),
        ],
      ),
    );
  }

  /// Build fixed commitments section (calendar events)
  Widget _buildFixedCommitmentsSection(BuildContext context, DashboardData data) {
    return Semantics(
      label: 'Fixed commitments: ${data.todayEvents.length} events',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                'Fixed Commitments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.todayEvents.isEmpty)
            _buildEmptyState(
              context,
              'No events scheduled',
              'Your day is clear',
              Icons.event_available,
            )
          else
            ...data.todayEvents.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EventCard(event: event),
                )),
        ],
      ),
    );
  }

  /// Build today's tasks section
  Widget _buildTodayTasksSection(BuildContext context, WidgetRef ref, DashboardData data) {
    return Semantics(
      label: 'Today\'s tasks: ${data.todayTasks.length} tasks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                'Today\'s Tasks (${data.todayTasks.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.todayTasks.isEmpty)
            _buildEmptyState(
              context,
              'No tasks due today',
              'Enjoy your clear schedule',
              Icons.check_circle,
            )
          else
            ...data.todayTasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TaskSummaryCard(task: task),
                )),
        ],
      ),
    );
  }

  /// Build tomorrow preview
  Widget _buildTomorrowPreview(BuildContext context, WidgetRef ref) {
    // For now, just show a simple placeholder
    // TODO: Add tomorrow's events and tasks count from a provider
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.arrow_forward,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tomorrow: Check upcoming tasks and events',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state for sections
  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFEF4444),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(dashboardDataProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Weekly View content (placeholder)
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
      ],
    );
  }

  /// Build Monthly View content (placeholder)
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

// Usage with go_router:
//
// Navigate to different views:
// - context.go('/dashboard?view=daily')
// - context.go('/dashboard?view=weekly')
// - context.go('/dashboard?view=monthly')
//
// The view parameter is extracted in app_router.dart and passed to this widget
