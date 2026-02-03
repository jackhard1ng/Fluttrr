
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/Apis_Constants.dart';
import "package:http/http.dart" as http;

class BusinessRepository{

  //................................. Send OTP ......................................

  Future<dynamic> SendOtp(String email ) async {

    try {
      final response = await http.post(
        Uri.parse(Apis.RequestOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,

        }
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }else if(response.statusCode == 400){

      } else {
        throw Exception("Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }


//...........................................Verify Otp............................

  Future<dynamic> VerifyOtp (String otp,String email) async {

    try {
      final response = await http.post(
        Uri.parse(Apis.RequestVerify),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "otp":otp,
          "email":email
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

//......................................... Create Event..................................

  Future<dynamic> createEvent({
    required String businessId,
    required String name,
    required String dateTime,
    required String endTime,
    required String eventPrivacy,
    required String attendeesLimit,
    required String latitude,
    required String longitude,
    required String details,
    required String eventType,
    required String ticketingWebsite,
    required String price,
    required String location,
    required File images,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      var uri = Uri.parse(Apis.CreateEvent);
      var request = http.MultipartRequest("POST", uri);

      request.headers["Authorization"] = "Bearer $token";
      // Add fields
      request.fields['business_id'] = businessId;
      request.fields['name'] = name;
      request.fields['date_time'] = dateTime;
      request.fields['end_time'] = dateTime;
      request.fields['event_privacy'] = eventPrivacy;
      request.fields['attendees_limit'] = attendeesLimit;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      request.fields['details'] = details;
      request.fields['event_type'] = eventType;
      request.fields['ticketing_website'] = ticketingWebsite;
      request.fields['price'] = "0.00";
      request.fields['location'] = location;

      // Attach multiple images
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          images.path,
          filename: images.path.split('/').last,
        ),
      );

      // Set headers
      request.headers.addAll({"Content-Type": "multipart/form-data"});

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }

//......................................... Create Business page...................................

  Future<dynamic> createBusinessPage({
    required String name,
    required String description,
    required String email,
    required String phoneNumber,
    required String websiteLink,
    required String facebookLink,
    required String instagramLink,
    required File logo,
    required File image,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      var uri = Uri.parse(Apis.CreateBusinessProfile);
      var request = http.MultipartRequest("POST", uri);
      request.headers["Authorization"] = "Bearer $token";
      // Add fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['email'] = email;
      request.fields['phoneNumber'] = phoneNumber;
      request.fields['website_link'] = websiteLink;
      request.fields['facebook_link'] = facebookLink;
      request.fields['instagram_link'] = instagramLink;

      // Attach files
      request.files.add(await http.MultipartFile.fromPath("logos", logo.path));
      request.files.add(await http.MultipartFile.fromPath("images", image.path));

      // Set headers
      request.headers.addAll({"Content-Type": "multipart/form-data"});

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }


//........................................Created Event Details.................................................
  Future<dynamic> MyEvents() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.GetCreatedEvent);

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




//.......................................... Get All Created Events....................................




//.............................Get My Bussiness Page Screen.................................

  Future<dynamic> GetDailyActivites() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.GetBusinessPage);

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



//...................................Edite Business page..............................

  Future<dynamic> EditeBusinessPage({
    required String id,
    required String name,
    required String description,
    required String email,
    required String phoneNumber,
    required String websiteLink,
    required String facebookLink,
    required String instagramLink,
    File? logo,
    File? image,
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      var uri = Uri.parse("${Apis.UpdateBussinessPage}$id");

      var request = http.MultipartRequest("PUT", uri);
      request.headers["Authorization"] = "Bearer $token";

      // Add form fields
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['email'] = email;
      request.fields['phoneNumber'] = phoneNumber;
      request.fields['website_link'] = websiteLink;
      request.fields['facebook_link'] = facebookLink;
      request.fields['instagram_link'] = instagramLink;

      // Attach files if provided
      if (logo != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'logo',
            logo.path,

          ),
        );
      } else {
      }

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,

          ),
        );
      } else {
      }

      // Set headers
      request.headers.addAll({"Content-Type": "multipart/form-data"});

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }



//...........................Edite Event ..........................................

  Future<dynamic> EditeEvent({
    required String id,
    required String businessId,
    required String name,
    required String dateTime,
    required String endTime,
    required String eventPrivacy,
    required String attendeesLimit,
    required String latitude,
    required String longitude,
    required String details,
    required String eventType,
    required String ticketingWebsite,
    required String price,
    required String location,
    File? images, // Made nullable
  }) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      var uri = Uri.parse("${Apis.EditeEvent}$id");
      var request = http.MultipartRequest("PUT", uri); // Changed to PUT

      request.headers["Authorization"] = "Bearer $token";

      // Add fields
      request.fields['business_id'] = businessId;
      request.fields['name'] = name;
      request.fields['date_time'] = dateTime;
      request.fields['end_time'] = endTime; // Fixed: Previously using dateTime instead of endTime
      request.fields['event_privacy'] = eventPrivacy;
      request.fields['attendees_limit'] = attendeesLimit;
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      request.fields['details'] = details;
      request.fields['event_type'] = eventType;
      request.fields['ticketing_website'] = ticketingWebsite;
      request.fields['price'] = price;
      request.fields['location'] = location;

      // Attach image only if it is not null
      if (images != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            images.path,
            filename: images.path.split('/').last,
          ),
        );
      }

      // Set headers
      request.headers.addAll({"Content-Type": "multipart/form-data"});

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }


//....................................Get Bussiness Analytics ....................


  Future<dynamic> GetBusinessAnalytics() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Analytics);

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


//.........................................Get Event Details ......................

  Future<dynamic> GetEventdetials( String id) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse("${Apis.MYEventDetails}$id");

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


//...........................Subscription.....................................

  Future<dynamic> SubsCription( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.Subscription);

      final response = await http.post(
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

//...........................Cancel Subscription.....................................

  Future<dynamic> CancelSubsCription( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.CancelSubscription);

      final response = await http.post(
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


  //...........................Business Status.....................................

  Future<dynamic> BusinessStatusCheck( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.BusinessStatus);

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

  //...........................Top Events .....................................

  Future<dynamic> TopEvent( ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> queryParams={
        "filterType":"all"
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.TopEvents);

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



//............................... BusinessChats............................................
  Future<dynamic> StartBusinessChatSend(
      String senderid,
      String businesid,
      String message
      ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      Map<String,dynamic> date={
        "senderId":senderid,
        "businessId":businesid,
        "message":message,
      };

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.StartBusinesschat);

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(date)
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

//...............................BusinessChatList.........................................

  Future<dynamic> BusinessChatList(String id,String type) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");

      // Constructing the URI with query parameters
      Uri uri = Uri.parse(Apis.GetBusinessChats).replace(queryParameters: {
        "id": id,
        "type":type
      });

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







}
