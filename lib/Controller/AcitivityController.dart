import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttrr/Models/ActivityDetailsScreen.dart';
import 'package:fluttrr/Models/ActivityListModel.dart';
import 'package:fluttrr/Models/DailyActivityModel.dart';
import 'package:fluttrr/Models/EventDetailsModel.dart';
import 'package:fluttrr/Models/MyActivityModel.dart';
import 'package:fluttrr/Models/SavedActivitesModel.dart';
import 'package:fluttrr/Models/UpComingActivityModel.dart';
import 'package:fluttrr/Repository/ActivityRepository.dart';

import '../Models/UnifieldsDetailsModel.dart';

class Acitivitycontroller extends GetxController {
  var location = "".obs;
  ActivityListModel? activityListModel;
  List<bool> likedStatus = [];
  List<bool> likedStatus2 = [];
  MyActivityModel? myActivityModel;
  DailyActivitesModel? dailyActivites;
  ActivityDetailsModel? activityDetailsModel;
  EventDetailsModel? eventDetailsModel;
  SavedEventsResponse? savedEventsResponse;
  UpComingActivitiesModel? upComingActivitiesModel;
  var counter = 1.obs; // Initialize the counter inside StatefulBuilder

  void incrementCounter() {
    counter.value++;
  }

  void decrementCounter() {
    if (counter > 1) {
      counter.value--;
    }
  }

//.................................. handeling the like status .....................

  // Key to save in shared prefs
  final String likedKey = "likedStatusList";

  Future<void> loadLikedStatus(int activityLength) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? likedStringList = prefs.getStringList(likedKey);

    if (likedStringList != null && likedStringList.length == activityLength) {
      likedStatus2 = likedStringList.map((e) => e == 'true').toList();
    } else {
      likedStatus2 = List.generate(activityLength, (index) => false);
    }
    update(["Activity_update"]);
  }

  Future<void> toggleLikedStatus(int index) async {
    likedStatus2[index] = !likedStatus2[index];
    update(["Activity_update"]);
    await _saveLikedStatus();
  }

  Future<void> _saveLikedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> likedStringList =
        likedStatus2.map((e) => e.toString()).toList();
    await prefs.setStringList(likedKey, likedStringList);
  }

//................................handeling upcoming...........................

// Key to save in shared prefs
  final String likedKey2 = "likedStatusList2";

  Future<void> loadLikedStatus2(int activityLength) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? likedStringList = prefs.getStringList(likedKey);

    if (likedStringList != null && likedStringList.length == activityLength) {
      likedStatus = likedStringList.map((e) => e == 'true').toList();
    } else {
      likedStatus = List.generate(activityLength, (index) => false);
    }
    update(["Activity_update"]);
  }

  Future<void> toggleLikedStatus2(int index) async {
    likedStatus[index] = !likedStatus[index];
    update(["Activity_update"]);
    await _saveLikedStatus2();
  }

  Future<void> _saveLikedStatus2() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> likedStringList =
        likedStatus.map((e) => e.toString()).toList();
    await prefs.setStringList(likedKey, likedStringList);
  }

  UnifiedEventModel?
      eventModel; //..............handle both event and activity details

  void loadData(dynamic json) {
    if (json.containsKey('data') && json['data'].containsKey('event_id')) {
      eventModel =
          UnifiedEventModel.fromEvent(EventDetailsModel.fromJson(json));
    } else {
      eventModel =
          UnifiedEventModel.fromActivity(ActivityDetailsModel.fromJson(json));
    }
  }

//................................ Daily Activities...................
  Future<bool> DailyActivities() async {
    final activity = await Activityrepository().GetDailyActivites();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      dailyActivites = DailyActivitesModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//..............................Get Acticity List ..................

  Future<bool> ActivitieList() async {
    final activity = await Activityrepository().ActivityList();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      activityListModel = ActivityListModel.fromJson(activity);
      await loadLikedStatus(activityListModel?.data?.length ?? 0);

      update(["Activity_update"]);
      return true;
    }
  }

