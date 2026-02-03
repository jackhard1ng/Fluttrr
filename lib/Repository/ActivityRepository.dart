
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "../Constants/Apis_Constants.dart";

class Activityrepository{

//......................................Get Daily Activites ................................

  Future<dynamic> GetDailyActivites() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.dailyactivities);

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


//...........................Get activity List...................................

  Future<dynamic> ActivityList() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.ActivityList);

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



//...........................Create Activity.................................

  Future<dynamic> CreateActivity({
    required File image,
    required String name,
    required String longitude,
    required String Latitude,
    required String description,
    required String totalslots,
    required String time,
    required String date,
    required String Location,
    required String totaltime,

  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      var uri = Uri.parse(Apis.CreateActivity);
      var request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";
      // request.headers["Authorization"] = "Bearer $token";

      // Adding form fields
      request.fields["name"] = name;
      request.fields["longitude"] = longitude;
      request.fields["latitude"] = Latitude;
      request.fields["description"] = description;
      request.fields["totalSlots"] = totalslots;
      request.fields["slots"] = totalslots;
      request.fields["date_time"] = date;
      request.fields["location"] = Location;
      request.fields["total_time"] = totaltime;

      // Adding the image file
      request.files.add(await http.MultipartFile.fromPath("images", image.path));

      // Sending request
      var response = await request.send();

      // Convert StreamedResponse to Readable Response
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody); // Return parsed JSON
      } else {
        return {"error": "Failed to upload recipe", "status": response.statusCode};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }


//.......................................Update Activity.........................

  Future<dynamic> PutActivity({
    required String activityId, // ID of the activity to update
    File? image, // Image is optional
    required String name,
    required String longitude,
    required String latitude,
    required String description,
    required String totalslots,
    required String time,
    required String date,
    required String location,
    required String totaltime,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      var uri = Uri.parse("${Apis.UpdateActivity}/$activityId"); // Adjust API endpoint as needed
      var request = http.MultipartRequest("PUT", uri);

      request.headers["Authorization"] = "Bearer $token";

      // Adding form fields
      request.fields["name"] = name;
      request.fields["longitude"] = longitude;
      request.fields["latitude"] = latitude;
      request.fields["description"] = description;
      request.fields["totalSlots"] = totalslots;
      // request.fields["time"] = time;
      request.fields["date_time"] = date;
      request.fields["location"] = location;
      request.fields["total_time"] = totaltime;

      // Adding image only if provided
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath("images", image.path));
      } else {
      }

      // Sending request
      var response = await request.send();

      // Convert StreamedResponse to Readable Response
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody); // Return parsed JSON
      } else {
        return {"error": "Failed to update activity", "status": response.statusCode};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }









//...................................Activity Details.............................

  Future<dynamic> ActivityDetails(String id) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      // Map<String,dynamic> queryParams={
      //   "filterType":"all"
      // };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse("${Apis.DetailActivity}/$id");

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

//...................................Event Details.............................

  Future<dynamic> EventDetails(String id) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      // Map<String,dynamic> queryParams={
      //   "filterType":"all"
      // };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse("${Apis.EventDetails}/$id");

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



  //...................................My  Activity .............................

  Future<dynamic> MyActivity() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      // Map<String,dynamic> queryParams={
      //   "filterType":"all"
      // };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.MyActivity);

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

//............................... Join Activity ..................................

  Future<Map<String, dynamic>> JoinActivity(String activityid, String gusts) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "activityIDs": activityid,
      "guests": gusts
    };
    try {
      final response = await http.post(
        Uri.parse(Apis.joinActivity),
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

//............................... Join Event ..................................

  Future<Map<String, dynamic>> JoinEvent(String eventid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "event_id": eventid,
    };
    try {
      final response = await http.post(
        Uri.parse(Apis.joinEvent),
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

  //............................... Save Activity ..................................

  Future<Map<String, dynamic>> SaveActivity(String activityid,) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {};
    try {
      final response = await http.post(
        Uri.parse("${Apis.saveActivity}/$activityid"),
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

  //............................... Save Event ..................................

  Future<Map<String, dynamic>> SaveEvent(String Eventid,) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {};
    try {
      final response = await http.post(
        Uri.parse("${Apis.saveEvent}/$Eventid"),
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


  //................................... saveList .............................

  Future<dynamic> saveList() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      // Map<String,dynamic> queryParams={
      //   "filterType":"all"
      // };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.saveList);

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Data fetched successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        return jsonDecode(response.body);
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch data. (${response.body})",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        throw Exception("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }


//.................................Filter Activities.......................................


  Future<Map<String, dynamic>> FilterActivity(String Name, String date,String time,String range) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "name": Name,
      "date":date,
      "range":range
    };
    try {
      final response = await http.post(
        Uri.parse(Apis.FilterActivites),
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

//............................... Join Event ..................................

  Future<Map<String, dynamic>> LeaveActivies(String Activityid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "activityIDs": Activityid,
    };
    try {
      final response = await http.post(
        Uri.parse(Apis.LeaveActivites),
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

//............................... Join Event ..................................

  Future<Map<String, dynamic>> LeaveEvent(String eventid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "event_id": eventid,
    };
    try {
      final response = await http.post(
        Uri.parse(Apis.LeaveEvent),
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

//............................... Delete Activity ..................................

  Future<Map<String, dynamic>> DeleteActivity(String Activityid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "event_id": Activityid,
    };
    try {
      final response = await http.delete(
        Uri.parse("${Apis.DeleteActivity}/$Activityid"),
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




//......................................UpComming Activities  ................................

  Future<dynamic> GetUpcomingActivites() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.UpcomingActivity);

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

//....................................Follow BusinessPage.........................
  Future<Map<String, dynamic>> FollowBusiness(String bussinessid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");

    try {
      final response = await http.post(
        Uri.parse("${Apis.followBusiness}/$bussinessid"),
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

  //.......................................UnFollow Busniesspage........................

  Future<Map<String, dynamic>> unFollowBusiness(String bussinessid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");

    try {
      final response = await http.post(
        Uri.parse("${Apis.unfollowbusiness}/$bussinessid"),
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
//.........................................EventClicks................................
  Future<Map<String, dynamic>> CLickFollowBusiness(String eventid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "event_id": eventid,
    };
    try {
      final response = await http.put(
        Uri.parse("${Apis.eventClicks}/$eventid/click"),
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

 //........................................EventViews...............................
  Future<Map<String, dynamic>> ViewFollowBusiness(String eventid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "event_id": eventid,
    };
    try {
      final response = await http.put(
        Uri.parse("${Apis.eventview}/$eventid/view"),
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
