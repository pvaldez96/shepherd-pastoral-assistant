import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_notifier.dart';
import 'widgets/quick_capture_bottom_sheet.dart';

/// Main scaffold with persistent navigation components
///
/// This widget wraps all main app screens and provides:
/// - Bottom navigation bar with 4 tabs (Daily, Weekly, Monthly, Quick Capture)
/// - Side drawer (hamburger menu) from right side
/// - AppBar with title and menu button
///
/// The scaffold is shared across all protected routes via ShellRoute,
/// ensuring navigation elements remain visible when switching screens.
///
/// Features:
/// - Bottom navigation highlights current route
/// - Drawer menu highlights current route
/// - Quick Capture bottom sheet for quick data entry
/// - Sign out functionality in drawer
/// - Responsive to current route changes
class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  /// Get the current tab index based on the current route
  int _getCurrentTabIndex(String location) {
    // Extract view parameter from dashboard route
    if (location.startsWith('/dashboard')) {
      final uri = Uri.parse(location);
      final view = uri.queryParameters['view'] ?? 'daily';

      switch (view) {
        case 'daily':
          return 0;
        case 'weekly':
          return 1;
        case 'monthly':
          return 2;
        default:
          return 0;
      }
    }

    // Default to Daily tab for all other routes
    return 0;
  }

  /// Handle bottom navigation tap
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/dashboard?view=daily');
        break;
      case 1:
        context.go('/dashboard?view=weekly');
        break;
      case 2:
        context.go('/dashboard?view=monthly');
        break;
      case 3:
        // Show Quick Capture bottom sheet
        _showQuickCaptureSheet();
        break;
    }
  }

  /// Show Quick Capture bottom sheet
  void _showQuickCaptureSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const QuickCaptureBottomSheet(),
    );
  }

  /// Get page title based on current route
  String _getPageTitle(String location) {
    if (location.startsWith('/dashboard')) {
      final uri = Uri.parse(location);
      final view = uri.queryParameters['view'] ?? 'daily';
      return 'Shepherd - ${view[0].toUpperCase()}${view.substring(1)} View';
    }

    if (location.startsWith('/tasks')) return 'Tasks';
    if (location.startsWith('/calendar')) return 'Calendar';
    if (location.startsWith('/people')) return 'People & Contacts';
    if (location.startsWith('/sermons')) return 'Sermons';
    if (location.startsWith('/notes')) return 'Notes';
    if (location.startsWith('/settings')) return 'Settings';

    return 'Shepherd';
  }

  /// Check if a drawer item is selected
  bool _isDrawerItemSelected(String location, String route) {
    return location.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentTabIndex = _getCurrentTabIndex(location);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      // AppBar with title and menu button (right side)
      appBar: AppBar(
        title: Text(_getPageTitle(location)),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide default leading
        actions: [
          // Menu button (right side) - opens drawer
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

      // Right-side drawer (endDrawer)
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Drawer header with user info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.user?.userMetadata?['name'] as String? ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (authState.user?.userMetadata?['church_name'] != null)
                      Text(
                        authState.user!.userMetadata!['church_name'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (authState.user?.email != null)
                      Text(
                        authState.user!.email!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),

              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _DrawerItem(
                      icon: Icons.check_box_outlined,
                      label: 'Tasks',
                      isSelected: _isDrawerItemSelected(location, '/tasks'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        context.go('/tasks');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_today,
                      label: 'Calendar',
                      isSelected: _isDrawerItemSelected(location, '/calendar'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/calendar');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.people_outline,
                      label: 'People',
                      isSelected: _isDrawerItemSelected(location, '/people'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/people');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.mic_none,
                      label: 'Sermons',
                      isSelected: _isDrawerItemSelected(location, '/sermons'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/sermons');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.notes,
                      label: 'Notes',
                      isSelected: _isDrawerItemSelected(location, '/notes'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/notes');
                      },
                    ),
                    const Divider(height: 24),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      isSelected: _isDrawerItemSelected(location, '/settings'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/settings');
                      },
                    ),
                  ],
                ),
              ),

              // Sign out button at bottom
              const Divider(height: 1),
              _DrawerItem(
                icon: Icons.logout,
                label: 'Sign Out',
                iconColor: const Color(0xFFEF4444),
                textColor: const Color(0xFFEF4444),
                onTap: () async {
                  Navigator.pop(context); // Close drawer

                  final shouldSignOut = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );

                  if (shouldSignOut == true && context.mounted) {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signed out successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // Body - child widget from router
      body: widget.child,

      // Bottom navigation bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTabIndex,
        onDestinationSelected: _onBottomNavTap,
        backgroundColor: Colors.white,
        elevation: 8,
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Daily',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_week_outlined),
            selectedIcon: Icon(Icons.view_week),
            label: 'Weekly',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Monthly',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Quick Capture',
          ),
        ],
      ),
    );
  }
}

/// Drawer menu item widget
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final effectiveIconColor = iconColor ?? (isSelected ? primaryColor : Colors.grey.shade700);
    final effectiveTextColor = textColor ?? (isSelected ? primaryColor : Colors.grey.shade900);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: effectiveIconColor,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: effectiveTextColor,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        // Ensure minimum touch target size
        minVerticalPadding: 12,
      ),
    );
  }
}

// Usage:
// This widget is used automatically by ShellRoute in app_router.dart
// No need to use it directly in other parts of the app
//
// Navigation is handled by go_router:
// - context.go('/tasks')
// - context.go('/dashboard?view=weekly')
// - etc.
