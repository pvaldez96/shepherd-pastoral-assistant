import 'package:flutter/material.dart';

/// Person creation and editing form screen
///
/// Features:
/// - Create new person or edit existing person (when personId is provided)
/// - Complete form validation with inline error messages
/// - Fields: Name, Email, Phone, Category, Contact frequency override, Notes, Tags
/// - Category dropdown with all person categories
/// - Tags input (multi-select or create new)
/// - Auto-focus on name field for quick data entry
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
/// // Create new person
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const PersonFormScreen(),
///   ),
/// );
///
/// // Edit existing person
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => PersonFormScreen(personId: person.id),
///   ),
/// );
/// ```
class PersonFormScreen extends StatefulWidget {
  /// Optional person ID for editing mode
  /// If null, screen is in creation mode
  final String? personId;

  const PersonFormScreen({
    super.key,
    this.personId,
  });

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  // ============================================================================
  // FORM STATE
  // ============================================================================

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Text editing controllers
  /// Must be disposed in dispose() method
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _contactFrequencyController = TextEditingController();

  // ============================================================================
  // FIELD STATE VARIABLES
  // ============================================================================

  /// Selected category (required)
  String? _selectedCategory;

  /// Tags (optional)
  final List<String> _selectedTags = [];

  /// Form submission state
  bool _isSubmitting = false;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();

    // TODO: If personId is provided, load person data and populate form
    // For now, form starts empty (create mode)

    if (widget.personId != null) {
      _loadPersonData();
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _contactFrequencyController.dispose();
    super.dispose();
  }

  // ============================================================================
  // DATA LOADING (EDIT MODE)
  // ============================================================================

  /// Load person data for editing
  ///
  /// TODO: Replace with actual repository call when implemented
  Future<void> _loadPersonData() async {
    // Placeholder for person loading
    // final person = await ref.read(personRepositoryProvider).getPerson(widget.personId!);
    // if (person != null) {
    //   setState(() {
    //     _nameController.text = person.name;
    //     _emailController.text = person.email ?? '';
    //     _phoneController.text = person.phone ?? '';
    //     _selectedCategory = person.category;
    //     _contactFrequencyController.text = person.contactFrequencyOverrideDays?.toString() ?? '';
    //     _notesController.text = person.notes ?? '';
    //     _selectedTags.addAll(person.tags);
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

  /// Build app bar with title
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.personId == null ? 'New Person' : 'Edit Person'),
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
            _buildNameField(),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPhoneField(),

            const SizedBox(height: 24),

            // Categorization Section
            _buildSectionHeader('Categorization'),
            const SizedBox(height: 12),
            _buildCategoryField(),

            const SizedBox(height: 24),

            // Pastoral Care Section
            _buildSectionHeader('Pastoral Care Settings'),
            const SizedBox(height: 12),
            _buildContactFrequencyField(),

            const SizedBox(height: 24),

            // Notes Section
            _buildSectionHeader('Notes'),
            const SizedBox(height: 12),
            _buildNotesField(),

            const SizedBox(height: 24),

            // Tags Section
            _buildSectionHeader('Tags (Optional)'),
            const SizedBox(height: 12),
            _buildTagsField(),

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

