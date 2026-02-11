import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../controllers/activity_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/common_widgets.dart';

/// Create activity screen - Business accounts only
class CreateActivityScreen extends StatelessWidget {
  const CreateActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }
    final activityController = Get.find<ActivityController>();
    final profileController = Get.find<ProfileController>();

    // Track if slots are unlimited
    final hasSlotLimit = true.obs;

    final List<String> eventTypes = [
      'Sports',
      'Music',
      'Food',
      'Art',
      'Social',
      'Gaming',
      'Fitness',
      'Travel',
      'Outdoor',
      'Wellness',
      'Learning',
      'Other',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
        actions: [
          // Show business badge if applicable
          Obx(() {
            if (profileController.currentUser.value?.isBusinessAccount == true) {
              return const Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: BusinessBadge(compact: true),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        // Check if user can create events (business accounts only)
        final canCreate = profileController.currentUser.value?.canCreateEvents ?? false;

        // If user cannot create events, show restriction message
        if (!canCreate) {
          return _buildBusinessOnlyMessage(context);
        }

        // Business user - show the create form
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business badge info
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withAlpha(26),
                      const Color(0xFFFFA500).withAlpha(26),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withAlpha(77),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: Color(0xFFFFD700),
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Creator',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Create activities for people to join',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Activity name
              CustomTextField(
                controller: activityController.nameController,
                labelText: 'Activity Name',
                hintText: 'Enter activity name',
                prefixIcon: const Icon(Icons.event),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Description
              CustomTextField(
                controller: activityController.descriptionController,
                labelText: 'Description',
                hintText: 'Describe your activity...',
                maxLines: 4,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Event type
              Text(
                'Event Type',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(() => Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: eventTypes.map((type) {
                      final isSelected =
                          activityController.selectedEventType.value == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (_) =>
                            activityController.selectedEventType.value = type,
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
                controller: activityController.locationController,
                labelText: 'Location',
                hintText: 'Enter location',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: Builder(
                  // Use Builder to get fresh context for mounted check (#63)
                  builder: (buttonContext) => IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      Get.snackbar(
                        'Location',
                        'Getting your current location...',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                      // Simulating setting a location with mounted check (#63)
                      Future.delayed(const Duration(seconds: 1), () {
                        // Check if context is still mounted before updating UI
                        if (!buttonContext.mounted) return;

                        activityController.locationController.text = 'Current Location';
                        Get.snackbar(
                          'Location Set',
                          'Using your current location',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Date & Time
              Text(
                'Date & Time',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Obx(() => GestureDetector(
                    onTap: () => _selectDateTime(context, activityController),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.grey,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            activityController.selectedDateTime.value != null
                                ? DateFormat('EEEE, MMMM d, y • h:mm a')
                                    .format(activityController.selectedDateTime.value!)
                                : 'Select date and time',
                            style: TextStyle(
                              color:
                                  activityController.selectedDateTime.value != null
                                      ? AppColors.black
                                      : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: AppSpacing.lg),

              // Capacity settings
              Text(
                'Capacity',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Toggle between limited and unlimited
              Obx(() => Column(
                    children: [
                      // Capacity type selector
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => hasSlotLimit.value = true,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: hasSlotLimit.value
                                      ? AppColors.primaryBlue.withAlpha(26)
                                      : AppColors.lightGrey,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(AppRadius.md),
                                    bottomLeft: Radius.circular(AppRadius.md),
                                  ),
                                  border: Border.all(
                                    color: hasSlotLimit.value
                                        ? AppColors.primaryBlue
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.group,
                                      color: hasSlotLimit.value
                                          ? AppColors.primaryBlue
                                          : AppColors.grey,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Set Limit',
                                      style: TextStyle(
                                        color: hasSlotLimit.value
                                            ? AppColors.primaryBlue
                                            : AppColors.grey,
                                        fontWeight: hasSlotLimit.value
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'e.g., 5/15 spots',
                                      style: TextStyle(
                                        color: AppColors.mediumGrey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                hasSlotLimit.value = false;
                                activityController.slotsController.clear();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: !hasSlotLimit.value
                                      ? AppColors.friendlyTeal.withAlpha(26)
                                      : AppColors.lightGrey,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(AppRadius.md),
                                    bottomRight: Radius.circular(AppRadius.md),
                                  ),
                                  border: Border.all(
                                    color: !hasSlotLimit.value
                                        ? AppColors.friendlyTeal
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.all_inclusive,
                                      color: !hasSlotLimit.value
                                          ? AppColors.friendlyTeal
                                          : AppColors.grey,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No Limit',
                                      style: TextStyle(
                                        color: !hasSlotLimit.value
                                            ? AppColors.friendlyTeal
                                            : AppColors.grey,
                                        fontWeight: !hasSlotLimit.value
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Open to everyone',
                                      style: TextStyle(
                                        color: AppColors.mediumGrey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Show slots input only if limited
                      if (hasSlotLimit.value) ...[
                        const SizedBox(height: AppSpacing.md),
                        CustomTextField(
                          controller: activityController.slotsController,
                          hintText: 'Maximum number of attendees',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.people_outline),
                        ),
                      ],
                    ],
                  )),

              const SizedBox(height: AppSpacing.lg),

              // Error message
              Obx(() {
                if (activityController.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      activityController.errorMessage.value,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Create button
              Obx(() => GradientButton(
                    text: 'Create Activity',
                    isLoading: activityController.isCreating.value,
                    onPressed: () async {
                      // If no limit, ensure slots field is empty/zero
                      if (!hasSlotLimit.value) {
                        activityController.slotsController.text = '0';
                      }

                      final success = await activityController.createActivity();
                      if (success) {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Activity created successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                        );
                      }
                    },
                  )),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      }),
    );
  }

  /// Build message for regular users who can't create events
  Widget _buildBusinessOnlyMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withAlpha(38),
                    const Color(0xFFFFA500).withAlpha(38),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_center_outlined,
                size: 64,
                color: Color(0xFFFFD700),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'Business Feature',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              'Creating activities is available for business accounts only. Business accounts can host events, workshops, and gatherings for the community.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGrey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Upgrade button
            GradientButton(
              text: 'Upgrade to Business',
              icon: Icons.verified,
              onPressed: () {
                Get.snackbar(
                  'Coming Soon',
                  'Business accounts will be available soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primaryBlue,
                  colorText: Colors.white,
                );
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // Back button
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Maybe later',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Benefits list
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Account Benefits',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildBenefitRow(Icons.event, 'Create unlimited activities'),
                  _buildBenefitRow(Icons.verified, 'Verified business badge'),
                  _buildBenefitRow(Icons.analytics_outlined, 'Activity analytics'),
                  _buildBenefitRow(Icons.people, 'Manage attendees'),
                  _buildBenefitRow(Icons.star_outline, 'Featured placement'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.friendlyTeal),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    ActivityController controller,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        controller.selectedDateTime.value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
    }
  }
}
