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
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    final activityController = Get.find<ActivityController>();
    final profileController = Get.find<ProfileController>();

    // Track if slots are unlimited
    final hasSlotLimit = true.obs;

    final List<String> eventTypes = [
      'Social',
      'Food & Drinks',
      'Outdoor',
      'Sports',
      'Nightlife',
      'Live Music',
      'Fitness',
      'Arts & Culture',
      'Networking',
      'Community',
      'Wellness',
      'Comedy',
      'Markets & Fairs',
      'Family',
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
                      AppColors.primaryBlue.withAlpha(26),
                      AppColors.accentBlue.withAlpha(26),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.primaryBlue.withAlpha(77),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: AppColors.primaryBlue,
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

              // Recurring event toggle
              _RecurringEventSection(activityController: activityController),

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
                    text: activityController.isRecurring.value
                        ? 'Create Recurring Activity'
                        : 'Create Activity',
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
                          activityController.isRecurring.value
                              ? 'Recurring activity created!'
                              : 'Activity created successfully!',
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
                    AppColors.primaryBlue.withAlpha(38),
                    AppColors.accentBlue.withAlpha(38),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_center_outlined,
                size: 64,
                color: AppColors.primaryBlue,
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

/// Recurring event configuration section
class _RecurringEventSection extends StatelessWidget {
  final ActivityController activityController;

  const _RecurringEventSection({required this.activityController});

  static const List<String> _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle
            GestureDetector(
              onTap: () => activityController.isRecurring.value =
                  !activityController.isRecurring.value,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: activityController.isRecurring.value
                      ? AppColors.primaryBlue.withAlpha(26)
                      : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: activityController.isRecurring.value
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      color: activityController.isRecurring.value
                          ? AppColors.primaryBlue
                          : AppColors.grey,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recurring Event',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: activityController.isRecurring.value
                                  ? AppColors.primaryBlue
                                  : AppColors.darkGrey,
                            ),
                          ),
                          Text(
                            'Repeats on a schedule (e.g. \$2 Tuesdays)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: activityController.isRecurring.value,
                      onChanged: (v) => activityController.isRecurring.value = v,
                      activeColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),

            // Recurring options (visible when toggled on)
            if (activityController.isRecurring.value) ...[
              const SizedBox(height: AppSpacing.lg),

              // Frequency type
              Text(
                'Frequency',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _FrequencyChip(
                    label: 'Daily',
                    icon: Icons.today,
                    isSelected: activityController.recurrenceType.value == 'daily',
                    onTap: () => activityController.recurrenceType.value = 'daily',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FrequencyChip(
                    label: 'Weekly',
                    icon: Icons.view_week,
                    isSelected: activityController.recurrenceType.value == 'weekly',
                    onTap: () => activityController.recurrenceType.value = 'weekly',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FrequencyChip(
                    label: 'Monthly',
                    icon: Icons.calendar_month,
                    isSelected: activityController.recurrenceType.value == 'monthly',
                    onTap: () => activityController.recurrenceType.value = 'monthly',
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Interval (every N days/weeks/months)
              Row(
                children: [
                  Text(
                    'Every',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (activityController.recurrenceInterval.value > 1) {
                              activityController.recurrenceInterval.value--;
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Text(
                          '${activityController.recurrenceInterval.value}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (activityController.recurrenceInterval.value < 12) {
                              activityController.recurrenceInterval.value++;
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.add, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    activityController.recurrenceType.value == 'daily'
                        ? (activityController.recurrenceInterval.value == 1 ? 'day' : 'days')
                        : activityController.recurrenceType.value == 'weekly'
                            ? (activityController.recurrenceInterval.value == 1 ? 'week' : 'weeks')
                            : (activityController.recurrenceInterval.value == 1 ? 'month' : 'months'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),

              // Weekly: day-of-week picker
              if (activityController.recurrenceType.value == 'weekly') ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Repeat On',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final isSelected = activityController.selectedDaysOfWeek.contains(index);
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          activityController.selectedDaysOfWeek.remove(index);
                        } else {
                          activityController.selectedDaysOfWeek.add(index);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _dayLabels[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.darkGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],

              // Monthly: day-of-month picker
              if (activityController.recurrenceType.value == 'monthly') ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Text(
                      'Day of Month:',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: DropdownButton<int>(
                        value: activityController.selectedDayOfMonth.value,
                        underline: const SizedBox.shrink(),
                        items: List.generate(
                          31,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: (v) {
                          if (v != null) activityController.selectedDayOfMonth.value = v;
                        },
                      ),
                    ),
                  ],
                ),
              ],

              // End date (optional)
              const SizedBox(height: AppSpacing.lg),
              Text(
                'End Date (optional)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_busy,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          activityController.recurrenceEndDate.value != null
                              ? DateFormat('MMMM d, y')
                                  .format(activityController.recurrenceEndDate.value!)
                              : 'No end date (runs indefinitely)',
                          style: TextStyle(
                            color: activityController.recurrenceEndDate.value != null
                                ? AppColors.black
                                : AppColors.grey,
                          ),
                        ),
                      ),
                      if (activityController.recurrenceEndDate.value != null)
                        GestureDetector(
                          onTap: () => activityController.recurrenceEndDate.value = null,
                          child: const Icon(Icons.close, size: 18, color: AppColors.grey),
                        ),
                    ],
                  ),
                ),
              ),

              // Summary
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.friendlyTeal.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.friendlyTeal,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _buildRecurrenceSummary(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.friendlyTeal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ));
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      activityController.recurrenceEndDate.value = date;
    }
  }

  String _buildRecurrenceSummary() {
    final type = activityController.recurrenceType.value;
    final interval = activityController.recurrenceInterval.value;

    String freq;
    if (type == 'daily') {
      freq = interval == 1 ? 'every day' : 'every $interval days';
    } else if (type == 'weekly') {
      final days = activityController.selectedDaysOfWeek.toList()..sort();
      final dayNames = days.map((d) => _dayFullName(d)).join(', ');
      freq = interval == 1 ? 'every week' : 'every $interval weeks';
      if (dayNames.isNotEmpty) {
        freq += ' on $dayNames';
      }
    } else {
      final dom = activityController.selectedDayOfMonth.value;
      freq = interval == 1
          ? 'every month on day $dom'
          : 'every $interval months on day $dom';
    }

    final end = activityController.recurrenceEndDate.value;
    if (end != null) {
      freq += ' until ${DateFormat('MMM d, y').format(end)}';
    }

    return 'Repeats $freq';
  }

  String _dayFullName(int day) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[day];
  }
}

/// Frequency selection chip
class _FrequencyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue.withAlpha(26)
                : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryBlue : AppColors.grey,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryBlue : AppColors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
