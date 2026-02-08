import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/utils.dart';

/// App version and update management
/// Call AppUpdateChecker.check() on app start to verify version

class AppUpdateChecker {
  // Current app version - update this with each release
  static const String currentVersion = '1.0.0';
  static const int currentBuildNumber = 1;

  /// Check for updates on app startup
  /// In production, this would call your backend API
  static Future<void> check(BuildContext context) async {
    // Simulate API call - replace with actual endpoint
    // final response = await api.get('/app/version');
    // final minVersion = response['min_version'];
    // final latestVersion = response['latest_version'];
    // final forceUpdate = response['force_update'];

    // For demo, we'll use hardcoded values
    const String minVersion = '1.0.0';
    const String latestVersion = '1.1.0';
    const bool forceUpdate = false;

    final needsUpdate = _compareVersions(currentVersion, latestVersion) < 0;
    final mustUpdate = _compareVersions(currentVersion, minVersion) < 0;

    if (mustUpdate) {
      _showForceUpdateDialog(context);
    } else if (needsUpdate) {
      _showOptionalUpdateDialog(context, latestVersion);
    }
  }

  /// Compare two version strings (e.g., "1.0.0" vs "1.1.0")
  /// Returns: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }
    return 0;
  }

  static void _showForceUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.system_update, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              const Text('Update Required'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A new version of Fluttrr is available with important updates.',
              ),
              SizedBox(height: 12),
              Text(
                'Please update to continue using the app.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => _openStore(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text(
                'Update Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showOptionalUpdateDialog(BuildContext context, String newVersion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 40,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'New Version Available!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fluttrr v$newVersion is now available with new features and improvements.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        _openStore();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _openStore() async {
    // Replace with your actual app store URLs
    const appStoreUrl = 'https://apps.apple.com/app/fluttrr/id123456789';
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.fluttrr.app';

    final url = GetPlatform.isIOS ? appStoreUrl : playStoreUrl;
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// What's New dialog - show after app updates
class WhatsNewDialog extends StatelessWidget {
  final String version;
  final List<WhatsNewItem> items;

  const WhatsNewDialog({
    super.key,
    required this.version,
    required this.items,
  });

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WhatsNewDialog(
        version: AppUpdateChecker.currentVersion,
        items: [
          WhatsNewItem(
            icon: Icons.speed,
            title: 'Faster Performance',
            description: 'We\'ve optimized the app for smoother scrolling and faster loading.',
          ),
          WhatsNewItem(
            icon: Icons.touch_app,
            title: 'Improved Gestures',
            description: 'Long-press on items for quick actions. Swipe to dismiss.',
          ),
          WhatsNewItem(
            icon: Icons.notifications_active,
            title: 'Better Notifications',
            description: 'More control over which notifications you receive.',
          ),
          WhatsNewItem(
            icon: Icons.bug_report,
            title: 'Bug Fixes',
            description: 'We squashed several bugs to improve your experience.',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D1B4D), Color(0xFF38B6FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What\'s New',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Version $version',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: TextStyle(
                                color: AppColors.mediumGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhatsNewItem {
  final IconData icon;
  final String title;
  final String description;

  WhatsNewItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// First-time user onboarding tips
class OnboardingTips {
  static const String _shownKey = 'onboarding_tips_shown';

  static Future<void> showIfNeeded(BuildContext context) async {
    // Check if already shown using SharedPreferences
    // For now, we'll skip the persistence check
    // In production: final shown = prefs.getBool(_shownKey) ?? false;

    // Show tips dialog
    // showTipsDialog(context);
  }

  static void showTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Text('💡'),
            const SizedBox(width: 8),
            const Text('Quick Tips'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TipItem(
              icon: Icons.touch_app,
              text: 'Long-press on items for quick actions',
            ),
            _TipItem(
              icon: Icons.swipe,
              text: 'Swipe left on messages to delete',
            ),
            _TipItem(
              icon: Icons.favorite,
              text: 'Double-tap events to save them',
            ),
            _TipItem(
              icon: Icons.vibration,
              text: 'Shake your phone to report issues',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              // Save that tips were shown
              // prefs.setBool(_shownKey, true);
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
