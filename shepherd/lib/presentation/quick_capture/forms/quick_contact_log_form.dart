import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/contact_log.dart';
import '../../../presentation/people/providers/people_providers.dart';

/// Quick Contact Log Form - Comprehensive fields for complete contact logging
///
/// This form includes ALL fields for contact logging,
/// displayed in a scrollable bottom sheet for quick capture.
///
/// Fields:
/// - Person (required, searchable dropdown)
/// - Contact Type (required, chips: Call, Visit, Email, Text, In Person)
/// - Contact Date (defaults to today)
/// - Duration (optional, minutes)
/// - Notes (optional, multiline text)
/// - Create Follow-up Task (optional, checkbox)
///
/// Features:
/// - Scrollable form that works in DraggableScrollableSheet
/// - Person search/dropdown with loading and error states
/// - Quick contact type selection with chips and icons
/// - Auto-defaults date to today
/// - Duration input with validation
/// - Keyboard-friendly with proper text input actions
/// - Haptic feedback on save
/// - Loading state while saving
/// - Complete validation
/// - Error handling with snackbar
/// - Follows Shepherd design system
class QuickContactLogForm extends ConsumerStatefulWidget {
  const QuickContactLogForm({super.key});

  @override
  ConsumerState<QuickContactLogForm> createState() => _QuickContactLogFormState();
}

class _QuickContactLogFormState extends ConsumerState<QuickContactLogForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();

  String? _selectedPersonId;
  String _selectedContactType = 'call';
  DateTime _selectedDate = DateTime.now();
  bool _createFollowUpTask = false;
  bool _isSaving = false;

  // Contact type options with icons
  static const Map<String, ContactTypeInfo> _contactTypes = {
    'call': ContactTypeInfo('Call', Icons.phone),
    'visit': ContactTypeInfo('Visit', Icons.home),
    'email': ContactTypeInfo('Email', Icons.email),
    'text': ContactTypeInfo('Text', Icons.message),
    'in_person': ContactTypeInfo('In Person', Icons.person),
  };

  @override
  void dispose() {
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// Handle form submission
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPersonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a person'),
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

      // Parse optional duration
      final durationMinutes = _durationController.text.isNotEmpty
          ? int.tryParse(_durationController.text)
          : null;

      // Create contact log entity
      final now = DateTime.now();
      final contactLog = ContactLogEntity(
        id: const Uuid().v4(),
        userId: userId,
        personId: _selectedPersonId!,
        contactDate: _selectedDate,
        contactType: _selectedContactType,
        durationMinutes: durationMinutes,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: now,
        localUpdatedAt: now.millisecondsSinceEpoch,
      );

      // Save to repository
      await ref.read(personRepositoryProvider).logContact(contactLog);

      // TODO: If _createFollowUpTask is true, create a follow-up task
      // This would require the task repository to be implemented
      // Example:
      // if (_createFollowUpTask) {
      //   final task = TaskEntity(
      //     id: const Uuid().v4(),
      //     userId: userId,
      //     title: 'Follow up with ${personName}',
      //     personId: _selectedPersonId,
      //     category: 'pastoral_care',
      //     priority: 'medium',
      //     status: 'not_started',
      //     createdAt: now,
      //     updatedAt: now,
      //     localUpdatedAt: now.millisecondsSinceEpoch,
      //   );
      //   await ref.read(taskRepositoryProvider).createTask(task);
      // }

      // Haptic feedback
      HapticFeedback.mediumImpact();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _createFollowUpTask
                  ? 'Contact logged! (Follow-up task coming soon)'
                  : 'Contact logged successfully!',
            ),
            backgroundColor: const Color(0xFF8B5CF6), // Purple
            duration: const Duration(seconds: 2),
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
            content: Text('Failed to log contact: $error'),
            backgroundColor: const Color(0xFFEF4444), // Error red
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6), // Purple
              onPrimary: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(peopleProvider);

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

            // Contact Information Section
            _buildSectionHeader('Contact Information'),
            const SizedBox(height: 12),
            _buildPersonField(peopleAsync),
            const SizedBox(height: 16),
            _buildContactTypeSelector(),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildDurationField(),
            const SizedBox(height: 24),

            // Notes Section
            _buildSectionHeader('Notes'),
            const SizedBox(height: 12),
            _buildNotesField(),
            const SizedBox(height: 24),

            // Follow-up Section
            _buildSectionHeader('Follow-up'),
            const SizedBox(height: 12),
            _buildFollowUpTaskCheckbox(),
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
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.contacts,
            color: Color(0xFF8B5CF6),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Quick Contact Log',
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

  /// Build person dropdown field
  Widget _buildPersonField(AsyncValue peopleAsync) {
    return peopleAsync.when(
      data: (people) {
        if (people.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No people found. Add people first before logging contacts.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedPersonId,
          decoration: InputDecoration(
            labelText: 'Person *',
            hintText: 'Select a person',
            prefixIcon: const Icon(Icons.person),
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
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
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
          isExpanded: true,
          items: people.map((person) {
            return DropdownMenuItem(
              value: person.id,
              child: Text(
                person.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPersonId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a person';
            }
            return null;
          },
        );
      },
      loading: () => Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error loading people: $error',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
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
          children: _contactTypes.entries.map((entry) {
            final isSelected = _selectedContactType == entry.key;
            final info = entry.value;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    info.icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(info.label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedContactType = entry.key;
                });
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF8B5CF6),
              checkmarkColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build date field
  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Contact Date',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          _formatDate(_selectedDate),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade900,
          ),
        ),
      ),
    );
  }

  /// Build duration field
  Widget _buildDurationField() {
    return TextFormField(
      controller: _durationController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Duration (minutes)',
        hintText: 'e.g., 30',
        prefixIcon: const Icon(Icons.timer_outlined),
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
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
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
          if (minutes == null || minutes < 1) {
            return 'Please enter a valid positive number';
          }
        }
        return null;
      },
    );
  }

  /// Build notes field
  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Notes',
        hintText: 'Any additional details...',
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
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSave(),
    );
  }

  /// Build follow-up task checkbox
  Widget _buildFollowUpTaskCheckbox() {
    return CheckboxListTile(
      value: _createFollowUpTask,
      onChanged: (value) {
        setState(() {
          _createFollowUpTask = value ?? false;
        });
      },
      title: const Text('Create Follow-up Task'),
      subtitle: const Text('Automatically create a task to follow up on this contact'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF8B5CF6),
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B5CF6), // Purple
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
              'Log Contact',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// Format date for display
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
      return DateFormat('EEE, MMM d, yyyy').format(date);
    }
  }
}

/// Contact type information holder
class ContactTypeInfo {
  final String label;
  final IconData icon;

  const ContactTypeInfo(this.label, this.icon);
}
