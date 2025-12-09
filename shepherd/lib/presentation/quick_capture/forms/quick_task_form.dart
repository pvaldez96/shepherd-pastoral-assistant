import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/task.dart';
import '../../../presentation/tasks/providers/task_providers.dart';

/// Quick Task Form - Comprehensive fields for complete task creation
///
/// This form includes ALL fields from the full task form screen,
/// displayed in a scrollable bottom sheet for quick capture.
///
/// Fields:
/// - Title (required, auto-focus)
/// - Description (text area)
/// - Due Date (optional, date picker)
/// - Due Time (optional, time picker, shown when date is set)
/// - Priority (high/medium/low chips)
/// - Category (dropdown, required)
/// - Estimated Duration (quick select chips + custom option)
/// - Person Link (optional, dropdown - coming soon)
/// - Tags (optional - coming soon)
/// - Recurrence (optional - coming soon)
///
/// Features:
/// - Scrollable form that works in DraggableScrollableSheet
/// - Auto-focus on title field
/// - Keyboard-friendly with proper text input actions
/// - Haptic feedback on save
/// - Loading state while saving
/// - Complete validation
/// - Error handling with snackbar
/// - Follows Shepherd design system
class QuickTaskForm extends ConsumerStatefulWidget {
  const QuickTaskForm({super.key});

  @override
  ConsumerState<QuickTaskForm> createState() => _QuickTaskFormState();
}

