import 'package:flutter/material.dart';

/// Colored badge widget for person categories
///
/// Displays a category label with appropriate color coding:
/// - Elder: Blue (#2563EB)
/// - Member: Purple (#8B5CF6)
/// - Visitor: Teal (#14B8A6)
/// - Leadership: Orange (#F59E0B)
/// - Crisis: Red (#EF4444)
/// - Family: Pink (#EC4899)
/// - Other: Gray (#6B7280)
///
/// Features:
/// - Compact design for card layouts
/// - White text on colored background
/// - 6px border radius
/// - Consistent with Shepherd design system
///
/// Usage:
/// ```dart
/// PersonCategoryBadge(category: 'elder')
/// PersonCategoryBadge(category: 'member')
/// ```
class PersonCategoryBadge extends StatelessWidget {
  final String category;

  const PersonCategoryBadge({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final categoryInfo = _getCategoryInfo(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryInfo.color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        categoryInfo.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Get category information (label and color)
  ///
  /// Returns a record with display label and color for each category.
  /// Colors follow Shepherd design system.
  ({String label, Color color}) _getCategoryInfo(String category) {
    switch (category.toLowerCase()) {
      case 'elder':
        return (
          label: 'Elder',
          color: const Color(0xFF2563EB), // Blue - primary color
        );
      case 'member':
        return (
          label: 'Member',
          color: const Color(0xFF8B5CF6), // Purple
        );
      case 'visitor':
        return (
          label: 'Visitor',
          color: const Color(0xFF14B8A6), // Teal
        );
      case 'leadership':
        return (
          label: 'Leadership',
          color: const Color(0xFFF59E0B), // Orange
        );
      case 'crisis':
        return (
          label: 'Crisis',
          color: const Color(0xFFEF4444), // Red
        );
      case 'family':
        return (
          label: 'Family',
          color: const Color(0xFFEC4899), // Pink
        );
      case 'other':
      default:
        return (
          label: 'Other',
          color: const Color(0xFF6B7280), // Gray
        );
    }
  }
}
