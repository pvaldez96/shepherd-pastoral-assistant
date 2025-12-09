// lib/presentation/settings/widgets/time_range_field.dart

import 'package:flutter/material.dart';

/// A widget for selecting a time range (start time and end time)
///
/// Features:
/// - Two time pickers: start time and end time
/// - Display format: "HH:MM" (24-hour)
/// - Storage format: "HH:MM" string
/// - Icon for visual identification
/// - Clear button to reset times
/// - Validates that end time is after start time
///
/// Usage:
/// ```dart
/// TimeRangeField(
///   label: 'Work Hours',
///   icon: Icons.work_outline,
///   startTime: '09:00',
///   endTime: '17:00',
///   onChanged: (start, end) {
///     print('Work hours: $start - $end');
///   },
/// )
/// ```
class TimeRangeField extends StatefulWidget {
  /// Label for this time range field
  final String label;

  /// Icon to display
  final IconData icon;

  /// Initial start time in format "HH:MM" or null
  final String? startTime;

  /// Initial end time in format "HH:MM" or null
  final String? endTime;

  /// Callback when times change
  /// Parameters: (startTime, endTime) - both can be null
  final Function(String?, String?) onChanged;

  const TimeRangeField({
    super.key,
    required this.label,
    required this.icon,
    this.startTime,
    this.endTime,
    required this.onChanged,
  });

  @override
  State<TimeRangeField> createState() => _TimeRangeFieldState();
}

class _TimeRangeFieldState extends State<TimeRangeField> {
  String? _startTime;
  String? _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: const Color(0xFF6B7280), // Text secondary
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827), // Text primary
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Time pickers row
        Row(
          children: [
            // Start time picker
            Expanded(
              child: _buildTimePicker(
                context,
                label: 'Start',
                value: _startTime,
                onTap: () => _pickTime(context, isStart: true),
              ),
            ),
            const SizedBox(width: 8),

            // Separator
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward,
                size: 20,
                color: Color(0xFF9CA3AF), // Text tertiary
              ),
            ),
            const SizedBox(width: 8),

            // End time picker
            Expanded(
              child: _buildTimePicker(
                context,
                label: 'End',
                value: _endTime,
                onTap: () => _pickTime(context, isStart: false),
              ),
            ),

            // Clear button
            if (_startTime != null || _endTime != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: _clearTimes,
                icon: const Icon(Icons.clear),
                color: const Color(0xFF6B7280),
                tooltip: 'Clear times',
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Build a single time picker button
  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFE5E7EB), // Border color
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280), // Text secondary
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? '--:--',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: value != null
                              ? const Color(0xFF111827) // Text primary
                              : const Color(0xFF9CA3AF), // Text tertiary
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time,
              size: 20,
              color: const Color(0xFF6B7280), // Text secondary
            ),
          ],
        ),
      ),
    );
  }

  /// Show time picker dialog
  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    // Get initial time
    TimeOfDay? initialTime;
    if (isStart && _startTime != null) {
      initialTime = _parseTimeString(_startTime!);
    } else if (!isStart && _endTime != null) {
      initialTime = _parseTimeString(_endTime!);
    }

    // Show picker
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB), // Shepherd primary blue
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString = _formatTimeOfDay(picked);

      setState(() {
        if (isStart) {
          _startTime = timeString;
          // Validate: if end time exists and is before start, clear it
          if (_endTime != null) {
            final start = _parseTimeString(_startTime!);
            final end = _parseTimeString(_endTime!);
            if (start != null && end != null && _isAfter(start, end)) {
              _endTime = null; // Clear invalid end time
            }
          }
        } else {
          _endTime = timeString;
          // Validate: end time should be after start time
          if (_startTime != null) {
            final start = _parseTimeString(_startTime!);
            final end = _parseTimeString(_endTime!);
            if (start != null && end != null && _isAfter(start, end)) {
              // Show error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('End time must be after start time'),
                  backgroundColor: Color(0xFFEF4444), // Error red
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
              _endTime = null; // Clear invalid end time
            }
          }
        }
      });

      // Notify parent
      widget.onChanged(_startTime, _endTime);
    }
  }

  /// Clear both times
  void _clearTimes() {
    setState(() {
      _startTime = null;
      _endTime = null;
    });
    widget.onChanged(null, null);
  }

  /// Format TimeOfDay to "HH:MM" string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Parse "HH:MM" string to TimeOfDay
  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Invalid format
    }
    return null;
  }

  /// Check if time1 is after time2
  bool _isAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute > time2.minute) return true;
    return false;
  }
}

// Usage examples:
//
// Basic usage:
// ```dart
// TimeRangeField(
//   label: 'Office Hours',
//   icon: Icons.business,
//   startTime: '09:00',
//   endTime: '17:00',
//   onChanged: (start, end) {
//     print('Office hours updated: $start to $end');
//   },
// )
// ```
//
// Without initial values:
// ```dart
// TimeRangeField(
//   label: 'Lunch Break',
//   icon: Icons.restaurant,
//   startTime: null,
//   endTime: null,
//   onChanged: (start, end) {
//     if (start != null && end != null) {
//       saveLunchHours(start, end);
//     }
//   },
// )
// ```
//
// With async save:
// ```dart
// TimeRangeField(
//   label: 'Focus Time',
//   icon: Icons.psychology,
//   startTime: settings.focusStart,
//   endTime: settings.focusEnd,
//   onChanged: (start, end) async {
//     await repository.updateFocusHours(
//       settingsId: settings.id,
//       start: start,
//       end: end,
//     );
//     showSnackBar('Focus hours saved');
//   },
// )
// ```
