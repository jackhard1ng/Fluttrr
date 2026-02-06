import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';
import '../constants/api_endpoints.dart';
import '../models/mate_model.dart';
import 'profile_preview_sheet.dart';

/// Smart friend suggestions based on shared interests and activity
class FriendSuggestionCard extends StatelessWidget {
  final MateModel mate;
  final List<String> sharedInterests;
  final int? mutualFriends;
  final String? suggestionReason;
  final VoidCallback? onWave;
  final VoidCallback? onDismiss;

  const FriendSuggestionCard({
    super.key,
    required this.mate,
    required this.sharedInterests,
    this.mutualFriends,
    this.suggestionReason,
    this.onWave,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiEndpoints.getImageUrl(mate.profileImage);
    final hasValidImage = ApiEndpoints.isValidImageUrl(mate.profileImage);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture with online indicator
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => ProfilePreviewSheet.show(context, mate),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          color: AppColors.lightGrey,
                          image: hasValidImage
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !hasValidImage
                            ? Icon(
                                Icons.person,
                                size: 32,
                                color: AppColors.mediumGrey,
                              )
                            : null,
                      ),
                    ),
                    if (mate.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: AppSpacing.md),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mate.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          if (onDismiss != null)
                            GestureDetector(
                              onTap: onDismiss,
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Suggestion reason
                      if (suggestionReason != null)
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppColors.friendlyPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              suggestionReason!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.friendlyPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                      // Mutual friends
                      if (mutualFriends != null && mutualFriends! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 14,
                                color: AppColors.mediumGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$mutualFriends mutual friend${mutualFriends! > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Shared interests
                      if (sharedInterests.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: sharedInterests.take(3).map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withAlpha(26),
                                borderRadius: BorderRadius.circular(AppRadius.circular),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 12,
                                    color: AppColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    interest,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withAlpha(77),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => ProfilePreviewSheet.show(context, mate),
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: const Text('View Profile'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mediumGrey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.lightGrey,
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onWave ?? () {
                      HapticFeedback.mediumImpact();
                      Get.snackbar(
                        'Wave Sent!',
                        'You waved at ${mate.displayName}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.friendlyTeal,
                        colorText: Colors.white,
                        icon: const Icon(Icons.waving_hand, color: Colors.white),
                      );
                    },
                    icon: const Icon(Icons.waving_hand, size: 18),
                    label: const Text('Wave'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.friendlyTeal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Friend suggestions section with title
class FriendSuggestionsSection extends StatelessWidget {
  final List<MateModel> suggestions;
  final List<String> userInterests;

  const FriendSuggestionsSection({
    super.key,
    required this.suggestions,
    required this.userInterests,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.friendlyPurple,
                      AppColors.primaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'People You Might Click With',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Based on your interests and activity',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Suggestions list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final mate = suggestions[index];
            final sharedInterests = _findSharedInterests(mate, userInterests);
            final reason = _getSuggestionReason(mate, sharedInterests);

            return FriendSuggestionCard(
              mate: mate,
              sharedInterests: sharedInterests,
              mutualFriends: Random().nextInt(5),
              suggestionReason: reason,
              onDismiss: () {
                // Remove from suggestions
              },
            );
          },
        ),
      ],
    );
  }

  List<String> _findSharedInterests(MateModel mate, List<String> userInterests) {
    if (mate.interests == null) return [];
    return mate.interests!
        .where((i) => userInterests.contains(i))
        .toList();
  }

  String _getSuggestionReason(MateModel mate, List<String> shared) {
    if (shared.length >= 3) return 'Many shared interests';
    if (shared.length >= 1) return 'Shares your love of ${shared.first}';
    if (mate.isOnline) return 'Active right now';
    if (mate.distance != null && mate.distance! < 5) return 'Very nearby';
    return 'Might be a great connection';
  }
}

/// Compatibility score indicator
class CompatibilityScore extends StatelessWidget {
  final int score; // 0-100
  final bool showLabel;

  const CompatibilityScore({
    super.key,
    required this.score,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Score circle
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withAlpha(179)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(77),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$score%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getScoreLabel(score),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 13,
                ),
              ),
              Text(
                'compatibility',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.friendlyTeal;
    if (score >= 40) return AppColors.friendlyOrange;
    return AppColors.mediumGrey;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Great Match!';
    if (score >= 60) return 'Good Match';
    if (score >= 40) return 'Fair Match';
    return 'Might Work';
  }
}

/// "Why you might get along" reasons widget
class ConnectionReasons extends StatelessWidget {
  final List<String> sharedInterests;
  final int? mutualFriends;
  final int? sharedEvents;
  final bool sameNeighborhood;

  const ConnectionReasons({
    super.key,
    required this.sharedInterests,
    this.mutualFriends,
    this.sharedEvents,
    this.sameNeighborhood = false,
  });

  @override
  Widget build(BuildContext context) {
    final reasons = <_Reason>[];

    if (sharedInterests.isNotEmpty) {
      reasons.add(_Reason(
        icon: Icons.interests,
        text: '${sharedInterests.length} shared interest${sharedInterests.length > 1 ? 's' : ''}',
        color: AppColors.friendlyPurple,
      ));
    }

    if (mutualFriends != null && mutualFriends! > 0) {
      reasons.add(_Reason(
        icon: Icons.people,
        text: '$mutualFriends mutual friend${mutualFriends! > 1 ? 's' : ''}',
        color: AppColors.primaryBlue,
      ));
    }

    if (sharedEvents != null && sharedEvents! > 0) {
      reasons.add(_Reason(
        icon: Icons.event,
        text: 'Both attended $sharedEvents event${sharedEvents! > 1 ? 's' : ''}',
        color: AppColors.friendlyOrange,
      ));
    }

    if (sameNeighborhood) {
      reasons.add(_Reason(
        icon: Icons.location_on,
        text: 'Same neighborhood',
        color: AppColors.friendlyTeal,
      ));
    }

    if (reasons.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.warmYellow,
              ),
              const SizedBox(width: 6),
              Text(
                'Why you might get along',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...reasons.map((reason) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: reason.color.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(reason.icon, size: 14, color: reason.color),
                ),
                const SizedBox(width: 8),
                Text(
                  reason.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _Reason {
  final IconData icon;
  final String text;
  final Color color;

  _Reason({
    required this.icon,
    required this.text,
    required this.color,
  });
}

/// Daily friend suggestion notification card
class DailySuggestionCard extends StatelessWidget {
  final MateModel mate;
  final VoidCallback? onView;
  final VoidCallback? onDismiss;

  const DailySuggestionCard({
    super.key,
    required this.mate,
    this.onView,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.friendlyPurple,
            AppColors.primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.friendlyPurple.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Today's Friend Pick",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: onDismiss,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Profile row
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  color: Colors.white.withAlpha(51),
                  image: ApiEndpoints.isValidImageUrl(mate.profileImage)
                      ? DecorationImage(
                          image: NetworkImage(
                            ApiEndpoints.getImageUrl(mate.profileImage),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !ApiEndpoints.isValidImageUrl(mate.profileImage)
                    ? const Icon(Icons.person, color: Colors.white54, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mate.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (mate.bio != null)
                      Text(
                        mate.bio!,
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onView ?? () => ProfilePreviewSheet.show(context, mate),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.friendlyPurple,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const Text(
                'Say Hello',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
