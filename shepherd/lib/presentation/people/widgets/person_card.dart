import 'package:flutter/material.dart';
import '../../../domain/entities/person.dart';
import 'person_category_badge.dart';

/// Reusable person card widget that displays individual person information
///
/// Features:
/// - Person name with category badge
/// - Last contact date with days since contact
/// - Overdue indicator (red) for people needing attention
/// - Up-to-date indicator (green) for recent contacts
/// - Quick action buttons: Call, Log Contact
/// - Tap card to navigate to person detail screen
/// - InkWell ripple effect for touch feedback
///
/// Design:
/// - Card elevation: 2
/// - Border radius: 12px
/// - Padding: 16px
/// - Overdue: Red left border (3px) and red badge
/// - Up to date: Green indicator
/// - Minimum 44x44 touch targets
///
/// Accessibility:
/// - Semantic labels for screen readers
/// - Proper button hints
/// - Touch target size compliance
///
/// Usage:
/// ```dart
/// PersonCard(
///   person: person,
///   onTap: () => context.push('/people/${person.id}'),
///   onLogContact: () => showContactLogSheet(context, person),
/// )
/// ```
class PersonCard extends StatelessWidget {
  final PersonEntity person;
  final VoidCallback? onTap;
  final VoidCallback? onLogContact;

  const PersonCard({
    super.key,
    required this.person,
    this.onTap,
    this.onLogContact,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = person.isOverdue();
    final daysSince = person.daysSinceLastContact;

    return Semantics(
      label: 'Person: ${person.name}, ${_getCategoryLabel()}, ${_getContactStatusLabel()}',
      button: true,
      hint: 'Tap to view person details',
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Overdue indicator as left border
          side: BorderSide(
            color: isOverdue ? const Color(0xFFEF4444) : Colors.transparent,
            width: isOverdue ? 3 : 0,
          ),
        ),
        child: InkWell(
          onTap: onTap ??
              () {
                // Default behavior: show placeholder message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Person detail screen coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Person avatar/initial circle
                _buildAvatar(context),
                const SizedBox(width: 12),

                // Main content area (name, contact info, status)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and category row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              person.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade900,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PersonCategoryBadge(category: person.category),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Last contact status
                      _buildContactStatus(context, daysSince, isOverdue),

                      const SizedBox(height: 12),

                      // Quick action buttons row
                      Row(
                        children: [
                          // Call button (if phone available)
                          if (person.phone != null) ...[
                            _buildCallButton(context),
                            const SizedBox(width: 8),
                          ],

                          // Log Contact button
                          _buildLogContactButton(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build person avatar circle with initials
  Widget _buildAvatar(BuildContext context) {
    final initials = _getInitials(person.name);
    final isOverdue = person.isOverdue();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isOverdue
            ? const Color(0xFFEF4444).withValues(alpha: 0.1) // Red for overdue
            : const Color(0xFF2563EB).withValues(alpha: 0.1), // Blue for normal
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isOverdue
                ? const Color(0xFFEF4444) // Red for overdue
                : const Color(0xFF2563EB), // Blue for normal
          ),
        ),
      ),
    );
  }

  /// Build contact status indicator
  ///
  /// Shows:
  /// - Red badge + "X days overdue" for overdue contacts
  /// - Green badge + "Last contact: X days ago" for up-to-date contacts
  /// - Gray badge + "Never contacted" if no contact logged
  Widget _buildContactStatus(BuildContext context, int? daysSince, bool isOverdue) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (daysSince == null) {
      // Never contacted
      statusColor = Colors.grey.shade600;
      statusIcon = Icons.warning_outlined;
      statusText = 'Never contacted';
    } else if (isOverdue) {
      // Overdue contact
      final threshold = person.getContactThreshold();
      final daysOverdue = daysSince - threshold;
      statusColor = const Color(0xFFEF4444); // Red
      statusIcon = Icons.warning;
      statusText = '$daysOverdue ${daysOverdue == 1 ? 'day' : 'days'} overdue';
    } else {
      // Up to date
      statusColor = const Color(0xFF10B981); // Green
      statusIcon = Icons.check_circle;
      statusText = 'Last contact: $daysSince ${daysSince == 1 ? 'day' : 'days'} ago';
    }

    return Row(
      children: [
        Icon(
          statusIcon,
          size: 16,
          color: statusColor,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build Call button
  ///
  /// Shows phone number. Placeholder for future phone dialer integration.
  /// Only shown if person has a phone number.
  Widget _buildCallButton(BuildContext context) {
    return Semantics(
      label: 'Call ${person.name}',
      button: true,
      hint: 'Shows phone number',
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Add url_launcher dependency and implement phone call
          // final uri = Uri(scheme: 'tel', path: person.phone!);
          // launchUrl(uri);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone: ${person.phone}'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  // TODO: Copy to clipboard
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.phone, size: 16),
        label: const Text('Call'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2563EB),
          side: BorderSide(color: Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(44, 44), // Minimum touch target
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build Log Contact button
  ///
  /// Opens contact log bottom sheet to record a new contact.
  Widget _buildLogContactButton(BuildContext context) {
    return Semantics(
      label: 'Log contact with ${person.name}',
      button: true,
      hint: 'Opens contact log form',
      child: ElevatedButton.icon(
        onPressed: onLogContact ??
            () {
              // Default behavior: show placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact log feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
        icon: const Icon(Icons.add_comment, size: 16),
        label: const Text('Log Contact'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(44, 44), // Minimum touch target
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Get initials from name
  ///
  /// Examples:
  /// - "John Doe" -> "JD"
  /// - "Jane" -> "J"
  /// - "Mary Jane Smith" -> "MS" (first and last)
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();

    // Return first letter of first word and last word
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Get category label for accessibility
  String _getCategoryLabel() {
    return PersonEntity.getCategoryDisplayName(person.category);
  }

  /// Get contact status label for accessibility
  String _getContactStatusLabel() {
    final daysSince = person.daysSinceLastContact;
    if (daysSince == null) return 'never contacted';

    final isOverdue = person.isOverdue();
    if (isOverdue) {
      final threshold = person.getContactThreshold();
      final daysOverdue = daysSince - threshold;
      return '$daysOverdue days overdue';
    } else {
      return 'contacted $daysSince days ago';
    }
  }
}
