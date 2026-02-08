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
                        } else {
                          Get.snackbar(
                            'Error',
                            profileController.errorMessage.value.isNotEmpty
                                ? profileController.errorMessage.value
                                : 'Failed to update profile. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.error,
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

            // Home Location
            CustomTextField(
              controller: profileController.locationController,
              labelText: 'Home Location',
              hintText: 'Enter your home city',
              prefixIcon: const Icon(Icons.home_outlined),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Browse Location (for events)
            _BrowseLocationSection(controller: profileController),

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

/// Browse location section for finding events in different cities
class _BrowseLocationSection extends StatelessWidget {
  final ProfileController controller;

  const _BrowseLocationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Browse Events In',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.friendlyTeal.withAlpha(26),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: const Text(
                'Travel Mode',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.friendlyTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Set a different city to find events when traveling',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mediumGrey,
              ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Current browse location
        Obx(() {
          final browseLocation = controller.browseLocation.value;
          final isUsingCurrentLocation = browseLocation.isEmpty;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isUsingCurrentLocation
                  ? AppColors.primaryBlue.withAlpha(13)
                  : AppColors.friendlyTeal.withAlpha(13),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isUsingCurrentLocation
                    ? AppColors.primaryBlue.withAlpha(51)
                    : AppColors.friendlyTeal.withAlpha(51),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUsingCurrentLocation
                        ? AppColors.primaryBlue.withAlpha(26)
                        : AppColors.friendlyTeal.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUsingCurrentLocation
                        ? Icons.my_location
                        : Icons.flight,
                    size: 20,
                    color: isUsingCurrentLocation
                        ? AppColors.primaryBlue
                        : AppColors.friendlyTeal,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUsingCurrentLocation
                            ? 'Using Current Location'
                            : 'Browsing in: $browseLocation',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUsingCurrentLocation
                            ? 'Events shown near your actual location'
                            : 'Events shown in your selected city',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isUsingCurrentLocation)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => controller.setBrowseLocation(''),
                    color: AppColors.mediumGrey,
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: AppSpacing.md),

        // Popular cities
        Text(
          'Popular Cities',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            'New York',
            'Los Angeles',
            'Chicago',
            'Houston',
            'Miami',
            'Seattle',
            'Denver',
            'Austin',
          ].map((city) {
            return GestureDetector(
              onTap: () => controller.setBrowseLocation(city),
              child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: controller.browseLocation.value == city
                          ? AppColors.friendlyTeal
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.circular),
                      border: Border.all(
                        color: controller.browseLocation.value == city
                            ? AppColors.friendlyTeal
                            : AppColors.lightGrey,
                      ),
                    ),
                    child: Text(
                      city,
                      style: TextStyle(
                        fontSize: 13,
                        color: controller.browseLocation.value == city
                            ? Colors.white
                            : AppColors.darkGrey,
                        fontWeight: controller.browseLocation.value == city
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  )),
            );
          }).toList(),
        ),
      ],
    );
  }
}
