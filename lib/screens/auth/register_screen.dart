import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

/// Registration screen
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();

    // Clear fields when entering registration (deferred to avoid setState during build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.clearFields();
    });

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
                  text: 'Create\nAccount',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Join our community today',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                // Username field
                CustomTextField(
                  controller: authController.userNameController,
                  labelText: 'Username',
                  hintText: 'Choose a username',
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: authController.validateUserName,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Email field
                CustomTextField(
                  controller: authController.emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: authController.validateEmail,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Password field
                Obx(() => CustomTextField(
                      controller: authController.passwordController,
                      labelText: 'Password',
                      hintText: 'Create a password',
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
                      hintText: 'Confirm your password',
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

                // Terms and conditions
                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                      activeColor: AppColors.primaryBlue,
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Register button
                Obx(() => GradientButton(
                      text: 'Create Account',
                      isLoading: authController.isLoading.value,
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final success = await authController.sendOtp();
                          if (success) {
                            Nav.toOtp(isRegistration: true);
                          }
                        }
                      },
                    )),

                const SizedBox(height: AppSpacing.xl),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
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
