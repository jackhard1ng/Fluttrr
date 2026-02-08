import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Thank the host button
class ThankHostButton extends StatelessWidget {
  final bool hasThanked;
  final String hostName;
  final VoidCallback onThank;

  const ThankHostButton({
    super.key,
    this.hasThanked = false,
    required this.hostName,
    required this.onThank,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasThanked
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onThank();
              Get.snackbar(
                '💜 Thanks Sent!',
                '$hostName will appreciate it',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.friendlyPurple,
                colorText: Colors.white,
              );
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: hasThanked
              ? AppColors.friendlyPurple.withAlpha(26)
              : AppColors.friendlyPurple,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasThanked ? '💜' : '🙏',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              hasThanked ? 'Thanked!' : 'Thank Host',
              style: TextStyle(
                color: hasThanked ? AppColors.friendlyPurple : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thanks received count
class ThanksReceived extends StatelessWidget {
  final int count;

  const ThanksReceived({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.friendlyPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💜', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$count thanks',
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

/// Post-event feedback prompt
class FeedbackPrompt extends StatelessWidget {
  final String eventName;
  final VoidCallback? onRate;
  final VoidCallback? onDismiss;

  const FeedbackPrompt({
    super.key,
    required this.eventName,
    this.onRate,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.friendlyPurple.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.friendlyPurple.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'How was $eventName?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (onDismiss != null)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDismiss!();
                  },
                  child: Icon(Icons.close, size: 20, color: AppColors.mediumGrey),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your feedback helps hosts improve future events',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mediumGrey,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRate?.call();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.friendlyPurple,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Center(
                child: Text(
                  'Rate Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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

/// Quick star rating
class QuickRating extends StatelessWidget {
  final int rating; // 0-5
  final Function(int) onRate;
  final bool readOnly;

  const QuickRating({
    super.key,
    this.rating = 0,
    required this.onRate,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starNum = i + 1;
        final isFilled = starNum <= rating;

        return GestureDetector(
          onTap: readOnly
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onRate(starNum);
                },
          child: Padding(
            padding: EdgeInsets.only(right: i < 4 ? 4 : 0),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: 28,
              color: isFilled ? AppColors.warmYellow : AppColors.lightGrey,
            ),
          ),
        );
      }),
    );
  }
}

/// Appreciation message
class AppreciationCard extends StatelessWidget {
  final String fromName;
  final String message;
  final String? eventName;

  const AppreciationCard({
    super.key,
    required this.fromName,
    required this.message,
    this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.friendlyPurple.withAlpha(26),
            AppColors.warmYellow.withAlpha(26),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.friendlyPurple.withAlpha(51),
                ),
                child: Center(
                  child: Text(
                    fromName[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.friendlyPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fromName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (eventName != null)
                      Text(
                        'from $eventName',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                  ],
                ),
              ),
              const Text('💜', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"$message"',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
