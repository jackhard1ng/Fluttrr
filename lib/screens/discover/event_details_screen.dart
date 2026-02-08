import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../constants/utils.dart';
import '../../widgets/event_bookmark.dart';
import '../../widgets/share_card.dart';
import '../../widgets/event_weather.dart';
import '../../widgets/going_together.dart';
import '../../widgets/spot_status.dart';
import '../../widgets/arrival_time.dart';
import '../../widgets/event_tags.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isBookmarked = false;
  RsvpStatus? _rsvpStatus;

  void showShareOptions(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#99)
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ShareMessageSheet(eventName: 'Friday Night Board Games'),
    );
  }

  void _showEventOptionsMenu(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#99)
    if (!context.mounted) return;

    const eventName = 'Friday Night Board Games';
    const hostName = 'Alex';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ListTile(
              leading: Icon(Icons.flag_outlined, color: AppColors.friendlyOrange),
              title: const Text('Report event'),
              subtitle: Text(
                'Report inappropriate content or safety concerns',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              onTap: () {
                Navigator.pop(context);
                Nav.toReport(eventName: eventName);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.person_off_outlined, color: AppColors.error),
              title: const Text('Report host'),
              subtitle: Text(
                'Report the event organizer',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              onTap: () {
                Navigator.pop(context);
                Nav.toReport(userName: hostName);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.help_outline, color: AppColors.primaryBlue),
              title: const Text('Get help'),
              subtitle: Text(
                'Contact support at support@fluttrr.com',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGrey),
              ),
              onTap: () {
                Navigator.pop(context);
                Nav.toHelp();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(77),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showShareOptions(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isBookmarked = !_isBookmarked);
                  showSavedToast(context, removed: !_isBookmarked);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isBookmarked ? AppColors.warmYellow : Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showEventOptionsMenu(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryBlue.withAlpha(51),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎮', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 8),
                      Text(
                        'Game Night',
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and host
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Friday Night Board Games',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.friendlyPurple,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'A',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hosted by Alex',
                                  style: TextStyle(
                                    color: AppColors.mediumGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  const EventTags(
                    tags: ['games', 'social', 'chill', 'indoor'],
                  ),
                  const SizedBox(height: 20),

                  // Date & Time
                  _InfoRow(
                    icon: Icons.calendar_today,
                    title: 'Friday, Dec 15',
                    subtitle: '7:00 PM - 10:00 PM',
                  ),
                  const SizedBox(height: 12),

                  // Location
                  _InfoRow(
                    icon: Icons.location_on,
                    title: 'The Game Cafe',
                    subtitle: '123 Main Street',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                      ),
                      child: Text(
                        'Map',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weather
                  const WeatherBadge(weather: WeatherType.sunny, temperature: 72),
                  const SizedBox(height: 20),

                  // Spots
                  const SpotAvailability(spotsLeft: 4, totalSpots: 12),
                  const SizedBox(height: 20),

                  // Friends going
                  const AlsoGoing(names: ['Sarah', 'Mike', 'Jordan']),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join us for a fun night of board games! We\'ll have classics like Catan, Ticket to Ride, and Codenames. Beginners welcome - we\'ll teach you the rules. Snacks and drinks available at the cafe.',
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // What to expect
                  Text(
                    'What to Expect',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ExpectationItem(icon: Icons.people, text: 'Small group (8-12 people)'),
                  _ExpectationItem(icon: Icons.timer, text: 'About 3 hours'),
                  _ExpectationItem(icon: Icons.attach_money, text: '\$5 venue fee'),
                  _ExpectationItem(icon: Icons.accessibility_new, text: 'Beginner friendly'),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: QuickRsvp(
            status: _rsvpStatus,
            onSelect: (status) {
              HapticFeedback.mediumImpact();
              setState(() => _rsvpStatus = status);
              if (status == RsvpStatus.going) {
                Get.snackbar(
                  '🎉 You\'re going!',
                  'See you at the event',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withAlpha(26),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ExpectationItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ExpectationItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
