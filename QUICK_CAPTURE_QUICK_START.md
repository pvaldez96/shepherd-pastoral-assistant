# Quick Capture - Quick Start Guide

## For Developers

### How to Use Quick Capture

The Quick Capture feature is automatically available in the bottom navigation. Users tap the (+) button to open it.

### File Locations

```
lib/presentation/quick_capture/
├── quick_capture_sheet.dart          # Main entry point
└── forms/
    ├── quick_task_form.dart          # Creates tasks
    ├── quick_event_form.dart         # Creates events
    ├── quick_note_form.dart          # Creates notes (TODO)
    └── quick_contact_log_form.dart   # Logs contacts
```

### Opening Quick Capture Programmatically

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => const QuickCaptureSheet(),
);
```

### Repository Methods Used

**Tasks:**
```dart
await ref.read(taskRepositoryProvider).createTask(task);
```

**Events:**
```dart
await ref.read(calendarEventRepositoryProvider).createEvent(event);
```

**Contact Logs:**
```dart
await ref.read(personRepositoryProvider).logContact(contactLog);
```

**Notes (TODO):**
```dart
await ref.read(noteRepositoryProvider).createNote(note);
```

### Adding a New Quick Capture Type

1. Create a new form in `lib/presentation/quick_capture/forms/`
2. Import it in `quick_capture_sheet.dart`
3. Add a new case to `_buildContent()` switch statement
4. Add a new `_TypeCard` in `_buildTypeSelection()`
5. Choose an appropriate color from the design system

### Form Structure Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickXxxForm extends ConsumerStatefulWidget {
  const QuickXxxForm({super.key});

  @override
  ConsumerState<QuickXxxForm> createState() => _QuickXxxFormState();
}

class _QuickXxxFormState extends ConsumerState<QuickXxxForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Create entity and save
      await ref.read(xxxRepositoryProvider).createXxx(xxx);

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $error'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            // Title
            Text('Quick Xxx', style: ...),

            // Fields
            TextFormField(
              controller: _controller,
              autofocus: true,
              // ...
            ),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                ? CircularProgressIndicator(...)
                : Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Design System Colors

```dart
const primaryBlue = Color(0xFF2563EB);    // Tasks, primary actions
const successGreen = Color(0xFF10B981);   // Events, success states
const warningOrange = Color(0xFFF59E0B);  // Notes, warnings
const errorRed = Color(0xFFEF4444);       // Errors
const purple = Color(0xFF8B5CF6);         // Contact Logs
```

### Common Patterns

**Date Picker:**
```dart
final DateTime? picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime.now(),
  lastDate: DateTime.now().add(Duration(days: 365)),
);
```

**Time Picker:**
```dart
final TimeOfDay? picked = await showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
);
```

**Filter Chips:**
```dart
FilterChip(
  label: Text('Option'),
  selected: _selected == value,
  onSelected: (selected) => setState(() => _selected = value),
  selectedColor: Color(0xFF2563EB).withValues(alpha: 0.2),
)
```

**Success Snackbar:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success message'),
    backgroundColor: Color(0xFF10B981),
    duration: Duration(seconds: 2),
  ),
);
```

**Error Snackbar:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Error message'),
    backgroundColor: Color(0xFFEF4444),
    duration: Duration(seconds: 3),
  ),
);
```

### Testing Quick Capture

**Manual Test:**
1. Run the app: `flutter run`
2. Tap the (+) button in bottom nav
3. Try creating each type of item
4. Verify success messages appear
5. Verify items appear in their respective lists

**Widget Test Example:**
```dart
testWidgets('Quick Task Form saves task', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: QuickTaskForm(),
        ),
      ),
    ),
  );

  // Enter title
  await tester.enterText(
    find.byType(TextFormField).first,
    'Test Task',
  );

  // Tap save
  await tester.tap(find.text('Save Task'));
  await tester.pumpAndSettle();

  // Verify success (would need mocking in real test)
  expect(find.text('Task created successfully!'), findsOneWidget);
});
```

### Troubleshooting

**Issue:** Sheet doesn't open
- Check that `backgroundColor: Colors.transparent` is set in `showModalBottomSheet`
- Verify import path is correct

**Issue:** Form doesn't save
- Check repository provider is available in widget tree
- Verify all required fields have values
- Check console for error messages

**Issue:** Keyboard covers fields
- Ensure `isScrollControlled: true` is set
- Verify bottom padding uses `MediaQuery.of(context).viewInsets.bottom`

**Issue:** People dropdown is empty in Contact Log
- Run `flutter run` to seed some test data first
- Verify people exist in the database

### Next Steps for Notes Implementation

When the Notes module is ready:

1. Create `NoteEntity` in `lib/domain/entities/note.dart`
2. Create `NoteRepository` in `lib/domain/repositories/note_repository.dart`
3. Implement repository in `lib/data/repositories/note_repository_impl.dart`
4. Create note providers in `lib/presentation/notes/providers/note_providers.dart`
5. Update `quick_note_form.dart`:
   - Import note entity and repository
   - Remove TODO comments
   - Uncomment entity creation code
   - Replace simulated save with actual `createNote()` call
   - Update success message

All the form structure is ready - just need to plug in the real repository!

## Quick Reference

### Colors
- Primary: `#2563EB` (blue)
- Success: `#10B981` (green)
- Warning: `#F59E0B` (orange)
- Error: `#EF4444` (red)
- Purple: `#8B5CF6`

### Spacing
- 8px, 12px, 16px, 24px (multiples of 4px)

### Border Radius
- Cards: 12px
- Buttons/Inputs: 8px
- Sheet top: 16px

### Touch Targets
- Minimum: 44x44
- Type cards: 88px height

### Form Requirements
- First field: `autofocus: true`
- Required fields: Label ends with ` *`
- Loading state: Disable button, show spinner
- Success: Haptic + snackbar + close
- Error: Keep open + show snackbar
