import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/event_vibe.dart';
import '../../widgets/event_tags.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _maxAttendees = 10;
  List<EventCategory> _selectedCategories = [];
  EventVibe? _selectedVibe;
  List<String> _tags = [];
  bool _isPrivate = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _titleController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _selectedDate != null &&
        _startTime != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.close, color: Colors.black),
        ),
        title: const Text(
          'Create Event',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isValid
                ? () {
                    HapticFeedback.mediumImpact();
                    Get.back();
                    Get.snackbar(
                      '🎉 Event Created!',
                      'Your event is now live',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                  }
                : null,
            child: Text(
              'Create',
              style: TextStyle(
                color: _isValid ? AppColors.primaryBlue : AppColors.mediumGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _InputField(
              label: 'Event Title',
              hint: 'Give your event a name',
              controller: _titleController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Date & Time
            Text(
              'When',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateTimePicker(
                    icon: Icons.calendar_today,
                    label: _selectedDate != null
                        ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                        : 'Date',
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTimePicker(
                    icon: Icons.access_time,
                    label: _startTime != null
                        ? _startTime!.format(context)
                        : 'Start',
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _startTime = time);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateTimePicker(
                    icon: Icons.access_time,
                    label: _endTime != null
                        ? _endTime!.format(context)
                        : 'End',
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => _endTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Location
            _InputField(
              label: 'Where',
              hint: 'Add a location',
              controller: _locationController,
              prefixIcon: Icons.location_on,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Description
            _InputField(
              label: 'Description',
              hint: 'Tell people what to expect...',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // Max attendees
            Text(
              'Max Attendees',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [5, 10, 20, 50].map((count) {
                final isSelected = _maxAttendees == count;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _maxAttendees = count);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: count != 50 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.lightGrey.withAlpha(128),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Categories
            CategoryPicker(
              selected: _selectedCategories,
              onToggle: (cat) {
                HapticFeedback.lightImpact();
                setState(() {
                  if (_selectedCategories.contains(cat)) {
                    _selectedCategories.remove(cat);
                  } else if (_selectedCategories.length < 3) {
                    _selectedCategories.add(cat);
                  }
                });
              },
            ),
            const SizedBox(height: 20),

            // Vibe
            VibePicker(
              selected: _selectedVibe,
              onSelect: (vibe) {
                setState(() => _selectedVibe = vibe);
              },
            ),
            const SizedBox(height: 20),

            // Tags
            EventTagsInput(
              tags: _tags,
              onAdd: (tag) {
                if (_tags.length < 5) {
                  setState(() => _tags.add(tag));
                }
              },
              onRemove: (tag) {
                setState(() => _tags.remove(tag));
              },
            ),
            const SizedBox(height: 20),

            // Private toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withAlpha(77),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    _isPrivate ? Icons.lock : Icons.lock_open,
                    color: _isPrivate ? AppColors.primaryBlue : AppColors.mediumGrey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Private Event',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _isPrivate
                              ? 'Only invited friends can join'
                              : 'Anyone can find and join',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPrivate,
                    onChanged: (v) {
                      HapticFeedback.lightImpact();
                      setState(() => _isPrivate = v);
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final int maxLines;
  final Function(String)? onChanged;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.prefixIcon,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: prefixIcon != null ? 12 : 16,
            vertical: maxLines > 1 ? 12 : 0,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withAlpha(128),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, color: AppColors.mediumGrey, size: 20),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: AppColors.mediumGrey),
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DateTimePicker({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withAlpha(128),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.mediumGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: label.contains('/') || label.contains(':')
                      ? AppColors.darkGrey
                      : AppColors.mediumGrey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
