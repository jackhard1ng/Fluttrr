import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import '../Constants/utils.dart';
import '../Controller/AcitivityController.dart';

class ActivityMapScreen extends StatefulWidget {
  const ActivityMapScreen({super.key});

  @override
  _ActivityMapScreenState createState() => _ActivityMapScreenState();
}

class _ActivityMapScreenState extends State<ActivityMapScreen> {
  Acitivitycontroller controller = Get.put(Acitivitycontroller());
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  final _fromTop = true;
  final String mapboxAccessToken =
      "pk.eyJ1IjoiamFja2hhcmRpbmcxNyIsImEiOiJjbTdzbXNlNzAxYzkxMmpvYWJuZXZoc3E2In0.v3vDy9EOl55cy_5V3oShlQ";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime =
        DateTime.parse(dateTimeString).toLocal(); // Convert to local time
    String formattedDate = DateFormat("MMMM d, y 'at' h:mm a").format(dateTime);
    return formattedDate;
  }

  Future<void> _getCurrentLocation() async {
    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData locationData = await location.getLocation();
      setState(() {
        _currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });

      _addCurrentLocationMarker();
      _fetchMatesAndAddMarkers();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentLocation != null) {
      setState(() {
        _markers.add(
          Marker(
            point: _currentLocation!,
            width: 40,
            height: 40,
            child: Icon(Icons.my_location, color: Colors.blue, size: 30),
          ),
        );
      });
    }
  }

  Future<void> _fetchMatesAndAddMarkers() async {
    try {
      await controller.ActivitieList();

      print("Activity Data: ${controller.activityListModel?.data}");

      setState(() {
        _markers.clear();
      });

      for (var activity in controller.activityListModel?.data ?? []) {
        double? latitude = activity.latitude;
        double? longitude = activity.longitude;
        String? name = activity.name;
        String? date = activity.dateTime;
        String? totalslot = activity.totalSlots.toString();
        String? location = activity.location.toString();
        String? remaingslot = activity.remainingSlots.toString();
        String? description = activity.description;
        String? imageUrl =
            (activity.image.isNotEmpty) ? activity.image[0] : null;

        print(
            "Activity: $name, Lat: $latitude, Lng: $longitude, Image: $imageUrl");

        if (latitude != null && longitude != null) {
          LatLng position = LatLng(latitude, longitude);
          setState(() {
            _markers.add(
              Marker(
                point: position,
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    alertBox(
                        imageUrl.toString(),
                        name.toString(),
                        date.toString(),
                        description.toString(),
                        totalslot,
                        remaingslot,
                        location);
                    // _showActivityDetails(name ?? "Activity", description ?? "No description", imageUrl);
                  },
                  child: ClipOval(
                    child: imageUrl != null
                        ? Image.network("${Apis.ip}$imageUrl",
                            fit: BoxFit.cover)
                        : Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ),
              ),
            );
          });
        }
      }

      print("Total markers added: ${_markers.length}");
    } catch (e) {
      print('Error fetching activity data: $e');
    }
  }

  alertBox(String image, String name, String date, String descrption,
      String totalslots, String remaing, String location) {
    showGeneralDialog(
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(
                    begin: Offset(0, _fromTop ? -1 : 1),
                    end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        barrierColor: Colors.black.withOpacity(0.6),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Dialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                // backgroundColor: Colors.black,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(13.0)),
                        color: Theme.of(context).cardColor),
                    width: 430,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 290,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13),
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage('${Apis.ip}$image'),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(21.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/Group 48095897.svg',
                                        height: 21,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      SvgPicture.asset(
                                        'assets/Group 48095896.svg',
                                        height: 21,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      SvgPicture.asset(
                                        'assets/Group.svg',
                                        height: 21,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDateTime(date),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff339003),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '2h ',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: lightBlue),
                                          ),
                                          SvgPicture.asset(
                                            'assets/timer.svg',
                                            color: lightBlue,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/pin.svg',
                                        height: 13,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        location,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: lightBlue,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    descrption,
                                    style: TextStyle(
                                      color: Theme.of(context).indicatorColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    ' 50 View · 15 Interested ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).indicatorColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 17,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 17),
                                                child: CircleAvatar(
                                                  radius: 17,
                                                  backgroundColor:
                                                      Colors.purple,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 34),
                                                child: CircleAvatar(
                                                  radius: 17,
                                                  backgroundColor: Colors.blue,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 53),
                                                child: CircleAvatar(
                                                  radius: 17,
                                                  backgroundColor: Colors.amber,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            ' $remaing/$totalslots Joined',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 27,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: lightBlue),
                                        child: Center(
                                          child: Text(
                                            'Join Now',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: whiteColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Close',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xffAA0000),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                ],
                              )),
                        ])));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation!,
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken",
                      additionalOptions: {"access_token": mapboxAccessToken},
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
              ],
            ),
    );
  }
}
