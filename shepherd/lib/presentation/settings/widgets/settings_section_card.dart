// lib/presentation/settings/widgets/settings_section_card.dart

import 'package:flutter/material.dart';

/// A card widget for grouping related settings
///
/// Features:
/// - Card with 12px border radius (Shepherd design system)
/// - Section title with optional subtitle
/// - Icon for visual identification
/// - White background with elevation
/// - Consistent spacing (16px padding)
///
/// Usage:
/// ```dart
/// SettingsSectionCard(
///   title: 'User Profile',
///   subtitle: 'Manage your personal information',
///   icon: Icons.person_outline,
///   children: [
///     TextField(...),
///     TextField(...),
///   ],
/// )
/// ```
class SettingsSectionCard extends StatelessWidget {
  /// Section title displayed at the top
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Icon displayed next to title
  final IconData icon;

  /// Child widgets to display in the card
  final List<Widget> children;

  const SettingsSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Shepherd design system
      ),
      color: Colors.white, // Surface color
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF2563EB), // Shepherd primary blue
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111827), // Text primary
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6B7280), // Text secondary
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              color: const Color(0xFFE5E7EB), // Border color
            ),
            const SizedBox(height: 16),

            // Section content
            ...children,
          ],
        ),
      ),
    );
  }
}

// Usage examples:
//
// Simple section with text fields:
// ```dart
// SettingsSectionCard(
//   title: 'Account',
//   icon: Icons.manage_accounts,
//   children: [
//     TextField(
//       decoration: InputDecoration(labelText: 'Name'),
//     ),
//     SizedBox(height: 16),
//     TextField(
//       decoration: InputDecoration(labelText: 'Email'),
//     ),
//   ],
// )
// ```
//
// Section with subtitle:
// ```dart
// SettingsSectionCard(
//   title: 'Notifications',
//   subtitle: 'Control how you receive updates',
//   icon: Icons.notifications_outlined,
//   children: [
//     SwitchListTile(
//       title: Text('Push Notifications'),
//       value: true,
//       onChanged: (value) {},
//     ),
//   ],
// )
// ```
