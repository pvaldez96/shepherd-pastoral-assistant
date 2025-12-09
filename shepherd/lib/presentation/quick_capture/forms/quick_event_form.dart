import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/calendar_event.dart';
import '../../../presentation/calendar/providers/calendar_event_providers.dart';

/// Quick Event Form - Comprehensive fields for complete event creation
///
/// This form includes ALL fields from the full event form screen,
/// displayed in a scrollable bottom sheet for quick capture.
///
/// Fields:
/// - Title (required, auto-focus)
/// - Description (text area)
/// - Location (text field)
/// - Start Date & Time (required)
/// - End Date & Time (required)
/// - Event Type (dropdown, required)
/// - Energy Drain (low/medium/high chips)
/// - Is Recurring (toggle)
/// - Recurrence Pattern (if recurring - coming soon)
/// - Travel Time Minutes (number input)
/// - Is Moveable (toggle)
/// - Requires Preparation (toggle)
/// - Preparation Buffer Hours (if requires prep)
/// - Person Link (optional - coming soon)
///
/// Features:
/// - Scrollable form that works in DraggableScrollableSheet
/// - Auto-focus on title field
/// - Smart defaults (end time = start + 1 hour)
/// - Keyboard-friendly with proper text input actions
/// - Haptic feedback on save
/// - Loading state while saving
/// - Complete validation
/// - Error handling with snackbar
/// - Follows Shepherd design system
class QuickEventForm extends ConsumerStatefulWidget {
  const QuickEventForm({super.key});

  @override
  ConsumerState<QuickEventForm> createState() => _QuickEventFormState();
}

