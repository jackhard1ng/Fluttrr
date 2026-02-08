import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  // Privacy settings
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  bool _showEventsAttended = true;
  bool _allowFriendRequests = true;
  bool _allowMessages = true;
  bool _showInNearby = true;
  bool _shareLocation = false;

  ProfileVisibility _profileVisibility = ProfileVisibility.everyone;
  MessagePrivacy _messagePrivacy = MessagePrivacy.friends;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Privacy',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile visibility
            _SectionHeader(title: 'Profile Visibility'),
            _OptionTile(
              title: 'Who can see my profile',
              subtitle: _profileVisibility.label,
              onTap: () => _showProfileVisibilitySheet(),
            ),
            const SizedBox(height: 8),

            _ToggleTile(
              title: 'Show events I\'ve attended',
              subtitle: 'Others can see your past events',
              value: _showEventsAttended,
              onChanged: (v) => setState(() => _showEventsAttended = v),
            ),
            const SizedBox(height: 24),

            // Online status
            _SectionHeader(title: 'Activity Status'),
            _ToggleTile(
              title: 'Show online status',
              subtitle: 'Let friends see when you\'re active',
              value: _showOnlineStatus,
              onChanged: (v) => setState(() => _showOnlineStatus = v),
            ),
            _ToggleTile(
              title: 'Show last seen',
              subtitle: 'Let friends see when you were last active',
              value: _showLastSeen,
              onChanged: (v) => setState(() => _showLastSeen = v),
            ),
            const SizedBox(height: 24),

            // Connections
            _SectionHeader(title: 'Connections'),
            _ToggleTile(
              title: 'Allow friend requests',
              subtitle: 'Others can send you friend requests',
              value: _allowFriendRequests,
              onChanged: (v) => setState(() => _allowFriendRequests = v),
            ),
            _OptionTile(
              title: 'Who can message me',
              subtitle: _messagePrivacy.label,
              onTap: () => _showMessagePrivacySheet(),
            ),
            const SizedBox(height: 24),

            // Location
            _SectionHeader(title: 'Location'),
            _ToggleTile(
              title: 'Show me in Nearby',
              subtitle: 'Appear in nearby people for others',
              value: _showInNearby,
              onChanged: (v) => setState(() => _showInNearby = v),
            ),
            _ToggleTile(
              title: 'Share location at events',
              subtitle: 'Let attendees see your location during events',
              value: _shareLocation,
              onChanged: (v) => setState(() => _shareLocation = v),
            ),
            const SizedBox(height: 24),

            // Blocked users
            _SectionHeader(title: 'Blocked'),
            _OptionTile(
              title: 'Blocked users',
              subtitle: 'Manage people you\'ve blocked',
              onTap: () => _showBlockedUsers(),
            ),
            const SizedBox(height: 24),

            // Data
            _SectionHeader(title: 'Your Data'),
            _OptionTile(
              title: 'Download my data',
              subtitle: 'Get a copy of your Fluttrr data',
              onTap: () {
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'Request Sent',
                  'We\'ll email you when your data is ready',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileVisibilitySheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who can see my profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...ProfileVisibility.values.map((v) {
              return ListTile(
                title: Text(v.label),
                subtitle: Text(v.description),
                trailing: _profileVisibility == v
                    ? Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  setState(() => _profileVisibility = v);
                  Get.back();
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMessagePrivacySheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who can message me',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...MessagePrivacy.values.map((v) {
              return ListTile(
                title: Text(v.label),
                trailing: _messagePrivacy == v
                    ? Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  setState(() => _messagePrivacy = v);
                  Get.back();
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBlockedUsers() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Blocked Users',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, color: AppColors.mediumGrey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block,
                    size: 48,
                    color: AppColors.mediumGrey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No blocked users',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Users you block will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

enum ProfileVisibility {
  everyone('Everyone', 'Anyone on Fluttrr can see your profile'),
  friends('Friends Only', 'Only your friends can see your full profile'),
  private('Private', 'Only you can see your profile');

  final String label;
  final String description;

  const ProfileVisibility(this.label, this.description);
}

enum MessagePrivacy {
  everyone('Everyone'),
  friends('Friends only'),
  nobody('Nobody');

  final String label;

  const MessagePrivacy(this.label);
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.mediumGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(77),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
}
