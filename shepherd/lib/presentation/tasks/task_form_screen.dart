import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Task creation and editing form screen
///
/// Features:
/// - Create new task or edit existing task (when taskId is provided)
/// - Complete form validation with inline error messages
/// - Date and time pickers with clear buttons
/// - Duration selector with quick select chips and custom option
/// - Category dropdown with all task categories
/// - Priority selector with visual indicators
/// - Auto-focus on title field for quick data entry
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
/// // Create new task
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const TaskFormScreen(),
///   ),
/// );
///
/// // Edit existing task
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => TaskFormScreen(taskId: task.id),
///   ),
/// );
/// ```
class TaskFormScreen extends StatefulWidget {
  /// Optional task ID for editing mode
  /// If null, screen is in creation mode
  final String? taskId;

  const TaskFormScreen({
    super.key,
    this.taskId,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // ============================================================================
  // FORM STATE
  // ============================================================================

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  /// Must be disposed in dispose() method
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ============================================================================
  // FIELD STATE VARIABLES
  // ============================================================================

  /// Selected due date (optional)
  DateTime? _selectedDueDate;

  /// Selected due time (optional, only valid if due date is set)
  TimeOfDay? _selectedDueTime;

  /// Estimated duration in minutes (optional)
  int? _estimatedDurationMinutes;

  /// Selected category (required)
  String? _selectedCategory;

  /// Selected priority (required, defaults to medium)
  String _selectedPriority = 'medium';

  /// Form submission state
  bool _isSubmitting = false;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();

    // TODO: If taskId is provided, load task data and populate form
    // For now, form starts empty (create mode)

    // Load task data in edit mode
    if (widget.taskId != null) {
      _loadTaskData();
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================================
  // DATA LOADING (EDIT MODE)
  // ============================================================================

  /// Load task data for editing
  ///
  /// TODO: Replace with actual task repository call when implemented
  /// This would fetch the task from the database and populate all fields
  Future<void> _loadTaskData() async {
    // Placeholder for task loading
    // final task = await ref.read(taskRepositoryProvider).getTask(widget.taskId!);
    // if (task != null) {
    //   setState(() {
    //     _titleController.text = task.title;
    //     _descriptionController.text = task.description ?? '';
    //     _selectedDueDate = task.dueDate;
    //     _selectedDueTime = task.dueTime != null ? _parseTimeOfDay(task.dueTime!) : null;
    //     _estimatedDurationMinutes = task.estimatedDurationMinutes;
    //     _selectedCategory = task.category;
    //     _selectedPriority = task.priority;
    //   });
    // }
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

  /// Build app bar with title and actions
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.taskId == null ? 'New Task' : 'Edit Task'),
      backgroundColor: const Color(0xFF2563EB), // Shepherd primary blue
      foregroundColor: Colors.white,
      elevation: 0,
      // Back button is automatic
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

            const SizedBox(height: 24),

            // Scheduling Section
            _buildSectionHeader('Scheduling'),
            const SizedBox(height: 12),
            _buildDueDateField(context),
            const SizedBox(height: 16),
            if (_selectedDueDate != null) ...[
              _buildDueTimeField(context),
              const SizedBox(height: 16),
            ],

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
  // FORM FIELDS
  // ============================================================================

  /// Build title input field (required)
  Widget _buildTitleField() {
    return Semantics(
      label: 'Task title',
      hint: 'Enter a title for this task',
      textField: true,
      child: TextFormField(
        controller: _titleController,
        autofocus: true, // Auto-focus for quick entry
        textCapitalization: TextCapitalization.sentences,
        maxLength: 200,
        decoration: InputDecoration(
          labelText: 'Title',
          hintText: 'Enter task title',
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
            return 'Please enter a task title';
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
      label: 'Task description',
      hint: 'Enter optional details about this task',
      textField: true,
      child: TextFormField(
        controller: _descriptionController,
        minLines: 3,
        maxLines: 8,
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

  /// Build due date picker field (optional)
  Widget _buildDueDateField(BuildContext context) {
    return Semantics(
      label: 'Due date',
      hint: _selectedDueDate == null ? 'No date set, tap to select' : 'Tap to change date',
      button: true,
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Due Date',
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
            suffixIcon: _selectedDueDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                        _selectedDueTime = null; // Clear time when date is cleared
                      });
                    },
                    tooltip: 'Clear date',
                  )
                : const Icon(Icons.calendar_today, size: 20),
          ),
          child: Text(
            _selectedDueDate != null
                ? DateFormat('EEE, MMM d, yyyy').format(_selectedDueDate!)
                : 'No date set',
            style: TextStyle(
              fontSize: 16,
              color: _selectedDueDate != null ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  /// Build due time picker field (optional, only shown if date is set)
  Widget _buildDueTimeField(BuildContext context) {
    return Semantics(
      label: 'Due time',
      hint: _selectedDueTime == null ? 'No time set, tap to select' : 'Tap to change time',
      button: true,
      child: InkWell(
        onTap: () => _selectTime(context),
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Due Time',
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
          ),
          child: Text(
            _selectedDueTime != null
                ? _selectedDueTime!.format(context)
                : 'No time set',
            style: TextStyle(
              fontSize: 16,
              color: _selectedDueTime != null ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  /// Build category dropdown field (required)
  Widget _buildCategoryField() {
    // Task categories matching the database schema
    final categories = {
      'sermon_prep': 'Sermon Prep',
      'pastoral_care': 'Pastoral Care',
      'admin': 'Admin',
      'personal': 'Personal',
      'worship_planning': 'Worship Planning',
    };

    return Semantics(
      label: 'Task category',
      hint: 'Select a category for this task',
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category',
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
        items: categories.entries.map((entry) {
          return DropdownMenuItem<String>(
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
      ),
    );
  }

  // ============================================================================
  // DURATION SELECTOR
  // ============================================================================

  /// Build duration selector with quick select chips
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
            _buildDurationChip(label: '15 min', minutes: 15),
            _buildDurationChip(label: '30 min', minutes: 30),
            _buildDurationChip(label: '1 hr', minutes: 60),
            _buildDurationChip(label: '2 hrs', minutes: 120),
            _buildCustomDurationChip(),
          ],
        ),
        if (_estimatedDurationMinutes != null) ...[
          const SizedBox(height: 8),
          Text(
            'Selected: ${_formatDuration(_estimatedDurationMinutes!)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  /// Build individual duration chip
  Widget _buildDurationChip({required String label, required int minutes}) {
    final isSelected = _estimatedDurationMinutes == minutes;

    return Semantics(
      label: '$label duration',
      button: true,
      selected: isSelected,
      hint: isSelected ? 'Currently selected' : 'Tap to select $label',
      child: FilterChip(
        label: Text(label),
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
      ),
    );
  }

  /// Build custom duration chip that opens dialog
  Widget _buildCustomDurationChip() {
    final hasCustomDuration = _estimatedDurationMinutes != null &&
        ![15, 30, 60, 120].contains(_estimatedDurationMinutes);

    return Semantics(
      label: 'Custom duration',
      button: true,
      hint: 'Tap to enter a custom duration',
      child: ActionChip(
        label: Text(hasCustomDuration ? 'Custom' : 'Custom'),
        avatar: Icon(
          Icons.edit_outlined,
          size: 18,
          color: hasCustomDuration ? Colors.white : Colors.grey.shade700,
        ),
        backgroundColor: hasCustomDuration ? const Color(0xFF2563EB) : Colors.white,
        labelStyle: TextStyle(
          color: hasCustomDuration ? Colors.white : Colors.grey.shade700,
          fontWeight: hasCustomDuration ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onPressed: () => _showCustomDurationDialog(),
      ),
    );
  }

  // ============================================================================
  // PRIORITY SELECTOR
  // ============================================================================

  /// Build priority selector with color-coded chips
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
          children: [
            Expanded(child: _buildPriorityChip(label: 'Low', value: 'low', color: Colors.grey.shade400)),
            const SizedBox(width: 8),
            Expanded(child: _buildPriorityChip(label: 'Medium', value: 'medium', color: const Color(0xFF2563EB))),
            const SizedBox(width: 8),
            Expanded(child: _buildPriorityChip(label: 'High', value: 'high', color: const Color(0xFFF59E0B))),
            const SizedBox(width: 8),
            Expanded(child: _buildPriorityChip(label: 'Urgent', value: 'urgent', color: const Color(0xFFEF4444))),
          ],
        ),
      ],
    );
  }

  /// Build individual priority chip
  Widget _buildPriorityChip({
    required String label,
    required String value,
    required Color color,
  }) {
    final isSelected = _selectedPriority == value;

    return Semantics(
      label: '$label priority',
      button: true,
      selected: isSelected,
      hint: isSelected ? 'Currently selected' : 'Tap to select $label priority',
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPriority = value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // SAVE BUTTON
  // ============================================================================

  /// Build save button at bottom of form
  Widget _buildSaveButton() {
    return Semantics(
      label: 'Save task',
      button: true,
      hint: 'Saves the task and returns to the task list',
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _saveTask,
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
                'Save Task',
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

  /// Show date picker dialog
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB), // Shepherd primary blue
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
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

  /// Show time picker dialog
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB), // Shepherd primary blue
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
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

  // ============================================================================
  // CUSTOM DURATION DIALOG
  // ============================================================================

  /// Show custom duration input dialog
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

  // ============================================================================
  // SAVE TASK
  // ============================================================================

  /// Save task to database
  ///
  /// Validates form, shows loading state, saves to database,
  /// shows success message, and navigates back.
  ///
  /// TODO: Replace with actual task repository call when implemented
  Future<void> _saveTask() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Create TaskEntity and save to database via repository
      // Example:
      // final task = TaskEntity(
      //   id: widget.taskId ?? const Uuid().v4(),
      //   userId: 'current-user-id', // Get from auth
      //   title: _titleController.text.trim(),
      //   description: _descriptionController.text.trim().isEmpty
      //       ? null
      //       : _descriptionController.text.trim(),
      //   dueDate: _selectedDueDate,
      //   dueTime: _selectedDueTime != null
      //       ? '${_selectedDueTime!.hour.toString().padLeft(2, '0')}:${_selectedDueTime!.minute.toString().padLeft(2, '0')}'
      //       : null,
      //   estimatedDurationMinutes: _estimatedDurationMinutes,
      //   category: _selectedCategory!,
      //   priority: _selectedPriority,
      //   status: 'not_started',
      //   createdAt: DateTime.now(),
      //   updatedAt: DateTime.now(),
      //   localUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      // );
      //
      // if (widget.taskId != null) {
      //   await ref.read(taskRepositoryProvider).updateTask(task);
      // } else {
      //   await ref.read(taskRepositoryProvider).createTask(task);
      // }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.taskId == null
                ? 'Task created successfully!'
                : 'Task updated successfully!',
          ),
          backgroundColor: const Color(0xFF10B981), // Shepherd success green
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to task list
      Navigator.pop(context);
    } catch (error) {
      // Show error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task: $error'),
          backgroundColor: const Color(0xFFEF4444), // Shepherd error red
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
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

  /// Format duration in minutes to human-readable string
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hour${hours == 1 ? '' : 's'}';
    }

    return '$hours hour${hours == 1 ? '' : 's'} $remainingMinutes minute${remainingMinutes == 1 ? '' : 's'}';
  }
}

// Usage examples:
//
// Create new task:
// ```dart
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => const TaskFormScreen(),
//   ),
// );
// ```
//
// Edit existing task:
// ```dart
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => TaskFormScreen(taskId: task.id),
//   ),
// );
// ```
//
// With go_router:
// ```dart
// GoRoute(
//   path: '/tasks/new',
//   builder: (context, state) => const TaskFormScreen(),
// ),
// GoRoute(
//   path: '/tasks/:id/edit',
//   builder: (context, state) => TaskFormScreen(
//     taskId: state.pathParameters['id'],
//   ),
// ),
// ```
