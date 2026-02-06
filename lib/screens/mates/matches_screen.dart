import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/mates_controller.dart';
import '../../models/mate_model.dart';
import '../../models/chat_model.dart';
import '../../widgets/common_widgets.dart';
import '../chat/chat_screen.dart';
import 'mate_profile_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => MateProfileScreen(userId: match.userId!)),
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
                      final conversation = ChatConversation(
                        otherUserId: match.userId,
                        otherUserName: match.userName,
                        otherUserImages: match.images,
                      );
                      Get.to(() => ChatScreen(conversation: conversation));
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
