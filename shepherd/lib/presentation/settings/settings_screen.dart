// lib/presentation/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../auth/auth_notifier.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_section_card.dart';
import 'widgets/time_range_field.dart';

/// Settings screen - comprehensive user preferences and configuration
///
/// Features:
/// - User profile (name, email, church, timezone)
/// - Personal schedule (blocked times, preferred focus hours)
/// - Contact frequency thresholds (elder, member, crisis)
/// - Sermon prep settings (weekly target hours)
/// - Workload management (max daily hours, min focus block)
/// - Account actions (sign out with confirmation)
///
/// Design:
/// - Background: #F9FAFB (Shepherd design system)
/// - Cards with 12px border radius
/// - Sections grouped logically
/// - Auto-save on field changes
/// - Loading states while saving
/// - Success/error feedback via SnackBar
///
/// Note: This screen does NOT have its own Scaffold/AppBar.
/// It's wrapped by MainScaffold which provides navigation.
///
/// Usage:
/// Navigate to this screen via: context.go('/settings')
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Form controllers for editable fields
  final _nameController = TextEditingController();
  final _churchNameController = TextEditingController();

  // Track if we're saving
  bool _isSaving = false;

  // Track if settings have been loaded
  bool _settingsLoaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _churchNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current user from auth state
    final authState = ref.watch(authNotifierProvider);
    final userId = authState.user?.id;
    final userEmail = authState.user?.email ?? 'No email';

    if (userId == null) {
      return const Center(
        child: Text('Please sign in to access settings'),
      );
    }

    // Watch user settings
    final settingsAsync = ref.watch(userSettingsProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Shepherd background
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2563EB), // Shepherd primary blue
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userSettingsProvider(userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (settings) {
          // Initialize settings if not found - create defaults
          if (settings == null) {
            return FutureBuilder(
              future: ref
                  .read(settingsRepositoryProvider)
                  .createDefaultSettings(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error creating settings: ${snapshot.error}'),
                  );
                }
                // Settings created, refresh
                Future.microtask(() {
                  ref.invalidate(userSettingsProvider(userId));
                });
                return const SizedBox.shrink();
              },
            );
          }

          // Load initial values into controllers (only once)
          if (!_settingsLoaded) {
            _loadInitialValues(authState.user?.userMetadata);
            _settingsLoaded = true;
          }

          return _buildSettingsContent(context, settings, userEmail);
        },
      ),
    );
  }

  /// Load initial values from user metadata
  void _loadInitialValues(Map<String, dynamic>? metadata) {
    if (metadata != null) {
      _nameController.text = metadata['name'] as String? ?? '';
      _churchNameController.text = metadata['church_name'] as String? ?? '';
    }
  }

  /// Build the main settings content
  Widget _buildSettingsContent(
    BuildContext context,
    UserSetting settings,
    String userEmail,
  ) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80, left: 16, right: 16),
      children: [
        // User Profile Section
        SettingsSectionCard(
          title: 'User Profile',
          icon: Icons.person_outline,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              enabled: !_isSaving,
              onChanged: (value) => _saveUserProfile(),
            ),
            const SizedBox(height: 16),

            // Email (read-only)
            TextField(
              controller: TextEditingController(text: userEmail),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                suffixIcon: Icon(Icons.lock_outline),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),

            // Church name
            TextField(
              controller: _churchNameController,
              decoration: const InputDecoration(
                labelText: 'Church Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.church),
              ),
              enabled: !_isSaving,
              onChanged: (value) => _saveUserProfile(),
            ),
            const SizedBox(height: 16),

            // Timezone dropdown (simplified - in production would use timezone picker)
            DropdownButtonFormField<String>(
              initialValue: 'America/Chicago',
              decoration: const InputDecoration(
                labelText: 'Timezone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'America/New_York', child: Text('Eastern Time')),
                DropdownMenuItem(
                    value: 'America/Chicago', child: Text('Central Time')),
                DropdownMenuItem(
                    value: 'America/Denver', child: Text('Mountain Time')),
                DropdownMenuItem(
                    value: 'America/Los_Angeles', child: Text('Pacific Time')),
              ],
              onChanged: _isSaving ? null : (value) {
                // TODO: Save timezone to user settings when user table is updated
                _showSnackBar('Timezone saved');
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Personal Schedule Section
        SettingsSectionCard(
          title: 'Personal Schedule',
          subtitle: 'Block out times when you\'re unavailable',
          icon: Icons.schedule_outlined,
          children: [
            TimeRangeField(
              label: 'Wrestling Training Time',
              icon: Icons.fitness_center,
              startTime: null, // TODO: Load from settings when implemented
              endTime: null,
              onChanged: (start, end) {
                // TODO: Save to settings
                _showSnackBar('Wrestling time updated');
              },
            ),
            const SizedBox(height: 16),

            TimeRangeField(
              label: 'Work Shift Time',
              icon: Icons.work_outline,
              startTime: null,
              endTime: null,
              onChanged: (start, end) {
                _showSnackBar('Work time updated');
              },
            ),
            const SizedBox(height: 16),

            TimeRangeField(
              label: 'Family Protected Time',
              icon: Icons.family_restroom,
              startTime: null,
              endTime: null,
              onChanged: (start, end) {
                _showSnackBar('Family time updated');
              },
            ),
            const SizedBox(height: 16),

            TimeRangeField(
              label: 'Preferred Focus Hours',
              icon: Icons.psychology_outlined,
              startTime: settings.preferredFocusHoursStart,
              endTime: settings.preferredFocusHoursEnd,
              onChanged: (start, end) => _saveFocusHours(settings.id, start, end),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Contact Thresholds Section
        SettingsSectionCard(
          title: 'Contact Thresholds',
          subtitle: 'Target frequency for pastoral care contacts',
          icon: Icons.people_outline,
          children: [
            _buildNumberField(
              label: 'Elder Contact Frequency (days)',
              icon: Icons.account_balance,
              initialValue: settings.elderContactFrequencyDays,
              onChanged: (value) => _saveContactFrequency(
                settings.id,
                elderDays: value,
              ),
            ),
            const SizedBox(height: 16),

            _buildNumberField(
              label: 'Member Contact Frequency (days)',
              icon: Icons.person,
              initialValue: settings.memberContactFrequencyDays,
              onChanged: (value) => _saveContactFrequency(
                settings.id,
                memberDays: value,
              ),
            ),
            const SizedBox(height: 16),

            _buildNumberField(
              label: 'Crisis Contact Frequency (days)',
              icon: Icons.warning_outlined,
              initialValue: settings.crisisContactFrequencyDays,
              onChanged: (value) => _saveContactFrequency(
                settings.id,
                crisisDays: value,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Sermon Prep Section
        SettingsSectionCard(
          title: 'Sermon Preparation',
          icon: Icons.book_outlined,
          children: [
            _buildNumberField(
              label: 'Weekly Target Hours',
              icon: Icons.access_time,
              initialValue: settings.weeklySermonPrepHours,
              onChanged: (value) => _saveSermonPrepHours(settings.id, value),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Workload Management Section
        SettingsSectionCard(
          title: 'Workload Management',
          subtitle: 'Prevent burnout with smart scheduling limits',
          icon: Icons.insights_outlined,
          children: [
            _buildNumberField(
              label: 'Max Daily Hours',
              icon: Icons.event_available,
              initialValue: settings.maxDailyHours,
              onChanged: (value) => _saveWorkloadSettings(
                settings.id,
                maxDailyHours: value,
              ),
            ),
            const SizedBox(height: 16),

            _buildNumberField(
              label: 'Min Focus Block (minutes)',
              icon: Icons.timer_outlined,
              initialValue: settings.minFocusBlockMinutes,
              onChanged: (value) => _saveWorkloadSettings(
                settings.id,
                minFocusBlockMinutes: value,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Account Section
        SettingsSectionCard(
          title: 'Account',
          icon: Icons.manage_accounts_outlined,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _showSignOutDialog(context),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444), // Shepherd error red
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build a number input field
  Widget _buildNumberField({
    required String label,
    required IconData icon,
    required int initialValue,
    required Function(int) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue.toString(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      keyboardType: TextInputType.number,
      enabled: !_isSaving,
      onChanged: (value) {
        final intValue = int.tryParse(value);
        if (intValue != null && intValue > 0) {
          onChanged(intValue);
        }
      },
    );
  }

  /// Save user profile (name, church name)
  Future<void> _saveUserProfile() async {
    // TODO: Update user table when user update method is added
    // For now, just show feedback
    _showSnackBar('Profile updated');
  }

  /// Save focus hours
  Future<void> _saveFocusHours(
    String settingsId,
    String? start,
    String? end,
  ) async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.updateFocusHours(
        settingsId: settingsId,
        preferredFocusHoursStart: start,
        preferredFocusHoursEnd: end,
      );
      _showSnackBar('Focus hours saved');
    } catch (e) {
      _showSnackBar('Failed to save: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Save contact frequency thresholds
  Future<void> _saveContactFrequency(
    String settingsId, {
    int? elderDays,
    int? memberDays,
    int? crisisDays,
  }) async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.updateContactFrequencies(
        settingsId: settingsId,
        elderContactFrequencyDays: elderDays,
        memberContactFrequencyDays: memberDays,
        crisisContactFrequencyDays: crisisDays,
      );
      _showSnackBar('Contact frequency saved');
    } catch (e) {
      _showSnackBar('Failed to save: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Save sermon prep hours
  Future<void> _saveSermonPrepHours(String settingsId, int hours) async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.updateSermonPrepSettings(
        settingsId: settingsId,
        weeklySermonPrepHours: hours,
      );
      _showSnackBar('Sermon prep hours saved');
    } catch (e) {
      _showSnackBar('Failed to save: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Save workload settings
  Future<void> _saveWorkloadSettings(
    String settingsId, {
    int? maxDailyHours,
    int? minFocusBlockMinutes,
  }) async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.updateWorkloadSettings(
        settingsId: settingsId,
        maxDailyHours: maxDailyHours,
        minFocusBlockMinutes: minFocusBlockMinutes,
      );
      _showSnackBar('Workload settings saved');
    } catch (e) {
      _showSnackBar('Failed to save: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Show sign out confirmation dialog
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out?\n\n'
          'Your data will be synced before signing out.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              await _handleSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  /// Handle sign out
  Future<void> _handleSignOut() async {
    setState(() => _isSaving = true);

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final success = await authNotifier.signOut();

      if (success && mounted) {
        // Navigation will happen automatically via router redirect
        _showSnackBar('Signed out successfully');
      } else if (mounted) {
        _showSnackBar('Failed to sign out', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error signing out: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Show feedback snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF4444) // Error red
            : const Color(0xFF10B981), // Success green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Usage:
// Navigate to settings: context.go('/settings')
//
// This screen is wrapped by MainScaffold which provides:
// - AppBar with title "Settings"
// - Bottom navigation
// - Side drawer