class _QuickTaskFormState extends ConsumerState<QuickTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  int? _estimatedDurationMinutes;
  String _selectedPriority = 'medium';
  String? _selectedCategory;
  bool _isSaving = false;

  // Duration options in minutes
  static const List<int> _durationOptions = [15, 30, 60, 120];

  // Category options matching the full form
  static const Map<String, String> _categoryOptions = {
    'sermon_prep': 'Sermon Prep',
    'pastoral_care': 'Pastoral Care',
    'admin': 'Admin',
    'personal': 'Personal',
    'worship_planning': 'Worship Planning',
  };

  // Priority options matching the full form
  static const Map<String, PriorityInfo> _priorityOptions = {
    'low': PriorityInfo('Low', Color(0xFF9CA3AF)),
    'medium': PriorityInfo('Medium', Color(0xFF2563EB)),
    'high': PriorityInfo('High', Color(0xFFF59E0B)),
    'urgent': PriorityInfo('Urgent', Color(0xFFEF4444)),
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handle form submission
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Get current user ID from auth state
      // For now, use a placeholder - this should come from auth
      const userId = 'current-user-id';

      // Combine date and time if both are set
      DateTime? dueDate = _selectedDueDate;
      String? dueTime;
      if (_selectedDueTime != null && _selectedDueDate != null) {
        dueTime = '${_selectedDueTime!.hour.toString().padLeft(2, '0')}:${_selectedDueTime!.minute.toString().padLeft(2, '0')}';
      }

      // Create task entity
      final now = DateTime.now();
      final task = TaskEntity(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: dueDate,
        dueTime: dueTime,
        estimatedDurationMinutes: _estimatedDurationMinutes,
        category: _selectedCategory!,
        priority: _selectedPriority,
        status: 'not_started',
        createdAt: now,
        updatedAt: now,
        localUpdatedAt: now.millisecondsSinceEpoch,
      );

      // Save to repository
      await ref.read(taskRepositoryProvider).createTask(task);

      // Haptic feedback
      HapticFeedback.mediumImpact();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
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
            content: Text('Failed to create task: $error'),
            backgroundColor: const Color(0xFFEF4444), // Error red
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Show date picker
  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB), // Primary blue
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  /// Show time picker
  Future<void> _selectDueTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB), // Primary blue
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDueTime) {
      setState(() {
        _selectedDueTime = picked;
      });
    }
  }

  /// Show custom duration dialog
  Future<void> _showCustomDurationDialog() async {
    final controller = TextEditingController(
      text: _estimatedDurationMinutes?.toString() ?? '',
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Duration'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Minutes',
              hintText: 'Enter duration in minutes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final minutes = int.tryParse(controller.text);
                if (minutes != null && minutes > 0) {
                  Navigator.pop(context, minutes);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Set'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _estimatedDurationMinutes = result;
      });
    }

    controller.dispose();
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
            const SizedBox(height: 24),

            // Scheduling Section
            _buildSectionHeader('Scheduling'),
            const SizedBox(height: 12),
            _buildDueDateField(),
            if (_selectedDueDate != null) ...[
              const SizedBox(height: 16),
              _buildDueTimeField(),
            ],
            const SizedBox(height: 24),

            // Time Estimation Section
            _buildSectionHeader('Time Estimation'),
            const SizedBox(height: 12),
            _buildDurationSelector(),
            const SizedBox(height: 24),

            // Categorization Section
            _buildSectionHeader('Categorization'),
            const SizedBox(height: 12),
            _buildCategoryField(),
            const SizedBox(height: 16),
            _buildPrioritySelector(),
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
            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.task_alt,
            color: Color(0xFF2563EB),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Quick Task',
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
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Title *',
        hintText: 'What needs to be done?',
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
          return 'Please enter a task title';
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

  /// Build due date field
  Widget _buildDueDateField() {
    return InkWell(
      onTap: _selectDueDate,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due Date',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          suffixIcon: _selectedDueDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedDueDate = null;
                      _selectedDueTime = null;
                    });
                  },
                  tooltip: 'Clear date',
                )
              : const Icon(Icons.calendar_today, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          _selectedDueDate == null
              ? 'No date set'
              : DateFormat('EEE, MMM d, yyyy').format(_selectedDueDate!),
          style: TextStyle(
            fontSize: 16,
            color: _selectedDueDate != null
                ? Colors.grey.shade900
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// Build due time field
  Widget _buildDueTimeField() {
    return InkWell(
      onTap: _selectDueTime,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due Time',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          suffixIcon: _selectedDueTime != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    setState(() {
                      _selectedDueTime = null;
                    });
                  },
                  tooltip: 'Clear time',
                )
              : const Icon(Icons.access_time, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          _selectedDueTime == null
              ? 'No time set'
              : _selectedDueTime!.format(context),
          style: TextStyle(
            fontSize: 16,
            color: _selectedDueTime != null
                ? Colors.grey.shade900
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// Build duration selector
  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Duration',
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
            ..._durationOptions.map((minutes) {
              final isSelected = _estimatedDurationMinutes == minutes;
              return FilterChip(
                label: Text(_formatDuration(minutes)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _estimatedDurationMinutes = selected ? minutes : null;
                  });
                },
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF2563EB),
                checkmarkColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
            // Custom duration chip
            ActionChip(
              label: Text(
                _estimatedDurationMinutes != null &&
                        !_durationOptions.contains(_estimatedDurationMinutes)
                    ? 'Custom (${_formatDuration(_estimatedDurationMinutes!)})'
                    : 'Custom',
              ),
              avatar: Icon(
                Icons.edit_outlined,
                size: 18,
                color: _estimatedDurationMinutes != null &&
                        !_durationOptions.contains(_estimatedDurationMinutes)
                    ? Colors.white
                    : Colors.grey.shade700,
              ),
              backgroundColor: _estimatedDurationMinutes != null &&
                      !_durationOptions.contains(_estimatedDurationMinutes)
                  ? const Color(0xFF2563EB)
                  : Colors.white,
              labelStyle: TextStyle(
                color: _estimatedDurationMinutes != null &&
                        !_durationOptions.contains(_estimatedDurationMinutes)
                    ? Colors.white
                    : Colors.grey.shade700,
              ),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: _showCustomDurationDialog,
            ),
          ],
        ),
      ],
    );
  }

  /// Build category field
  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category *',
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
      items: _categoryOptions.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  /// Build priority selector
  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _priorityOptions.entries.map((entry) {
            final isSelected = _selectedPriority == entry.key;
            final info = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key == 'urgent' ? 0 : 8,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPriority = entry.key;
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

  /// Build save button
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _handleSave,
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Save Task',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// Format duration for display
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${remainingMinutes}m';
    }
  }
}

/// Priority information holder
class PriorityInfo {
  final String label;
  final Color color;

  const PriorityInfo(this.label, this.color);
}
