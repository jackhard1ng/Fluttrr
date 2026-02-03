import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../controllers/activity_controller.dart';
import '../../widgets/common_widgets.dart';

/// Create activity screen
class CreateActivityScreen extends StatelessWidget {
  const CreateActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();

    final List<String> eventTypes = [
      'Sports',
      'Music',
      'Food',
      'Art',
      'Social',
      'Gaming',
      'Fitness',
      'Travel',
      'Other',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  // Get current location
                },
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

            // Total slots
            CustomTextField(
              controller: activityController.slotsController,
              labelText: 'Number of Spots',
              hintText: 'Enter maximum attendees',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.people_outline),
            ),

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
