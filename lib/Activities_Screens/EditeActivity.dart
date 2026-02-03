import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocode/geocode.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';

import '../Constants/button.dart';
import '../Constants/utils.dart';
import '../Controller/AcitivityController.dart';

class Editeactivity extends StatefulWidget {
  final String id;
  final String ActivityType;
  final String Description;
  final String location;
  final String Dateandtime;
  final String image;
  final String numberofPeople;
  final String TotalTime;

  const Editeactivity(
      {super.key,
      required this.ActivityType,
      required this.Description,
      required this.location,
      required this.Dateandtime,
      required this.image,
      required this.numberofPeople,
      required this.TotalTime,
      required this.id});

  @override
  State<Editeactivity> createState() => _EditeactivityState();
}

class _EditeactivityState extends State<Editeactivity> {
  Acitivitycontroller acitivitycontroller = Get.put(Acitivitycontroller());
  bool loading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _activitytype = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _totalslots = TextEditingController();
  final TextEditingController _totaltime = TextEditingController();

  LatLng? _selectedLatLng;

  @override
  void initState() {
    super.initState();
    _initializeUserLocation();
    _activitytype.text = widget.ActivityType;
    _description.text = widget.Description;
    acitivitycontroller.location.value = widget.location;
    _totalslots.text = widget.numberofPeople;
    _totaltime.text = widget.TotalTime;
    print("Date and time: ${widget.Dateandtime}");

    // Parse the string to DateTime
    selectedDate = DateTime.tryParse(widget.Dateandtime);

    // Update selectedTime from selectedDate
    if (selectedDate != null) {
      selectedTime =
          TimeOfDay(hour: selectedDate!.hour, minute: selectedDate!.minute);
    }

    print("Selected Date: $selectedDate"); // Example: 2025-03-14 20:41:06.000Z
    print(
        "Selected Time: ${selectedTime?.format(Get.context!)}"); // Example: 8:41 PM
  }

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // Ensure initial date is a valid weekday
    DateTime initialDate = selectedDate ?? DateTime.now();

    while (initialDate.weekday == DateTime.saturday ||
        initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate.add(Duration(days: 1)); // Move to next day
    }

