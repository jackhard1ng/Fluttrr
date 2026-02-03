import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttrr/Constants/all_textfields.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BusinessPageController.dart';

import '../Controller/ActivityController.dart';
import 'businessevents_screen.dart';

class CreateeventScreen extends StatefulWidget {
  const CreateeventScreen({super.key});

  @override
  State<CreateeventScreen> createState() => _CreateeventScreenState();
}

class _CreateeventScreenState extends State<CreateeventScreen> {
  bool loading = false;
  BusinessController businessController = Get.put(BusinessController());
  ActivityController controller = Get.put(ActivityController());
  final _formKey = GlobalKey<FormState>();
  final List<String> eventTypes = ['Paid', 'Free'];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController privacyController = TextEditingController();
  final TextEditingController attendeesController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController ticketingController = TextEditingController();

  String? selectedEventType;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
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
        initialTime: TimeOfDay.now(),
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
        initialTime: TimeOfDay.now(),
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

  void _submitForm() async {
    setState(() {
      loading = true;
    });
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an event image')),
      );
      return;
    }

    if (_endDate != null &&
        _startDate != null &&
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }
    final location =
        await controller.getCoordinatesFromGeoCode(locationController.text);

    final ok = await businessController.CreateEvent(
        "${businessController.businessPageModel?.profile?.id.toString()}",
        nameController.text,
        _startDate.toString(),
        _endDate.toString(),
        privacyController.text,
        attendeesController.text,
        location["latitude"].toString(),
        location["longitude"].toString(),
        detailsController.text,
        selectedEventType.toString(),
        ticketingController.text,
        privacyController.text,
        locationController.text,
        _selectedImage!);

    if (ok) {
      await businessController.GetMYEvents();
      setState(() {
        loading = false;
      });

      Get.offAll(() => BusinesseventsScreen());
      // Form is valid, proceed with submission
      print('Form submitted successfully');
    } else {
      setState(() {
        loading = false;
      });
      print('Form submitted Falied');
    }

    // Add your form submission logic here
  }

  @override
  void initState() {
    super.initState();
    businessController.GetBusinessPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Events',
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
                    gradient: LinearGradient(colors: [
                      Color(0xff007BFD),
                      Color(0xff20235A),
                    ]),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
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
                    Text(
                      'Event Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: nameController,
                      hintText: 'Event Name',
                      validator: (value) =>
                          _validateRequired(value, 'event name'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Start Date And Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _selectStartDate,
                      child: AbsorbPointer(
                        child: Business_TextField(
                          controller: startDateController,
                          hintText: 'Dec 21, 2025 9:00 PM',
                          validator: (value) =>
                              _validateDate(value, 'start date'),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'End Date And Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: _selectEndDate,
                      child: AbsorbPointer(
                        child: Business_TextField(
                          controller: endDateController,
                          hintText: 'Dec 21, 2025 9:00 PM',
                          validator: (value) =>
                              _validateDate(value, 'end date'),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Event Privacy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: privacyController,
                      hintText: 'Who can see it?',
                      validator: (value) =>
                          _validateRequired(value, 'event privacy'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Number of Attendees',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: attendeesController,
                      hintText: 'Set a Max Number of Attendees',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          _validateRequired(value, 'number of attendees'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: locationController,
                      hintText: 'Event Location',
                      validator: (value) =>
                          _validateRequired(value, 'location'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: detailsController,
                      maxLines: 3,
                      hintText: 'What are the Event Details',
                      validator: (value) =>
                          _validateRequired(value, 'event details'),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Event Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
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
                                'Select',
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
                            color: Color(0xffF1F1F1),
                          ),
                          elevation: 0,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
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
                    SizedBox(height: 15),
                    Text(
                      'Ticketing Website',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Business_TextField(
                      controller: ticketingController,
                      hintText: 'Ticketing Website URL',
                      validator: _validateURL,
                    ),
                    SizedBox(height: 33),
                    Row(
                      children: [
                        Expanded(
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
                            child: Center(
                              child: Text(
                                'Draft',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          child: loading
                              ? Center(
                                  child: GradientProgressIndicator(
                                    radius: 17,
                                    duration: 3,
                                    strokeWidth: 5,
                                    backgroundColor: Colors.white,
                                    gradientStops: const [
                                      0.2,
                                      0.7,
                                      0.3,
                                      0.3,
                                    ],
                                    gradientColors: const [
                                      Color(0xff4F78DA),
                                      Color(0xff339003),
                                      Color(0xff4F78DA),
                                      Colors.white
                                    ],
                                    child: Text(''),
                                  ),
                                )
                              : Button(
                                  borderRadius: BorderRadius.circular(10),
                                  height: 56,
                                  width: double.infinity,
                                  onTap: _submitForm,
                                  child: const Center(
                                    child: Text(
                                      'Publish',
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
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
