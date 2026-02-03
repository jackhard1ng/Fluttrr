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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("token", data["token"]);
        return data;
      } else {
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
      } else {
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      // Obtain authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return null;
      }

      // Pass the ID token to your backend authentication method
      return await Google_Auth(googleAuth.idToken!);
    } catch (e) {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
      } else {
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to post data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }
}