class _QuickEventFormState extends ConsumerState<QuickEventForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _travelTimeController = TextEditingController();
  final _preparationBufferController = TextEditingController();

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String? _selectedEventType;
  String _energyDrain = 'medium';
  bool _isMoveable = true;
  bool _isRecurring = false;
  bool _requiresPreparation = false;
  bool _isSaving = false;

  // Event type options matching the full form
  static const Map<String, String> _eventTypeOptions = {
    'service': 'Worship Service',
    'meeting': 'Meeting',
    'pastoral_visit': 'Pastoral Visit',
    'personal': 'Personal',
    'work': 'Work',
    'family': 'Family',
    'blocked_time': 'Blocked Time',
  };

  // Energy drain options
  static const Map<String, EnergyInfo> _energyDrainOptions = {
    'low': EnergyInfo('Low', Color(0xFF10B981)),
    'medium': EnergyInfo('Medium', Color(0xFFF59E0B)),
    'high': EnergyInfo('High', Color(0xFFEF4444)),
  };

  @override
  void initState() {
    super.initState();
    // Default end time is 1 hour after start
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _travelTimeController.dispose();
    _preparationBufferController.dispose();
    super.dispose();
  }

  /// Handle form submission
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Combine date and time to create DateTime objects
    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    // Validate that end is after start
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date/time must be after start date/time'),
          backgroundColor: Color(0xFFEF4444), // Error red
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Get current user ID from auth state
      // For now, use a placeholder - this should come from auth
      const userId = 'current-user-id';

      // Parse optional numeric fields
      final travelTimeMinutes = _travelTimeController.text.isNotEmpty
          ? int.tryParse(_travelTimeController.text)
          : null;

      final preparationBufferHours = _requiresPreparation && _preparationBufferController.text.isNotEmpty
          ? int.tryParse(_preparationBufferController.text)
          : null;

      // Create event entity
      final now = DateTime.now();
      final event = CalendarEventEntity(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        eventType: _selectedEventType!,
        isRecurring: _isRecurring,
        recurrencePattern: null, // TODO: Implement recurrence pattern editor
        travelTimeMinutes: travelTimeMinutes,
        energyDrain: _energyDrain,
        isMoveable: _isMoveable,
        requiresPreparation: _requiresPreparation,
        preparationBufferHours: preparationBufferHours,
        personId: null, // TODO: Add person picker
        createdAt: now,
        updatedAt: now,
        localUpdatedAt: now.millisecondsSinceEpoch,
      );

      // Save to repository
      await ref.read(calendarEventRepositoryProvider).createEvent(event);

      // Haptic feedback
      HapticFeedback.mediumImpact();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Color(0xFF10B981), // Success green
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Close the bottom sheet
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create event: $error'),
            backgroundColor: const Color(0xFFEF4444), // Error red
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show date and time picker for start
  Future<void> _selectStartDateTime() async {
    // First pick date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (mounted) {
      // Then pick time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _startTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF2563EB),
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _startDate = pickedDate;
          _startTime = pickedTime;
          // If end is before start, update end to maintain 1 hour duration
          if (_endDate.isBefore(pickedDate)) {
            _endDate = pickedDate;
          }
        });
      }
    }
  }

  /// Show date and time picker for end
  Future<void> _selectEndDateTime() async {
    // First pick date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    if (mounted) {
      // Then pick time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF2563EB),
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _endDate = pickedDate;
          _endTime = pickedTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // Basic Information Section
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 12),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildLocationField(),
            const SizedBox(height: 24),

            // Date & Time Section
            _buildSectionHeader('Date & Time'),
            const SizedBox(height: 12),
            _buildStartDateTimeField(),
            const SizedBox(height: 16),
            _buildEndDateTimeField(),
            const SizedBox(height: 24),

            // Event Details Section
            _buildSectionHeader('Event Details'),
            const SizedBox(height: 12),
            _buildEventTypeField(),
            const SizedBox(height: 16),
            _buildEnergyDrainSelector(),
            const SizedBox(height: 24),

            // Options Section
            _buildSectionHeader('Options'),
            const SizedBox(height: 12),
            _buildMoveableCheckbox(),
            _buildRecurringCheckbox(),
            const SizedBox(height: 16),
            _buildTravelTimeField(),
            const SizedBox(height: 16),
            _buildPreparationCheckbox(),
            if (_requiresPreparation) ...[
              const SizedBox(height: 16),
              _buildPreparationBufferField(),
            ],
            const SizedBox(height: 32),

            // Save button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.event,
            color: Color(0xFF10B981),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Quick Event',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
          ),
        ),
      ],
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Build title field
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Title *',
        hintText: 'What is the event?',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an event title';
        }
        if (value.length > 200) {
          return 'Title must be 200 characters or less';
        }
        return null;
      },
    );
  }

  /// Build description field
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      minLines: 3,
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Add details (optional)',
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.newline,
    );
  }

  /// Build location field
  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Location',
        hintText: 'Enter location (optional)',
        prefixIcon: const Icon(Icons.location_on_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  /// Build start date/time field
  Widget _buildStartDateTimeField() {
    return InkWell(
      onTap: _selectStartDateTime,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Start Date & Time *',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          suffixIcon: const Icon(Icons.access_time, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          _formatDateTime(_startDate, _startTime),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade900,
          ),
        ),
      ),
    );
  }

  /// Build end date/time field
  Widget _buildEndDateTimeField() {
    return InkWell(
      onTap: _selectEndDateTime,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'End Date & Time *',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          suffixIcon: const Icon(Icons.access_time, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          _formatDateTime(_endDate, _endTime),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade900,
          ),
        ),
      ),
    );
  }

  /// Build event type field
  Widget _buildEventTypeField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedEventType,
      decoration: InputDecoration(
        labelText: 'Event Type *',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: _eventTypeOptions.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedEventType = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an event type';
        }
        return null;
      },
    );
  }

  /// Build energy drain selector
  Widget _buildEnergyDrainSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Energy Drain',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _energyDrainOptions.entries.map((entry) {
            final isSelected = _energyDrain == entry.key;
            final info = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key == 'high' ? 0 : 8,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _energyDrain = entry.key;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? info.color : Colors.white,
                      border: Border.all(
                        color: isSelected ? info.color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      info.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build moveable checkbox
  Widget _buildMoveableCheckbox() {
    return CheckboxListTile(
      value: _isMoveable,
      onChanged: (value) {
        setState(() {
          _isMoveable = value ?? true;
        });
      },
      title: const Text('Is Moveable'),
      subtitle: const Text('Can this event be rescheduled if needed?'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF2563EB),
    );
  }

  /// Build recurring checkbox
  Widget _buildRecurringCheckbox() {
    return CheckboxListTile(
      value: _isRecurring,
      onChanged: (value) {
        setState(() {
          _isRecurring = value ?? false;
        });
      },
      title: const Text('Is Recurring'),
      subtitle: const Text('Does this event repeat? (Pattern setup coming soon)'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF2563EB),
    );
  }

  /// Build travel time field
  Widget _buildTravelTimeField() {
    return TextFormField(
      controller: _travelTimeController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Travel Time (minutes)',
        hintText: 'e.g., 30',
        prefixIcon: const Icon(Icons.directions_car_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final minutes = int.tryParse(value);
          if (minutes == null || minutes < 0) {
            return 'Please enter a valid positive number';
          }
        }
        return null;
      },
    );
  }

  /// Build preparation checkbox
  Widget _buildPreparationCheckbox() {
    return CheckboxListTile(
      value: _requiresPreparation,
      onChanged: (value) {
        setState(() {
          _requiresPreparation = value ?? false;
        });
      },
      title: const Text('Requires Preparation'),
      subtitle: const Text('Does this event need preparation time?'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF2563EB),
    );
  }

  /// Build preparation buffer field
  Widget _buildPreparationBufferField() {
    return TextFormField(
      controller: _preparationBufferController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Preparation Buffer (hours) *',
        hintText: 'e.g., 2',
        prefixIcon: const Icon(Icons.edit_calendar_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (_requiresPreparation) {
          if (value == null || value.isEmpty) {
            return 'Please enter preparation hours';
          }
          final hours = int.tryParse(value);
          if (hours == null || hours < 1) {
            return 'Please enter a valid positive number';
          }
        }
        return null;
      },
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981), // Success green
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Save Event',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// Format date and time for display
  String _formatDateTime(DateTime date, TimeOfDay time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (dateOnly == today) {
      dateStr = 'Today';
    } else if (dateOnly == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = DateFormat('EEE, MMM d').format(date);
    }

    // Format time
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';

    return '$dateStr at $hour:$minute $period';
  }
}

/// Energy information holder
class EnergyInfo {
  final String label;
  final Color color;

  const EnergyInfo(this.label, this.color);
}
