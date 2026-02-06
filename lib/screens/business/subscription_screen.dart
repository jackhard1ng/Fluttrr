import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/business_controller.dart';
import '../../services/stripe_service.dart';
import '../../widgets/common_widgets.dart';

/// Subscription screen
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _businessController = Get.find<BusinessController>();
  int _selectedPlanIndex = 1; // Default to Pro plan

  final List<_SubscriptionPlan> _plans = [
    _SubscriptionPlan(
      name: 'Basic',
      price: 0,
      period: 'Free',
      features: [
        'Create up to 3 events',
        'Basic analytics',
        'Email support',
        'Public events only',
      ],
      notIncluded: [
        'Priority support',
        'Advanced analytics',
        'Unlimited events',
        'Private events',
      ],
    ),
    _SubscriptionPlan(
      name: 'Pro',
      price: 29,
      period: '/month',
      features: [
        'Create up to 20 events',
        'Advanced analytics',
        'Priority email support',
        'Public & private events',
        'Custom branding',
        'Promoted listings',
      ],
      notIncluded: [
        'Unlimited events',
        'API access',
      ],
      isPopular: true,
    ),
    _SubscriptionPlan(
      name: 'Enterprise',
      price: 99,
      period: '/month',
      features: [
        'Unlimited events',
        'Full analytics suite',
        '24/7 priority support',
        'All event types',
        'Custom branding',
        'Promoted listings',
        'API access',
        'Dedicated account manager',
      ],
      notIncluded: [],
    ),
  ];

  Future<void> _subscribe() async {
    final selectedPlan = _plans[_selectedPlanIndex];

    if (selectedPlan.price == 0) {
      Get.snackbar(
        'Info',
        'You are already on the free plan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final stripeService = StripeService();
      final result = await stripeService.processPayment(
        amount: selectedPlan.price * 100, // Convert to cents
        currency: 'usd',
        merchantDisplayName: 'Fluttrr Business',
        metadata: {
          'plan': selectedPlan.name,
        },
      );

      Get.back(); // Dismiss loading

      if (result.success) {
        Get.snackbar(
          'Success',
          'Successfully subscribed to ${selectedPlan.name} plan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
        _businessController.loadSubscriptionStatus();
      } else {
        Get.snackbar(
          'Error',
          result.error ?? 'Payment failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Dismiss loading
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const GradientText(
              text: 'Choose Your Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Unlock powerful features to grow your business',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.grey,
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Current plan
            Obx(() {
              final status = _businessController.subscriptionStatus.value;
              if (status != null && status.isActive) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Plan: ${status.planName ?? 'Free'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (status.expiryDate != null)
                              Text(
                                'Renews on ${status.expiryDate!.day}/${status.expiryDate!.month}/${status.expiryDate!.year}',
                                style: const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Plans
            ...List.generate(_plans.length, (index) {
              final plan = _plans[index];
              final isSelected = _selectedPlanIndex == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedPlanIndex = index),
                child: _PlanCard(
                  plan: plan,
                  isSelected: isSelected,
                ),
              );
            }),

            const SizedBox(height: AppSpacing.xl),

            // Subscribe button
            GradientButton(
              text: _plans[_selectedPlanIndex].price == 0
                  ? 'Current Plan'
                  : 'Subscribe to ${_plans[_selectedPlanIndex].name}',
              onPressed: _subscribe,
            ),

            const SizedBox(height: AppSpacing.md),

            // Terms
            Center(
              child: Text(
                'By subscribing, you agree to our Terms of Service\nand Privacy Policy. Cancel anytime.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Subscription plan data model
class _SubscriptionPlan {
  final String name;
  final int price;
  final String period;
  final List<String> features;
  final List<String> notIncluded;
  final bool isPopular;

  _SubscriptionPlan({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.notIncluded,
    this.isPopular = false,
  });
}

/// Plan card widget
class _PlanCard extends StatelessWidget {
  final _SubscriptionPlan plan;
  final bool isSelected;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppShadows.medium : AppShadows.small,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan name and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              plan.price == 0 ? 'Free' : '\$${plan.price}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : Colors.black,
                              ),
                            ),
                            if (plan.price > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  plan.period,
                                  style: const TextStyle(
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),

                // Features
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),

                // Not included features
                ...plan.notIncluded.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cancel,
                            color: AppColors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          // Popular badge
          if (plan.isPopular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: const BoxDecoration(
                  gradient: AppGradients.primaryHorizontal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.sm),
                    bottomRight: Radius.circular(AppRadius.sm),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
