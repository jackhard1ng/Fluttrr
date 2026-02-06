import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Promo code display
class PromoCodeBadge extends StatelessWidget {
  final String code;
  final String? discount;
  final VoidCallback? onCopy;

  const PromoCodeBadge({
    super.key,
    required this.code,
    this.discount,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        HapticFeedback.lightImpact();
        Get.snackbar(
          'Copied!',
          'Promo code copied to clipboard',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        onCopy?.call();
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
          border: Border.all(
            color: AppColors.friendlyPurple.withAlpha(77),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.friendlyPurple,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (discount != null)
                    Text(
                      discount!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.friendlyPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(128),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.copy, size: 18, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Create promo code card
class CreatePromoCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreatePromoCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryBlue,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              'Create Promo Code',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Active promo list item
class PromoListItem extends StatelessWidget {
  final String code;
  final String discount;
  final int usedCount;
  final int? maxUses;
  final String? expiresAt;
  final bool isActive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PromoListItem({
    super.key,
    required this.code,
    required this.discount,
    this.usedCount = 0,
    this.maxUses,
    this.expiresAt,
    this.isActive = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success.withAlpha(26)
                      : AppColors.mediumGrey.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.success : AppColors.mediumGrey,
                  ),
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(Icons.edit, size: 18, color: AppColors.mediumGrey),
                ),
              if (onDelete != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete, size: 18, color: AppColors.error),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                code,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.friendlyOrange.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Text(
                  discount,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.friendlyOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, size: 14, color: AppColors.mediumGrey),
              const SizedBox(width: 4),
              Text(
                maxUses != null
                    ? '$usedCount / $maxUses used'
                    : '$usedCount used',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
              if (expiresAt != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 14, color: AppColors.mediumGrey),
                const SizedBox(width: 4),
                Text(
                  'Expires $expiresAt',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Discount badge
class DiscountBadge extends StatelessWidget {
  final String discount;

  const DiscountBadge({super.key, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            discount,
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
}

/// Has promo badge
class HasPromoBadge extends StatelessWidget {
  const HasPromoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.friendlyPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer, size: 12, color: AppColors.friendlyPurple),
          const SizedBox(width: 4),
          Text(
            'Promo',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.friendlyPurple,
            ),
          ),
        ],
      ),
    );
  }
}
