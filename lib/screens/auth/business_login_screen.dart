import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';

/// Business login screen - separate from regular user login
class BusinessLoginScreen extends StatelessWidget {
  const BusinessLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.put to ensure controller exists, or find if already registered
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.businessGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Back button
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(26),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Business branding
                  Center(
                    child: Column(
                      children: [
                        // Business icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D1B4D), Color(0xFF38B6FF)], // Dark to light blue
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withAlpha(77),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Fluttrr for Business',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Host events • Build community • Grow your brand',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Welcome text
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to your business account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withAlpha(179),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Email field
                  _BusinessTextField(
                    controller: authController.emailController,
                    label: 'Business Email',
                    hint: 'Enter your business email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: authController.validateEmail,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Password field
                  Obx(() => _BusinessTextField(
                    controller: authController.passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: !authController.isPasswordVisible.value,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white.withAlpha(128),
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
                      onPressed: Nav.toForgotPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accentBlue,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Error message
                  Obx(() {
                    if (authController.errorMessage.value.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(51),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.error.withAlpha(77),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                authController.errorMessage.value,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // Login button
                  Obx(() => _BusinessButton(
                    text: 'Sign In to Business',
                    isLoading: authController.isLoading.value,
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final success = await authController.loginBusiness();
                        if (success) {
                          if (!Get.isRegistered<ProfileController>()) {
                            Get.put(ProfileController(), permanent: true);
                          }
                          // Navigate to business dashboard instead of regular home
                          Nav.toBusinessDashboard();
                        }
                      }
                    },
                  )),

                  const SizedBox(height: AppSpacing.xl),

                  // Create business account
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Don't have a business account?",
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton(
                          onPressed: () => Get.toNamed(AppRoutes.businessRegister),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withAlpha(77)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.md,
                            ),
                          ),
                          child: const Text('Create Business Account'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Benefits section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Colors.white.withAlpha(26),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Benefits',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withAlpha(230),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _BenefitItem(
                          icon: Icons.event,
                          text: 'Create and manage events',
                        ),
                        _BenefitItem(
                          icon: Icons.analytics_outlined,
                          text: 'Track attendance & analytics',
                        ),
                        _BenefitItem(
                          icon: Icons.people_outline,
                          text: 'Build your local community',
                        ),
                        _BenefitItem(
                          icon: Icons.star_outline,
                          text: 'Collect reviews & ratings',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Back to regular login
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: Colors.white.withAlpha(128),
                      ),
                      label: Text(
                        'Back to regular sign in',
                        style: TextStyle(
                          color: Colors.white.withAlpha(128),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BusinessTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const _BusinessTextField({
    this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    required this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(230),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withAlpha(77),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.white.withAlpha(128),
              size: 22,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withAlpha(26),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: Colors.white.withAlpha(26),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.accentBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            errorStyle: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class _BusinessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _BusinessButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isLoading
            ? null
            : const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF0D1B4D), // Dark blue
                  Color(0xFF38B6FF), // Light blue
                ],
              ),
        color: isLoading ? AppColors.primaryBlue.withAlpha(128) : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: isLoading
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryBlue.withAlpha(77),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onPressed?.call();
                },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.accentBlue,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withAlpha(179),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
