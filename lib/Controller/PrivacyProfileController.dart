import 'package:get/get.dart';
import 'package:fluttrr/Models/PrivacyModel.dart';
import 'package:fluttrr/Repository/PrivacyPolicy.dart';

class Privacyprofilecontroller extends GetxController {
  privacyModel? Privacymodel;

//.............................Update Privacy..................................

  Future<bool> UpdatePrivacy(
      bool travler,
      bool local,
      bool male,
      bool female,
      bool nonbinary,
      bool everyone,
      bool privatemood,
      double maxrang,
      double minrang) async {
    final Profile = await PrivacyPolicyRepository().UpdatePrivacyPolicy(
        travler,
        local,
        male,
        female,
        nonbinary,
        everyone,
        privatemood,
        maxrang,
        minrang);
    print("Profile Fetch is : $Profile");
    // profile = profileModel.fromJson(Profile);
    update(["Profile_update"]);
    return true;
  }

//..............................Get Privacy...............................................

  Future<bool> GetPrivacy() async {
    final Profile = await PrivacyPolicyRepository().GetPrivacyPolicy();
    print("Profile Fetch is : $Profile");
    Privacymodel = privacyModel.fromJson(Profile);
    update(["Profile_update"]);
    return true;
  }
}
