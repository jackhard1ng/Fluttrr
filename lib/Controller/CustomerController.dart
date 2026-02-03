import 'package:get/get.dart';
import 'package:fluttrr/Models/CustomerSupport/GetTickets.dart';
import 'package:fluttrr/Repository/CustomerSupportRepository.dart';

class CustomerController extends GetxController {
  GetTickets? getTickets;
  //................................ Get Tickets...................
  Future<bool> GetTicketss() async {
    final activity = await CustomerSupportRepository().GetTickets();
    print("Profile Fetch is : $activity");
    if (activity == null) {
      return false;
    } else {
      getTickets = GetTickets.fromJson(activity);
      // dailyActivites = DailyActivitesModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }

//..................................SendTickes.......................................

  Future<bool> SendTickets(
    String Complaintype,
    String Des,
  ) async {
    final activity =
        await CustomerSupportRepository().SendTickets(Complaintype, Des);
    print("Profile Fetch is : $activity");
    if (activity == null) {
      return false;
    } else {
      // dailyActivites = DailyActivitesModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }
}
