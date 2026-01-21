import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Models/MatesFilterModel.dart';
import 'package:fluttrr/Models/MatesListModel.dart';
import 'package:fluttrr/Models/MatesMatchModel.dart';
import 'package:fluttrr/Models/MatesModel.dart';
import 'package:fluttrr/Models/NearbyMates.dart';
import 'package:fluttrr/Models/ViewByDistanceModel.dart';
import 'package:fluttrr/Repository/MatesRepository.dart';

class Matescontroller extends GetxController {
  MatesModel? matesModel;
  NearbyMates? nearbyMates;
  MateListModel? mateListModel;
  ViewByDistanceModel? viewByDistanceModel;
  MatesMatchModel? matesMatchModel;
  MatesFilterModel? matesFilterModel;

//.............................Get Mates .....................

  Future<bool> GetMates(String parameter) async {
    final Mates = await Matesrepository().GetMates(parameter);
    print("Profile Fatch is : $Mates");
    if (Mates == null) {
      return false;
    } else {
      matesModel = MatesModel.fromJson(Mates);
      update(["Profile_update"]);
      return true;
    }
  }

  //.............................Get Nearby Mates.....................

  Future<bool> NearbyMatesMates() async {
    final Mates = await Matesrepository().NearbyMates();
    print("Profile Fatch is : $Mates");
    if (Mates == null) {
      return false;
    } else {
      nearbyMates = NearbyMates.fromJson(Mates);
      update(["Profile_update"]);
      return true;
    }
  }

//.............................Get  Match mates list  .....................

  Future<bool> MatesMatchList() async {
    final Mates = await Matesrepository().MatesMatchList();
    print("Profile Fatch is : $Mates");
    if (Mates == null) {
      return false;
    } else {
      matesMatchModel = MatesMatchModel.fromJson(Mates);
      update(["Profile_update"]);
      return true;
    }
  }

//.............................Get Recently Match mates list  .....................

  Future<bool> MatesMatchRecentlyList() async {
    final Mates = await Matesrepository().GetRecentlyMatchesMates();
    print("Profile Fatch is : $Mates");
    if (Mates == null) {
      return false;
    } else {
      matesMatchModel = MatesMatchModel.fromJson(Mates);
      update(["Profile_update"]);
      return true;
    }
  }

//.............................Get Active  Match mates list  .....................

  Future<bool> MatesMatchActiveList() async {
    final Mates = await Matesrepository().GetActiveMatchesMates();
    print("Profile Fatch is : $Mates");
    if (Mates == null) {
      return false;
    } else {
      matesMatchModel = MatesMatchModel.fromJson(Mates);
      update(["Profile_update"]);
      return true;
    }
  }

  //.............................Get ViewByDistance MatesList .....................

  Future<bool> ViewByDistance(String distance, String unit) async {
    final Mates = await Matesrepository().ViewByDistance(distance, unit);
    print("Profile Fatch is : $Mates");
    viewByDistanceModel = ViewByDistanceModel.fromJson(Mates);
    update(["Profile_update"]);
    return true;
  }

  //.............................Get mateFilter .....................

  Future<bool> MatesFilter(
    String ageMin,
    String ageMax,
    String status,
    String gender,
    List language,
    String interests,
    List Interest,
  ) async {
    final Mates = await Matesrepository()
        .FilterNearbyMates(ageMin, ageMax, status, gender, language, Interest);
    print("Profile Fatch is : $Mates");
    matesFilterModel = MatesFilterModel.fromJson(Mates);
    update(["Profile_update"]);
    return true;
  }

//....................................Liked Mates.........................................

  Future<bool> LikedMates(String Likedid, BuildContext context) async {
    final Mates = await Matesrepository().Likedmate(Likedid);
    print("Profile Fatch is : $Mates");
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: "Liked Successfully ",
      ),
    );
    matesFilterModel = MatesFilterModel.fromJson(Mates);
    update(["Profile_update"]);
    return true;
  }
}
