import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/business_controller.dart';
import '../../widgets/common_widgets.dart';

/// Business create/edit profile screen
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
  bool _isEditMode = false;
  bool _isEmailVerified = false;
  bool _showOtpField = false;
  int _countdown = 0;
  Timer? _countdownTimer;
  File? _profileImage;
  File? _coverImage;
  String? _existingProfileImageUrl;
  String? _existingCoverImageUrl;
  String _selectedCategory = '';

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
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final business = _businessController.businessProfile.value;
    if (business != null && _businessController.hasBusiness.value) {
      // Edit mode: populate fields from existing profile
      _isEditMode = true;
      _nameController.text = business.businessName ?? business.name ?? '';
      _descriptionController.text = business.description ?? '';
      _emailController.text = business.email ?? '';
      _phoneController.text = business.phone ?? '';
      _addressController.text = business.address ?? '';
      _locationController.text = business.location ?? '';
      _websiteController.text = business.website ?? '';
      _facebookController.text = business.facebook ?? '';
      _instagramController.text = business.instagram ?? '';
      _selectedCategory = business.category ?? '';
      _existingProfileImageUrl = business.profileImage;
      _existingCoverImageUrl = business.coverImage;
      // In edit mode, email is already verified
      _isEmailVerified = true;
    }
  }

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

    if (!mounted) return;
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

    if (!mounted) return;
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditMode) {
      // Edit mode: update existing profile
      // Sync local fields to the controller's text controllers for updateBusinessProfile()
      _businessController.businessNameController.text = _nameController.text.trim();
      _businessController.businessEmailController.text = _emailController.text.trim();
      _businessController.businessPhoneController.text = _phoneController.text.trim();
      _businessController.businessDescriptionController.text = _descriptionController.text.trim();
      _businessController.businessAddressController.text = _addressController.text.trim();
      _businessController.businessWebsiteController.text = _websiteController.text.trim();
      _businessController.selectedCategory.value = _selectedCategory;

      final success = await _businessController.updateBusinessProfile();

      if (success) {
        // Upload new images if picked
        if (_profileImage != null) {
          await _businessController.uploadProfileImage(_profileImage!);
        }
        if (_coverImage != null) {
          await _businessController.uploadCoverImage(_coverImage!);
        }

        Get.snackbar(
          'Success',
          'Business profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          _businessController.errorMessage.value.isNotEmpty
              ? _businessController.errorMessage.value
              : 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } else {
      // Create mode: validate email and images
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

      // Set category on controller before create
      _businessController.selectedCategory.value = _selectedCategory;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Business Profile' : 'Create Business Profile'),
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

                    // Category
                    _buildLabel('Business Category'),
                    _buildCategoryDropdown(),

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

                    // Save/Create button
                    Obx(() => GradientButton(
                          text: _isEditMode ? 'Save Profile' : 'Create Profile',
                          isLoading: _businessController.isLoading.value ||
                              _businessController.isCreating.value,
                          onPressed: _saveProfile,
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

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
          hint: const Text('Select business category'),
          isExpanded: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          items: _businessTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    // Determine which image to display for cover and profile
    final ImageProvider? coverImageProvider;
    if (_coverImage != null) {
      coverImageProvider = FileImage(_coverImage!);
    } else if (_existingCoverImageUrl != null && _existingCoverImageUrl!.isNotEmpty) {
      coverImageProvider = NetworkImage(_existingCoverImageUrl!);
    } else {
      coverImageProvider = null;
    }

    final ImageProvider? profileImageProvider;
    if (_profileImage != null) {
      profileImageProvider = FileImage(_profileImage!);
    } else if (_existingProfileImageUrl != null && _existingProfileImageUrl!.isNotEmpty) {
      profileImageProvider = NetworkImage(_existingProfileImageUrl!);
    } else {
      profileImageProvider = null;
    }

    final bool hasCoverImage = coverImageProvider != null;
    final bool hasProfileImage = profileImageProvider != null;

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
                image: hasCoverImage
                    ? DecorationImage(
                        image: coverImageProvider!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasCoverImage
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
                  : Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(128),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
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
                    image: hasProfileImage
                        ? DecorationImage(
                            image: profileImageProvider!,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !hasProfileImage
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
    // In edit mode, show email as read-only with verified badge
    if (_isEditMode || _isEmailVerified) {
      return CustomTextField(
        controller: _emailController,
        hintText: 'Business email',
        prefixIcon: const Icon(Icons.email),
        enabled: !_isEditMode, // Allow change only in create mode after verify
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
