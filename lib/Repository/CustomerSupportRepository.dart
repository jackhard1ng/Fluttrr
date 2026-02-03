

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import '../Constants/Apis_Constants.dart';

class CustomerSupportRepository{

  //......................................Get Tickets ................................

  Future<dynamic> GetTickets() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      print("The token is : $token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Compalin);
      print("The URl is : $uri");

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("Status code : ${response.statusCode}");
      print("API response : ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("API Failed Status code : ${response.statusCode}");
        print("API Failed response : ${response.body}");
        throw Exception("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in GET: $e");
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
      print("The token is : $token");

      Map<String,dynamic> senddata={
        "complaint_type": Complaintype,
        "description": Des,
        "date": DateTime.now().toString(),
        "status": "open"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Compalin);
      print("The URl is : $uri");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(senddata)
      );

      print("Status code : ${response.statusCode}");
      print("API response : ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("API Failed Status code : ${response.statusCode}");
        print("API Failed response : ${response.body}");
        throw Exception("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in GET: $e");
      return null;
    }
  }


}