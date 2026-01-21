import 'package:get/get.dart';
import 'package:fluttrr/Models/MatePrfileViewModel.dart';
import 'package:fluttrr/Repository/ViewProfileRepository.dart';

class Viewprofilecontroller extends GetxController {
  MateProfileViewModel? metaprofile;

//.............................Get the Mateprofile.....................
  Future<bool> GetProfileMates(String id) async {
    final Profile = await Viewprofilerepository().GetProfileMate(id);
    print("Profile Fatch is : $Profile");
    if (Profile == null) {
      return false;
    } else {
      metaprofile = MateProfileViewModel.fromJson(Profile);
      update(["Profile_update"]);
      return true;
    }
  }
}
