import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/business_controller.dart';
import '../../widgets/common_widgets.dart';

/// Business create profile screen
class BusinessCreateProfileScreen extends StatefulWidget {
  const BusinessCreateProfileScreen({super.key});

  @override
  State<BusinessCreateProfileScreen> createState() =>
      _BusinessCreateProfileScreenState();
}

class _BusinessCreateProfileScreenState
    extends State<BusinessCreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessController = Get.isRegistered<BusinessController>()
      ? Get.find<BusinessController>()
      : Get.put(BusinessController());
  final _imagePicker = ImagePicker();

  // Text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();

  // State
  bool _isEmailVerified = false;
  bool _showOtpField = false;
  int _countdown = 0;
  Timer? _countdownTimer;
  File? _profileImage;
  File? _coverImage;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(image.path);
          } else {
            _coverImage = File(image.path);
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(_emailController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _businessController.sendBusinessOtp(
      _emailController.text,
    );

    if (success) {
      setState(() {
        _showOtpField = true;
      });
      _startCountdown();
      Get.snackbar(
        'Success',
        'OTP sent to your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _businessController.verifyBusinessOtp(
      email: _emailController.text,
      otp: _otpController.text,
    );

    if (success) {
      setState(() {
        _isEmailVerified = true;
        _showOtpField = false;
      });
      _countdownTimer?.cancel();
      Get.snackbar(
        'Success',
        'Email verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEmailVerified) {
      Get.snackbar(
        'Error',
        'Please verify your email first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (_profileImage == null) {
      Get.snackbar(
        'Error',
        'Please select a profile image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (_coverImage == null) {
      Get.snackbar(
        'Error',
        'Please select a cover image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _businessController.createBusinessProfile(
      name: _nameController.text,
      description: _descriptionController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      location: _locationController.text,
      address: _addressController.text,
      website: _websiteController.text,
      facebook: _facebookController.text,
      instagram: _instagramController.text,
      profileImage: _profileImage!,
      coverImage: _coverImage!,
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Business profile created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      Nav.toBusinessHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Business Profile'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover and profile images
              _buildImageSection(),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _buildLabel('Business Name'),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Enter business name',
                      prefixIcon: const Icon(Icons.business),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter business name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    _buildLabel('Description'),
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Describe your business',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter business description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Email with verification
                    _buildLabel('Business Email'),
                    _buildEmailSection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Phone
                    _buildLabel('Phone Number'),
                    CustomTextField(
                      controller: _phoneController,
                      hintText: 'Enter phone number',
                      prefixIcon: const Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Location
                    _buildLabel('City'),
                    CustomTextField(
                      controller: _locationController,
                      hintText: 'e.g. Kansas City',
                      prefixIcon: const Icon(Icons.location_on),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter city';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Address
                    _buildLabel('Business Address'),
                    CustomTextField(
                      controller: _addressController,
                      hintText: 'Enter full street address',
                      prefixIcon: const Icon(Icons.home),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Website (optional)
                    _buildLabel('Website (Optional)'),
                    CustomTextField(
                      controller: _websiteController,
                      hintText: 'https://example.com',
                      prefixIcon: const Icon(Icons.language),
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Social links
                    _buildLabel('Social Links (Optional)'),
                    CustomTextField(
                      controller: _facebookController,
                      hintText: 'Facebook URL',
                      prefixIcon: const Icon(Icons.facebook),
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    CustomTextField(
                      controller: _instagramController,
                      hintText: 'Instagram URL',
                      prefixIcon: const Icon(Icons.camera_alt),
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Create button
                    Obx(() => GradientButton(
                          text: 'Create Profile',
                          isLoading: _businessController.isLoading.value,
                          onPressed: _createProfile,
                        )),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        // Cover image
        Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryHorizontal,
                image: _coverImage != null
                    ? DecorationImage(
                        image: FileImage(_coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _coverImage == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Add Cover Image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // Profile image
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: GestureDetector(
            onTap: () => _pickImage(true),
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGrey,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    image: _profileImage != null
                        ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _profileImage == null
                      ? const Icon(
                          Icons.add_a_photo,
                          color: AppColors.grey,
                          size: 30,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    if (_isEmailVerified) {
      return CustomTextField(
        controller: _emailController,
        hintText: 'Business email',
        prefixIcon: const Icon(Icons.email),
        enabled: false,
        suffixIcon: const Icon(
          Icons.verified,
          color: AppColors.success,
        ),
      );
    }

    if (_showOtpField) {
      return Column(
        children: [
          CustomTextField(
            controller: _otpController,
            hintText: 'Enter OTP',
            prefixIcon: const Icon(Icons.lock),
            keyboardType: TextInputType.number,
            suffixIcon: _countdown > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Text(
                      '${_countdown}s',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _countdown == 0 ? _sendOtp : null,
                  child: const Text('Resend OTP'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Obx(() => GradientButton(
                      text: 'Verify',
                      isLoading: _businessController.isLoading.value,
                      onPressed: _verifyOtp,
                    )),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: _emailController,
            hintText: 'Business email',
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter valid email';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Obx(() => SizedBox(
              width: 100,
              child: GradientButton(
                text: 'Verify',
                isLoading: _businessController.isLoading.value,
                onPressed: _sendOtp,
              ),
            )),
      ],
    );
  }
}
