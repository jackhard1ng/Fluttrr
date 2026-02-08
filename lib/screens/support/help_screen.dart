import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  final List<_HelpCategory> _categories = [
    _HelpCategory(
      icon: Icons.event,
      title: 'Events',
      color: AppColors.primaryBlue,
      faqs: [
        _FAQ('How do I create an event?', 'Go to the home screen and tap the + button. Fill in the event details like title, date, location, and description. You can also add tags and set capacity limits.'),
        _FAQ('Can I edit my event after posting?', 'Yes! Go to your event and tap the edit icon. You can update details anytime before the event starts.'),
        _FAQ('How do I cancel an event?', 'Open the event, tap the menu icon (three dots), and select "Cancel Event". All attendees will be notified.'),
      ],
    ),
    _HelpCategory(
      icon: Icons.people,
      title: 'Friends & Connections',
      color: AppColors.friendlyPurple,
      faqs: [
        _FAQ('How do I add friends?', 'You can send friend requests from someone\'s profile, or connect with people you meet at events. Go to Mates tab to see suggestions.'),
        _FAQ('Can I see mutual friends?', 'Yes! When viewing someone\'s profile, you\'ll see mutual friends and events you\'ve both attended.'),
        _FAQ('How do I block someone?', 'Go to their profile, tap the menu icon, and select "Block". They won\'t be able to see your profile or contact you.'),
      ],
    ),
    _HelpCategory(
      icon: Icons.chat,
      title: 'Messages',
      color: AppColors.friendlyTeal,
      faqs: [
        _FAQ('Who can message me?', 'By default, only your friends can send you direct messages. Event group chats include all attendees.'),
        _FAQ('How do I mute notifications?', 'Open the chat, tap the info icon, and toggle "Mute Notifications".'),
      ],
    ),
    _HelpCategory(
      icon: Icons.person,
      title: 'Account & Privacy',
      color: AppColors.friendlyOrange,
      faqs: [
        _FAQ('How do I change my password?', 'Go to Settings > Account > Change Password. You\'ll need to enter your current password first.'),
        _FAQ('Who can see my profile?', 'Your profile is visible to other Fluttrr users. You can adjust privacy settings in Settings > Privacy.'),
        _FAQ('How do I delete my account?', 'Go to Settings > Account > Delete Account. This action is permanent and cannot be undone.'),
      ],
    ),
    _HelpCategory(
      icon: Icons.business,
      title: 'Business Accounts',
      color: AppColors.warmYellow,
      faqs: [
        _FAQ('How do I switch to a business account?', 'Go to Settings > Account > Switch to Business. You\'ll need to provide business details for verification.'),
        _FAQ('What are the benefits of a business account?', 'Business accounts can create unlimited events, access analytics, add promo codes, and feature events.'),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          'Help & FAQ',
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
            // Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(128),
                borderRadius: BorderRadius.circular(AppRadius.circular),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.mediumGrey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search help topics...',
                        hintStyle: TextStyle(color: AppColors.mediumGrey),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickAction(
                  icon: Icons.email,
                  label: 'Contact Us',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(
                      const ClipboardData(text: 'support@fulttrr.com'),
                    );
                    Get.snackbar(
                      'Email Copied!',
                      'support@fulttrr.com copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                  },
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.bug_report,
                  label: 'Report Bug',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Get.toNamed('/report');
                  },
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.lightbulb,
                  label: 'Suggest',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Get.toNamed('/report');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // FAQ sections
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            ..._categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final isExpanded = _expandedIndex == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: category.color.withAlpha(26),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Icon(
                                category.icon,
                                color: category.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.mediumGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: category.faqs.map((faq) {
                            return _FAQItem(faq: faq);
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Contact Support section
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withAlpha(26),
                    AppColors.friendlyTeal.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.primaryBlue.withAlpha(51)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: AppColors.primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email Support',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              'support@fulttrr.com',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Our support team typically responds within 24 hours. For urgent issues, please include "URGENT" in your subject line.',
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Still need help
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(128),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  const Text('🤔', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 12),
                  const Text(
                    'Still need help?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Report an issue or submit feedback',
                    style: TextStyle(color: AppColors.mediumGrey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Get.toNamed('/report');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.friendlyOrange,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Center(
                              child: Text(
                                'Report Issue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Clipboard.setData(
                              const ClipboardData(text: 'support@fulttrr.com'),
                            );
                            Get.snackbar(
                              'Email Copied',
                              'support@fulttrr.com copied to clipboard',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.success,
                              colorText: Colors.white,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Center(
                              child: Text(
                                'Copy Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCategory {
  final IconData icon;
  final String title;
  final Color color;
  final List<_FAQ> faqs;

  _HelpCategory({
    required this.icon,
    required this.title,
    required this.color,
    required this.faqs,
  });
}

class _FAQ {
  final String question;
  final String answer;

  _FAQ(this.question, this.answer);
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withAlpha(77),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryBlue),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final _FAQ faq;

  const _FAQItem({required this.faq});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.remove : Icons.add,
                    size: 18,
                    color: AppColors.mediumGrey,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                widget.faq.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mediumGrey,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
