
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
      print("The token is :$token");
      final response = await http.get(
        Uri.parse("${Apis.MateProfile}/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization":"Bearer $token"
        },
      );
      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception("Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }








}