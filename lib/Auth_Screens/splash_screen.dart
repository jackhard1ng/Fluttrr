import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_progress_indicator/widget/gradient_progress_indicator_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttrr/Auth_Screens/login_screen.dart';
import 'package:fluttrr/Constants/bottombar.dart';

import '../Controller/ProfileController.dart';
import '../ProfileScreens/ProfileSetupScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ProfileController profileController = Get.put(ProfileController());
  Timer? timer;

  @override
  void initState() {
    timer = Timer(const Duration(seconds: 3), () async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      final token = pref.getString("token");
      if (token == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        final profile = await profileController.GetProfile();
        if (profile) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BottomBar(screen: 0)));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfileSetupScreen()));
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/Vector 151 (1).png',
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo (2).png',
                scale: 2.3,
              ),
              SizedBox(
                height: 17,
              ),
              GradientProgressIndicator(
                radius: 21,
                duration: 3,
                strokeWidth: 7,
                backgroundColor: Colors.white,
                gradientStops: const [
                  0.2,
                  0.7,
                  0.3,
                  0.3,
                ],
                gradientColors: const [
                  Color(0xff007BFD),
                  Color(0xff20235A),
                  Color(0xff007BFD),
                  Colors.white
                ],
                child: Text(''),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/Vector 150.png'),
              Image.asset(
                'assets/Group 48096196 (1).png',
                width: 190,
              ),
              Image.asset('assets/Vector 149.png'),
            ],
          )
        ],
      ),
    );
  }
}
