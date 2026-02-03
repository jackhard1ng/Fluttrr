import 'package:get/get.dart';
import 'package:fluttrr/Models/CutomerSupport/GetTickets.dart';
import 'package:fluttrr/Repository/CustomerSupportRespository.dart';

class CustomerController extends GetxController {
  GetTickets? getTickets;
  //................................ Get Tickets...................
  Future<bool> GetTicketss() async {
    final activity = await CustomerSupportRespostory().GetTickets();
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
        await CustomerSupportRespostory().SendTickets(Complaintype, Des);
    if (activity == null) {
      return false;
    } else {
      // dailyActivites = DailyActivitesModel.fromJson(activity);
      update(["Activity_update"]);
      return true;
    }
  }
}
