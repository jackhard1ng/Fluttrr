import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';

/// Modern login screen with brand identity
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final formKey = GlobalKey<FormState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.userLoginDarkGradient
              : AppGradients.userLoginGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Logo and branding
                  Center(
                    child: Column(
                      children: [
                        // Butterfly logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withAlpha(51),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/lgo1.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primaryDark,
                                  child: const Icon(
                                    Icons.flutter_dash,
                                    size: 40,
                                    color: AppColors.primaryBlue,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // App name
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.accentBlue],
                          ).createShader(bounds),
                          child: const Text(
                            'fluttrr.',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Welcome text
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to reconnect with your friends',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Email field
                  _ModernTextField(
                    controller: authController.emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: authController.validateEmail,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Password field
                  Obx(() => _ModernTextField(
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
                        color: AppColors.mediumGrey,
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
                        foregroundColor: AppColors.primaryBlue,
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
                          color: AppColors.error.withAlpha(26),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.error.withAlpha(51),
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
                  Obx(() => _ModernButton(
                    text: 'Sign In',
                    isLoading: authController.isLoading.value,
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final success = await authController.login();
                        if (success) {
                          Get.put(ProfileController());
                          Nav.toHome();
                        }
                      }
                    },
                  )),

                  const SizedBox(height: AppSpacing.xl),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.lightGrey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          'or continue with',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Google sign in
                  _SocialLoginButton(
                    label: 'Continue with Google',
                    onPressed: () async {
                      final success = await authController.signInWithGoogle();
                      if (success) {
                        Get.put(ProfileController());
                        Nav.toHome();
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Sign up link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New to Fluttrr? ",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.register),
                          child: const Text(
                            'Join Now',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Platonic friendship tagline
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.friendlyTeal.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: AppColors.friendlyTeal,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'A safe space for real friendships',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.friendlyTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Business account link - clearly separated
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withAlpha(13),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.primaryDark.withAlpha(26),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Have a business?',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              Text(
                                'Host events and connect with customers',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.businessLogin),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            backgroundColor: AppColors.primaryDark.withAlpha(26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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

/// Modern text field widget
class _ModernTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const _ModernTextField({
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
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.mediumGrey.withAlpha(128),
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.mediumGrey,
              size: 22,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern gradient button
class _ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ModernButton({
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
        gradient: onPressed != null && !isLoading
            ? AppGradients.buttonGradient
            : null,
        color: onPressed == null || isLoading ? AppColors.grey : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: onPressed != null && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withAlpha(77),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
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
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Social login button
class _SocialLoginButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.lightGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/google logo.png',
                  width: 18,
                  height: 18,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
