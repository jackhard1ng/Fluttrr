

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

import '../Constants/Apis_Constants.dart';

class PrivacyPolicyRepository{

//..........................................Get Privacy Policy.........................

  Future<Map<String, dynamic>> UpdatePrivacyPolicy(
      bool travler,
      bool local,
      bool male,
      bool female,
      bool nonbinary,
      bool everyone,
      bool privatemood,
      double maxrang,
      double minrang
      ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "privacy": {
        "traveller": travler,
        "local": local,
        "male": male,
        "female": female,
        "non_binary": nonbinary,
        "everyone": everyone,
        "private_mode": privatemood,
        "age_range_min": minrang,
        "age_range_max":maxrang
        }

    };
    try {
      final response = await http.put(
        Uri.parse(Apis.UpdatePolicy),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Add if required
        },
        body: jsonEncode(requestData)


      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Return response as Map
      } else {
        return {
          "success": false,
          "statusCode": response.statusCode,
          "message": "Error: ${response.body}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Exception: $e",
      };
    }
  }

//.......................................Get PrivacyPolicy........................

  Future<Map<String, dynamic>> GetPrivacyPolicy() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    try {
      final response = await http.get(
          Uri.parse(Apis.Getprivacy),

          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token", // Add if required
          },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Return response as Map
      } else {
        return {
          "success": false,
          "statusCode": response.statusCode,
          "message": "Error: ${response.body}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Exception: $e",
      };
    }
  }






}