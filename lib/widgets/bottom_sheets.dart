import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/utils.dart';

/// Helper class for showing bottom sheets
class AppBottomSheet {
  AppBottomSheet._();

  /// Show a basic bottom sheet with custom content
  static Future<T?> show<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    Color? backgroundColor,
    double? elevation,
  }) {
    return Get.bottomSheet<T>(
      child,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Get.theme.scaffoldBackgroundColor,
      elevation: elevation ?? 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    );
  }

  /// Show an action sheet with list of options
  static Future<T?> showActions<T>({
    String? title,
    String? message,
    required List<BottomSheetAction<T>> actions,
    bool showCancel = true,
    String cancelText = 'Cancel',
  }) {
    return show<T>(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const _SheetHandle(),

            // Title and message
            if (title != null || message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    if (title != null)
                      Text(
                        title,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        message,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

            const Divider(height: 1),

            // Actions
            ...actions.map((action) => _ActionTile<T>(action: action)),

            // Cancel
            if (showCancel) ...[
              const Divider(height: 1),
              _ActionTile<T>(
                action: BottomSheetAction<T>(
                  icon: Icons.close,
                  label: cancelText,
                  onTap: () => Get.back(),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  /// Show a confirmation bottom sheet
  static Future<bool> showConfirmation({
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    bool isDangerous = false,
  }) async {
    final result = await show<bool>(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              const SizedBox(height: AppSpacing.md),

              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isDangerous ? AppColors.error : AppColors.warning)
                      .withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDangerous ? Icons.warning_amber : Icons.help_outline,
                  color: isDangerous ? AppColors.error : AppColors.warning,
                  size: 32,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                title,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      child: Text(cancelText),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor ??
                            (isDangerous ? AppColors.error : AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  /// Show a picker bottom sheet
  static Future<T?> showPicker<T>({
    required String title,
    required List<T> items,
    required String Function(T) labelBuilder,
    T? selectedItem,
    Widget Function(T, bool)? itemBuilder,
  }) {
    return show<T>(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),

            // Title
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Divider(height: 1),

            // Items
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selectedItem;

                  if (itemBuilder != null) {
                    return GestureDetector(
                      onTap: () => Get.back(result: item),
                      child: itemBuilder(item, isSelected),
                    );
                  }

                  return ListTile(
                    title: Text(
                      labelBuilder(item),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primaryBlue : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primaryBlue)
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Get.back(result: item);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  /// Show an input bottom sheet
  static Future<String?> showInput({
    required String title,
    String? hint,
    String? initialValue,
    String submitText = 'Submit',
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await show<String>(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SheetHandle(),
                const SizedBox(height: AppSpacing.md),

                // Title
                Text(
                  title,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Input
                TextFormField(
                  controller: controller,
                  autofocus: true,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  keyboardType: keyboardType,
                  validator: validator,
                  decoration: InputDecoration(
                    hintText: hint,
                    filled: true,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Submit button
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Get.back(result: controller.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: Text(submitText),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    controller.dispose();
    return result;
  }
}

/// Bottom sheet action item
class BottomSheetAction<T> {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final T? value;
  final Color? color;
  final bool isDangerous;

  const BottomSheetAction({
    this.icon,
    required this.label,
    this.onTap,
    this.value,
    this.color,
    this.isDangerous = false,
  });
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ActionTile<T> extends StatelessWidget {
  final BottomSheetAction<T> action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = action.color ??
        (action.isDangerous ? AppColors.error : null);

    return ListTile(
      leading: action.icon != null
          ? Icon(action.icon, color: color)
          : null,
      title: Text(
        action.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        if (action.value != null) {
          Get.back(result: action.value);
        } else {
          action.onTap?.call();
        }
      },
    );
  }
}
