import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../config/routes.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/common_widgets.dart';

/// Profile setup screen for new users
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _genders = ['Male', 'Female', 'Non-binary', 'Other'];
  final List<String> _interests = [
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < 2 ? AppSpacing.xs : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primaryBlue
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  // Page 1: Basic Info
                  _BasicInfoPage(
                    profileController: profileController,
                    genders: _genders,
                  ),

                  // Page 2: Interests
                  _InterestsPage(
                    profileController: profileController,
                    interests: _interests,
                  ),

                  // Page 3: Bio
                  _BioPage(profileController: profileController),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _currentPage < 2
                        ? GradientButton(
                            text: 'Continue',
                            onPressed: _nextPage,
                          )
                        : Obx(() => GradientButton(
                              text: 'Complete Setup',
                              isLoading: profileController.isUpdating.value,
                              onPressed: () async {
                                final success =
                                    await profileController.updateProfile();
                                if (success) {
                                  Nav.toHome();
                                }
                              },
                            )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Basic info page
class _BasicInfoPage extends StatelessWidget {
  final ProfileController profileController;
  final List<String> genders;

  const _BasicInfoPage({
    required this.profileController,
    required this.genders,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GradientText(
            text: "Let's Get\nStarted",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Tell us a bit about yourself',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: AppSpacing.xl),

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
        ],
      ),
    );
  }
}

/// Interests page
class _InterestsPage extends StatelessWidget {
  final ProfileController profileController;
  final List<String> interests;

  const _InterestsPage({
    required this.profileController,
    required this.interests,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GradientText(
            text: 'Your\nInterests',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Select at least 3 interests',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: AppSpacing.xl),

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

          const SizedBox(height: AppSpacing.lg),

          Obx(() => Text(
                '${profileController.selectedInterests.length} interests selected',
                style: Theme.of(context).textTheme.bodySmall,
              )),
        ],
      ),
    );
  }
}

/// Bio page
class _BioPage extends StatelessWidget {
  final ProfileController profileController;

  const _BioPage({required this.profileController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GradientText(
            text: 'About\nYou',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Write a short bio to introduce yourself',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Bio
          CustomTextField(
            controller: profileController.bioController,
            labelText: 'Bio',
            hintText: 'Tell others about yourself...',
            maxLines: 5,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            'This will be displayed on your profile',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
