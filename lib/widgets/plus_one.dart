import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Plus one toggle
class PlusOneToggle extends StatelessWidget {
  final bool bringingPlusOne;
  final String? plusOneName;
  final Function(bool) onToggle;
  final VoidCallback? onAddName;

  const PlusOneToggle({
    super.key,
    this.bringingPlusOne = false,
    this.plusOneName,
    required this.onToggle,
    this.onAddName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bringingPlusOne
            ? AppColors.friendlyPurple.withAlpha(26)
            : AppColors.lightGrey.withAlpha(77),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: bringingPlusOne
              ? AppColors.friendlyPurple
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            bringingPlusOne ? Icons.person_add : Icons.person_add_alt_1,
            color: bringingPlusOne
                ? AppColors.friendlyPurple
                : AppColors.mediumGrey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bringing a +1?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                if (bringingPlusOne && plusOneName != null)
                  Text(
                    plusOneName!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.friendlyPurple,
                    ),
                  )
                else if (bringingPlusOne)
                  GestureDetector(
                    onTap: onAddName,
                    child: Text(
                      'Add their name',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: bringingPlusOne,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onToggle(value);
            },
            activeColor: AppColors.friendlyPurple,
          ),
        ],
      ),
    );
  }
}

/// Plus one badge
class PlusOneBadge extends StatelessWidget {
  final String? name;

  const PlusOneBadge({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.friendlyPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_add, size: 14, color: AppColors.friendlyPurple),
          const SizedBox(width: 5),
          Text(
            name != null ? '+1 ($name)' : '+1 Guest',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.friendlyPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Plus ones count for event
class PlusOnesCount extends StatelessWidget {
  final int count;

  const PlusOnesCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withAlpha(128),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_add, size: 14, color: AppColors.mediumGrey),
          const SizedBox(width: 5),
          Text(
            '+$count guest${count > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bring a friend prompt
class BringFriendPrompt extends StatelessWidget {
  final VoidCallback? onInvite;

  const BringFriendPrompt({super.key, this.onInvite});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onInvite?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.friendlyPurple.withAlpha(26),
              AppColors.primaryBlue.withAlpha(26),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.friendlyPurple.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.friendlyPurple.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add,
                color: AppColors.friendlyPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Know someone who\'d love this?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Invite a friend to join!',
                    style: TextStyle(
                      fontSize: 13,
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

/// Guest list entry
class GuestEntry extends StatelessWidget {
  final String name;
  final bool isHost;
  final bool hasPlusOne;
  final String? plusOneName;

  const GuestEntry({
    super.key,
    required this.name,
    this.isHost = false,
    this.hasPlusOne = false,
    this.plusOneName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHost
                  ? AppColors.warmYellow.withAlpha(51)
                  : AppColors.primaryBlue.withAlpha(26),
            ),
            child: Center(
              child: Text(
                name[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isHost ? AppColors.warmYellow : AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warmYellow.withAlpha(51),
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: Text(
                          'Host',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.warmYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasPlusOne)
                  Text(
                    plusOneName != null
                        ? '+ $plusOneName'
                        : '+ 1 guest',
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
    );
  }
}
