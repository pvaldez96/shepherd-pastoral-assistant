import 'package:flutter/material.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/contact_log.dart';
import 'widgets/person_category_badge.dart';
import 'widgets/contact_history_tile.dart';
import 'widgets/contact_log_bottom_sheet.dart';

/// Person detail screen - displays full information for a single person
///
/// Features:
/// - Header: Name, category badge, photo placeholder
/// - Contact info: Phone, email (tappable to call/email)
/// - Status: Last contact date, days since, next recommended contact
/// - Contact history: Timeline of logged contacts (type, date, notes)
/// - Related items (placeholders): Tasks, Events, Notes
/// - Quick actions: Call, Email, Text, Log Contact, Create Task, Add Note
/// - Edit button in app bar
/// - Scrollable content
///
/// Design:
/// - Background: #F9FAFB
/// - White card sections with elevation 1
/// - 16px padding between sections
/// - Shepherd design system colors
///
/// State Management:
/// - TODO: Use Riverpod providers for real-time updates
/// - For now, accepts PersonEntity as parameter
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => PersonDetailScreen(personId: person.id),
///   ),
/// );
/// ```
class PersonDetailScreen extends StatefulWidget {
  final String personId;

  const PersonDetailScreen({
    super.key,
    required this.personId,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: Load person data from Riverpod provider
    // final personAsync = ref.watch(personProvider(widget.personId));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(context),
      body: _buildPlaceholderView(),
    );
  }

  /// Build app bar with edit button
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Person Details'),
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // TODO: Navigate to edit screen
            // context.push('/people/${widget.personId}/edit');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit person feature coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          tooltip: 'Edit person',
        ),
      ],
    );
  }

  /// Build placeholder view
  Widget _buildPlaceholderView() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Person Detail',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'UI component created!\nData integration coming next.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Person ID: ${widget.personId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build complete person detail view with data
  Widget _buildPersonDetail(PersonEntity person, List<ContactLogEntity> contactLogs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card with photo, name, category
          _buildHeaderCard(person),
          const SizedBox(height: 16),

          // Contact information card
          _buildContactInfoCard(person),
          const SizedBox(height: 16),

          // Status card (last contact, days since, next contact)
          _buildStatusCard(person),
          const SizedBox(height: 16),

          // Quick actions
          _buildQuickActions(person),
          const SizedBox(height: 16),

          // Contact history
          _buildContactHistory(contactLogs),
          const SizedBox(height: 16),

          // Related items (placeholder)
          _buildRelatedItems(),

          // Extra padding at bottom
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Build header card with photo, name, and category
  Widget _buildHeaderCard(PersonEntity person) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile photo placeholder (circular avatar)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getInitials(person.name),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              person.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Category badge
            PersonCategoryBadge(category: person.category),
          ],
        ),
      ),
    );
  }

  /// Build contact information card
  Widget _buildContactInfoCard(PersonEntity person) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Phone
            if (person.phone != null) ...[
              _buildContactInfoTile(
                icon: Icons.phone,
                label: 'Phone',
                value: person.phone!,
                onTap: () {
                  // TODO: Launch phone dialer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Phone: ${person.phone}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

            // Email
            if (person.email != null) ...[
              _buildContactInfoTile(
                icon: Icons.email,
                label: 'Email',
                value: person.email!,
                onTap: () {
                  // TODO: Launch email client
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email: ${person.email}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],

            // No contact info message
            if (person.phone == null && person.email == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No contact information available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build contact info tile (phone or email)
  Widget _buildContactInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// Build status card (pastoral care status)
  Widget _buildStatusCard(PersonEntity person) {
    final daysSince = person.daysSinceLastContact;
    final isOverdue = person.isOverdue();
    final threshold = person.getContactThreshold();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pastoral Care Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Last contact date
            _buildStatusRow(
              label: 'Last Contact',
              value: person.lastContactDate != null
                  ? _formatDate(person.lastContactDate!)
                  : 'Never contacted',
              icon: Icons.calendar_today,
              color: isOverdue ? const Color(0xFFEF4444) : Colors.grey.shade600,
            ),
            const SizedBox(height: 12),

            // Days since contact
            if (daysSince != null)
              _buildStatusRow(
                label: 'Days Since Contact',
                value: '$daysSince ${daysSince == 1 ? 'day' : 'days'}',
                icon: Icons.schedule,
                color: isOverdue ? const Color(0xFFEF4444) : Colors.grey.shade600,
              ),
            const SizedBox(height: 12),

            // Contact frequency threshold
            _buildStatusRow(
              label: 'Contact Frequency',
              value: 'Every $threshold ${threshold == 1 ? 'day' : 'days'}',
              icon: Icons.repeat,
              color: Colors.grey.shade600,
            ),

            // Status indicator
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOverdue
                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                    : const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning : Icons.check_circle,
                    color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOverdue
                          ? 'Overdue - contact needed'
                          : 'Up to date',
                      style: TextStyle(
                        color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
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

  /// Build status row
  Widget _buildStatusRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ),
      ],
    );
  }

  /// Build quick actions section
  Widget _buildQuickActions(PersonEntity person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.add_comment,
                label: 'Log Contact',
                color: const Color(0xFF2563EB),
                onPressed: () {
                  showContactLogBottomSheet(
                    context: context,
                    person: person,
                    onSave: (contactData) async {
                      // TODO: Save to repository
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.task_alt,
                label: 'Create Task',
                color: const Color(0xFF10B981),
                onPressed: () {
                  // TODO: Navigate to task creation with person pre-filled
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Create task feature coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build contact history section
  Widget _buildContactHistory(List<ContactLogEntity> contactLogs) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contact History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (contactLogs.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${contactLogs.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact log timeline
            if (contactLogs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No contact history yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              )
            else
              ...contactLogs.asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;
                return ContactHistoryTile(
                  contactLog: log,
                  isFirst: index == 0,
                  isLast: index == contactLogs.length - 1,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  /// Build related items section (placeholder)
  Widget _buildRelatedItems() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Related Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tasks, Events, and Notes related to this person will appear here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
