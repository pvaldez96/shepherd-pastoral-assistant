import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Quick Note Form - Comprehensive fields for complete note creation
///
/// This form includes ALL available fields for note creation,
/// displayed in a scrollable bottom sheet for quick capture.
///
/// Fields:
/// - Title (optional, for note title)
/// - Content (required, multiline text field, auto-focus)
/// - Person Link (optional, dropdown)
/// - Tags (optional, multi-select - coming soon)
/// - Note Type/Category (dropdown - coming soon)
///
/// Features:
/// - Scrollable form that works in DraggableScrollableSheet
/// - Auto-focus on content field
/// - Multiline text input with expandable height
/// - Keyboard-friendly with proper text input actions
/// - Haptic feedback on save
/// - Loading state while saving
/// - Error handling with snackbar
/// - Follows Shepherd design system
///
/// Note: This form is a placeholder until the Notes module is fully implemented.
/// Some features are marked as "coming soon" and will be enabled when the
/// backend repository and data models are ready.
class QuickNoteForm extends ConsumerStatefulWidget {
  const QuickNoteForm({super.key});

  @override
  ConsumerState<QuickNoteForm> createState() => _QuickNoteFormState();
}

class _QuickNoteFormState extends ConsumerState<QuickNoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // TODO: Uncomment when person linking is implemented
  // String? _linkedPersonId;

  // TODO: Uncomment when note categories are implemented
  // String? _selectedCategory;

  // TODO: Uncomment when tags are implemented
  // List<String> _selectedTags = [];

  bool _isSaving = false;

  // TODO: Implement note categories when Notes module is ready
  // static const Map<String, String> _categoryOptions = {
  //   'general': 'General',
  //   'sermon_idea': 'Sermon Idea',
  //   'prayer_request': 'Prayer Request',
  //   'meeting_notes': 'Meeting Notes',
  //   'personal': 'Personal',
  // };

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
      // TODO: Implement note creation when Notes repository is ready
      // For now, simulate a save operation
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Uncomment and implement when Notes repository is ready:
      // final note = NoteEntity(
      //   id: const Uuid().v4(),
      //   userId: 'current-user-id',
      //   title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      //   content: _contentController.text.trim(),
      //   personId: _linkedPersonId,
      //   category: _selectedCategory,
      //   tags: _selectedTags,
      //   createdAt: DateTime.now(),
      //   updatedAt: DateTime.now(),
      //   localUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      // );
      //
      // await ref.read(noteRepositoryProvider).createNote(note);

      // Haptic feedback
      HapticFeedback.mediumImpact();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved! (Notes module coming soon)'),
            backgroundColor: Color(0xFFF59E0B), // Warning orange
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
            content: Text('Failed to save note: $error'),
            backgroundColor: const Color(0xFFEF4444), // Error red
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Watch people provider when linking notes to people is implemented
    // final peopleAsync = ref.watch(peopleProvider);

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
            _buildSectionHeader('Note Details'),
            const SizedBox(height: 12),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildContentField(),
            const SizedBox(height: 24),

            // Linking & Categorization Section
            _buildSectionHeader('Organization (Coming Soon)'),
            const SizedBox(height: 12),
            _buildPersonLinkPlaceholder(),
            const SizedBox(height: 16),
            _buildCategoryPlaceholder(),
            const SizedBox(height: 16),
            _buildTagsPlaceholder(),
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
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.note_add,
            color: Color(0xFFF59E0B),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Quick Note',
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
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Give your note a title (optional)',
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
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  /// Build content field (main note text)
  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      autofocus: true,
      maxLines: 8,
      minLines: 6,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Note Content *',
        hintText: 'What do you want to remember?',
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
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
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
      textInputAction: TextInputAction.newline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter note content';
        }
        return null;
      },
    );
  }

  /// Build person link placeholder
  Widget _buildPersonLinkPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Link to Person',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coming soon: Link notes to specific people',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build category placeholder
  Widget _buildCategoryPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.category_outlined, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coming soon: Categorize notes (Sermon Idea, Prayer, etc.)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build tags placeholder
  Widget _buildTagsPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.label_outline, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Coming soon: Tag notes for easy filtering',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF59E0B), // Warning orange
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
              'Save Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

// TODO: When Notes repository is implemented, update this form to:
// 1. Import the note entity and repository
// 2. Create note entities with proper fields
// 3. Call repository.createNote() instead of simulating
// 4. Add person linking dropdown when supported
// 5. Add category dropdown with note categories
// 6. Add multi-select tag input
// 7. Update success message to confirm actual save
//
// Example repository call structure:
// final noteRepository = ref.read(noteRepositoryProvider);
// await noteRepository.createNote(note);
