import 'package:flutter/material.dart';

/// Option for the expandable action button
///
/// Each option represents an action that can be triggered from the expanded menu.
/// Options are displayed as icon + label buttons that expand upward from the FAB.
class ActionButtonOption {
  /// Icon to display for this option
  final IconData icon;

  /// Label text to display next to the icon
  final String label;

  /// Callback when this option is tapped
  final VoidCallback onTap;

  /// Optional custom color for this option
  /// If null, uses the theme's primary color
  final Color? color;

  const ActionButtonOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

/// Expandable speed dial style FAB that shows multiple action options
///
/// Features:
/// - Shows a [+] button by default
/// - When pressed, expands upward to show multiple action options
/// - Each option has an icon and label
/// - Tapping outside closes the menu
/// - Smooth animations with staggered appearance
/// - Full accessibility support
///
/// Design:
/// - Main FAB: 56x56 with primary blue color (#2563EB)
/// - Option buttons: 48x48 with white background
/// - Labels: White text on semi-transparent background
/// - Animations: 250ms duration with curves
/// - Backdrop: Semi-transparent overlay when expanded
///
/// Usage:
/// ```dart
/// ExpandableActionButton(
///   options: [
///     ActionButtonOption(
///       icon: Icons.add_task,
///       label: 'Add Task',
///       onTap: () => print('Add task'),
///     ),
///     ActionButtonOption(
///       icon: Icons.add,
///       label: 'Quick Capture',
///       onTap: () => print('Quick capture'),
///     ),
///   ],
/// )
/// ```
///
/// Accessibility:
/// - Semantics labels for screen readers
/// - Minimum 44x44 touch targets
/// - Clear focus indicators
/// - Meaningful button descriptions
class ExpandableActionButton extends StatefulWidget {
  /// List of action options to display when expanded
  final List<ActionButtonOption> options;

  const ExpandableActionButton({
    super.key,
    required this.options,
  });

  @override
  State<ExpandableActionButton> createState() => _ExpandableActionButtonState();
}

class _ExpandableActionButtonState extends State<ExpandableActionButton>
    with SingleTickerProviderStateMixin {
  /// Animation controller for expand/collapse animation
  late AnimationController _animationController;

  /// Animation for the main FAB rotation
  late Animation<double> _rotationAnimation;

  /// Animation for the backdrop opacity
  late Animation<double> _backdropAnimation;

  /// Whether the menu is currently expanded
  bool get _isExpanded => _animationController.isCompleted;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Rotation animation for the main FAB icon (+ rotates to X)
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45 degrees (1/8 of full rotation)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Backdrop opacity animation
    _backdropAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Toggle the expanded state
  void _toggle() {
    if (_isExpanded) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  /// Close the menu
  void _close() {
    if (_isExpanded) {
      _animationController.reverse();
    }
  }

  /// Handle option tap
  void _handleOptionTap(ActionButtonOption option) {
    // Close menu first
    _close();

    // Wait for animation to complete before executing callback
    Future.delayed(const Duration(milliseconds: 100), () {
      option.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Backdrop overlay - tapping closes the menu
        AnimatedBuilder(
          animation: _backdropAnimation,
          builder: (context, child) {
            if (_backdropAnimation.value == 0) {
              return const SizedBox.shrink();
            }

            return Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4 * _backdropAnimation.value),
                ),
              ),
            );
          },
        ),

        // Action options (expanded upward)
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Build option buttons with staggered animation
                ...widget.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;

                  // Stagger the animation for each option
                  final delay = index * 0.05;
                  final adjustedValue = (_animationController.value - delay).clamp(0.0, 1.0);

                  // Scale and fade animation for each option
                  final scale = Curves.easeOutBack.transform(adjustedValue);
                  final opacity = adjustedValue;

                  if (opacity == 0) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: opacity,
                        child: _buildOptionButton(context, option, theme),
                      ),
                    ),
                  );
                }).toList().reversed,

                // Main FAB
                _buildMainFAB(theme),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Build an individual option button
  Widget _buildOptionButton(
    BuildContext context,
    ActionButtonOption option,
    ThemeData theme,
  ) {
    final buttonColor = option.color ?? theme.colorScheme.primary;

    return Semantics(
      label: option.label,
      button: true,
      hint: 'Double tap to ${option.label.toLowerCase()}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              option.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Icon button
          Material(
            color: buttonColor,
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(28),
            child: InkWell(
              onTap: () => _handleOptionTap(option),
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: Icon(
                  option.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the main FAB
  Widget _buildMainFAB(ThemeData theme) {
    return Semantics(
      label: _isExpanded ? 'Close menu' : 'Open action menu',
      button: true,
      hint: _isExpanded
          ? 'Double tap to close action menu'
          : 'Double tap to open action menu with multiple options',
      child: Material(
        color: theme.colorScheme.primary,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159, // Convert to radians
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Usage Example:
// ```dart
// FloatingActionButton location in Scaffold:
//
// Scaffold(
//   floatingActionButton: ExpandableActionButton(
//     options: [
//       ActionButtonOption(
//         icon: Icons.event_add,
//         label: 'Add Event',
//         onTap: () => Navigator.push(...),
//       ),
//       ActionButtonOption(
//         icon: Icons.today,
//         label: 'Go to Today',
//         onTap: () => scrollToToday(),
//       ),
//       ActionButtonOption(
//         icon: Icons.add,
//         label: 'Quick Capture',
//         onTap: () => showQuickCapture(),
//       ),
//     ],
//   ),
// )
// ```
