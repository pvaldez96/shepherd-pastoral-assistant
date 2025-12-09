import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/expandable_action_button.dart';

/// Enum representing different pages in the app
///
/// Used to determine which action button options to show based on the current page.
enum AppPage {
  /// Dashboard (Daily/Weekly/Monthly views)
  dashboard,

  /// Calendar page
  calendar,

  /// Tasks page
  tasks,

  /// People directory page
  people,

  /// Sermons page
  sermons,

  /// Notes page
  notes,

  /// Settings page
  settings,
}

/// Provider that returns the current app page based on the route location
///
/// Usage:
/// ```dart
/// final currentPage = ref.watch(currentPageProvider);
/// ```
final currentPageProvider = Provider<AppPage>((ref) {
  // This will be overridden in MainScaffold based on the current route
  return AppPage.dashboard;
});

/// Provider that returns the appropriate action button options for the current page
///
/// Each page has its own set of contextual actions:
/// - Dashboard: Returns null (uses normal quick capture button)
/// - Calendar: Add Event, Go to Today, Quick Capture
/// - Tasks: Add Task, Quick Capture
/// - People: Add Person, Quick Capture
/// - Sermons: Add Sermon, Quick Capture
/// - Notes: Add Note, Quick Capture
/// - Settings: No actions (null)
///
/// Usage:
/// ```dart
/// final options = ref.watch(actionButtonOptionsProvider);
/// if (options != null) {
///   return ExpandableActionButton(options: options);
/// } else {
///   return FloatingActionButton(onPressed: showQuickCapture);
/// }
/// ```
final actionButtonOptionsProvider = Provider<List<ActionButtonOption>?>((ref) {
  final currentPage = ref.watch(currentPageProvider);

  switch (currentPage) {
    case AppPage.dashboard:
      // Dashboard uses normal quick capture button, not expandable
      return null;

    case AppPage.calendar:
      return [
        ActionButtonOption(
          icon: Icons.event,
          label: 'Add Event',
          onTap: () {
            // TODO: Implement navigation to event form
            // This will be passed from MainScaffold
          },
        ),
        ActionButtonOption(
          icon: Icons.today,
          label: 'Go to Today',
          onTap: () {
            // TODO: Implement scroll to today
            // This will be passed from MainScaffold
          },
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: () {
            // TODO: Implement quick capture
            // This will be passed from MainScaffold
          },
        ),
      ];

    case AppPage.tasks:
      return [
        ActionButtonOption(
          icon: Icons.add_task,
          label: 'Add Task',
          onTap: () {
            // TODO: Implement navigation to task form
            // This will be passed from MainScaffold
          },
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: () {
            // TODO: Implement quick capture
            // This will be passed from MainScaffold
          },
        ),
      ];

    case AppPage.people:
      return [
        ActionButtonOption(
          icon: Icons.person_add,
          label: 'Add Person',
          onTap: () {
            // TODO: Implement navigation to person form
            // This will be passed from MainScaffold
          },
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: () {
            // TODO: Implement quick capture
            // This will be passed from MainScaffold
          },
        ),
      ];

    case AppPage.sermons:
      return [
        ActionButtonOption(
          icon: Icons.mic,
          label: 'Add Sermon',
          onTap: () {
            // TODO: Implement navigation to sermon form
            // This will be passed from MainScaffold
          },
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: () {
            // TODO: Implement quick capture
            // This will be passed from MainScaffold
          },
        ),
      ];

    case AppPage.notes:
      return [
        ActionButtonOption(
          icon: Icons.note_add,
          label: 'Add Note',
          onTap: () {
            // TODO: Implement navigation to note form
            // This will be passed from MainScaffold
          },
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: () {
            // TODO: Implement quick capture
            // This will be passed from MainScaffold
          },
        ),
      ];

    case AppPage.settings:
      // Settings page has no actions
      return null;
  }
});

