

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import '../Constants/Apis_Constants.dart';

class CustomerSupportRespostory{

  //......................................Get Tickets ................................

  Future<dynamic> GetTickets() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Compalin);

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }


  //......................................send Tickets ................................

  Future<dynamic> SendTickets(
      String Complaintype,
      String Des,

      ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> senddata={
        "complaint_type": Complaintype,
        "description": Des,
        "date": DateTime.now().toString(),
        "status": "open"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Compalin);

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(senddata)
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }


}
