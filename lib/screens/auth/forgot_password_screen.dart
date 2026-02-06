import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

/// Forgot password screen
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();

    // Clear email field
    authController.emailController.clear();
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
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const GradientText(
                  text: 'Forgot\nPassword?',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  "Don't worry! Enter your email address and we'll send you a verification code.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                // Illustration
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                // Email field
                CustomTextField(
                  controller: authController.emailController,
                  labelText: 'Email',
                  hintText: 'Enter your registered email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: authController.validateEmail,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: AppSpacing.lg),

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

                // Send code button
                Obx(() => GradientButton(
                      text: 'Send Verification Code',
                      isLoading: authController.isLoading.value,
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final success =
                              await authController.requestPasswordResetOtp();
                          if (success) {
                            Nav.toOtp(isRegistration: false);
                          }
                        }
                      },
                    )),

                const SizedBox(height: AppSpacing.xl),

                // Back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
