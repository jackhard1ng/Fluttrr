import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

/// Reset password screen
class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Clear password fields
    authController.passwordController.clear();
    authController.confirmPasswordController.clear();
    authController.errorMessage.value = '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const GradientText(
                  text: 'Reset\nPassword',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  'Create a strong password for your account',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                // New password field
                Obx(() => CustomTextField(
                      controller: authController.passwordController,
                      labelText: 'New Password',
                      hintText: 'Enter new password',
                      obscureText: !authController.isPasswordVisible.value,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: authController.togglePasswordVisibility,
                      ),
                      validator: authController.validatePassword,
                      textInputAction: TextInputAction.next,
                    )),

                const SizedBox(height: AppSpacing.lg),

                // Confirm password field
                Obx(() => CustomTextField(
                      controller: authController.confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Confirm new password',
                      obscureText:
                          !authController.isConfirmPasswordVisible.value,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          authController.isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            authController.toggleConfirmPasswordVisibility,
                      ),
                      validator: authController.validateConfirmPassword,
                      textInputAction: TextInputAction.done,
                    )),

                const SizedBox(height: AppSpacing.lg),

                // Password requirements
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password must contain:',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _PasswordRequirement(
                        text: 'At least 6 characters',
                        isMet: authController.passwordController.text.length >=
                            6,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Error message
                Obx(() {
                  if (authController.errorMessage.value.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        authController.errorMessage.value,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Reset button
                Obx(() => GradientButton(
                      text: 'Reset Password',
                      isLoading: authController.isLoading.value,
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final success = await authController.resetPassword();
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'Password has been reset successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.success,
                              colorText: Colors.white,
                            );
                            Nav.toLogin();
                          }
                        }
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Password requirement widget
class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isMet ? AppColors.success : AppColors.grey,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: TextStyle(
            color: isMet ? AppColors.success : AppColors.darkGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
