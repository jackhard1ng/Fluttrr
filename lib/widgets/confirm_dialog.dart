import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Simple confirmation dialog
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final bool isDangerous;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(result: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withAlpha(128),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          cancelLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Get.back(result: true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: confirmColor ??
                            (isDangerous ? AppColors.error : AppColors.primaryBlue),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          confirmLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      ),
    );
  }

  static Future<bool?> show({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    bool isDangerous = false,
  }) {
    return Get.dialog<bool>(
      ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        isDangerous: isDangerous,
      ),
    );
  }
}

/// Success dialog
class SuccessDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String buttonLabel;
  final VoidCallback? onDismiss;

  const SuccessDialog({
    super.key,
    required this.title,
    this.message,
    this.buttonLabel = 'Done',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 32,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Get.back();
                onDismiss?.call();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required String title,
    String? message,
    String buttonLabel = 'Done',
    VoidCallback? onDismiss,
  }) {
    return Get.dialog(
      SuccessDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel,
        onDismiss: onDismiss,
      ),
    );
  }
}

/// Quick action sheet
class QuickActionSheet extends StatelessWidget {
  final String? title;
  final List<QuickActionItem> actions;

  const QuickActionSheet({
    super.key,
    this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ...actions.map((action) => _ActionItem(action: action)),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    String? title,
    required List<QuickActionItem> actions,
  }) {
    return Get.bottomSheet(
      QuickActionSheet(title: title, actions: actions),
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isDangerous;
  final VoidCallback onTap;

  QuickActionItem({
    required this.icon,
    required this.label,
    this.color,
    this.isDangerous = false,
    required this.onTap,
  });
}

class _ActionItem extends StatelessWidget {
  final QuickActionItem action;

  const _ActionItem({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = action.color ??
        (action.isDangerous ? AppColors.error : AppColors.darkGrey);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.back();
        action.onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(action.icon, color: color),
            const SizedBox(width: 16),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
