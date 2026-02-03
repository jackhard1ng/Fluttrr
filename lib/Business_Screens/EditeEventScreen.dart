import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/all_textfields.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BussinessPageController.dart';
import 'package:fluttrr/Models/BussinessModel/BusinessEventListModel.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  BusinessController businessController = Get.put(BusinessController());
  final _formKey = GlobalKey<FormState>();
  final List<String> eventTypes = ['Paid', 'Free'];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  late final TextEditingController nameController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;
  late final TextEditingController privacyController;
  late final TextEditingController attendeesController;
  late final TextEditingController locationController;
  late final TextEditingController detailsController;
  late final TextEditingController ticketingController;

  String? selectedEventType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with event data
    nameController = TextEditingController(text: widget.event.name);
    startDateController = TextEditingController(
        text: widget.event.dateTime != null
            ? DateFormat('MMM d, y h:mm a').format(widget.event.dateTime!)
            : '');
    endDateController = TextEditingController(
        text: widget.event.endTime != null
            ? DateFormat('MMM d, y h:mm a').format(widget.event.endTime!)
            : '');
    privacyController =
        TextEditingController(text: widget.event.eventPrivacy ?? 'Public');
    attendeesController =
        TextEditingController(text: widget.event.totalSlots?.toString() ?? '0');
    locationController = TextEditingController(text: widget.event.location);
    detailsController = TextEditingController(text: widget.event.description);
    ticketingController =
        TextEditingController(text: widget.event.ticketingWebsite ?? '');
    selectedEventType = widget.event.eventType;
    _startDate = widget.event.dateTime;
    _endDate = widget.event.endTime;
  }

  @override
  void dispose() {
    nameController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    privacyController.dispose();
    attendeesController.dispose();
    locationController.dispose();
    detailsController.dispose();
    ticketingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDate ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _startDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          startDateController.text =
              DateFormat('MMM d, y h:mm a').format(_startDate!);
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _endDate ?? (_startDate ?? DateTime.now()).add(Duration(days: 1)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            _endDate ?? (_startDate ?? DateTime.now()).add(Duration(hours: 1))),
      );
      if (time != null) {
        setState(() {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          endDateController.text =
              DateFormat('MMM d, y h:mm a').format(_endDate!);
        });
      }
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validateDate(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select $fieldName';
    }
    return null;
  }

  String? _validateURL(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!Uri.tryParse(value)!.hasAbsolutePath) {
        return 'Please enter a valid URL';
      }
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endDate != null &&
        _startDate != null &&
        _endDate!.isBefore(_startDate!)) {
      Get.snackbar('Error', 'End date must be after start date');
      return;
    }

    // Call update event API
    final success = await businessController.updateEvent(
      widget.event.eventId.toString(),
      widget.event.eventId.toString(),
      nameController.text,
      _startDate.toString(),
      _endDate.toString(),
      privacyController.text,
      attendeesController.text,
      widget.event.latitude ?? '0',
      widget.event.longitude ?? '0',
      detailsController.text,
      selectedEventType.toString(),
      ticketingController.text,
      '0', // Update if your event has price
      locationController.text,
      _selectedImage, // Pass null to keep existing image
    );

    if (success) {
      Get.back(result: true);
      Get.snackbar('Success', 'Event updated successfully');
      businessController.GetMYEvents();
    } else {
      Get.snackbar('Error', 'Failed to update event');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: const Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Event',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 283,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0xff007BFD),
                      Color(0xff20235A),
                    ]),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : widget.event.image != null
                          ? Image.network("${Apis.ip}${widget.event.image!}",
                              fit: BoxFit.cover)
                          : Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Image.asset('assets/eve.png'),
                            ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: nameController,
                      hintText: 'Event Name',
                      validator: (value) =>
                          _validateRequired(value, 'event name'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Start Date And Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _selectStartDate,
                      child: AbsorbPointer(
                        child: Business_TextField(
                          controller: startDateController,
                          hintText: 'Select start date',
                          validator: (value) =>
                              _validateDate(value, 'start date'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'End Date And Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _selectEndDate,
                      child: AbsorbPointer(
                        child: Business_TextField(
                          controller: endDateController,
                          hintText: 'Select end date',
                          validator: (value) =>
                              _validateDate(value, 'end date'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Event Privacy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: privacyController,
                      hintText: 'Event privacy',
                      validator: (value) =>
                          _validateRequired(value, 'event privacy'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Number of Attendees',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: attendeesController,
                      hintText: 'Max attendees',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          _validateRequired(value, 'number of attendees'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: locationController,
                      hintText: 'Event location',
                      validator: (value) =>
                          _validateRequired(value, 'location'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: detailsController,
                      maxLines: 3,
                      hintText: 'Event details',
                      validator: (value) =>
                          _validateRequired(value, 'event details'),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Event Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        iconStyleData: IconStyleData(
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 19),
                            child: SvgPicture.asset('assets/drop.svg'),
                          ),
                        ),
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Select event type',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: discriptionColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: eventTypes
                            .map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 7),
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedEventType,
                        onChanged: (value) {
                          setState(() {
                            selectedEventType = value;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 60,
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 7, right: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: const Color(0xffF1F1F1),
                          ),
                          elevation: 0,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(17),
                              bottomRight: Radius.circular(17),
                            ),
                            color: Colors.white,
                          ),
                          offset: const Offset(-20, 0),
                          scrollbarTheme: const ScrollbarThemeData(
                            radius: Radius.circular(40),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 30, right: 7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Ticketing Website',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Business_TextField(
                      controller: ticketingController,
                      hintText: 'Ticketing website URL',
                      validator: _validateURL,
                    ),
                    const SizedBox(height: 33),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(10),
                                border: GradientBoxBorder(
                                  width: 1.3,
                                  gradient: lefttorightgradient,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Button(
                            borderRadius: BorderRadius.circular(10),
                            height: 56,
                            width: double.infinity,
                            onTap: _submitForm,
                            child: const Center(
                              child: Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
