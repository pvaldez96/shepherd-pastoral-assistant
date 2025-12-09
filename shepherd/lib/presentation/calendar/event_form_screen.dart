import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/calendar_event.dart';
import 'providers/calendar_event_providers.dart';

/// Calendar event creation and editing form screen
///
/// Features:
/// - Create new event or edit existing event (when event is provided)
/// - Complete form validation with inline error messages
/// - Date and time pickers for start/end datetime
/// - Event type dropdown with all event types
/// - Energy drain and preparation settings
/// - Recurring event toggle (pattern editor not yet implemented)
/// - Travel time and flexibility settings
/// - Auto-validation to ensure end is after start
/// - Proper controller disposal to prevent memory leaks
/// - Mobile-optimized keyboard handling
/// - Accessibility support with semantic labels
///
/// Design System:
/// - Background: #F9FAFB (Shepherd background)
/// - Surface: #FFFFFF (card/form background)
/// - Primary: #2563EB (buttons, selected states)
/// - Success: #10B981 (save confirmation)
/// - Error: #EF4444 (validation errors)
/// - Border radius: 8px for inputs
/// - Spacing: 16px between fields, 24px between sections
/// - Typography: Body 16pt minimum
///
/// Usage:
/// ```dart
/// // Create new event
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const EventFormScreen(),
///   ),
/// );
///
/// // Create event with pre-filled date
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => EventFormScreen(
///       initialDate: DateTime(2024, 12, 25),
///     ),
///   ),
/// );
///
/// // Edit existing event
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => EventFormScreen(event: existingEvent),
///   ),
/// );
/// ```
class EventFormScreen extends ConsumerStatefulWidget {
  /// Optional event for editing mode
  /// If null, screen is in creation mode
  final CalendarEventEntity? event;

  /// Optional initial date for creating new events
  /// Only used when event is null
  final DateTime? initialDate;

  const EventFormScreen({
    super.key,
    this.event,
    this.initialDate,
  });

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  // ============================================================================
  // FORM STATE
  // ============================================================================

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  /// Must be disposed in dispose() method
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _travelTimeController = TextEditingController();
  final _preparationBufferController = TextEditingController();

  // ============================================================================
  // FIELD STATE VARIABLES
  // ============================================================================

  /// Start date (required)
  DateTime? _startDate;

  /// Start time (required)
  TimeOfDay? _startTime;

  /// End date (required)
  DateTime? _endDate;

  /// End time (required)
  TimeOfDay? _endTime;

  /// Selected event type (required)
  String? _selectedEventType;

  /// Energy drain level (required, defaults to medium)
  String _energyDrain = 'medium';

  /// Is event moveable (defaults to true)
  bool _isMoveable = true;

  /// Is event recurring (defaults to false)
  bool _isRecurring = false;

  /// Requires preparation (defaults to false)
  bool _requiresPreparation = false;

  /// Form submission state
  bool _isSubmitting = false;

  // ============================================================================
  // EVENT TYPE OPTIONS
  // ============================================================================

  /// Available event types with display labels
  static const Map<String, String> _eventTypes = {
    'service': 'Worship Service',
    'meeting': 'Meeting',
    'pastoral_visit': 'Pastoral Visit',
    'personal': 'Personal',
    'work': 'Work',
    'family': 'Family',
    'blocked_time': 'Blocked Time',
  };

  /// Energy drain options
  static const Map<String, String> _energyDrainOptions = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
  };

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();

    if (widget.event != null) {
      // Edit mode - populate form with event data
      _loadEventData(widget.event!);
    } else if (widget.initialDate != null) {
      // Create mode with initial date
      _initializeWithDate(widget.initialDate!);
    } else {
      // Create mode without initial date - default to today
      _initializeWithDate(DateTime.now());
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _travelTimeController.dispose();
    _preparationBufferController.dispose();
    super.dispose();
  }

  // ============================================================================
  // DATA LOADING (EDIT MODE)
  // ============================================================================

  /// Load event data for editing
  void _loadEventData(CalendarEventEntity event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description ?? '';
    _locationController.text = event.location ?? '';

    setState(() {
      _startDate = DateTime(
        event.startDateTime.year,
        event.startDateTime.month,
        event.startDateTime.day,
      );
      _startTime = TimeOfDay.fromDateTime(event.startDateTime);

      _endDate = DateTime(
        event.endDateTime.year,
        event.endDateTime.month,
        event.endDateTime.day,
      );
      _endTime = TimeOfDay.fromDateTime(event.endDateTime);

      _selectedEventType = event.eventType;
      _energyDrain = event.energyDrain;
      _isMoveable = event.isMoveable;
      _isRecurring = event.isRecurring;
      _requiresPreparation = event.requiresPreparation;
    });

    if (event.travelTimeMinutes != null) {
      _travelTimeController.text = event.travelTimeMinutes.toString();
    }

    if (event.preparationBufferHours != null) {
      _preparationBufferController.text = event.preparationBufferHours.toString();
    }
  }

  /// Initialize form with a specific date (for create mode)
  void _initializeWithDate(DateTime date) {
    setState(() {
      _startDate = DateTime(date.year, date.month, date.day);
      _startTime = const TimeOfDay(hour: 9, minute: 0); // Default to 9:00 AM

      _endDate = DateTime(date.year, date.month, date.day);
      _endTime = const TimeOfDay(hour: 10, minute: 0); // Default to 10:00 AM (1 hour duration)
    });
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(context),
      body: _buildForm(context),
    );
  }

  // ============================================================================
  // APP BAR
  // ============================================================================

  /// Build app bar with title and save action
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.event == null ? 'New Event' : 'Edit Event'),
      backgroundColor: const Color(0xFF2563EB), // Shepherd primary blue
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Save button in AppBar
        TextButton(
          onPressed: _isSubmitting ? null : _saveEvent,
          child: Text(
            'Save',
            style: TextStyle(
              color: _isSubmitting ? Colors.white.withValues(alpha: 0.5) : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // FORM
  // ============================================================================

  /// Build scrollable form with all fields
  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            _buildStartDateTimeFields(context),
            const SizedBox(height: 16),
            _buildEndDateTimeFields(context),

            const SizedBox(height: 24),

            // Event Details Section
            _buildSectionHeader('Event Details'),
            const SizedBox(height: 12),
            _buildEventTypeField(),
            const SizedBox(height: 16),
            _buildEnergyDrainField(),

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

            // Save button (also accessible via AppBar)
            _buildSaveButton(),

            // Extra padding for keyboard
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // SECTION HEADERS
  // ============================================================================

  /// Build section header with gray text
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

  // ============================================================================
  // FORM FIELDS - BASIC INFORMATION
  // ============================================================================

  /// Build title input field (required)
  Widget _buildTitleField() {
    return Semantics(
      label: 'Event title',
      hint: 'Enter a title for this event',
      textField: true,
      child: TextFormField(
        controller: _titleController,
        autofocus: true, // Auto-focus for quick entry
        textCapitalization: TextCapitalization.sentences,
        maxLength: 200,
        decoration: InputDecoration(
          labelText: 'Title *',
          hintText: 'Enter event title',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
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
          counterText: '', // Hide character counter
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter an event title';
          }
          if (value.length > 200) {
            return 'Title must be 200 characters or less';
          }
          return null;
        },
      ),
    );
  }

  /// Build description input field (optional, multiline)
  Widget _buildDescriptionField() {
    return Semantics(
      label: 'Event description',
      hint: 'Enter optional details about this event',
      textField: true,
      child: TextFormField(
        controller: _descriptionController,
        minLines: 3,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Description',
          hintText: 'Add details (optional)',
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
      ),
    );
  }

  /// Build location input field (optional)
  Widget _buildLocationField() {
    return Semantics(
      label: 'Event location',
      hint: 'Enter location for this event',
      textField: true,
      child: TextFormField(
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
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // FORM FIELDS - DATE & TIME
  // ============================================================================

  /// Build start date and time fields
  Widget _buildStartDateTimeFields(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildDateField(
            context: context,
            label: 'Start Date *',
            date: _startDate,
            onTap: () => _selectStartDate(context),
            semanticLabel: 'Start date',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildTimeField(
            context: context,
            label: 'Start Time *',
            time: _startTime,
            onTap: () => _selectStartTime(context),
            semanticLabel: 'Start time',
          ),
        ),
      ],
    );
  }

  /// Build end date and time fields
  Widget _buildEndDateTimeFields(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildDateField(
            context: context,
            label: 'End Date *',
            date: _endDate,
            onTap: () => _selectEndDate(context),
            semanticLabel: 'End date',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildTimeField(
            context: context,
            label: 'End Time *',
            time: _endTime,
            onTap: () => _selectEndTime(context),
            semanticLabel: 'End time',
          ),
        ),
      ],
    );
  }

  /// Build a date picker field
  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: date == null ? 'No date set, tap to select' : 'Tap to change date',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(
            date != null ? DateFormat('MMM d, yyyy').format(date) : 'Select date',
            style: TextStyle(
              fontSize: 15,
              color: date != null ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  /// Build a time picker field
  Widget _buildTimeField({
    required BuildContext context,
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: time == null ? 'No time set, tap to select' : 'Tap to change time',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: const Icon(Icons.access_time, size: 18),
          ),
          child: Text(
            time != null ? time.format(context) : 'Select time',
            style: TextStyle(
              fontSize: 15,
              color: time != null ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // FORM FIELDS - EVENT DETAILS
  // ============================================================================

  /// Build event type dropdown field (required)
  Widget _buildEventTypeField() {
    return Semantics(
      label: 'Event type',
      hint: 'Select the type of event',
      child: DropdownButtonFormField<String>(
        initialValue: _selectedEventType,
        decoration: InputDecoration(
          labelText: 'Event Type *',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
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
        ),
        items: _eventTypes.entries.map((entry) {
          return DropdownMenuItem<String>(
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
      ),
    );
  }

  /// Build energy drain dropdown field
  Widget _buildEnergyDrainField() {
    return Semantics(
      label: 'Energy drain',
      hint: 'Select the energy level required for this event',
      child: DropdownButtonFormField<String>(
        initialValue: _energyDrain,
        decoration: InputDecoration(
          labelText: 'Energy Drain',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
        ),
        items: _energyDrainOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _energyDrain = value ?? 'medium';
          });
        },
      ),
    );
  }

  // ============================================================================
  // FORM FIELDS - OPTIONS
  // ============================================================================

  /// Build is moveable checkbox
  Widget _buildMoveableCheckbox() {
    return Semantics(
      label: 'Is moveable',
      hint: _isMoveable ? 'Event is moveable' : 'Event is fixed',
      checked: _isMoveable,
      child: CheckboxListTile(
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
      ),
    );
  }

  /// Build is recurring checkbox
  Widget _buildRecurringCheckbox() {
    return Semantics(
      label: 'Is recurring',
      hint: _isRecurring ? 'Event is recurring' : 'Event is not recurring',
      checked: _isRecurring,
      child: CheckboxListTile(
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
      ),
    );
  }

  /// Build travel time field
  Widget _buildTravelTimeField() {
    return Semantics(
      label: 'Travel time in minutes',
      hint: 'Enter how many minutes of travel time before this event',
      textField: true,
      child: TextFormField(
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
            borderSide: BorderSide(color: Colors.grey.shade300),
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
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final minutes = int.tryParse(value);
            if (minutes == null || minutes < 0) {
              return 'Please enter a valid positive number';
            }
          }
          return null;
        },
      ),
    );
  }

  /// Build requires preparation checkbox
  Widget _buildPreparationCheckbox() {
    return Semantics(
      label: 'Requires preparation',
      hint: _requiresPreparation ? 'Event requires preparation' : 'Event does not require preparation',
      checked: _requiresPreparation,
      child: CheckboxListTile(
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
      ),
    );
  }

  /// Build preparation buffer field (only shown when requires preparation is checked)
  Widget _buildPreparationBufferField() {
    return Semantics(
      label: 'Preparation buffer in hours',
      hint: 'Enter how many hours needed for preparation',
      textField: true,
      child: TextFormField(
        controller: _preparationBufferController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Preparation Buffer (hours)',
          hintText: 'e.g., 2',
          prefixIcon: const Icon(Icons.edit_calendar_outlined),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
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
        ),
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
      ),
    );
  }

  // ============================================================================
  // SAVE BUTTON
  // ============================================================================

  /// Build save button at bottom of form
  Widget _buildSaveButton() {
    return Semantics(
      label: 'Save event',
      button: true,
      hint: 'Saves the event and returns to the calendar',
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _saveEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Event',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ============================================================================
  // DATE/TIME PICKERS
  // ============================================================================

  /// Show start date picker dialog
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, update it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  /// Show start time picker dialog
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  /// Show end date picker dialog
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  /// Show end time picker dialog
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  // ============================================================================
  // SAVE EVENT
  // ============================================================================

  /// Save event to database
  ///
  /// Validates form, shows loading state, saves to database,
  /// shows success message, and navigates back.
  Future<void> _saveEvent() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate start/end datetime
    if (_startDate == null || _startTime == null) {
      _showErrorSnackBar('Please select a start date and time');
      return;
    }

    if (_endDate == null || _endTime == null) {
      _showErrorSnackBar('Please select an end date and time');
      return;
    }

    // Combine date and time to create DateTime objects
    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    // Validate that end is after start
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      _showErrorSnackBar('End date/time must be after start date/time');
      return;
    }

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Parse optional numeric fields
      final travelTimeMinutes = _travelTimeController.text.isNotEmpty
          ? int.tryParse(_travelTimeController.text)
          : null;

      final preparationBufferHours = _requiresPreparation && _preparationBufferController.text.isNotEmpty
          ? int.tryParse(_preparationBufferController.text)
          : null;

      final now = DateTime.now();
      final repository = ref.read(calendarEventRepositoryProvider);

      // Create or update event
      if (widget.event == null) {
        // Create new event
        final newEvent = CalendarEventEntity(
          id: const Uuid().v4(),
          userId: 'default-user', // TODO: Get from auth provider
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
          syncStatus: 'pending',
          localUpdatedAt: now.millisecondsSinceEpoch,
          serverUpdatedAt: null,
          version: 1,
        );

        await repository.createEvent(newEvent);
      } else {
        // Update existing event
        final updatedEvent = widget.event!.copyWith(
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
          travelTimeMinutes: travelTimeMinutes,
          energyDrain: _energyDrain,
          isMoveable: _isMoveable,
          requiresPreparation: _requiresPreparation,
          preparationBufferHours: preparationBufferHours,
          updatedAt: now,
          localUpdatedAt: now.millisecondsSinceEpoch,
          version: widget.event!.version + 1,
        );

        await repository.updateEvent(updatedEvent);
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.event == null
                ? 'Event created successfully!'
                : 'Event updated successfully!',
          ),
          backgroundColor: const Color(0xFF10B981), // Shepherd success green
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to calendar
      Navigator.pop(context);
    } catch (error) {
      // Show error message
      if (!mounted) return;

      _showErrorSnackBar('Failed to save event: $error');
    } finally {
      // Reset submitting state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444), // Shepherd error red
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
