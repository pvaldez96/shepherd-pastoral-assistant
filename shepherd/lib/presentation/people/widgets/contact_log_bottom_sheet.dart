import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/person.dart';

/// Bottom sheet widget for logging a contact with a person
///
/// Features:
/// - Contact type selector (chips): Call, Visit, Email, Text, In Person
/// - Date picker (defaults to today)
/// - Duration input (optional, in minutes)
/// - Notes text area
/// - Checkbox: Create follow-up task
/// - Save button with validation
/// - Keyboard-aware scrolling
///
/// Design:
/// - Rounded top corners (16px)
/// - Safe area padding
/// - Responsive to keyboard
/// - Minimum touch targets (44x44)
/// - Shepherd design system colors
///
/// Usage:
/// ```dart
/// showContactLogBottomSheet(
///   context: context,
///   person: person,
///   onSave: (contactLog) async {
///     // Save to repository
///   },
/// )
/// ```
class ContactLogBottomSheet extends StatefulWidget {
  final PersonEntity person;
  final Function(Map<String, dynamic> contactData)? onSave;

  const ContactLogBottomSheet({
    super.key,
    required this.person,
    this.onSave,
  });

  @override
  State<ContactLogBottomSheet> createState() => _ContactLogBottomSheetState();
}

class _ContactLogBottomSheetState extends State<ContactLogBottomSheet> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  // Form state
  String? _selectedContactType;
  DateTime _selectedDate = DateTime.now();
  bool _createFollowUpTask = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with person name and close button
                _buildHeader(context),
                const SizedBox(height: 24),

                // Contact type selector
                _buildContactTypeSelector(),
                const SizedBox(height: 20),

                // Date picker
                _buildDateField(context),
                const SizedBox(height: 16),

                // Duration input
                _buildDurationField(),
                const SizedBox(height: 16),

                // Notes text area
                _buildNotesField(),
                const SizedBox(height: 16),

                // Create follow-up task checkbox
                _buildFollowUpCheckbox(),
                const SizedBox(height: 24),

                // Save button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with person name and close button
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log Contact',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'with ${widget.person.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close',
        ),
      ],
    );
  }

  /// Build contact type selector with chips
  Widget _buildContactTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildContactTypeChip('call', 'Call', Icons.phone),
            _buildContactTypeChip('visit', 'Visit', Icons.home),
            _buildContactTypeChip('email', 'Email', Icons.email),
            _buildContactTypeChip('text', 'Text', Icons.message),
            _buildContactTypeChip('in_person', 'In Person', Icons.person),
          ],
        ),
        if (_selectedContactType == null) ...[
          const SizedBox(height: 8),
          Text(
            'Please select a contact type',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  /// Build individual contact type chip
  Widget _buildContactTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedContactType == type;

    return Semantics(
      label: '$label contact type',
      button: true,
      selected: isSelected,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedContactType = selected ? type : null;
          });
        },
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade100,
        selectedColor: const Color(0xFF2563EB),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Build date picker field
  Widget _buildDateField(BuildContext context) {
    return Semantics(
      label: 'Contact date',
      hint: 'Tap to select date',
      button: true,
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Date',
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
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          child: Text(
            DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  /// Build duration input field
  Widget _buildDurationField() {
    return Semantics(
      label: 'Duration in minutes',
      hint: 'Optional field',
      textField: true,
      child: TextFormField(
        controller: _durationController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Duration (optional)',
          hintText: 'Minutes',
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
          suffixIcon: const Icon(Icons.schedule, size: 20),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final duration = int.tryParse(value);
            if (duration == null || duration <= 0) {
              return 'Please enter a valid duration';
            }
          }
          return null;
        },
      ),
    );
  }

  /// Build notes text area field
  Widget _buildNotesField() {
    return Semantics(
      label: 'Contact notes',
      hint: 'Optional notes about this contact',
      textField: true,
      child: TextFormField(
        controller: _notesController,
        minLines: 3,
        maxLines: 6,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Notes (optional)',
          hintText: 'Add any details about this contact...',
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

  /// Build follow-up task checkbox
  Widget _buildFollowUpCheckbox() {
    return Semantics(
      label: 'Create follow-up task',
      hint: 'Checkbox',
      child: CheckboxListTile(
        value: _createFollowUpTask,
        onChanged: (value) {
          setState(() {
            _createFollowUpTask = value ?? false;
          });
        },
        title: const Text('Create follow-up task'),
        subtitle: Text(
          'Suggests a follow-up date based on contact frequency',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: const Color(0xFF2563EB),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return Semantics(
      label: 'Save contact log',
      button: true,
      hint: 'Saves the contact log and returns',
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveContactLog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
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
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save Contact',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Show date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Save contact log
  Future<void> _saveContactLog() async {
    // Validate contact type selection
    if (_selectedContactType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a contact type'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare contact data
      final contactData = {
        'personId': widget.person.id,
        'contactType': _selectedContactType!,
        'contactDate': _selectedDate,
        'durationMinutes': _durationController.text.isNotEmpty
            ? int.parse(_durationController.text)
            : null,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'createFollowUpTask': _createFollowUpTask,
      };

      // Call onSave callback if provided
      if (widget.onSave != null) {
        await widget.onSave!(contactData);
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact logged successfully!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Close bottom sheet
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log contact: $error'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// Helper function to show the contact log bottom sheet
///
/// Usage:
/// ```dart
/// final result = await showContactLogBottomSheet(
///   context: context,
///   person: person,
///   onSave: (contactData) async {
///     // Save to repository
///     await repository.createContactLog(contactData);
///   },
/// );
///
/// if (result == true) {
///   // Contact logged successfully
/// }
/// ```
Future<bool?> showContactLogBottomSheet({
  required BuildContext context,
  required PersonEntity person,
  Function(Map<String, dynamic> contactData)? onSave,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ContactLogBottomSheet(
      person: person,
      onSave: onSave,
    ),
  );
}
