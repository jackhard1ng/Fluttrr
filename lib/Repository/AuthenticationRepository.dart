import "dart:convert";
import "package:google_sign_in/google_sign_in.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "package:fluttrr/Constants/Apis_Constants.dart";

class AuthenticationRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        "174536441327-4e2qvue78msm6ehab4s4mlf3imvaerkq.apps.googleusercontent.com",
  );

  //................................. Login User ......................................
  Future<dynamic> LoginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Apis.Login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("token", data["token"]);
        return data;
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }

  //................................. Send OTP ......................................

  Future<dynamic> SendOtp(
      String userName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Apis.sendotp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"userName": userName, "email": email, "password": password}),
      );
      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }

//...........................................Verify Otp............................

  Future<dynamic> VerifyOtp(String otp, String email) async {
    try {
      final response = await http.post(
        Uri.parse(Apis.verifyotp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"otp": otp, "email": email}),
      );
      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }

//...................................... Change-Password......................

  Future<dynamic> ChangePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(Apis.changepassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"oldPassword": oldPassword, "newPassword": newPassword}),
      );
      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }

//...................................... Google Auth ...........................

  Future<dynamic> Google_Auth(
    String id,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(Apis.verifyotp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": id}),
      );
      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Google Sign-In canceled.");
        return null;
      }

      // Obtain authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        print("Failed to retrieve ID Token.");
        return null;
      }

      // Pass the ID token to your backend authentication method
      print("Google ID Token: ${googleAuth.idToken}");
      return await Google_Auth(googleAuth.idToken!);
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

//............................ForgetPassword.....................................

  Future<dynamic> ForgetPassword(String newPassword, String conPassword) async {
    try {
      final response = await http.post(
        Uri.parse(Apis.ForgetPassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"newPassword": newPassword, "confirmPassword": conPassword}),
      );
      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }

//................................. Send OTP ......................................

  Future<dynamic> ForgetSendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse(Apis.ForgetSendOTp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
        }),
      );
      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }

//...........................................Verify Otp............................

  Future<dynamic> ForgetVerifyOtp(String otp, String email) async {
    try {
      final response = await http.post(
        Uri.parse(Apis.ForgetVerifyOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"otp": otp, "email": email}),
      );
      print("Status code : ${response.statusCode}");
      print("api response : ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Api Failed Status code : ${response.statusCode}");
        print("Api Failed response : ${response.body}");
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in POST: $e");
      return null;
    }
  }
}
