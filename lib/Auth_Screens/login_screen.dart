import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Auth_Screens/ForgotScreen.dart';
import 'package:fluttrr/Auth_Screens/register_screen.dart';
import 'package:fluttrr/Constants/all_textfields.dart';
import 'package:fluttrr/Constants/bottombar.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Controller/ProfileController.dart';
import 'package:fluttrr/ProfileScreens/ProfileSetupScreen.dart';

import '../Controller/AuthenticationController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());
  ProfileController profileController = Get.put(ProfileController());
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 95, left: 35, right: 35),
                          child: Column(
                            children: [
                              Text(
                                'Welcome back\nto',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 36,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Image.asset(
                                'assets/logo (2).png',
                                height: 70,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Email Or Username',
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
                                hintText: 'Enter Your Email Or Username',
                                controller: authenticationController.loginemail,
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
                                hintText: 'Enter Your Password',
                                controller:
                                    authenticationController.loginpassword,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Get.to(() => ForgotScreen());
                                    },
                                    child: Text(
                                      'Forgot your Password?',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff4F78DA)),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              loading
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
                                          loading = true;
                                        });
                                        if (authenticationController
                                                .loginemail.text.isNotEmpty ||
                                            authenticationController
                                                .loginpassword
                                                .text
                                                .isNotEmpty) {
                                          final login =
                                              await authenticationController
                                                  .LoginUser(
                                                      authenticationController
                                                          .loginemail.text,
                                                      authenticationController
                                                          .loginpassword.text);
                                          if (login) {
                                            setState(() {
                                              loading = false;
                                            });
                                            final profile =
                                                await profileController
                                                    .GetProfile();
                                            if (profile) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          BottomBar(
                                                              screen: 0)));
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProfileSetupScreen()));
                                            }
                                            showTopSnackBar(
                                              Overlay.of(context),
                                              CustomSnackBar.success(
                                                message:
                                                    "User Login Successfull.",
                                              ),
                                            );
                                          } else {
                                            setState(() {
                                              loading = false;
                                            });
                                            showTopSnackBar(
                                              Overlay.of(context),
                                              CustomSnackBar.error(
                                                message:
                                                    "User Failed to Login.",
                                              ),
                                            );
                                          }
                                        } else {
                                          showTopSnackBar(
                                            Overlay.of(context),
                                            CustomSnackBar.info(
                                              message:
                                                  "All Fields are required.",
                                            ),
                                          );
                                        }
                                      },
                                      child: const Center(
                                          child: Text(
                                        'Login',
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      )),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Color(0xff027FAB).withOpacity(0.3),
                            ),
                          ),
                          Text("  Or Signup With  "),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Color(0xff027FAB).withOpacity(0.3),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      spacing: 30,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            authenticationController.GoogleAuth();
                          },
                          child: Container(
                            height: 50,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 5)
                                ],
                                shape: BoxShape.circle),
                            child: Center(
                                child: Image.asset(
                              "assets/google logo.png",
                              height: 30,
                              width: 30,
                            )),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ],
                              shape: BoxShape.circle),
                          child: Center(
                              child: Image.asset(
                            "assets/Group.png",
                            height: 30,
                            width: 30,
                          )),
                        ),
                        Container(
                          height: 50,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ],
                              shape: BoxShape.circle),
                          child: Center(
                              child: Image.asset(
                            "assets/Vector (1).png",
                            height: 30,
                            width: 30,
                          )),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Not register yet ?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterScreen(),
                                    ));
                              },
                              child: Text(
                                ' Create Account',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff4F78DA)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
