
import "dart:convert";

import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "../Constants/Apis_Constants.dart";

class Viewprofilerepository{

//......................................Get Mates profile Info................................

  Future<dynamic> GetProfileMate( String id
      ) async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse("${Apis.MateProfile}/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":"Bearer $token"
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }








}