    // Pick Date & Time Together
    DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: initialDate, // Use valid initial date
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      selectableDayPredicate: (date) {
        // Disable weekends (Saturday & Sunday)
        return date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday;
      },
    ).then((pickedDate) async {
      if (pickedDate == null) return null; // User canceled date picker

      // Pick Time immediately after Date selection
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );

      if (pickedTime == null) return null; // User canceled time picker

      // Combine Date & Time into a single DateTime object
      return DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });

    setState(() {
      selectedDate = pickedDateTime; // Store complete DateTime
    });

    print("Selected DateTime: $pickedDateTime");
  }

  Future<void> _initializeUserLocation() async {
    try {
      Position position = await _determinePosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);
      String address = await _convertLatLngToAddress(userLocation);
      setState(() {
        _selectedLatLng = userLocation;
        _locationController.text = address;
      });
    } catch (e) {
      setState(() {
        _selectedLatLng = LatLng(37.7749, -122.4194); // Default: San Francisco
        _locationController.text = "San Francisco, CA, USA";
      });
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied forever.");
      }
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> _convertLatLngToAddress(LatLng location) async {
    try {
      GeoCode geoCode = GeoCode();
      Address address = await geoCode.reverseGeocoding(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      return "${address.streetAddress}, ${address.city}, ${address.countryName}";
    } catch (e) {
      return "Unknown Location";
    }
  }

  Future<void> _openMap() async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(initialLocation: _selectedLatLng),
      ),
    );

    if (pickedLocation != null) {
      String address = await _convertLatLngToAddress(pickedLocation);
      setState(() {
        _selectedLatLng = pickedLocation;
        _locationController.text = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 66, left: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Create Activity:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 13,
            ),
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(gradient: lefttorightgradient),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activities Type:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      controller: _activitytype,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                        filled: true,
                        fillColor: Color(0xffF1F1F1),
                        hintText: 'activities type',
                        hintStyle:
                            TextStyle(fontSize: 14, color: discriptionColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 19,
                  ),
                  Text(
                    'Activities Description:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TextFormField(
                      maxLines: 3,
                      style: TextStyle(color: Colors.black),
                      controller: _description,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                        filled: true,
                        fillColor: Color(0xffF1F1F1),
                        hintText: 'activities description',
                        hintStyle:
                            TextStyle(fontSize: 14, color: discriptionColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 19,
                  ),
                  Text(
                    'Location:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child:
                        Obx(() => acitivitycontroller.location.value.isNotEmpty
                            ? TextFormField(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 13),
                                  filled: true,
                                  fillColor: Color(0xffF1F1F1),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.map, color: Colors.blue),
                                    onPressed: _openMap,
                                  ),
                                  hintText: 'Enter address or pick from map',
                                  // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                controller: TextEditingController(
                                    text: acitivitycontroller
                                        .location.value), // Update controller
                                onChanged: (value) {
                                  acitivitycontroller.location.value =
                                      value; // Sync user input
                                },
                              )
                            : TextFormField(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 13),
                                  filled: true,
                                  fillColor: Color(0xffF1F1F1),
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.map, color: Colors.blue),
                                    onPressed: _openMap,
                                  ),
                                  hintText: 'Enter address or pick from map',
                                  // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                controller:
                                    TextEditingController(), // Update controller
                                // onChanged: (value) {
                                //   acitivitycontroller.location.value = value; // Sync user input
                                // },
                              )),
                  ),
                  SizedBox(height: 19),
                  Text(
                    'Date And Time:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Date Field
                  GestureDetector(
                    onTap: () => _selectDateTime(context),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Color(0xffF1F1F1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate != null
                                ? "$selectedDate"
                                : "Select Date",
                            style: TextStyle(color: Colors.black),
                          ),
                          SvgPicture.asset('assets/Group 48096193 (1).svg'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 19),
                  Text(
                    'Upload Images:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xffF1F1F1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 13),
                            child: Row(
                              children: [
                                Text(
                                  'upload images',
                                  style: TextStyle(
                                      fontSize: 14, color: discriptionColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 56,
                          width: 103,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: lightBlue),
                          child: Center(
                            child: Text(
                              'Upload',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    child: Image.network(
                      "${Apis.ip}${widget.image}",
                      height: 200,
                      // width: 80,
                    ),
                  ),

                  SizedBox(
                    height: 19,
                  ),
                  Text(
                    'Number of People:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      controller: _totalslots,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                        filled: true,
                        fillColor: Color(0xffF1F1F1),
                        hintText: 'number of people',
                        hintStyle:
                            TextStyle(fontSize: 14, color: discriptionColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 19,
                  ),
                  Text(
                    'Total Time:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TextFormField(
                      controller: _totaltime,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                        filled: true,
                        fillColor: Color(0xffF1F1F1),
                        hintText: 'Total Time',
                        hintStyle:
                            TextStyle(fontSize: 14, color: discriptionColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 33,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(10),
                          border: GradientBoxBorder(
                              width: 1.3, gradient: lefttorightgradient),
                        ),
                        child: Center(
                            child: Text(
                          'Preview',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        )),
                      )),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: loading
                            ? GradientProgressIndicator(
                                radius: 21,
                                duration: 3,
                                strokeWidth: 7,
                                backgroundColor: Colors.white,
                                gradientStops: const [
                                  0.2,
                                  0.7,
                                  0.3,
                                  0.3,
                                ],
                                gradientColors: const [
                                  Color(0xff007BFD),
                                  Color(0xff20235A),
                                  Color(0xff007BFD),
                                  Colors.white
                                ],
                                child: Text(''),
                              )
                            : Button(
                                borderRadius: BorderRadius.circular(10),
                                height: 56,
                                width: double.infinity,
                                onTap: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  final location = await acitivitycontroller
                                      .getCoordinatesFromGeoCode(
                                          _locationController.text);
                                  print(
                                      "the langitude is :${location["longitude"]}");
                                  print(
                                      "the Latitude is   :${location["latitude"]}");
                                  final create =
                                      await acitivitycontroller.UpdateActivity(
                                          widget.id,
                                          _selectedImage,
                                          _activitytype.text,
                                          location["longitude"].toString(),
                                          location["latitude"].toString(),
                                          _description.text,
                                          _totalslots.text,
                                          selectedTime.toString(),
                                          selectedDate.toString(),
                                          acitivitycontroller.location.value,
                                          _totaltime.text);
                                  if (create) {
                                    setState(() {
                                      loading = false;
                                    });
                                    Get.back();
                                  } else {
                                    setState(() {
                                      loading = false;
                                    });
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      CustomSnackBar.error(
                                        message: "Failed to Create Activity!.",
                                      ),
                                    );
                                  }
                                },
                                child: const Center(
                                    child: Text(
                                  'Update',
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                )),
                              ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 33,
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

class MapScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const MapScreen({super.key, this.initialLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Acitivitycontroller acitivitycontroller = Get.put(Acitivitycontroller());
  LatLng? _pickedLocation;
  late final MapController _mapController;
  String mapboxApiKey =
      "pk.eyJ1IjoiamFja2hhcmRpbmcxNyIsImEiOiJjbTdzbXNlNzAxYzkxMmpvYWJuZXZoc3E2In0.v3vDy9EOl55cy_5V3oShlQ";

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pickedLocation = widget.initialLocation ?? LatLng(37.7749, -122.4194);
  }

  Future<String> _convertLatLngToAddress(LatLng location) async {
    try {
      GeoCode geoCode = GeoCode();
      Address address = await geoCode.reverseGeocoding(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      return "${address.streetAddress}, ${address.city}, ${address.countryName}";
    } catch (e) {
      return "Unknown Location";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _pickedLocation);
            },
            child: Text('Select', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
            initialCenter: _pickedLocation!,
            initialZoom: 13.0,
            onTap: (tapPosition, latLng) async {
              setState(() {
                _pickedLocation = latLng; // Update location immediately
              });

              String address = await _convertLatLngToAddress(latLng);
              acitivitycontroller.location.value = address.toString();

              print("${acitivitycontroller.location}");

              setState(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Selected: $address")),
                );
              });
            }),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxApiKey",
            userAgentPackageName: 'com.example.yourapp',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _pickedLocation!,
                width: 40.0,
                height: 40.0,
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
