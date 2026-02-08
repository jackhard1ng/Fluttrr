import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../controllers/business_controller.dart';
import '../../widgets/common_widgets.dart';

/// Quick event creation screen for businesses
/// Designed for minimal friction - get events published fast!
class QuickCreateEventScreen extends StatefulWidget {
  const QuickCreateEventScreen({super.key});

  @override
  State<QuickCreateEventScreen> createState() => _QuickCreateEventScreenState();
}

class _QuickCreateEventScreenState extends State<QuickCreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _slotsController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedType;
  bool _hasLimit = true;
  bool _isCreating = false;

  final List<_EventTypeOption> _eventTypes = [
    _EventTypeOption('Social', Icons.people_outline, AppColors.primaryBlue),
    _EventTypeOption('Sports', Icons.sports_soccer, AppColors.friendlyTeal),
    _EventTypeOption('Food', Icons.restaurant_outlined, AppColors.friendlyOrange),
    _EventTypeOption('Wellness', Icons.spa_outlined, AppColors.friendlyPink),
    _EventTypeOption('Music', Icons.music_note_outlined, AppColors.friendlyPurple),
    _EventTypeOption('Outdoor', Icons.park_outlined, AppColors.success),
    _EventTypeOption('Learning', Icons.school_outlined, AppColors.accentBlue),
    _EventTypeOption('Other', Icons.category_outlined, AppColors.mediumGrey),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _slotsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      Get.snackbar(
        'Missing Info',
        'Please select a date and time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }
    if (_selectedType == null) {
      Get.snackbar(
        'Missing Info',
        'Please select an event type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Combine date and time
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // End time defaults to 2 hours after start
      final endDateTime = startDateTime.add(const Duration(hours: 2));

      // Parse slots - 0 or null means unlimited
      final maxAttendees = _hasLimit && _slotsController.text.isNotEmpty
          ? int.tryParse(_slotsController.text)
          : null;

      // Get business controller and create event
      final businessController = Get.find<BusinessController>();
      final success = await businessController.createEvent(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Join us for ${_nameController.text.trim()}!',
        location: _locationController.text.trim(),
        startDate: startDateTime,
        endDate: endDateTime,
        eventType: _selectedType!,
        maxAttendees: maxAttendees,
      );

      setState(() => _isCreating = false);

      if (success) {
        Get.back();
        Get.snackbar(
          'Event Created!',
          'Your event "${_nameController.text}" is now live',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          businessController.errorMessage.value.isNotEmpty
              ? businessController.errorMessage.value
              : 'Failed to create event. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isCreating = false);
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Progress indicator
            _StepIndicator(
              currentStep: _getCurrentStep(),
              totalSteps: 4,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Event Name - Big and prominent
            _SectionTitle(
              title: 'What\'s your event called?',
              subtitle: 'Choose a catchy name',
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Morning Yoga in the Park',
                filled: true,
                fillColor: AppColors.lightGrey.withAlpha(128),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.edit_outlined),
              ),
              style: const TextStyle(fontSize: 16),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an event name';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Event Type - Visual grid
            _SectionTitle(
              title: 'What type of event?',
              subtitle: 'Helps people find your event',
            ),
            const SizedBox(height: AppSpacing.sm),
            _EventTypeGrid(
              types: _eventTypes,
              selectedType: _selectedType,
              onTypeSelected: (type) {
                setState(() => _selectedType = type);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Date & Time - Side by side
            _SectionTitle(
              title: 'When is it happening?',
              subtitle: 'Pick a date and time',
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _DateTimePicker(
                    icon: Icons.calendar_today_outlined,
                    label: _selectedDate != null
                        ? DateFormat('EEE, MMM d').format(_selectedDate!)
                        : 'Select Date',
                    isSelected: _selectedDate != null,
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _DateTimePicker(
                    icon: Icons.access_time_outlined,
                    label: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    isSelected: _selectedTime != null,
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Location
            _SectionTitle(
              title: 'Where is it?',
              subtitle: 'Add the venue or address',
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'e.g., Central Park, Main Entrance',
                filled: true,
                fillColor: AppColors.lightGrey.withAlpha(128),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    // Get current location
                    _locationController.text = 'Current Location';
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Capacity - Toggle
            _SectionTitle(
              title: 'How many people can join?',
              subtitle: 'Set a limit or keep it open',
            ),
            const SizedBox(height: AppSpacing.sm),
            _CapacitySelector(
              hasLimit: _hasLimit,
              slotsController: _slotsController,
              onLimitChanged: (value) {
                setState(() => _hasLimit = value);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Description - Optional but helpful
            _SectionTitle(
              title: 'Add some details',
              subtitle: 'Help people know what to expect',
              optional: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What will you be doing? Any special instructions?',
                filled: true,
                fillColor: AppColors.lightGrey.withAlpha(128),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Create Button
            _CreateEventButton(
              isCreating: _isCreating,
              onPressed: _createEvent,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  int _getCurrentStep() {
    if (_nameController.text.isEmpty) return 1;
    if (_selectedType == null) return 2;
    if (_selectedDate == null || _selectedTime == null) return 3;
    return 4;
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Creating Events'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tips for great events:'),
            SizedBox(height: 12),
            _HelpTip(icon: Icons.title, text: 'Use clear, descriptive names'),
            _HelpTip(icon: Icons.photo_camera, text: 'Add photos after creating'),
            _HelpTip(icon: Icons.schedule, text: 'Pick convenient times'),
            _HelpTip(icon: Icons.people, text: 'Start with smaller groups'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}

class _HelpTip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpTip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep - 1;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? AppColors.primaryBlue
                  : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool optional;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (optional) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Optional',
                  style: TextStyle(fontSize: 10, color: AppColors.mediumGrey),
                ),
              ),
            ],
          ],
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.mediumGrey,
          ),
        ),
      ],
    );
  }
}

class _EventTypeOption {
  final String name;
  final IconData icon;
  final Color color;

  const _EventTypeOption(this.name, this.icon, this.color);
}

class _EventTypeGrid extends StatelessWidget {
  final List<_EventTypeOption> types;
  final String? selectedType;
  final Function(String) onTypeSelected;

  const _EventTypeGrid({
    required this.types,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: types.map((type) {
        final isSelected = selectedType == type.name;
        return GestureDetector(
          onTap: () => onTypeSelected(type.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? type.color.withAlpha(26) : AppColors.lightGrey.withAlpha(128),
              borderRadius: BorderRadius.circular(AppRadius.circular),
              border: Border.all(
                color: isSelected ? type.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 18,
                  color: isSelected ? type.color : AppColors.mediumGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  type.name,
                  style: TextStyle(
                    color: isSelected ? type.color : AppColors.darkGrey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateTimePicker({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withAlpha(26)
              : AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primaryBlue : AppColors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryBlue : AppColors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapacitySelector extends StatelessWidget {
  final bool hasLimit;
  final TextEditingController slotsController;
  final Function(bool) onLimitChanged;

  const _CapacitySelector({
    required this.hasLimit,
    required this.slotsController,
    required this.onLimitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onLimitChanged(true),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: hasLimit
                        ? AppColors.primaryBlue.withAlpha(26)
                        : AppColors.lightGrey.withAlpha(128),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(AppRadius.md),
                    ),
                    border: Border.all(
                      color: hasLimit ? AppColors.primaryBlue : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.group,
                        color: hasLimit ? AppColors.primaryBlue : AppColors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Limited',
                        style: TextStyle(
                          color: hasLimit ? AppColors.primaryBlue : AppColors.grey,
                          fontWeight: hasLimit ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onLimitChanged(false),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: !hasLimit
                        ? AppColors.friendlyTeal.withAlpha(26)
                        : AppColors.lightGrey.withAlpha(128),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(AppRadius.md),
                      bottomRight: Radius.circular(AppRadius.md),
                    ),
                    border: Border.all(
                      color: !hasLimit ? AppColors.friendlyTeal : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.all_inclusive,
                        color: !hasLimit ? AppColors.friendlyTeal : AppColors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlimited',
                        style: TextStyle(
                          color: !hasLimit ? AppColors.friendlyTeal : AppColors.grey,
                          fontWeight: !hasLimit ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Slots input (only if limited)
        if (hasLimit) ...[
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: slotsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'How many spots?',
              filled: true,
              fillColor: AppColors.lightGrey.withAlpha(128),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.people_outline),
            ),
            validator: (value) {
              if (hasLimit && (value == null || value.isEmpty)) {
                return 'Please enter number of spots';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}

class _CreateEventButton extends StatelessWidget {
  final bool isCreating;
  final VoidCallback onPressed;

  const _CreateEventButton({
    required this.isCreating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCreating ? null : onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Center(
            child: isCreating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Publish Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
