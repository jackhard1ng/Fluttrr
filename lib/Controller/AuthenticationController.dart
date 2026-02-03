import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Repository/AuthenticationRepository.dart';

class AuthenticationController extends GetxController {
  //..........................Signup.......................................
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
//..........................Login ..........................................
  TextEditingController loginemail = TextEditingController();
  TextEditingController loginpassword = TextEditingController();

  @override
  void onClose() {
    username.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    loginemail.dispose();
    loginpassword.dispose();
    super.onClose();
  }

//.................................Login User.................................
  Future<bool> LoginUser(String email, String password) async {
    final LoginUser =
        await AuthenticationRepository().LoginUser(email, password);
    print("LoginUser Fetch is : $LoginUser");
    if (LoginUser == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//.................................SendOtp User.................................
  Future<bool> SendOtp(String userName, String email, String password) async {
    final SendOtp =
        await AuthenticationRepository().SendOtp(userName, email, password);
    print("SendOtp Fetch is : $SendOtp");
    if (SendOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//.................................VerifyOtp User.................................
  Future<bool> VerifyOtp(String otp, String email) async {
    final VerifyOtp = await AuthenticationRepository().VerifyOtp(otp, email);
    print("VerifyOtp Fetch is : $VerifyOtp");
    if (VerifyOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

  //.................................Login User.................................
  Future<bool> ForgotPassword(String oldPassword, String newPassword) async {
    final ForgotPassword = await AuthenticationRepository()
        .ChangePassword(oldPassword, newPassword);
    print("ForgotPassword Fetch is : $ForgotPassword");
    if (ForgotPassword == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//...............................google Auth............................

  Future<bool> GoogleAuth() async {
    final result = await AuthenticationRepository().signInWithGoogle();
    print("Google signin is : $result");
    if (result == null) {
      return false;
    } else {
      return true;
    }
  }

  //.................................Reset Password User.................................
  Future<bool> ResetPassword(String oldPassword, String newPassword) async {
    final ForgotPassword = await AuthenticationRepository()
        .ForgetPassword(oldPassword, newPassword);
    print("ForgotPassword Fetch is : $ForgotPassword");
    if (ForgotPassword == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

  //.................................ForgetSendOtp User.................................
  Future<bool> ForgetSendOtp(String email) async {
    final SendOtp = await AuthenticationRepository().ForgetSendOtp(email);
    print("SendOtp Fetch is : $SendOtp");
    if (SendOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//.................................ForgetVerifyOtp User.................................
  Future<bool> ForgetVerifyOtp(String otp, String email) async {
    final VerifyOtp =
        await AuthenticationRepository().ForgetVerifyOtp(otp, email);
    print("VerifyOtp Fetch is : $VerifyOtp");
    if (VerifyOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }
}
