import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// User level and XP display
class UserLevel extends StatelessWidget {
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final bool compact;

  const UserLevel({
    super.key,
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentXp / xpToNextLevel;
    final levelTitle = _getLevelTitle(level);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_getLevelColor(level), _getLevelColor(level).withAlpha(179)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.circular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getLevelIcon(level),
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Lvl $level',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getLevelColor(level).withAlpha(26),
            _getLevelColor(level).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _getLevelColor(level).withAlpha(51)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_getLevelColor(level), _getLevelColor(level).withAlpha(179)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _getLevelColor(level),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentXp / $xpToNextLevel XP',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getLevelIcon(level),
                color: _getLevelColor(level),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _getLevelColor(level).withAlpha(51),
              valueColor: AlwaysStoppedAnimation(_getLevelColor(level)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${xpToNextLevel - currentXp} XP to Level ${level + 1}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level < 5) return 'Newcomer';
    if (level < 10) return 'Friendly Face';
    if (level < 20) return 'Social Butterfly';
    if (level < 30) return 'Friend Magnet';
    if (level < 50) return 'Community Star';
    return 'Friendship Legend';
  }

  Color _getLevelColor(int level) {
    if (level < 5) return AppColors.mediumGrey;
    if (level < 10) return AppColors.friendlyTeal;
    if (level < 20) return AppColors.primaryBlue;
    if (level < 30) return AppColors.friendlyPurple;
    if (level < 50) return AppColors.friendlyOrange;
    return AppColors.warmYellow;
  }

  IconData _getLevelIcon(int level) {
    if (level < 5) return Icons.sentiment_satisfied;
    if (level < 10) return Icons.emoji_emotions;
    if (level < 20) return Icons.star;
    if (level < 30) return Icons.auto_awesome;
    if (level < 50) return Icons.diamond;
    return Icons.workspace_premium;
  }
}

/// Achievement card
class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double progress;
  final String? progressText;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.progress = 0,
    this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isUnlocked ? color.withAlpha(13) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isUnlocked ? color : AppColors.lightGrey,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: color.withAlpha(51),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked ? color : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? Colors.white : AppColors.mediumGrey,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isUnlocked ? color : AppColors.darkGrey,
                      ),
                    ),
                    if (isUnlocked) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mediumGrey,
                  ),
                ),
                if (!isUnlocked && progress > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.lightGrey,
                            valueColor: AlwaysStoppedAnimation(color),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      if (progressText != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          progressText!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Streak display with fire animation feel
class StreakDisplay extends StatelessWidget {
  final int streakDays;
  final bool isActiveToday;
  final VoidCallback? onTap;

  const StreakDisplay({
    super.key,
    required this.streakDays,
    this.isActiveToday = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStreakColor(streakDays);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withAlpha(179)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.circular),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: TextStyle(fontSize: streakDays >= 7 ? 18 : 14),
            ),
            const SizedBox(width: 6),
            Text(
              '$streakDays day${streakDays != 1 ? 's' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (!isActiveToday) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStreakColor(int days) {
    if (days < 3) return AppColors.friendlyOrange;
    if (days < 7) return const Color(0xFFFF5722);
    if (days < 14) return const Color(0xFFE91E63);
    if (days < 30) return AppColors.friendlyPurple;
    return AppColors.warmYellow;
  }
}

/// Daily challenges widget
class DailyChallenges extends StatelessWidget {
  final List<Challenge> challenges;
  final VoidCallback? onViewAll;

  const DailyChallenges({
    super.key,
    required this.challenges,
    this.onViewAll,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warmYellow.withAlpha(26),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.flag,
                      color: AppColors.warmYellow,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Daily Challenges',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View all',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...challenges.take(3).map((challenge) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ChallengeItem(challenge: challenge),
            );
          }),
        ],
      ),
    );
  }
}