  /// Build name input field (required)
  Widget _buildNameField() {
    return Semantics(
      label: 'Person name',
      hint: 'Enter the person\'s full name',
      textField: true,
      child: TextFormField(
        controller: _nameController,
        autofocus: true, // Auto-focus for quick entry
        textCapitalization: TextCapitalization.words,
        maxLength: 100,
        decoration: InputDecoration(
          labelText: 'Name',
          hintText: 'Enter full name',
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
            return 'Please enter a name';
          }
          if (value.length > 100) {
            return 'Name must be 100 characters or less';
          }
          return null;
        },
      ),
    );
  }

  /// Build email input field (optional)
  Widget _buildEmailField() {
    return Semantics(
      label: 'Email address',
      hint: 'Optional email address',
      textField: true,
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email (optional)',
          hintText: 'email@example.com',
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
          prefixIcon: const Icon(Icons.email, size: 20),
        ),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            // Basic email validation
            if (!value.contains('@') || !value.contains('.')) {
              return 'Please enter a valid email';
            }
          }
          return null;
        },
      ),
    );
  }

  /// Build phone input field (optional)
  Widget _buildPhoneField() {
    return Semantics(
      label: 'Phone number',
      hint: 'Optional phone number',
      textField: true,
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Phone (optional)',
          hintText: '(123) 456-7890',
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
          prefixIcon: const Icon(Icons.phone, size: 20),
        ),
      ),
    );
  }

  /// Build category dropdown field (required)
  Widget _buildCategoryField() {
    // Person categories matching the database schema
    final categories = {
      'elder': 'Elder',
      'member': 'Member',
      'visitor': 'Visitor',
      'leadership': 'Leadership',
      'crisis': 'Crisis',
      'family': 'Family',
      'other': 'Other',
    };

    return Semantics(
      label: 'Person category',
      hint: 'Select a category for this person',
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
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

  /// Build contact frequency override field (optional)
  Widget _buildContactFrequencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Contact frequency override',
          hint: 'Optional custom contact frequency in days',
          textField: true,
          child: TextFormField(
            controller: _contactFrequencyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Contact Frequency Override (optional)',
              hintText: 'Days',
              helperText: 'Custom frequency in days (overrides category default)',
              helperMaxLines: 2,
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
              prefixIcon: const Icon(Icons.schedule, size: 20),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final days = int.tryParse(value);
                if (days == null || days <= 0) {
                  return 'Please enter a valid number of days';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Leave empty to use category default',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build notes input field (optional, multiline)
  Widget _buildNotesField() {
    return Semantics(
      label: 'Notes',
      hint: 'Optional notes about this person',
      textField: true,
      child: TextFormField(
        controller: _notesController,
        minLines: 3,
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Notes (optional)',
          hintText: 'Add any relevant notes...',
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

  /// Build tags field (optional)
  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display selected tags
        if (_selectedTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedTags.remove(tag);
                  });
                },
                backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
        if (_selectedTags.isNotEmpty) const SizedBox(height: 12),

        // Add tag button
        OutlinedButton.icon(
          onPressed: _showAddTagDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Tag'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tags help organize and filter people',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // SAVE BUTTON
  // ============================================================================

  /// Build save button at bottom of form
  Widget _buildSaveButton() {
    return Semantics(
      label: 'Save person',
      button: true,
      hint: 'Saves the person and returns to the list',
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _savePerson,
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
                'Save Person',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ============================================================================
  // ADD TAG DIALOG
  // ============================================================================

  /// Show add tag dialog
  Future<void> _showAddTagDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Tag name',
              hintText: 'e.g., Small Group, Volunteer',
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
                final tag = controller.text.trim();
                if (tag.isNotEmpty) {
                  Navigator.pop(context, tag);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null && !_selectedTags.contains(result)) {
      setState(() {
        _selectedTags.add(result);
      });
    }

    controller.dispose();
  }

  // ============================================================================
  // SAVE PERSON
  // ============================================================================

  /// Save person to database
  ///
  /// Validates form, shows loading state, saves to database,
  /// shows success message, and navigates back.
  ///
  /// TODO: Replace with actual person repository call when implemented
  Future<void> _savePerson() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Create PersonEntity and save to database via repository
      // Example:
      // final person = PersonEntity(
      //   id: widget.personId ?? const Uuid().v4(),
      //   userId: 'current-user-id', // Get from auth
      //   name: _nameController.text.trim(),
      //   email: _emailController.text.trim().isEmpty
      //       ? null
      //       : _emailController.text.trim(),
      //   phone: _phoneController.text.trim().isEmpty
      //       ? null
      //       : _phoneController.text.trim(),
      //   category: _selectedCategory!,
      //   contactFrequencyOverrideDays: _contactFrequencyController.text.isEmpty
      //       ? null
      //       : int.parse(_contactFrequencyController.text),
      //   notes: _notesController.text.trim().isEmpty
      //       ? null
      //       : _notesController.text.trim(),
      //   tags: _selectedTags,
      //   createdAt: DateTime.now(),
      //   updatedAt: DateTime.now(),
      //   localUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      // );
      //
      // if (widget.personId != null) {
      //   await ref.read(personRepositoryProvider).updatePerson(person);
      // } else {
      //   await ref.read(personRepositoryProvider).createPerson(person);
      // }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.personId == null
                ? 'Person created successfully!'
                : 'Person updated successfully!',
          ),
          backgroundColor: const Color(0xFF10B981), // Shepherd success green
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to people list
      Navigator.pop(context);
    } catch (error) {
      // Show error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save person: $error'),
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
}

// Usage examples:
//
// Create new person:
// ```dart
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => const PersonFormScreen(),
//   ),
// );
// ```
//
// Edit existing person:
// ```dart
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => PersonFormScreen(personId: person.id),
//   ),
// );
// ```
//
// With go_router:
// ```dart
// GoRoute(
//   path: '/people/new',
//   builder: (context, state) => const PersonFormScreen(),
// ),
// GoRoute(
//   path: '/people/:id/edit',
//   builder: (context, state) => PersonFormScreen(
//     personId: state.pathParameters['id'],
//   ),
// ),
// ```
