import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Controller/AuthenticationController.dart';

import 'SetNewPassword.dart';

class Forgetotp extends StatefulWidget {
  final String email;

  const Forgetotp({
    super.key,
    required this.email,
  });

  @override
  State<Forgetotp> createState() => _ForgetotpState();
}

class _ForgetotpState extends State<Forgetotp> {
  AuthenticationController controller = Get.put(AuthenticationController());
  bool isloading = false;
  int countdown = 0;
  Timer? timer;

  void startCountdown() {
    setState(() {
      countdown = 60; // Start countdown from 60 seconds
    });

    timer?.cancel(); // Cancel any existing timer
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel timer when screen is disposed
    super.dispose();
  }

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 95),
                      child: Column(
                        children: [
                          Text(
                            'Enter OTP Code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            'Enter the 6-digit code sent to\n${widget.email}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 19),
                          OtpTextField(
                            mainAxisAlignment: MainAxisAlignment.center,
                            cursorColor: Colors.blue,
                            enabledBorderColor:
                                const Color.fromRGBO(158, 158, 158, 1),
                            margin: const EdgeInsets.all(2.5),
                            borderWidth: 1,
                            borderRadius: BorderRadius.circular(50),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            numberOfFields: 6,
                            fieldHeight: 45,
                            enabled: true,
                            filled: true,
                            fillColor: Colors.white,
                            disabledBorderColor: Colors.grey,
                            showFieldAsBox: true,
                            fieldWidth: 45,
                            onSubmit: (String verificationCode) async {
                              print("the send opt is : $verificationCode");
                              setState(() {
                                isloading = true;
                              });
                              final otp = await controller.ForgetVerifyOtp(
                                  verificationCode, widget.email);
                              if (otp) {
                                Get.to(() => ResetPaswordScreen());
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.success(
                                    message:
                                        "OTP Verified successfully. Please try to login.",
                                  ),
                                );
                              } else {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.error(
                                    message: "Failed to Verify OTP.",
                                  ),
                                );
                              }
                              setState(() {
                                isloading = false;
                              });
                            },
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            "Didn't get a code?",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: countdown == 0
                                    ? () async {
                                        startCountdown();
                                        final login =
                                            await controller.ForgetSendOtp(
                                                widget.email);
                                        if (login) {
                                          showTopSnackBar(
                                            Overlay.of(context),
                                            CustomSnackBar.error(
                                              message: "OTP Sent to Email..",
                                            ),
                                          );
                                        } else {
                                          showTopSnackBar(
                                            Overlay.of(context),
                                            CustomSnackBar.error(
                                              message:
                                                  "User Failed to Sent Verification OTP.",
                                            ),
                                          );
                                        }
                                      }
                                    : null, // Disable button if countdown is active
                                child: Text(
                                  countdown > 0
                                      ? 'Resend in $countdown sec'
                                      : 'Resend Code',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: countdown > 0
                                        ? Colors.grey
                                        : const Color(0xff4F78DA),
                                  ),
                                ),
                              ),
                              const Text(
                                '  | ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff4F78DA),
                                ),
                              ),
                              TextButton(
                                onPressed: countdown == 0
                                    ? () async {
                                        startCountdown();
                                        // Implement Resend Via Text functionality here
                                      }
                                    : null,
                                child: Text(
                                  'Resend Via Text',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: countdown > 0
                                        ? Colors.grey
                                        : const Color(0xff4F78DA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: Button(
                              borderRadius: BorderRadius.circular(70),
                              height: 64,
                              width: double.infinity,
                              onTap: () {
                                Get.back();
                              },
                              child: const Center(
                                child: Text(
                                  'Change Email',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
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
