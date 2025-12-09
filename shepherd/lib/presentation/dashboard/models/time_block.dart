/// Represents an available time block (gap between events)
///
/// Used by the dashboard to show available slots for scheduling tasks.
/// Time blocks are calculated by finding gaps between calendar events.
class TimeBlock {
  /// Start time of the available block
  final DateTime startTime;

  /// End time of the available block
  final DateTime endTime;

  const TimeBlock({
    required this.startTime,
    required this.endTime,
  });

  /// Duration of the time block in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// Duration as a formatted string (e.g., "1h 30m")
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Start time formatted as HH:mm (e.g., "09:00")
  String get formattedStartTime {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// End time formatted as HH:mm (e.g., "10:30")
  String get formattedEndTime {
    final hour = endTime.hour.toString().padLeft(2, '0');
    final minute = endTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Time range as a formatted string (e.g., "09:00 - 10:30")
  String get formattedTimeRange => '$formattedStartTime - $formattedEndTime';

  /// Whether this time block is long enough for a task (minimum 15 minutes)
  bool get isUsable => durationMinutes >= 15;

  /// Whether this time block is in the future
  bool get isFuture => startTime.isAfter(DateTime.now());

  /// Whether this time block is currently active (now is within the block)
  bool get isCurrent {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  @override
  String toString() => 'TimeBlock($formattedTimeRange, $formattedDuration)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeBlock &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => Object.hash(startTime, endTime);
}
