import 'package:flutter/material.dart';
import 'forms/quick_task_form.dart';
import 'forms/quick_event_form.dart';
import 'forms/quick_note_form.dart';
import 'forms/quick_contact_log_form.dart';

/// Quick Capture bottom sheet for fast data entry
///
/// Step 1: Type Selection Screen - Shows 4 large tappable cards
/// Step 2: Context-aware form based on selection
///
/// Features:
/// - Fast entry with minimal fields
/// - Smart defaults
/// - Auto-focus on first field
/// - Keyboard-friendly
/// - Haptic feedback on save
/// - Proper error handling
class QuickCaptureSheet extends StatefulWidget {
  const QuickCaptureSheet({super.key});

  @override
  State<QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends State<QuickCaptureSheet> {
  /// Current view: 'selection', 'task', 'event', 'note', 'contact_log'
  String _currentView = 'selection';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with handle bar and close button
          _buildHeader(),

          // Content based on current view
          Flexible(
            child: SingleChildScrollView(
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build header with handle bar, back button, and close button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button (only show when not in selection view)
          if (_currentView != 'selection')
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _currentView = 'selection';
                });
              },
              tooltip: 'Back to selection',
            )
          else
            const SizedBox(width: 48), // Spacer for alignment

          // Handle bar (centered)
          Expanded(
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Close button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  /// Build content based on current view
  Widget _buildContent() {
    switch (_currentView) {
      case 'task':
        return const QuickTaskForm();
      case 'event':
        return const QuickEventForm();
      case 'note':
        return const QuickNoteForm();
      case 'contact_log':
        return const QuickContactLogForm();
      case 'selection':
      default:
        return _buildTypeSelection();
    }
  }

  /// Build type selection screen with 4 large cards
  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Quick Capture',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to add?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Type selection cards
          _TypeCard(
            icon: Icons.check_box_outlined,
            label: 'Task',
            color: const Color(0xFF2563EB), // Primary blue
            onTap: () {
              setState(() {
                _currentView = 'task';
              });
            },
          ),
          const SizedBox(height: 12),

          _TypeCard(
            icon: Icons.event,
            label: 'Event',
            color: const Color(0xFF10B981), // Success green
            onTap: () {
              setState(() {
                _currentView = 'event';
              });
            },
          ),
          const SizedBox(height: 12),

          _TypeCard(
            icon: Icons.note_add,
            label: 'Note',
            color: const Color(0xFFF59E0B), // Warning orange
            onTap: () {
              setState(() {
                _currentView = 'note';
              });
            },
          ),
          const SizedBox(height: 12),

          _TypeCard(
            icon: Icons.contact_phone,
            label: 'Contact Log',
            color: const Color(0xFF8B5CF6), // Purple
            onTap: () {
              setState(() {
                _currentView = 'contact_log';
              });
            },
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

/// Type selection card widget
///
/// Large, tappable card with icon and label.
/// Minimum 88px height for easy tapping.
class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(minHeight: 88),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),

                // Label
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                  ),
                ),

                // Chevron icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Usage:
// showModalBottomSheet(
//   context: context,
//   isScrollControlled: true,
//   backgroundColor: Colors.transparent,
//   builder: (context) => const QuickCaptureSheet(),
// );
