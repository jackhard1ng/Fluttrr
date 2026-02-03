import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import '../Controller/MatesController.dart';

class MatesMapScreen extends StatefulWidget {
  const MatesMapScreen({super.key});

  @override
  _MatesMapScreenState createState() => _MatesMapScreenState();
}

class _MatesMapScreenState extends State<MatesMapScreen> {
  Matescontroller controller = Get.put(Matescontroller());
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  bool _isKm = true;
  double _distance = 25.0;
  final String mapboxAccessToken =
      "pk.eyJ1IjoiamFja2hhcmRpbmcxNyIsImEiOiJjbTdzbXNlNzAxYzkxMmpvYWJuZXZoc3E2In0.v3vDy9EOl55cy_5V3oShlQ";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
      // Error getting location
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
      await controller.ViewByDistance("25", "km");

      // Clear previous markers to prevent duplicates
      setState(() {
        _markers.clear();
      });

      for (var mate in controller.viewByDistanceModel?.users ?? []) {
        // Convert latitude and longitude from String? to double?
        double? latitude = double.tryParse(mate.latitude ?? "");
        double? longitude = double.tryParse(mate.longitude ?? "");
        String? name = mate.user?.userName;
        String? imageUrl =
            (mate.images?.isNotEmpty == true) ? mate.images![0] : null;

        if (latitude != null && longitude != null && imageUrl != null) {
          LatLng position = LatLng(latitude, longitude);
          setState(() {
            _markers.add(
              Marker(
                point: position,
                width: 50,
                height: 50,
                child: ClipOval(
                  child:
                      Image.network("${Apis.ip}$imageUrl", fit: BoxFit.cover),
                ),
              ),
            );
          });
        }
      }
    } catch (e) {
      // Error fetching mate data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Mates Map')),
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
                // Distance slider UI
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity, // Ensures full width
                    height: 200,
                    color: Theme.of(context).cardColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Distance Range: ${_distance.toStringAsFixed(1)} ${_isKm ? "km" : "miles"}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _distance,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          label:
                              "${_distance.toStringAsFixed(1)} ${_isKm ? "km" : "miles"}",
                          onChanged: (value) {
                            setState(() {
                              _distance = value;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Kilometers"),
                            Switch(
                              value: _isKm,
                              onChanged: (value) {
                                Future.microtask(() {
                                  setState(() {
                                    _isKm = value;
                                    controller.ViewByDistance(
                                        _distance.toString(),
                                        _isKm ? "km" : "miles");
                                    _distance = _isKm
                                        ? _distance * 1.60934
                                        : _distance / 1.60934;
                                  });
                                });
                              },
                            ),
                            Text("Miles"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
