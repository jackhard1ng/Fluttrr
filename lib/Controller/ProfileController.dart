import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Models/BadgesModel/BadgesModel.dart';
import 'package:fluttrr/Models/BadgesModel/LeaderBoardModel.dart';
import 'package:fluttrr/Models/GalleryDataModel.dart';
import 'package:fluttrr/Models/Notifications/NotificationsModel.dart';
import 'package:fluttrr/Models/Percentages.dart';
import 'package:fluttrr/Models/ProfileModel.dart';
import 'package:fluttrr/Models/TotalActivityCount.dart';
import 'package:fluttrr/Models/TotalJoinedActivitesModel.dart';
import 'package:fluttrr/Models/TotalMatchCount.dart';
import 'package:fluttrr/Models/TotalMatchListModel.dart';
import 'package:fluttrr/Repository/ProfileRespository.dart';

import '../Models/JoinedActivityModel.dart';

class ProfileController extends GetxController {
  profileModel? profile;
  GalleryDataModel? galleryDataModel;
  TotalActivityCount? totalActivityCount;
  TotalJoinedActivitesCount? totalJoinedActivitesCount;
  TotalMatchCount? totalMatchCount;
  JoinedActivitesModel? joinedActivitesModel;
  TotalMatchListModel? totalMatchListModel;
  BadgesModel? badgesModel;
  LeaderBoardModel? leaderBoardModel;
  NotificationsModel? notificationsModel;
  Percentage? percentage;

//.............................Get the profile...........................

  Future<bool> GetProfile() async {
    final Profile = await ProfileRepository().GetProfile();
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      profile = profileModel.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

  Future<bool> GetPrcentage() async {
    final Profile = await ProfileRepository().GetPercentage();
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      percentage = Percentage.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

//.............................Get Gallery List...........................

  Future<bool> GetGalleryList() async {
    final Profile = await ProfileRepository().GetGallery();
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      galleryDataModel = GalleryDataModel.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

  //.............................Upload Gallery List...........................

  Future<bool> UploadGallery(
    String description, // ID of the activity to update
    File? image, // Image is optional
  ) async {
    final Profile = await ProfileRepository()
        .UploadGallery(description: description, image: image);
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      profile = profileModel.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

  //.............................Get Total Activities...........................

  Future<bool> TotalActivites() async {
    final Profile = await ProfileRepository().GetTotalActivites();
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      totalActivityCount = TotalActivityCount.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

  //.............................Get Total Matcehs...........................

  Future<bool> TotalMatches() async {
    final Profile = await ProfileRepository().GetTotalMatches();
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      totalMatchCount = TotalMatchCount.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

  //.............................Get Total joined Activities...........................

  Future<bool> JoinedActivites() async {
    final Profile = await ProfileRepository().GetTotalJoinedActivites();
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      totalJoinedActivitesCount = TotalJoinedActivitesCount.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

  //.............................Get Total Matcehs List...........................

  Future<bool> TotalMatchesList() async {
    final Profile = await ProfileRepository().GetTotalMatchesList();
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      totalMatchListModel = TotalMatchListModel.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

  //.............................Get Total joined Activities List...........................

  Future<bool> JoinedActivitesList() async {
    final Profile = await ProfileRepository().GetTotalJoinedActivitesList();
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      joinedActivitesModel = JoinedActivitesModel.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }

//................................Edite Profile.........................

  Future<bool> editProfile({
    required String age,
    required String gender,
    required String status,
    required String bio,
    required List<String> interests,
    required List<String> Language,
    required String longitude,
    required String latitude,
    required String userName,
    File? image,
    File? coverImage,
  }) async {
    try {
      final profile = await ProfileRepository().editProfile(
        age: age,
        gender: gender,
        status: status,
        bio: bio,
        interests: interests,
        language: Language,
        longitude: longitude,
        latitude: latitude,
        userName: userName,
        image: image,
        coverImage: coverImage,
      );

      print("Profile Fetch Response: $profile");

      if (profile == null) {
        return false;
      } else {
        // joinedActivitesModel = JoinedActivitesModel.fromJson(profile);
        update(["Profile_update"]);
        return true;
      }
    } catch (e) {
      print("⚠️ Error updating profile: $e");
      return false;
    }
  }

//.......................................Update Location ..........................

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return null;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return null;
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Send location to API
    await ProfileRepository()
        .UpdateLocation(position.latitude, position.longitude);

    return position;
  }

//....................................Update FCM Token ...............................

  Future<void> updateFcmToken() async {
    try {
      // Get the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Send FCM token to the API
      await ProfileRepository().UpdateFCMToken(fcmToken);
      print("FCM Token updated successfully: $fcmToken");
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }

//........................Setup Profile Screen ............................

  Future<bool> setupProfile({
    required int age,
    required String gender,
    required String status,
    required String username,
    required String bio,
    required String country,
    required List<String> interests, // String Array
    required File image, // Single profile image
    required File coverImage, // Cover image
    required double latitude,
    required double longitude,
    required List<String> languages, // String Array
    required String location,
  }) async {
    try {
      final ok = await ProfileRepository().setupProfile(
          age: age,
          gender: gender,
          username: username,
          status: status,
          bio: bio,
          country: country,
          interests: interests,
          image: image,
          coverImage: coverImage,
          latitude: latitude,
          longitude: longitude,
          languages: languages,
          location: location);
      if (ok) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error in profile setup: $e");
      return false;
    }
  }

//...............................Badges.......................

  Future<bool> Badgeslist() async {
    final activity = await ProfileRepository().BadgesList();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      badgesModel = BadgesModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//...............................Badges Claimed.......................

  Future<bool> BadgesClaimed(String id) async {
    final activity = await ProfileRepository().ClaimedBadges(id);
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      // badgesModel = BadgesModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

  //...................... leaderBoard...........................

  Future<bool> LeaderBoard() async {
    final activity = await ProfileRepository().LeaderBoard();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      leaderBoardModel = LeaderBoardModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

  //...................... Notifications...........................

  Future<bool> Notifications() async {
    final activity = await ProfileRepository().Notifications();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      notificationsModel = NotificationsModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

  //...................... Online...........................

  Future<bool> Online() async {
    final activity = await ProfileRepository().Online();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      // notificationsModel = NotificationsModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

  //...................... Offline...........................

  Future<bool> Offline() async {
    final activity = await ProfileRepository().Offline();
    print("Profile Fatch is : $activity");
    if (activity == null) {
      return false;
    } else {
      // notificationsModel = NotificationsModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }
}
