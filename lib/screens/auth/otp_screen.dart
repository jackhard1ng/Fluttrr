import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/common_widgets.dart';

/// OTP verification screen
class OtpScreen extends StatefulWidget {
  final bool isRegistration;

  const OtpScreen({
    super.key,
    this.isRegistration = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const GradientText(
                text: 'Verify Your\nEmail',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                'We sent a verification code to',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                authController.tempEmail,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryBlue,
                    ),
              ),

              const SizedBox(height: AppSpacing.xl * 2),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
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
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Verify button
              Obx(() => GradientButton(
                    text: 'Verify',
                    isLoading: authController.isLoading.value,
                    onPressed: () async {
                      authController.otpController.text = _otp;

                      if (widget.isRegistration) {
                        final success = await authController.verifyOtp();
                        if (success) {
                          if (!Get.isRegistered<ProfileController>()) {
                            Get.put(ProfileController(), permanent: true);
                          }
                          // Navigate to profile setup for new users (clear stack)
                          Get.offAllNamed(AppRoutes.profileSetup);
                        }
                      } else {
                        final success =
                            await authController.verifyPasswordResetOtp();
                        if (success) {
                          Nav.toResetPassword();
                        }
                      }
                    },
                  )),

              const SizedBox(height: AppSpacing.xl),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (widget.isRegistration) {
                        await authController.sendOtp();
                      } else {
                        await authController.requestPasswordResetOtp();
                      }
                      Get.snackbar(
                        'Code Sent',
                        'A new verification code has been sent',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                    },
                    child: const Text(
                      'Resend',
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
    );
  }
}
