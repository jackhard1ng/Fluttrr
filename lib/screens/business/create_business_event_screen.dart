import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../constants/utils.dart';
import '../../controllers/business_controller.dart';
import '../../widgets/common_widgets.dart';

/// Create business event screen
class CreateBusinessEventScreen extends StatefulWidget {
  const CreateBusinessEventScreen({super.key});

  @override
  State<CreateBusinessEventScreen> createState() =>
      _CreateBusinessEventScreenState();
}

class _CreateBusinessEventScreenState extends State<CreateBusinessEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessController = Get.find<BusinessController>();
  final _imagePicker = ImagePicker();

  // Text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _attendeesController = TextEditingController();
  final _ticketUrlController = TextEditingController();

  // State
  File? _eventImage;
  DateTime? _startDate;
  DateTime? _endDate;
  String _eventType = 'Free';
  String _privacy = 'Public';

  final List<String> _eventTypes = ['Free', 'Paid'];
  final List<String> _privacyOptions = ['Public', 'Followers Only', 'Private'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _attendeesController.dispose();
    _ticketUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _eventImage = File(image.path);
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

  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartDate) {
            _startDate = dateTime;
            // Reset end date if it's before start date
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = null;
            }
          } else {
            _endDate = dateTime;
          }
        });
      }
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_eventImage == null) {
      Get.snackbar(
        'Error',
        'Please select an event image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (_startDate == null) {
      Get.snackbar(
        'Error',
        'Please select a start date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (_endDate == null) {
      Get.snackbar(
        'Error',
        'Please select an end date',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _businessController.createEvent(
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      eventType: _eventType,
      privacy: _privacy,
      maxAttendees: int.tryParse(_attendeesController.text) ?? 0,
      ticketUrl: _ticketUrlController.text,
      image: _eventImage!,
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Event created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          TextButton(
            onPressed: () {
              // Save as draft
              Get.snackbar(
                'Draft',
                'Event saved as draft',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Draft'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event image picker
              _buildImagePicker(),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event name
                    _buildLabel('Event Name'),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Enter event name',
                      prefixIcon: const Icon(Icons.event),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter event name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Start date
                    _buildLabel('Start Date & Time'),
                    _buildDatePicker(
                      date: _startDate,
                      hint: 'Select start date',
                      onTap: () => _selectDate(true),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // End date
                    _buildLabel('End Date & Time'),
                    _buildDatePicker(
                      date: _endDate,
                      hint: 'Select end date',
                      onTap: () => _selectDate(false),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Location
                    _buildLabel('Location'),
                    CustomTextField(
                      controller: _locationController,
                      hintText: 'Enter event location',
                      prefixIcon: const Icon(Icons.location_on),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Event type
                    _buildLabel('Event Type'),
                    _buildDropdown(
                      value: _eventType,
                      items: _eventTypes,
                      onChanged: (value) {
                        setState(() => _eventType = value ?? 'Free');
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Privacy
                    _buildLabel('Privacy'),
                    _buildDropdown(
                      value: _privacy,
                      items: _privacyOptions,
                      onChanged: (value) {
                        setState(() => _privacy = value ?? 'Public');
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Max attendees
                    _buildLabel('Maximum Attendees'),
                    CustomTextField(
                      controller: _attendeesController,
                      hintText: 'Enter max number of attendees',
                      prefixIcon: const Icon(Icons.people),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter max attendees';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    _buildLabel('Event Details'),
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Describe your event',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter event details';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Ticketing URL (optional)
                    _buildLabel('Ticketing Website (Optional)'),
                    CustomTextField(
                      controller: _ticketUrlController,
                      hintText: 'https://tickets.example.com',
                      prefixIcon: const Icon(Icons.link),
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Create button
                    Obx(() => GradientButton(
                          text: 'Publish Event',
                          isLoading: _businessController.isLoading.value,
                          onPressed: _createEvent,
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _eventImage == null ? AppGradients.primaryHorizontal : null,
          image: _eventImage != null
              ? DecorationImage(
                  image: FileImage(_eventImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _eventImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_photo_alternate,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add Event Image',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: IconButton(
                      onPressed: () {
                        setState(() => _eventImage = null);
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDatePicker({
    DateTime? date,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.grey),
            const SizedBox(width: AppSpacing.md),
            Text(
              date != null
                  ? DateFormat('MMM d, y • h:mm a').format(date)
                  : hint,
              style: TextStyle(
                color: date != null ? Colors.black : AppColors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
