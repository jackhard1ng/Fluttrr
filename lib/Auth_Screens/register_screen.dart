import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Auth_Screens/login_screen.dart';
import 'package:fluttrr/Auth_Screens/otp_screen.dart';
import 'package:fluttrr/Constants/all_textfields.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Controller/AuthenticationController.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());
  final _formKey = GlobalKey<FormState>();

  bool? isChecked = false;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/Vector 151 (1).png',
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/Vector 150.png'),
                  Image.asset('assets/Vector 149.png'),
                ],
              )
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 95, left: 35, right: 35),
              child: Column(
                children: [
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Image.asset(
                    'assets/logo (2).png',
                    height: 70,
                  ),
                  SizedBox(
                    height: 23,
                  ),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Join TripMates and turn every journey into a story of unforgettable connections and shared adventures!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(
                    height: 23,
                  ),
                  Row(
                    children: [
                      Text(
                        'Username',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  TextFields(
                    hintText: 'Enter your username',
                    controller: authenticationController.username,
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  Row(
                    children: [
                      Text(
                        'Your email',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  TextFields(
                    hintText: 'Enter your email',
                    controller: authenticationController.email,
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  Row(
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  TextFields_Passwords(
                    hintText: 'Enter your Password',
                    controller: authenticationController.password,
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  Row(
                    children: [
                      Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  TextFields_Passwords(
                    hintText: 'Enter your confirm password',
                    controller: authenticationController.Confermpassword,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          side: BorderSide(color: Colors.green, width: 1.5),
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value;
                            });
                          },
                        ),
                      ),
                      Text(
                        'I accept the terms and privacy policy',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  isloading
                      ? Center(
                          child: GradientProgressIndicator(
                            radius: 17,
                            duration: 3,
                            strokeWidth: 5,
                            backgroundColor: Colors.white,
                            gradientStops: const [
                              0.2,
                              0.7,
                              0.3,
                              0.3,
                            ],
                            gradientColors: const [
                              Color(0xff4F78DA),
                              Color(0xff339003),
                              Color(0xff4F78DA),
                              Colors.white
                            ],
                            child: Text(''),
                          ),
                        )
                      : Button(
                          borderRadius: BorderRadius.circular(70),
                          height: 64,
                          width: double.infinity,
                          onTap: () async {
                            setState(() {
                              isloading = true;
                            });

                            print(authenticationController.username.text);
                            print(authenticationController.email.text);
                            print(authenticationController.password.text);
                            print(
                                authenticationController.Confermpassword.text);

                            if (authenticationController.username.text.isEmpty ||
                                authenticationController.email.text.isEmpty ||
                                authenticationController
                                    .password.text.isEmpty ||
                                authenticationController
                                    .Confermpassword.text.isEmpty) {
                              setState(() {
                                isloading = false;
                              });
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.info(
                                  message: "All fields are required.",
                                ),
                              );
                            } else if (authenticationController.password.text !=
                                authenticationController.Confermpassword.text) {
                              setState(() {
                                isloading = false;
                              });
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.info(
                                  message:
                                      "Password and Confirm Password do not match.",
                                ),
                              );
                            } else {
                              if (isChecked == false) {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.info(
                                    message: "Please accept the policy.",
                                  ),
                                );
                                setState(() {
                                  isloading = false;
                                });
                                return; // ✅ This is important to stop the operation
                              }

                              final sendOtp =
                                  await authenticationController.SendOtp(
                                authenticationController.username.text,
                                authenticationController.email.text,
                                authenticationController.password.text,
                              );

                              if (!sendOtp) {
                                setState(() {
                                  isloading = false;
                                });
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.error(
                                    message:
                                        "Failed to send OTP. Please try again.",
                                  ),
                                );
                              } else {
                                setState(() {
                                  isloading = false;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtpScreen(
                                      email:
                                          authenticationController.email.text,
                                      password: authenticationController
                                          .password.text,
                                      username: authenticationController
                                          .username.text,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Get.offAll(() => LoginScreen());
                        },
                        child: Text(
                          '  Log in',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff4F78DA)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 45,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
