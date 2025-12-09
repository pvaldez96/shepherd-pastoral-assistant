# Expandable Action Button - Developer Guide

## Quick Start

The expandable action button is a reusable speed dial FAB that shows multiple contextual actions. It's automatically configured in MainScaffold based on the current page.

## Basic Usage

### Option 1: Use in MainScaffold (Recommended)
The button is already integrated! Just navigate to any page and it automatically shows the appropriate actions.

```dart
// Navigate to tasks page
context.go('/tasks');
// Action button automatically shows: Add Task, Quick Capture
```

### Option 2: Use Directly in Custom Screen

```dart
import 'package:shepherd/presentation/shared/widgets/expandable_action_button.dart';

class MyCustomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('My Screen')),
      floatingActionButton: ExpandableActionButton(
        options: [
          ActionButtonOption(
            icon: Icons.add,
            label: 'Add Item',
            onTap: () {
              // Handle add item
              print('Add item tapped');
            },
          ),
          ActionButtonOption(
            icon: Icons.edit,
            label: 'Edit',
            onTap: () {
              // Handle edit
              print('Edit tapped');
            },
            color: Colors.orange, // Optional custom color
          ),
        ],
      ),
    );
  }
}
```

## ActionButtonOption Properties

```dart
class ActionButtonOption {
  final IconData icon;        // Icon to display
  final String label;         // Text label shown next to button
  final VoidCallback onTap;   // Callback when tapped
  final Color? color;         // Optional custom color (defaults to primary)
}
```

## Adding Actions to a New Page

### Step 1: Add Page to AppPage Enum
```dart
// lib/presentation/shared/providers/action_button_provider.dart

enum AppPage {
  dashboard,
  calendar,
  tasks,
  people,
  sermons,
  notes,
  settings,
  myNewPage,  // Add your new page
}
```

### Step 2: Update getPageFromRoute()
```dart
AppPage getPageFromRoute(String location) {
  if (location.startsWith('/dashboard')) {
    return AppPage.dashboard;
  }
  // ... existing code ...
  else if (location.startsWith('/my-new-page')) {
    return AppPage.myNewPage;  // Add your route
  }

  return AppPage.dashboard;
}
```

### Step 3: Add Actions to createActionButtonOptions()
```dart
List<ActionButtonOption> createActionButtonOptions({
  required AppPage page,
  // ... existing parameters ...
  VoidCallback? onMyNewAction,  // Add your callback parameter
  required VoidCallback onQuickCapture,
}) {
  switch (page) {
    // ... existing cases ...

    case AppPage.myNewPage:
      return [
        ActionButtonOption(
          icon: Icons.star,
          label: 'My Action',
          onTap: onMyNewAction ?? () {},
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: onQuickCapture,
        ),
      ];

    // ... rest of cases ...
  }
}
```

### Step 4: Add Handler to MainScaffold
```dart
// lib/presentation/main/main_scaffold.dart

Widget? _buildActionButton(BuildContext context, AppPage page) {
  switch (page) {
    // ... existing cases ...

    case AppPage.myNewPage:
      return ExpandableActionButton(
        options: createActionButtonOptions(
          page: page,
          onMyNewAction: _handleMyNewAction,
          onQuickCapture: _showQuickCaptureSheet,
        ),
      );
  }
}

void _handleMyNewAction() {
  // Implement your action
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MyNewActionScreen(),
    ),
  );
}
```

## Examples

### Example 1: Simple Two-Button Menu
```dart
ExpandableActionButton(
  options: [
    ActionButtonOption(
      icon: Icons.camera,
      label: 'Take Photo',
      onTap: () => takePhoto(),
    ),
    ActionButtonOption(
      icon: Icons.image,
      label: 'Choose Image',
      onTap: () => chooseFromGallery(),
    ),
  ],
)
```

### Example 2: Multi-Action Menu with Custom Colors
```dart
ExpandableActionButton(
  options: [
    ActionButtonOption(
      icon: Icons.add,
      label: 'Create New',
      onTap: () => createNew(),
      color: Color(0xFF2563EB), // Blue
    ),
    ActionButtonOption(
      icon: Icons.edit,
      label: 'Edit Existing',
      onTap: () => edit(),
      color: Color(0xFFF59E0B), // Orange
    ),
    ActionButtonOption(
      icon: Icons.delete,
      label: 'Delete',
      onTap: () => delete(),
      color: Color(0xFFEF4444), // Red
    ),
  ],
)
```

### Example 3: Navigation Actions
```dart
ExpandableActionButton(
  options: [
    ActionButtonOption(
      icon: Icons.event,
      label: 'Add Event',
      onTap: () => context.push('/calendar/new'),
    ),
    ActionButtonOption(
      icon: Icons.task,
      label: 'Add Task',
      onTap: () => context.push('/tasks/new'),
    ),
    ActionButtonOption(
      icon: Icons.note,
      label: 'Quick Note',
      onTap: () => showQuickNoteDialog(context),
    ),
  ],
)
```