class _ChallengeItem extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeItem({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: challenge.isCompleted
            ? AppColors.success.withAlpha(13)
            : AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: challenge.isCompleted
            ? Border.all(color: AppColors.success.withAlpha(51))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: challenge.isCompleted
                  ? AppColors.success
                  : AppColors.primaryBlue.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              challenge.isCompleted ? Icons.check : challenge.icon,
              color: challenge.isCompleted ? Colors.white : AppColors.primaryBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration:
                        challenge.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: AppColors.warmYellow),
                    const SizedBox(width: 4),
                    Text(
                      '+${challenge.xpReward} XP',
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
          if (!challenge.isCompleted && challenge.progress > 0)
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: challenge.progress,
                    strokeWidth: 4,
                    backgroundColor: AppColors.lightGrey,
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                  ),
                  Center(
                    child: Text(
                      '${(challenge.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

/// Leaderboard widget
class FriendLeaderboard extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final int currentUserRank;

  const FriendLeaderboard({
    super.key,
    required this.entries,
    required this.currentUserRank,
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard, color: AppColors.warmYellow),
              const SizedBox(width: 8),
              const Text(
                'Friend Leaderboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...entries.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isCurrentUser = index + 1 == currentUserRank;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppColors.primaryBlue.withAlpha(26)
                    : index < 3
                        ? _getPodiumColor(index).withAlpha(13)
                        : null,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: isCurrentUser
                    ? Border.all(color: AppColors.primaryBlue)
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: index < 3
                        ? Text(
                            _getMedal(index),
                            style: const TextStyle(fontSize: 18),
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withAlpha(26),
                      shape: BoxShape.circle,
                      image: item.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.imageUrl == null
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCurrentUser ? 'You' : item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isCurrentUser
                                ? AppColors.primaryBlue
                                : AppColors.darkGrey,
                          ),
                        ),
                        Text(
                          '${item.xp} XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.streakDays > 0)
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 2),
                        Text(
                          '${item.streakDays}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.friendlyOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getMedal(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '';
    }
  }

  Color _getPodiumColor(int index) {
    switch (index) {
      case 0:
        return AppColors.warmYellow;
      case 1:
        return AppColors.mediumGrey;
      case 2:
        return const Color(0xFFCD7F32);
      default:
        return Colors.transparent;
    }
  }
}

/// XP earned notification
class XpEarnedBanner extends StatelessWidget {
  final int amount;
  final String reason;
  final VoidCallback? onDismiss;

  const XpEarnedBanner({
    super.key,
    required this.amount,
    required this.reason,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warmYellow, AppColors.friendlyOrange],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmYellow.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+$amount XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  reason,
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: Colors.white.withAlpha(179),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// Challenge model
class Challenge {
  final String id;
  final String title;
  final IconData icon;
  final int xpReward;
  final double progress;
  final bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.icon,
    required this.xpReward,
    this.progress = 0,
    this.isCompleted = false,
  });
}

/// Leaderboard entry model
class LeaderboardEntry {
  final String name;
  final String? imageUrl;
  final int xp;
  final int streakDays;

  LeaderboardEntry({
    required this.name,
    this.imageUrl,
    required this.xp,
    this.streakDays = 0,
  });
}

/// Weekly activity summary
class WeeklyActivitySummary extends StatelessWidget {
  final Map<String, int> dailyActivity; // day -> activity count
  final int totalEvents;
  final int newFriends;

  const WeeklyActivitySummary({
    super.key,
    required this.dailyActivity,
    required this.totalEvents,
    required this.newFriends,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxActivity = dailyActivity.values.isEmpty
        ? 1
        : dailyActivity.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              final dayKey = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][entry.key];
              final activity = dailyActivity[dayKey] ?? 0;
              final height = maxActivity > 0 ? (activity / maxActivity) * 40 : 0;

              return Column(
                children: [
                  Container(
                    width: 30,
                    height: 40,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 20,
                      height: height.toDouble() + 4,
                      decoration: BoxDecoration(
                        color: activity > 0
                            ? AppColors.primaryBlue.withAlpha(activity * 60)
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _SummaryChip(
                icon: Icons.event,
                label: '$totalEvents events',
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 10),
              _SummaryChip(
                icon: Icons.people,
                label: '$newFriends new friends',
                color: AppColors.friendlyTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