//..............................Get Acticity List ..................

  Future<bool> CreateActivity(
    File image,
    String name,
    String longitude,
    String Latitude,
    String description,
    String totalslots,
    String time,
    String date,
    String Location,
    String totaltime,
  ) async {
    final activity = await Activityrepository().CreateActivity(
        image: image,
        name: name,
        longitude: longitude,
        Latitude: Latitude,
        description: description,
        totalslots: totalslots,
        time: time,
        date: date,
        Location: Location,
        totaltime: totaltime);
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      dailyActivites = DailyActivitesModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

  //..............................Update Acticity  ..................

  Future<bool> UpdateActivity(
    String activityId, // ID of the activity to update
    File? image, // Image is optional
    String name,
    String longitude,
    String latitude,
    String description,
    String totalslots,
    String time,
    String date,
    String location,
    String totaltime,
  ) async {
    final activity = await Activityrepository().PutActivity(
        activityId: activityId,
        name: name,
        longitude: longitude,
        latitude: latitude,
        description: description,
        totalslots: totalslots,
        time: time,
        date: date,
        location: location,
        totaltime: totaltime,
        image: image);
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      dailyActivites = DailyActivitesModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//...................................... get the Location in Langitude and latitude ..........

  Future<Map<String, double>> getCoordinatesFromGeoCode(
      String addressInput) async {
    // First try: Use device's GPS if address is not specific
    if (addressInput.isEmpty ||
        addressInput.toLowerCase().contains("current location")) {
      try {
        return await _getCurrentLocation();
      } catch (e) {
        print("Failed to get current location: $e");
        // Continue to try geocoding
      }
    }

    // Second try: Basic geocoding without API
    try {
      GeoCode geoCode = GeoCode();
      Coordinates coordinates =
          await geoCode.forwardGeocoding(address: addressInput);

      if (coordinates.latitude != null && coordinates.longitude != null) {
        // Basic validation of coordinates
        if (_isValidCoordinate(coordinates.latitude!, coordinates.longitude!)) {
          return {
            'latitude': coordinates.latitude!,
            'longitude': coordinates.longitude!,
          };
        }
      }
    } catch (e) {
      print("Geocoding failed: $e");
    }

    // Final fallback: Try to get approximate location from device
    try {
      return await _getCurrentLocation();
    } catch (e) {
      print("Final fallback failed: $e");
      throw Exception(
          "Could not determine location from address '$addressInput'");
    }
  }

  Future<Map<String, double>> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }

  bool _isValidCoordinate(double lat, double lng) {
    // Basic validation that coordinates are within world bounds
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

//..............................Get Acticity Details ..................

  Future<bool> ActivitieDetails(String id) async {
    final activity = await Activityrepository().ActivityDetails(id);
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      activityDetailsModel = ActivityDetailsModel.fromJson(activity);
      loadData(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//..............................Get Event Details ..................

  Future<bool> EventDetails(String id) async {
    final activity = await Activityrepository().EventDetails(id);
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      eventDetailsModel = EventDetailsModel.fromJson(activity);
      loadData(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//..............................Get My Acticity  ..................

  Future<bool> MyActivitie() async {
    final activity = await Activityrepository().MyActivity();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      myActivityModel = MyActivityModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//.......................................Join Activity.......................

  Future<bool> joinActivity(
    String Activityid,
    String gusts,
  ) async {
    final activity = await Activityrepository().JoinActivity(Activityid, gusts);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

//.......................................Join Event.......................

  Future<bool> joinEvent(String eventid) async {
    final activity = await Activityrepository().JoinEvent(eventid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

  //.......................................Save Activity.......................

  Future<bool> saveActivity(
    String activityid,
  ) async {
    final activity = await Activityrepository().SaveActivity(activityid);
    print("Profile Fatch is : $activity");
    Get.snackbar(
      "Success",
      "Activity Saved successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

//.......................................Save Event.......................

  Future<bool> saveEvent(
    String Eventid,
  ) async {
    final activity = await Activityrepository().SaveEvent(Eventid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

  //..............................Get My SaveList  ..................

  Future<bool> SaveList() async {
    final activity = await Activityrepository().saveList();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      savedEventsResponse = SavedEventsResponse.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//....................................... FilterActivity .......................

  Future<bool> FilterActivity(
      String Name, String date, String time, String range) async {
    final activity =
        await Activityrepository().FilterActivity(Name, date, time, range);
    print("Profile Fatch is : $activity");
    activityListModel = ActivityListModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

//.......................................Leave Activity.......................

  Future<bool> LeaveActivity(String Activityid) async {
    final activity = await Activityrepository().LeaveActivies(Activityid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

//.......................................Leave Event.......................

  Future<bool> LeaveEvent(String eventid) async {
    final activity = await Activityrepository().LeaveEvent(eventid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

//.......................................Delete Activity.......................

  Future<bool> DeleteActivity(String eventid) async {
    final activity = await Activityrepository().DeleteActivity(eventid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

//................................ UpComing Activities...................
  Future<bool> UpcommingActivities() async {
    final activity = await Activityrepository().GetUpcomingActivites();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      upComingActivitiesModel = UpComingActivitiesModel.fromJson(activity);

      await loadLikedStatus2(upComingActivitiesModel?.activities?.length ?? 0);

      update(["Activity_update"]);
      return true;
    }
  }

//..............................Follow Business...................................
  Future<bool> FollowBusiness(String bussinessid) async {
    final activity = await Activityrepository().FollowBusiness(bussinessid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }

//................................Unfollow Business...............................

  Future<bool> unFollowBusiness(String bussinessid) async {
    final activity = await Activityrepository().unFollowBusiness(bussinessid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }
//...............................Event Click.........................................

  Future<bool> CLickFollowBusiness(String eventid) async {
    final activity = await Activityrepository().CLickFollowBusiness(eventid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }
//..................................EventViews......................................

  Future<bool> ViewFollowBusiness(String eventid) async {
    final activity = await Activityrepository().ViewFollowBusiness(eventid);
    print("Profile Fatch is : $activity");
    // dailyActivites = DailyActivitesModel.fromJson(activity);
    update(["Activity_update"]);
    return true;
  }
}
