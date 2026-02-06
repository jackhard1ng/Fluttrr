import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/utils.dart';

/// Onboarding page widget
class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final Color? backgroundColor;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.white,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Page indicator dots
class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Color? activeColor;
  final Color? inactiveColor;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? (activeColor ?? AppColors.primaryBlue)
                : (inactiveColor ?? AppColors.lightGrey),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Feature highlight card
class FeatureHighlight extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  const FeatureHighlight({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final featureColor = color ?? AppColors.primaryBlue;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: featureColor.withAlpha(13),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: featureColor.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: featureColor.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: featureColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: featureColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
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

/// Tooltip overlay for feature discovery
class TooltipOverlay extends StatelessWidget {
  final String message;
  final Widget child;
  final bool showAbove;
  final VoidCallback? onDismiss;

  const TooltipOverlay({
    super.key,
    required this.message,
    required this.child,
    this.showAbove = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: showAbove ? null : null,
          bottom: showAbove ? null : null,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkGrey,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (onDismiss != null)
                    Icon(Icons.close, size: 18, color: Colors.white.withAlpha(179)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Welcome card for first-time users
class WelcomeCard extends StatelessWidget {
  final String userName;
  final VoidCallback? onGetStarted;
  final VoidCallback? onDismiss;

  const WelcomeCard({
    super.key,
    required this.userName,
    this.onGetStarted,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.friendlyPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👋',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome, $userName!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ready to meet new friends and join fun events?',
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          if (onGetStarted != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onGetStarted!();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Permission request card
class PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onAllow;
  final VoidCallback? onSkip;

  const PermissionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onAllow,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: AppColors.mediumGrey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (onSkip != null)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSkip!();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withAlpha(128),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          'Not Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (onSkip != null) const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onAllow?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Center(
                      child: Text(
                        'Allow',
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
    );
  }
}

/// Setup progress indicator
class SetupProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const SetupProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.primaryBlue
                              : AppColors.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : AppColors.mediumGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted ? AppColors.success : AppColors.lightGrey,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stepLabels.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isCompleted || isCurrent
                    ? AppColors.darkGrey
                    : AppColors.mediumGrey,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Tip of the day card
class TipOfTheDay extends StatelessWidget {
  final String tip;
  final VoidCallback? onDismiss;

  const TipOfTheDay({
    super.key,
    required this.tip,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmYellow.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warmYellow.withAlpha(77)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 18, color: AppColors.mediumGrey),
            ),
        ],
      ),
    );
  }
}
