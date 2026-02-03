
import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "../Constants/Apis_Constants.dart";

class ProfileRepository{

//......................................Get Profile Info................................

  Future<dynamic> GetProfile() async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse(Apis.Profile),
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



//.....................................Get Gallery date....................................

  Future<dynamic> GetGallery() async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse(Apis.GalleryList),
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


//...................................Upload Gallery Image.................................

  Future<dynamic> UploadGallery({required String description, File? image,}) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      var uri = Uri.parse(Apis.GalleryUpload); // Adjust API endpoint as needed
      var request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";

      // Adding form fields
      request.fields["description"] = description;
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


  //.....................................Get Total Activites ....................................

  Future<dynamic> GetTotalActivites() async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse(Apis.TotalActivity),
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

  //.....................................Get Total Matches....................................

  Future<dynamic> GetTotalMatches() async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse(Apis.TotalMatch),
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

  //.....................................Get Total joined Activites....................................

  Future<dynamic> GetTotalJoinedActivites() async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse(Apis.JoinedActivites),
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


  //.....................................Get Total MatechsList....................................

  Future<dynamic> GetTotalMatchesList() async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse(Apis.userMatches),
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

  //.....................................Get Total joined Activites List....................................

  Future<dynamic> GetTotalJoinedActivitesList() async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse(Apis.ListJoinedActivites),
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


  //...................................Edite Profile Screen.................................

  Future<dynamic> editProfile({
    required String age,
    required String gender,
    required String status,
    required String bio,
    required List<String> interests,
    required List<String> language, // Renamed to lowercase for consistency
    required String longitude,
    required String latitude,
    required String userName,
    File? image,
    File? coverImage,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      var uri = Uri.parse(Apis.EditeProfile); // Adjust API endpoint as needed
      var request = http.MultipartRequest("PUT", uri);

      request.headers["Authorization"] = "Bearer $token";

      // Adding form fields
      request.fields["age"] = age;
      request.fields["gender"] = gender;
      request.fields["status"] = status;
      request.fields["bio"] = bio;
      request.fields["longitude"] = longitude;
      request.fields["latitude"] = latitude;
      request.fields["userName"] = userName;

      // Sending interests as a normal list (e.g., interests[0]=English, interests[1]=Urdu)
      for (int i = 0; i < interests.length; i++) {
        request.fields["interests[$i]"] = interests[i];
      }

      for (int i = 0; i < language.length; i++) {
        request.fields["Language[$i]"] = language[i];
      }

      // Adding images only if provided
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath("images", image.path));
      } else {
      }

      if (coverImage != null) {
        request.files.add(await http.MultipartFile.fromPath("coverImage", coverImage.path));
      } else {
      }

      // Sending request
      var response = await request.send();

      // Convert StreamedResponse to Readable Response
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody); // Return parsed JSON
      } else {
        return {"error": "Failed to update profile", "status": response.statusCode};
      }
    } catch (e) {
      return {"error": "An error occurred: $e"};
    }
  }



//................................UpdateUser Location............................
  Future<Map<String, dynamic>> UpdateLocation(double latitude, double longitude,) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "latitude":latitude ,
      "longitude":longitude
    };
    try {
      final response = await http.put(
        Uri.parse(Apis.UpdateLocation),
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



//................................Update FCM Token................................


  Future<Map<String, dynamic>> UpdateFCMToken(String fcmToken) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    Map<String, dynamic> requestData = {
      "fcmToken":fcmToken ,

    };
    try {
      final response = await http.post(
        Uri.parse(Apis.UpdateFCMToken),
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


//......................Setup Profile .......................................

  Future<bool> setupProfile({
    required int age,
    required String gender,
    required String status,
    required String username,
    required String bio,
    required String country,
    required List<String> interests,
    required File image,
    required File coverImage,
    required double latitude,
    required double longitude,
    required List<String> languages,
    required String location,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");


      var uri = Uri.parse(Apis.SetupProfile);
      var request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";
      request.headers["Content-Type"] = "multipart/form-data";

      request.fields['age'] = age.toString();
      request.fields['gender'] = gender;
      request.fields['status'] = status;
      request.fields['bio'] = bio;
      request.fields['country'] = country;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['location'] = location;

      // Add interests as array
      for (var interest in interests) {
        request.fields['interests[]'] = interest;
      }

      // Add languages as array
      for (var lang in languages) {
        request.fields['language[]'] = lang;
      }

      request.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'coverImage',
        coverImage.path,
        filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(responseBody);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (e is http.ClientException) {
      }
      return false;
    }
  }




//.......................................ChangePassword............................



  Future<bool> changePassword(String oldPassword, String newPassword) async {
    // Replace with actual API URL

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      final response = await http.put(
        Uri.parse(Apis.changepassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include authentication if required
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


//............................Badges........................................

  Future<dynamic> BadgesList( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.BadgesList);

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


//...........................Claimed Badges...........................

  Future<dynamic> ClaimedBadges (String id,) async {

    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      final response = await http.post(
        Uri.parse(Apis.BadgesVerified),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "achievementId":id,

        }
        ),
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


//..........................LeaderBoard.......................................



  Future<dynamic> LeaderBoard( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.LeaderBoard);

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


//..........................LeaderBoard.......................................



  Future<dynamic> Notifications( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.NotificationScreen);

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




//..........................Online.......................................

  Future<dynamic> Online( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.online);

      final response = await http.put(
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

  //..........................Offline.......................................

  Future<dynamic> Offline( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.offline);

      final response = await http.put(
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


//............................Profile monnitor...............................

  Future<dynamic> GetPercentage() async {

    try {
      SharedPreferences pref=await SharedPreferences.getInstance();
      final token= pref.getString("token");
      final response = await http.get(
        Uri.parse(Apis.percentage),
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
