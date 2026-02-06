import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../models/event_model.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/event_vibe.dart';
import '../../widgets/event_tags.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  late DateTime? _selectedDate;
  late TimeOfDay? _startTime;
  late TimeOfDay? _endTime;
  late int _maxAttendees;
  late List<EventCategory> _selectedCategories;
  late EventVibe? _selectedVibe;
  late List<String> _tags;
  late bool _isPrivate;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description ?? '');
    _locationController = TextEditingController(text: widget.event.location);

    _selectedDate = widget.event.date;
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;
    _maxAttendees = widget.event.maxAttendees;
    _selectedCategories = widget.event.categories
        .map((c) => EventCategory.values.firstWhere(
              (cat) => cat.name == c,
              orElse: () => EventCategory.social,
            ))
        .toList();
    _selectedVibe = widget.event.vibe != null
        ? EventVibe.values.firstWhere(
            (v) => v.name == widget.event.vibe,
            orElse: () => EventVibe.casual,
          )
        : null;
    _tags = List.from(widget.event.tags);
    _isPrivate = widget.event.isPrivate;
  }

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

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          return await _showDiscardDialog();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () async {
              if (_hasChanges) {
                final discard = await _showDiscardDialog();
                if (discard) Get.back();
              } else {
                Get.back();
              }
            },
            child: const Icon(Icons.close, color: Colors.black),
          ),
          title: const Text(
            'Edit Event',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: (_isValid && _hasChanges)
                  ? () {
                      HapticFeedback.mediumImpact();
                      // Save changes
                      Get.back();
                      Get.snackbar(
                        'Changes Saved',
                        'Your event has been updated',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: Colors.white,
                      );
                    }
                  : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: (_isValid && _hasChanges)
                      ? AppColors.primaryBlue
                      : AppColors.mediumGrey,
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
                controller: _titleController,
                onChanged: (_) {
                  _markChanged();
                  setState(() {});
                },
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
                          initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          _markChanged();
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
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          _markChanged();
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
                          initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          _markChanged();
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
                controller: _locationController,
                prefixIcon: Icons.location_on,
                onChanged: (_) {
                  _markChanged();
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),

              // Description
              _InputField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 4,
                onChanged: (_) => _markChanged(),
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
                        _markChanged();
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
                  _markChanged();
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
                  _markChanged();
                  setState(() => _selectedVibe = vibe);
                },
              ),
              const SizedBox(height: 20),

              // Tags
              EventTagsInput(
                tags: _tags,
                onAdd: (tag) {
                  if (_tags.length < 5) {
                    _markChanged();
                    setState(() => _tags.add(tag));
                  }
                },
                onRemove: (tag) {
                  _markChanged();
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
                        _markChanged();
                        setState(() => _isPrivate = v);
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cancel event button
              GestureDetector(
                onTap: () => _showCancelEventDialog(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(13),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.error.withAlpha(51)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Cancel Event',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDiscardDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Discard', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showCancelEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text(
          'Are you sure you want to cancel this event? All attendees will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Event'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
              Get.snackbar(
                'Event Cancelled',
                'All attendees have been notified',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
              );
            },
            child: Text('Cancel Event', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final int maxLines;
  final Function(String)? onChanged;

  const _InputField({
    required this.label,
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