## Animation Customization

The animations are pre-configured for optimal UX. If you need to customize:

```dart
// In expandable_action_button.dart

// Change animation duration
_animationController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 300), // Default: 250ms
);

// Change stagger delay
final delay = index * 0.08; // Default: 0.05

// Change rotation amount
end: 0.25, // 90 degrees (default: 0.125 = 45 degrees)
```

## Styling Guidelines

### Colors
- Primary actions: Use theme primary color (#2563EB)
- Warning actions: Use warning color (#F59E0B)
- Danger actions: Use error color (#EF4444)
- Success actions: Use success color (#10B981)

### Icons
- Use Material Icons
- Keep icons semantically meaningful
- Size: 24px (automatically applied)

### Labels
- Keep short (2-3 words max)
- Use title case (e.g., "Add Task")
- Be action-oriented (start with verb)

## Best Practices

### DO:
✅ Keep options count to 2-4 items
✅ Order by importance (most important at top)
✅ Use clear, action-oriented labels
✅ Provide semantic hints for accessibility
✅ Test with screen readers
✅ Use consistent icons across the app

### DON'T:
❌ Add more than 5 options (gets crowded)
❌ Use vague labels like "OK" or "Do it"
❌ Forget to add color parameter for danger actions
❌ Nest navigation actions (keep flat)
❌ Use tiny icons or long labels

## Accessibility

The component includes built-in accessibility:

- **Screen Reader Labels**: Each option announces its label
- **Hints**: Provides context ("Double tap to add task")
- **Touch Targets**: Minimum 56x56 (exceeds 44x44 requirement)
- **High Contrast**: White on color backgrounds
- **Focus Management**: Proper focus order

### Testing with Screen Readers

**Android (TalkBack):**
```
Settings → Accessibility → TalkBack → On
```

**iOS (VoiceOver):**
```
Settings → Accessibility → VoiceOver → On
```

## Troubleshooting

### Button Doesn't Expand
- Check that options list is not empty
- Verify animation controller is properly initialized
- Check for conflicting gesture detectors

### Options Appear Instantly (No Animation)
- Ensure `SingleTickerProviderStateMixin` is added to State
- Check animation controller duration is not zero
- Verify `pumpAndSettle()` in widget tests

### Button Not Showing
- Check if page returns null from `_buildActionButton()`
- Verify route is mapped in `getPageFromRoute()`
- Check for conflicting `floatingActionButton` in screen

### Callbacks Not Firing
- Ensure `onTap` is properly assigned
- Check if menu closes too quickly (delay is 100ms)
- Verify callback function is not null

## Performance Tips

1. **Use const constructors** when possible:
```dart
const ActionButtonOption(
  icon: Icons.add,
  label: 'Add',
  onTap: myCallback, // Can't be const if callback isn't const
)
```

2. **Avoid rebuilding entire widget tree**:
```dart
// Good: Only rebuild button
final options = useMemoized(() => createOptions(), [dependency]);

// Bad: Rebuild on every frame
final options = createOptions();
```

3. **Dispose properly**:
```dart
@override
void dispose() {
  _animationController.dispose();
  super.dispose();
}
```

## Common Patterns

### Pattern 1: Add + Quick Capture
Most common pattern for data entry screens:
```dart
options: [
  ActionButtonOption(icon: Icons.add_task, label: 'Add Task', onTap: addTask),
  ActionButtonOption(icon: Icons.add, label: 'Quick Capture', onTap: quickCapture),
]
```

### Pattern 2: CRUD Operations
For detail/edit screens:
```dart
options: [
  ActionButtonOption(icon: Icons.save, label: 'Save', onTap: save),
  ActionButtonOption(icon: Icons.share, label: 'Share', onTap: share),
  ActionButtonOption(icon: Icons.delete, label: 'Delete', onTap: delete, color: Colors.red),
]
```

### Pattern 3: View Switching
For screens with multiple views:
```dart
options: [
  ActionButtonOption(icon: Icons.list, label: 'List View', onTap: () => switchView('list')),
  ActionButtonOption(icon: Icons.grid_view, label: 'Grid View', onTap: () => switchView('grid')),
  ActionButtonOption(icon: Icons.calendar_today, label: 'Calendar', onTap: () => switchView('cal')),
]
```

## Version History

### v1.0.0 (December 9, 2024)
- Initial implementation
- Speed dial animation
- Staggered appearance
- Accessibility support
- Integration with MainScaffold

---

**Need Help?**
- Check the implementation in `expandable_action_button.dart`
- Review examples in `action_button_provider.dart`
- See usage in `main_scaffold.dart`
