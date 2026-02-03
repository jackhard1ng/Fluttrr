import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/common_widgets.dart';
import '../home/main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// Login screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Header
                const GradientText(
                  text: 'Welcome\nBack',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: AppSpacing.xl * 2),

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
                      hintText: 'Enter your password',
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
                      textInputAction: TextInputAction.done,
                    )),

                const SizedBox(height: AppSpacing.sm),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

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

                // Login button
                Obx(() => GradientButton(
                      text: 'Sign In',
                      isLoading: authController.isLoading.value,
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final success = await authController.login();
                          if (success) {
                            Get.put(ProfileController());
                            Get.offAll(() => const MainScreen());
                          }
                        }
                      },
                    )),

                const SizedBox(height: AppSpacing.xl),

                // Or divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'Or continue with',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Google sign in
                _SocialButton(
                  icon: 'assets/google_icon.svg',
                  label: 'Continue with Google',
                  onPressed: () async {
                    final success = await authController.signInWithGoogle();
                    if (success) {
                      Get.put(ProfileController());
                      Get.offAll(() => const MainScreen());
                    }
                  },
                ),

                const SizedBox(height: AppSpacing.xl * 2),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const RegisterScreen()),
                      child: const Text(
                        'Sign Up',
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

/// Social login button
class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Try to load SVG, fallback to icon
            _buildIcon(),
            const SizedBox(width: AppSpacing.md),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // Return a simple Google icon as fallback
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
