import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Compatibility score display
class CompatibilityScore extends StatelessWidget {
  final int matchPercentage;
  final String? label;
  final bool showDetails;

  const CompatibilityScore({
    super.key,
    required this.matchPercentage,
    this.label,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String emoji;

    if (matchPercentage >= 80) {
      color = AppColors.success;
      emoji = '🎯';
    } else if (matchPercentage >= 60) {
      color = AppColors.friendlyTeal;
      emoji = '✨';
    } else if (matchPercentage >= 40) {
      color = AppColors.warmYellow;
      emoji = '👋';
    } else {
      color = AppColors.mediumGrey;
      emoji = '🌱';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            '$matchPercentage% ${label ?? 'match'}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Detailed compatibility breakdown
class CompatibilityBreakdown extends StatelessWidget {
  final int overallScore;
  final Map<String, int> categoryScores;

  const CompatibilityBreakdown({
    super.key,
    required this.overallScore,
    required this.categoryScores,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Compatibility',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.darkGrey,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.friendlyTeal],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  '$overallScore%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...categoryScores.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ScoreBar(
                label: entry.key,
                score: entry.value,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreBar({
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkGrey,
              ),
            ),
            Text(
              '$score%',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation(
              score >= 70 ? AppColors.success :
              score >= 40 ? AppColors.warmYellow : AppColors.mediumGrey,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// Interest selector with categories
class InterestSelector extends StatefulWidget {
  final List<String> selectedInterests;
  final Function(List<String>) onChanged;
  final int maxSelections;

  const InterestSelector({
    super.key,
    required this.selectedInterests,
    required this.onChanged,
    this.maxSelections = 10,
  });

  @override
  State<InterestSelector> createState() => _InterestSelectorState();
}

class _InterestSelectorState extends State<InterestSelector> {
  final Map<String, List<Map<String, dynamic>>> _interestCategories = {
    'Activities': [
      {'name': 'Hiking', 'icon': Icons.terrain},
      {'name': 'Gaming', 'icon': Icons.sports_esports},
      {'name': 'Fitness', 'icon': Icons.fitness_center},
      {'name': 'Yoga', 'icon': Icons.self_improvement},
      {'name': 'Running', 'icon': Icons.directions_run},
      {'name': 'Cycling', 'icon': Icons.pedal_bike},
      {'name': 'Swimming', 'icon': Icons.pool},
      {'name': 'Dancing', 'icon': Icons.music_note},
    ],
    'Social': [
      {'name': 'Coffee chats', 'icon': Icons.coffee},
      {'name': 'Board games', 'icon': Icons.casino},
      {'name': 'Wine tasting', 'icon': Icons.wine_bar},
      {'name': 'Book clubs', 'icon': Icons.menu_book},
      {'name': 'Karaoke', 'icon': Icons.mic},
      {'name': 'Brunch', 'icon': Icons.brunch_dining},
      {'name': 'Potlucks', 'icon': Icons.restaurant},
      {'name': 'Trivia nights', 'icon': Icons.quiz},
    ],
    'Creative': [
      {'name': 'Photography', 'icon': Icons.camera_alt},
      {'name': 'Art', 'icon': Icons.palette},
      {'name': 'Writing', 'icon': Icons.edit_note},
      {'name': 'Music', 'icon': Icons.headphones},
      {'name': 'DIY & Crafts', 'icon': Icons.handyman},
      {'name': 'Cooking', 'icon': Icons.restaurant_menu},
      {'name': 'Gardening', 'icon': Icons.local_florist},
      {'name': 'Film making', 'icon': Icons.videocam},
    ],
    'Lifestyle': [
      {'name': 'Movies', 'icon': Icons.movie},
      {'name': 'Podcasts', 'icon': Icons.podcasts},
      {'name': 'Travel', 'icon': Icons.flight},
      {'name': 'Foodie', 'icon': Icons.local_dining},
      {'name': 'Pets', 'icon': Icons.pets},
      {'name': 'Volunteering', 'icon': Icons.volunteer_activism},
      {'name': 'Meditation', 'icon': Icons.spa},
      {'name': 'Languages', 'icon': Icons.translate},
    ],
    'Learning': [
      {'name': 'Tech', 'icon': Icons.computer},
      {'name': 'Finance', 'icon': Icons.attach_money},
      {'name': 'Science', 'icon': Icons.science},
      {'name': 'History', 'icon': Icons.history_edu},
      {'name': 'Philosophy', 'icon': Icons.psychology},
      {'name': 'Entrepreneurship', 'icon': Icons.rocket_launch},
      {'name': 'Career growth', 'icon': Icons.trending_up},
      {'name': 'Sustainability', 'icon': Icons.eco},
    ],
  };

  String _selectedCategory = 'Activities';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _interestCategories.keys.map((category) {
              final isSelected = category == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = category);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.lightGrey.withAlpha(128),
                      borderRadius: BorderRadius.circular(AppRadius.circular),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.darkGrey,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Selection count
        Text(
          '${widget.selectedInterests.length}/${widget.maxSelections} selected',
          style: TextStyle(
            color: AppColors.mediumGrey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Interest grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interestCategories[_selectedCategory]!.map((interest) {
            final isSelected = widget.selectedInterests.contains(interest['name']);
            final canSelect = isSelected || widget.selectedInterests.length < widget.maxSelections;

            return GestureDetector(
              onTap: () {
                if (!canSelect) return;

                HapticFeedback.lightImpact();
                final newList = List<String>.from(widget.selectedInterests);
                if (isSelected) {
                  newList.remove(interest['name']);
                } else {
                  newList.add(interest['name']);
                }
                widget.onChanged(newList);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withAlpha(26)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.lightGrey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      interest['icon'],
                      size: 18,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.mediumGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      interest['name'],
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.darkGrey,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Shared interests display between two users
class MutualInterests extends StatelessWidget {
  final List<String> interests;
  final String? otherPersonName;

  const MutualInterests({
    super.key,
    required this.interests,
    this.otherPersonName,
  });

  @override
  Widget build(BuildContext context) {
    if (interests.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.friendlyPurple.withAlpha(13),
            AppColors.primaryBlue.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.friendlyPurple.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.friendlyPurple,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                otherPersonName != null
                    ? 'You and $otherPersonName both like'
                    : 'Shared interests',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.friendlyPurple.withAlpha(26),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// "Why you might click" card showing compatibility reasons
class WhyYouMightClick extends StatelessWidget {
  final List<String> reasons;
  final String otherPersonName;

  const WhyYouMightClick({
    super.key,
    required this.reasons,
    required this.otherPersonName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warmYellow.withAlpha(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.warmYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Why you might click',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...reasons.map((reason) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Vibe match indicator (for quick visual matching)
class VibeMatch extends StatelessWidget {
  final String vibe;
  final double matchLevel; // 0.0 to 1.0

  const VibeMatch({
    super.key,
    required this.vibe,
    required this.matchLevel,
  });

  @override
  Widget build(BuildContext context) {
    final vibeData = _getVibeData(vibe);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: vibeData['color'].withAlpha((matchLevel * 51).toInt()),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: vibeData['color'].withAlpha((matchLevel * 128).toInt()),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            vibeData['icon'],
            size: 16,
            color: vibeData['color'],
          ),
          const SizedBox(width: 6),
          Text(
            vibe,
            style: TextStyle(
              fontSize: 12,
              color: vibeData['color'],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getVibeData(String vibe) {
    final vibes = {
      'Chill': {'icon': Icons.spa, 'color': AppColors.friendlyTeal},
      'Adventurous': {'icon': Icons.explore, 'color': AppColors.friendlyOrange},
      'Creative': {'icon': Icons.palette, 'color': AppColors.friendlyPurple},
      'Social': {'icon': Icons.people, 'color': AppColors.primaryBlue},
      'Foodie': {'icon': Icons.restaurant, 'color': AppColors.warmYellow},
      'Active': {'icon': Icons.directions_run, 'color': AppColors.success},
      'Nerdy': {'icon': Icons.psychology, 'color': const Color(0xFF9C27B0)},
      'Night owl': {'icon': Icons.nightlight_round, 'color': const Color(0xFF3F51B5)},
    };
    return vibes[vibe] ?? {'icon': Icons.star, 'color': AppColors.primaryBlue};
  }
}
