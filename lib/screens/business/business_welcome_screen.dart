import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../widgets/common_widgets.dart';

/// Business welcome screen
class BusinessWelcomeScreen extends StatelessWidget {
  const BusinessWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),

              // Illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryRadial,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_center,
                  size: 100,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              const GradientText(
                text: 'Grow Your Business',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'Create a business profile to promote your events and connect with more people in your community.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey,
                    ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Features list
              _FeatureItem(
                icon: Icons.event,
                title: 'Create Events',
                description: 'Host and promote events to your audience',
              ),
              const SizedBox(height: AppSpacing.md),
              _FeatureItem(
                icon: Icons.analytics,
                title: 'Track Analytics',
                description: 'Get insights on your events and audience',
              ),
              const SizedBox(height: AppSpacing.md),
              _FeatureItem(
                icon: Icons.people,
                title: 'Build Community',
                description: 'Connect with attendees and grow your following',
              ),

              const Spacer(),

              // Get started button
              GradientButton(
                text: 'Get Started',
                onPressed: () => Nav.toBusinessCreateProfile(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Skip button
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Maybe Later'),
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature item widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withAlpha(26),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
