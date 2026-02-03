import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Repository/AuthenticationRepository.dart';

class AuthenticationController extends GetxController {
  //..........................Signup.......................................
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController Confermpassword = TextEditingController();
//..........................Login ..........................................
  TextEditingController loginemail = TextEditingController();
  TextEditingController loginpassword = TextEditingController();

//.................................Login User.................................
  Future<bool> LoginUser(String email, String password) async {
    final LoginUser =
        await AuthenticationRepository().LoginUser(email, password);
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
    if (ForgotPassword == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }

//...............................google Auth............................

  Future<bool> GoogleAuth() async {
    final Google = await AuthenticationRepository().signInWithGoogle();
    return true;
  }

  //.................................Reset Password User.................................
  Future<bool> ResetPassword(String oldPassword, String newPassword) async {
    final ForgotPassword = await AuthenticationRepository()
        .ForgetPassword(oldPassword, newPassword);
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
    if (VerifyOtp == null) {
      return false;
    } else {
      // menutypeModel=MenutypeModel.fromJson(Menutype);
      return true;
    }
  }
}
