import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/contact_log.dart';

/// Timeline tile widget for displaying contact log entries
///
/// Features:
/// - Contact type icon (phone, email, visit, etc.)
/// - Contact date in readable format
/// - Duration if available
/// - Notes preview (expandable)
/// - Timeline connector line between entries
/// - Color-coded by contact type
///
/// Design:
/// - Left: Icon in colored circle
/// - Center: Timeline connector line
/// - Right: Contact details card
/// - Tap to expand/collapse full notes
/// - Card elevation: 1
/// - Border radius: 8px
///
/// Usage:
/// ```dart
/// ContactHistoryTile(
///   contactLog: log,
///   isFirst: index == 0,
///   isLast: index == logs.length - 1,
/// )
/// ```
class ContactHistoryTile extends StatefulWidget {
  final ContactLogEntity contactLog;
  final bool isFirst;
  final bool isLast;

  const ContactHistoryTile({
    super.key,
    required this.contactLog,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<ContactHistoryTile> createState() => _ContactHistoryTileState();
}

class _ContactHistoryTileState extends State<ContactHistoryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final contactLog = widget.contactLog;
    final typeInfo = _getContactTypeInfo(contactLog.contactType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Icon and timeline connector
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Top connector line (invisible if first)
                if (!widget.isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: Colors.grey.shade300,
                  ),

                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeInfo.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    typeInfo.icon,
                    size: 20,
                    color: typeInfo.color,
                  ),
                ),

                // Bottom connector line (invisible if last)
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),

          // Right side: Contact details card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  onTap: () {
                    if (contactLog.notes != null && contactLog.notes!.isNotEmpty) {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: Type label and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Contact type label
                            Text(
                              typeInfo.label,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                            ),

                            // Date
                            Text(
                              _formatDate(contactLog.contactDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),

                        // Duration (if available)
                        if (contactLog.durationMinutes != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(contactLog.durationMinutes!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ],

                        // Notes (if available)
                        if (contactLog.notes != null && contactLog.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            contactLog.notes!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                            maxLines: _isExpanded ? null : 2,
                            overflow: _isExpanded ? null : TextOverflow.ellipsis,
                          ),

                          // Expand/collapse indicator
                          if (contactLog.notes!.length > 100 || contactLog.notes!.contains('\n')) ...[
                            const SizedBox(height: 4),
                            Text(
                              _isExpanded ? 'Show less' : 'Show more',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get contact type information (icon, label, color)
  ({IconData icon, String label, Color color}) _getContactTypeInfo(String type) {
    switch (type.toLowerCase()) {
      case 'visit':
        return (
          icon: Icons.home,
          label: 'Home Visit',
          color: const Color(0xFF2563EB), // Blue
        );
      case 'call':
        return (
          icon: Icons.phone,
          label: 'Phone Call',
          color: const Color(0xFF10B981), // Green
        );
      case 'email':
        return (
          icon: Icons.email,
          label: 'Email',
          color: const Color(0xFF8B5CF6), // Purple
        );
      case 'text':
        return (
          icon: Icons.message,
          label: 'Text Message',
          color: const Color(0xFF14B8A6), // Teal
        );
      case 'in_person':
        return (
          icon: Icons.person,
          label: 'In Person',
          color: const Color(0xFFF59E0B), // Orange
        );
      case 'other':
      default:
        return (
          icon: Icons.chat,
          label: 'Other Contact',
          color: const Color(0xFF6B7280), // Gray
        );
    }
  }

  /// Format date for display
  ///
  /// Shows:
  /// - "Today" for today's date
  /// - "Yesterday" for yesterday
  /// - "MMM d, yyyy" for other dates (e.g., "Dec 9, 2024")
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  /// Format duration in minutes to human-readable string
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }

    return '$hours ${hours == 1 ? 'hr' : 'hrs'} $remainingMinutes min';
  }
}
