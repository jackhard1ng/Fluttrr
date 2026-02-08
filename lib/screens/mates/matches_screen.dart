import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/mates_controller.dart';
import '../../models/mate_model.dart';
import '../../models/chat_model.dart';
import '../../widgets/common_widgets.dart';

/// Matches screen showing mutual likes
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  void _loadMatches() {
    final controller = Get.find<MatesController>();
    controller.loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final matesController = Get.find<MatesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: Obx(() {
        if (matesController.isLoading.value && matesController.matches.isEmpty) {
          return const LoadingIndicator();
        }

        if (matesController.matches.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border,
            title: 'No Matches Yet',
            subtitle: 'Keep swiping to find your perfect match!',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadMatches(),
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: matesController.matches.length,
            itemBuilder: (context, index) {
              return _MatchCard(match: matesController.matches[index]);
            },
          ),
        );
      }),
    );
  }
}

/// Match card widget
class _MatchCard extends StatelessWidget {
  final MatchModel match;

  const _MatchCard({required this.match});

  void _showMatchOptions(BuildContext context) {
    // Check if context is still mounted before showing bottom sheet (#97)
    if (!context.mounted) return;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withAlpha(26),
                    ),
                    child: Center(
                      child: Text(
                        (match.userName ?? 'U')[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.userName ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.favorite, size: 14, color: AppColors.error),
                            const SizedBox(width: 4),
                            Text(
                              'Matched!',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
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
            const Divider(),
            ListTile(
              leading: Icon(Icons.person, color: AppColors.primaryBlue),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                if (match.userId != null) {
                  Nav.toMateProfile(match.userId!);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: AppColors.friendlyTeal),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                if (match.userId != null) {
                  final conversation = ChatConversation(
                    otherUserId: match.userId,
                    otherUserName: match.userName ?? 'User',
                    otherUserImages: match.images,
                  );
                  Nav.toChat(conversation);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: AppColors.friendlyPurple),
              title: const Text('Invite to Event'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
                Nav.toDiscover();
                Get.snackbar(
                  'Invite to Event',
                  'Select an event to invite ${match.userName ?? 'your match'}',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.block, color: AppColors.error),
              title: Text('Unmatch', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                _confirmUnmatch(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmUnmatch(BuildContext context) {
    // Check if context is still mounted before showing dialog (#97)
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unmatch?'),
        content: Text('Are you sure you want to unmatch with ${match.userName ?? 'this person'}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              Get.snackbar(
                'Unmatched',
                'You have unmatched with ${match.userName ?? 'this person'}',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: Text('Unmatch', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (match.userId != null) {
          Nav.toMateProfile(match.userId!);
        }
      },
      onLongPress: () => _showMatchOptions(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          image: match.profileImage != null
              ? DecorationImage(
                  image: NetworkImage(match.profileImage!),
                  fit: BoxFit.cover,
                )
              : null,
          color: AppColors.lightGrey,
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(179),
                  ],
                ),
              ),
            ),

            // Default avatar
            if (match.profileImage == null)
              const Center(
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.grey,
                ),
              ),

            // Content
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.userName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () {
                      if (match.userId == null) return;
                      final conversation = ChatConversation(
                        otherUserId: match.userId,
                        otherUserName: match.userName ?? 'User',
                        otherUserImages: match.images,
                      );
                      Nav.toChat(conversation);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Message',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