/// Helper function to determine AppPage from route location
///
/// Usage:
/// ```dart
/// final page = getPageFromRoute('/calendar');
/// // Returns: AppPage.calendar
/// ```
AppPage getPageFromRoute(String location) {
  if (location.startsWith('/dashboard')) {
    return AppPage.dashboard;
  } else if (location.startsWith('/calendar')) {
    return AppPage.calendar;
  } else if (location.startsWith('/tasks')) {
    return AppPage.tasks;
  } else if (location.startsWith('/people')) {
    return AppPage.people;
  } else if (location.startsWith('/sermons')) {
    return AppPage.sermons;
  } else if (location.startsWith('/notes')) {
    return AppPage.notes;
  } else if (location.startsWith('/settings')) {
    return AppPage.settings;
  }

  // Default to dashboard
  return AppPage.dashboard;
}

/// Function to create action button options with actual callbacks
///
/// This is used by MainScaffold to provide the actual navigation callbacks
/// for each action.
///
/// Usage:
/// ```dart
/// final options = createActionButtonOptions(
///   page: AppPage.calendar,
///   onAddEvent: () => Navigator.push(...),
///   onGoToToday: () => scrollToToday(),
///   onQuickCapture: () => showQuickCapture(),
/// );
/// ```
List<ActionButtonOption> createActionButtonOptions({
  required AppPage page,
  VoidCallback? onAddEvent,
  VoidCallback? onGoToToday,
  VoidCallback? onAddTask,
  VoidCallback? onAddPerson,
  VoidCallback? onAddSermon,
  VoidCallback? onAddNote,
  required VoidCallback onQuickCapture,
}) {
  switch (page) {
    case AppPage.calendar:
      return [
        ActionButtonOption(
          icon: Icons.event,
          label: 'Add Event',
          onTap: onAddEvent ?? () {},
        ),
        ActionButtonOption(
          icon: Icons.today,
          label: 'Go to Today',
          onTap: onGoToToday ?? () {},
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: onQuickCapture,
        ),
      ];

    case AppPage.tasks:
      return [
        ActionButtonOption(
          icon: Icons.add_task,
          label: 'Add Task',
          onTap: onAddTask ?? () {},
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: onQuickCapture,
        ),
      ];

    case AppPage.people:
      return [
        ActionButtonOption(
          icon: Icons.person_add,
          label: 'Add Person',
          onTap: onAddPerson ?? () {},
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: onQuickCapture,
        ),
      ];

    case AppPage.sermons:
      return [
        ActionButtonOption(
          icon: Icons.mic,
          label: 'Add Sermon',
          onTap: onAddSermon ?? () {},
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: onQuickCapture,
        ),
      ];

    case AppPage.notes:
      return [
        ActionButtonOption(
          icon: Icons.note_add,
          label: 'Add Note',
          onTap: onAddNote ?? () {},
        ),
        ActionButtonOption(
          icon: Icons.add,
          label: 'Quick Capture',
          onTap: onQuickCapture,
        ),
      ];

    case AppPage.dashboard:
    case AppPage.settings:
      // These pages don't use expandable button
      return [];
  }
}

// Usage Example in MainScaffold:
// ```dart
// class _MainScaffoldState extends ConsumerState<MainScaffold> {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final location = GoRouterState.of(context).uri.toString();
//     final currentPage = getPageFromRoute(location);
//
//     Widget? actionButton;
//     if (currentPage == AppPage.dashboard) {
//       // Normal FAB for dashboard
//       actionButton = FloatingActionButton(
//         onPressed: _showQuickCaptureSheet,
//         child: const Icon(Icons.add),
//       );
//     } else if (currentPage != AppPage.settings) {
//       // Expandable button for other pages
//       final options = createActionButtonOptions(
//         page: currentPage,
//         onAddEvent: () => context.go('/calendar/new'),
//         onAddTask: () => Navigator.push(...),
//         onQuickCapture: _showQuickCaptureSheet,
//       );
//       if (options.isNotEmpty) {
//         actionButton = ExpandableActionButton(options: options);
//       }
//     }
//
//     return Scaffold(
//       floatingActionButton: actionButton,
//       // ...
//     );
//   }
// }
// ```
