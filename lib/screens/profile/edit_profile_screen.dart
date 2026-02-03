import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/common_widgets.dart';

/// Edit profile screen
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    final List<String> genders = ['Male', 'Female', 'Non-binary', 'Other'];
    final List<String> interests = [
      'Sports',
      'Music',
      'Art',
      'Travel',
      'Food',
      'Movies',
      'Gaming',
      'Reading',
      'Fitness',
      'Photography',
      'Dancing',
      'Cooking',
      'Hiking',
      'Yoga',
      'Tech',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Obx(() => TextButton(
                onPressed: profileController.isUpdating.value
                    ? null
                    : () async {
                        final success =
                            await profileController.updateProfile();
                        if (success) {
                          Get.back();
                          Get.snackbar(
                            'Success',
                            'Profile updated successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.success,
                            colorText: Colors.white,
                          );
                        }
                      },
                child: profileController.isUpdating.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo
            Center(
              child: Stack(
                children: [
                  Obx(() => UserAvatar(
                        imageUrl: profileController.profileImage,
                        size: 100,
                      )),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Change profile photo
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Username
            CustomTextField(
              controller: profileController.userNameController,
              labelText: 'Username',
              hintText: 'Enter your username',
              prefixIcon: const Icon(Icons.person_outlined),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Age
            CustomTextField(
              controller: profileController.ageController,
              labelText: 'Age',
              hintText: 'Enter your age',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.cake_outlined),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Gender
            Text(
              'Gender',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Obx(() => Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: genders.map((gender) {
                    final isSelected =
                        profileController.selectedGender.value == gender;
                    return ChoiceChip(
                      label: Text(gender),
                      selected: isSelected,
                      onSelected: (_) => profileController.setGender(gender),
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.darkGrey,
                      ),
                    );
                  }).toList(),
                )),

            const SizedBox(height: AppSpacing.lg),

            // Location
            CustomTextField(
              controller: profileController.locationController,
              labelText: 'Location',
              hintText: 'Enter your city',
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Bio
            CustomTextField(
              controller: profileController.bioController,
              labelText: 'Bio',
              hintText: 'Tell others about yourself...',
              maxLines: 4,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Interests
            Text(
              'Interests',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Obx(() => Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: interests.map((interest) {
                    final isSelected =
                        profileController.selectedInterests.contains(interest);
                    return TagChip(
                      label: interest,
                      selected: isSelected,
                      onTap: () => profileController.toggleInterest(interest),
                    );
                  }).toList(),
                )),

            const SizedBox(height: AppSpacing.xl),

            // Error message
            Obx(() {
              if (profileController.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    profileController.errorMessage.value,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
