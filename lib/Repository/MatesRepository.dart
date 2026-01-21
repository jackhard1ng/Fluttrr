
import "dart:convert";

import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "../Constants/Apis_Constants.dart";

class Matesrepository{

//......................................Get Mates filter Info................................

  Future<dynamic> GetMates(String parameter) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      print("The token is : $token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Mates).replace(queryParameters: queryParams);
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


//................................... Nearby Mates ..................................
  Future<dynamic> NearbyMates() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      print("The token is : $token");
      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.nearbyMates);
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


//.................................Get Matches mates  .............................
  Future<dynamic> MatesMatchList() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      print("The token is : $token");
      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.MatchMates);
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

  //.................................Get Recently Matches mates  .............................
  Future<dynamic> GetRecentlyMatchesMates() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      print("The token is : $token");

      Map<String,dynamic> queryParams={
        "filterType":"joinRecently"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Mates).replace(queryParameters: queryParams);
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


  //.................................Get Active Matches mates  .............................
  Future<dynamic> GetActiveMatchesMates() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      print("The token is : $token");

      Map<String,dynamic> queryParams={
        "filterType":"recentlyActive"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Mates).replace(queryParameters: queryParams);
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



//................................... ViewByDistance Mates ..................................


  Future<Map<String, dynamic>> ViewByDistance(
      String distance,
      String unit
      ) async {
    // Data to send in the request body
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    print("The token is : $token");
    Map<String, dynamic> requestData = {
      "distance": distance,
      "unit": unit,
    };
    try {
      final response = await http.post(
        Uri.parse(Apis.ViewbyDistance),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Add if required
        },
        body: jsonEncode(requestData),
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


//................................... Filter Mates Nearby ..................................


  Future<Map<String, dynamic>> FilterNearbyMates(
      String ageMin,
      String ageMax,
      String status,
      String gender,
      List language,
      List interests,

      ) async {
    // Data to send in the request body
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    print("The token is : $token");
    Map<String, dynamic> requestData = {
      "ageMin":ageMin,
      "ageMax": ageMax,
      "status": status,
      "gender": gender,
      // "language": language,
      // "interests": interests
    };

    print("the send data : $requestData");
    try {
      final response = await http.post(
        Uri.parse(Apis.NearbyFilter),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Add if required
        },
        body: jsonEncode(requestData),
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


//............................... LIked the mates ..................................

  Future<Map<String, dynamic>> Likedmate(
      String likedid,

      ) async {
    // Data to send in the request body
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    print("The token is : $token");
    Map<String, dynamic> requestData = {
      "likedId":likedid,

    };
    try {
      final response = await http.post(
        Uri.parse(Apis.LikedMate),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Add if required
        },
        body: jsonEncode(requestData),
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