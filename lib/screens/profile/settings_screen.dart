import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';

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
            onTap: () {
              // Navigate to profile info
            },
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              // Navigate to change password
            },
          ),
          _SettingsTile(
            icon: Icons.link,
            title: 'Linked Accounts',
            onTap: () {
              // Navigate to linked accounts
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Privacy section
          _SectionHeader(title: 'Privacy'),
          _SettingsTile(
            icon: Icons.visibility_outlined,
            title: 'Visibility & Preferences',
            onTap: () {
              // Navigate to visibility settings
            },
          ),
          _SettingsTile(
            icon: Icons.block_outlined,
            title: 'Blocked Users',
            onTap: () {
              // Navigate to blocked users
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Notifications section
          _SectionHeader(title: 'Notifications'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notification Preferences',
            onTap: () {
              // Navigate to notification settings
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Support section
          _SectionHeader(title: 'Support'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {
              // Navigate to help center
            },
          ),
          _SettingsTile(
            icon: Icons.report_outlined,
            title: 'Report a Problem',
            onTap: () {
              // Navigate to report problem
            },
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Fluttrr',
            onTap: () {
              // Navigate to about
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Legal section
          _SectionHeader(title: 'Legal'),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              // Open terms
            },
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              // Open privacy policy
            },
          ),

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authController = Get.find<AuthController>();
              await authController.logout();
              Get.offAll(() => const LoginScreen());
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Delete account
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
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
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
