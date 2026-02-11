import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';

/// Business registration screen - uses AuthController for state management
class BusinessRegisterScreen extends StatelessWidget {
  const BusinessRegisterScreen({super.key});

  static const List<String> _businessTypes = [
    'Cafe / Restaurant',
    'Bar / Pub',
    'Gym / Fitness',
    'Entertainment Venue',
    'Community Center',
    'Co-working Space',
    'Retail Store',
    'Art Gallery / Museum',
    'Sports Facility',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure auth controller exists
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final formKey = GlobalKey<FormState>();
    final agreeToTerms = false.obs;

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

                  const SizedBox(height: AppSpacing.lg),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        // Business icon with gradient
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0D1B4D), // Dark blue
                                Color(0xFF38B6FF), // Light blue
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
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
                            size: 35,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Create Business Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Start hosting events and building your community',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(179),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Business Name
                  _BusinessTextField(
                    controller: authController.businessNameController,
                    label: 'Business Name',
                    hint: 'Enter your business name',
                    prefixIcon: Icons.business,
                    validator: authController.validateBusinessName,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Business Type dropdown
                  _BusinessDropdown(
                    label: 'Business Type',
                    hint: 'Select your business type',
                    value: authController.selectedBusinessType,
                    items: _businessTypes,
                    validator: authController.validateBusinessType,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Email
                  _BusinessTextField(
                    controller: authController.emailController,
                    label: 'Business Email',
                    hint: 'Enter your business email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: authController.validateEmail,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Phone
                  _BusinessTextField(
                    controller: authController.businessPhoneController,
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: authController.validatePhone,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Password
                  Obx(() => _BusinessTextField(
                        controller: authController.passwordController,
                        label: 'Password',
                        hint: 'Create a password (min 8 characters)',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: !authController.isPasswordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            authController.isPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withAlpha(128),
                          ),
                          onPressed: authController.togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      )),

                  const SizedBox(height: AppSpacing.md),

                  // Confirm Password
                  Obx(() => _BusinessTextField(
                        controller: authController.confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        prefixIcon: Icons.lock_outlined,
                        obscureText:
                            !authController.isConfirmPasswordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            authController.isConfirmPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white.withAlpha(128),
                          ),
                          onPressed:
                              authController.toggleConfirmPasswordVisibility,
                        ),
                        validator: authController.validateConfirmPassword,
                        textInputAction: TextInputAction.done,
                      )),

                  const SizedBox(height: AppSpacing.lg),

                  // Terms checkbox
                  Obx(() => Row(
                        children: [
                          Checkbox(
                            value: agreeToTerms.value,
                            onChanged: (value) =>
                                agreeToTerms.value = value ?? false,
                            activeColor: AppColors.primaryBlue,
                            checkColor: Colors.white,
                            side: BorderSide(color: Colors.white.withAlpha(128)),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  agreeToTerms.value = !agreeToTerms.value,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withAlpha(179),
                                  ),
                                  children: const [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: AppColors.accentBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppColors.accentBlue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),

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

                  // Register button
                  Obx(() => _BusinessButton(
                        text: 'Create Business Account',
                        isLoading: authController.isLoading.value,
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          if (!agreeToTerms.value) {
                            Get.snackbar(
                              'Terms Required',
                              'Please agree to the Terms of Service and Privacy Policy',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.warning,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(AppSpacing.md),
                              borderRadius: AppRadius.md,
                            );
                            return;
                          }

                          final success =
                              await authController.registerBusiness();
                          if (success) {
                            if (!Get.isRegistered<ProfileController>()) {
                              Get.put(ProfileController(), permanent: true);
                            }
                            Get.snackbar(
                              'Account Created',
                              'Welcome to Fluttrr for Business!',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.success,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(AppSpacing.md),
                              borderRadius: AppRadius.md,
                            );
                            Nav.toBusinessDashboard();
                          }
                        },
                      )),

                  const SizedBox(height: AppSpacing.xl),

                  // Already have account
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withAlpha(179),
                          ),
                          children: const [
                            TextSpan(text: 'Already have a business account? '),
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

/// Business text field widget
class _BusinessTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const _BusinessTextField({
    this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
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
          cursorColor: AppColors.accentBlue,
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
            fillColor: Colors.white.withAlpha(20),
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

/// Business dropdown widget
class _BusinessDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final RxString value;
  final List<String> items;
  final String? Function(String?)? validator;

  const _BusinessDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    this.validator,
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
        Obx(() => DropdownButtonFormField<String>(
              value: value.value.isEmpty ? null : value.value,
              hint: Text(
                hint,
                style: TextStyle(color: Colors.white.withAlpha(77)),
              ),
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(fontSize: 16, color: Colors.white),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withAlpha(128),
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.category_outlined,
                  color: Colors.white.withAlpha(128),
                  size: 22,
                ),
                filled: true,
                fillColor: Colors.white.withAlpha(20),
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
              items: items.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  value.value = newValue;
                }
              },
              validator: validator,
            )),
      ],
    );
  }
}

/// Business gradient button
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
