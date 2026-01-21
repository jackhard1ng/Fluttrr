import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Auth_Screens/ForgetOtp.dart';
import 'package:fluttrr/Constants/all_textfields.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Controller/ProfileController.dart';

import '../Controller/AuthenticationController.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
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
                                'Forget Password\nof',
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
                                            .loginemail.text.isNotEmpty) {
                                          final login =
                                              await authenticationController
                                                  .ForgetSendOtp(
                                                      authenticationController
                                                          .loginemail.text);
                                          if (login) {
                                            setState(() {
                                              loading = false;
                                            });

                                            Get.to(Forgetotp(
                                                email: authenticationController
                                                    .loginemail.text));
                                          } else {
                                            setState(() {
                                              loading = false;
                                            });
                                            showTopSnackBar(
                                              Overlay.of(context),
                                              CustomSnackBar.error(
                                                message:
                                                    "User Failed to Sent Verification OTP.",
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
                                        'Forget Now',
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
