import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../repositories/profile_repository.dart';
import '../../widgets/common_widgets.dart';
import '../admin/admin_dashboard_screen.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Account section
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profile Information',
            onTap: () => Nav.toEditProfile(),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => _showChangePasswordDialog(context),
          ),
          _SettingsTile(
            icon: Icons.link,
            title: 'Linked Accounts',
            onTap: () => _showComingSoonDialog(context, 'Linked Accounts'),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Privacy section
          _SectionHeader(title: 'Privacy'),
          _LowProfileTile(),
          _SettingsTile(
            icon: Icons.visibility_outlined,
            title: 'Visibility & Preferences',
            onTap: () => Nav.toPrivacy(),
          ),
          _SettingsTile(
            icon: Icons.block_outlined,
            title: 'Blocked Users',
            onTap: () => Nav.toBlockedUsers(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Notifications section
          _SectionHeader(title: 'Notifications'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notification Preferences',
            onTap: () => _showNotificationPreferences(context),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Support section
          _SectionHeader(title: 'Support'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () => Nav.toHelp(),
          ),
          _SettingsTile(
            icon: Icons.report_outlined,
            title: 'Report a Problem',
            onTap: () => Nav.toReport(),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Fluttrr',
            onTap: () => _showAboutDialog(context),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Legal section
          _SectionHeader(title: 'Legal'),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _showLegalDialog(context, 'Terms of Service'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _showLegalDialog(context, 'Privacy Policy'),
          ),

          // Admin section (only visible to admins)
          _AdminPanelTile(),

          const SizedBox(height: AppSpacing.xl),

          // Logout button
          GradientButton(
            text: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),

          const SizedBox(height: AppSpacing.md),

          // Delete account
          Center(
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context),
              child: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Check if context is still mounted before showing dialog (#71)
    if (!context.mounted) return;

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              final authController = Get.find<AuthController>();
              await authController.logout();
              Nav.toLogin();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    // Check if context is still mounted before showing dialog (#71)
    if (!context.mounted) return;

    final passwordController = TextEditingController();

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will permanently delete your account and all data. This cannot be undone.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter your password to confirm:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Your password',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              passwordController.dispose();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final password = passwordController.text.trim();
              if (password.isEmpty) {
                Get.snackbar(
                  'Password Required',
                  'Please enter your password to confirm',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
                return;
              }

              Navigator.pop(dialogContext);
              passwordController.dispose();

              final profileController = Get.find<ProfileController>();
              final success = await profileController.deleteAccount(password);

              if (success) {
                final authController = Get.find<AuthController>();
                await authController.logout();
                Get.snackbar(
                  'Account Deleted',
                  'Your account has been deleted',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
                Nav.toLogin();
              } else {
                Get.snackbar(
                  'Deletion Failed',
                  'Incorrect password or server error',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Delete Permanently',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    // Check if context is still mounted before showing dialog (#71)
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'Password reset is coming soon. For now, please contact support@fluttrr.com to change your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotificationPreferences(BuildContext context) {
    if (!context.mounted) return;

    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _NotificationPreferencesSheet(),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    // Check if context is still mounted before showing bottom sheet (#71)
    if (!context.mounted) return;

    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction,
                  size: 30,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This feature is coming soon! We\'re working hard to bring it to you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                  Get.snackbar(
                    '🔔 You\'re on the list!',
                    'We\'ll notify you when $feature is ready',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D1B4D), Color(0xFF38B6FF)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Center(
                    child: Text(
                      'Notify Me When Ready',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Maybe Later',
                  style: TextStyle(color: AppColors.mediumGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    // Check if context is still mounted before showing dialog (#85)
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.friendlyTeal],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'F',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Fluttrr'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The social app for making real friendships.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Need help? Contact us at:',
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'support@fluttrr.com',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title) {
    // Check if context is still mounted before showing dialog (#86)
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last updated: February 2024',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title == 'Terms of Service'
                    ? 'By using Fluttrr, you agree to use the app responsibly and respect other users. '
                      'You must be at least 18 years old to use this service. '
                      'We reserve the right to suspend accounts that violate our community guidelines.\n\n'
                      'For the full terms, please visit our website or contact support@fluttrr.com.'
                    : 'We respect your privacy and are committed to protecting your personal data. '
                      'We collect information you provide directly and use it to improve your experience. '
                      'We do not sell your personal information to third parties.\n\n'
                      'For the full privacy policy, please visit our website or contact support@fluttrr.com.',
                style: const TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primaryBlue,
            ),
      ),
    );
  }
}

/// Settings tile widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing = null,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}

/// Admin Panel tile - only shows for admin users
class _AdminPanelTile extends StatelessWidget {
  const _AdminPanelTile();

  @override
  Widget build(BuildContext context) {
    // Check if admin controller exists and user is admin
    final AdminController adminController;
    try {
      adminController = Get.find<AdminController>();
    } catch (_) {
      // Controller not registered, try to create it
      Get.put(AdminController());
      return _buildAdminCheck();
    }

    return Obx(() {
      if (!adminController.isAdmin) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Admin'),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withValues(alpha: 0.1),
                  Colors.deepPurple.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
              ),
              title: const Text(
                'Admin Panel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                adminController.currentAdmin.value?.roleDisplay ?? 'Manage app',
                style: TextStyle(color: Colors.deepPurple.shade300, fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.deepPurple),
              onTap: () {
                HapticFeedback.mediumImpact();
                Get.to(() => const AdminDashboardScreen());
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAdminCheck() {
    final adminController = Get.find<AdminController>();
    return Obx(() {
      if (adminController.isLoading.value) {
        return const SizedBox.shrink();
      }
      if (!adminController.isAdmin) {
        return const SizedBox.shrink();
      }
      return _AdminPanelTile();
    });
  }
}

/// Notification preferences bottom sheet
class _NotificationPreferencesSheet extends StatefulWidget {
  const _NotificationPreferencesSheet();

  @override
  State<_NotificationPreferencesSheet> createState() => _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState extends State<_NotificationPreferencesSheet> {
  final ProfileRepository _repo = ProfileRepository();
  bool _isLoading = true;
  bool _isSaving = false;

  bool _activityReminders = true;
  bool _messageNotifications = true;
  bool _promotionalEmails = false;
  int _reminderTime = 30;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final response = await _repo.getNotificationPreferences();
      if (response.success && response.data != null) {
        final data = response.data!;
        setState(() {
          _activityReminders = data['activityReminders'] ?? true;
          _messageNotifications = data['messageNotifications'] ?? true;
          _promotionalEmails = data['promotionalEmails'] ?? false;
          _reminderTime = data['reminderTime'] ?? 30;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final response = await _repo.updateNotificationPreferences(
        activityReminders: _activityReminders,
        messageNotifications: _messageNotifications,
        promotionalEmails: _promotionalEmails,
        reminderTime: _reminderTime,
      );

      setState(() => _isSaving = false);

      if (response.success) {
        if (mounted) Navigator.pop(context);
        Get.snackbar(
          'Preferences Saved',
          'Your notification preferences have been updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not save preferences',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              SwitchListTile(
                title: const Text('Activity Reminders'),
                subtitle: Text(
                  'Get reminded before events you\'ve joined',
                  style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
                ),
                value: _activityReminders,
                onChanged: (v) => setState(() => _activityReminders = v),
                activeColor: AppColors.primaryBlue,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Message Notifications'),
                subtitle: Text(
                  'Get notified when you receive new messages',
                  style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
                ),
                value: _messageNotifications,
                onChanged: (v) => setState(() => _messageNotifications = v),
                activeColor: AppColors.primaryBlue,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Promotional Updates'),
                subtitle: Text(
                  'Receive news about new features and events',
                  style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
                ),
                value: _promotionalEmails,
                onChanged: (v) => setState(() => _promotionalEmails = v),
                activeColor: AppColors.primaryBlue,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Text(
                'Reminder Time',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'How many minutes before an event to remind you',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [15, 30, 60, 120].map((mins) {
                  final isSelected = _reminderTime == mins;
                  final label = mins < 60 ? '$mins min' : '${mins ~/ 60} hr';
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _reminderTime = mins),
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkGrey,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Low Profile mode toggle tile
class _LowProfileTile extends StatelessWidget {
  const _LowProfileTile();

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Obx(() => ListTile(
          leading: Icon(
            profileController.isLowProfile.value
                ? Icons.visibility_off
                : Icons.visibility,
            color: profileController.isLowProfile.value
                ? AppColors.primaryBlue
                : AppColors.grey,
          ),
          title: const Text('Low Profile'),
          subtitle: Text(
            profileController.isLowProfile.value
                ? 'Hidden from Discover - Events only'
                : 'Visible to everyone nearby',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
          trailing: Switch.adaptive(
            value: profileController.isLowProfile.value,
            onChanged: (value) async {
              HapticFeedback.mediumImpact();
              final success = await profileController.toggleLowProfile();
              if (success) {
                Get.snackbar(
                  value ? 'Low Profile Enabled' : 'Low Profile Disabled',
                  value
                      ? 'You\'re hidden from Discover but can still join events'
                      : 'You\'re now visible to everyone nearby',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primaryBlue,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            activeColor: AppColors.primaryBlue,
          ),
          contentPadding: EdgeInsets.zero,
        ));
  }
}
