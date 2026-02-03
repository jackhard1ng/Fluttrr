import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Business_Screens/businesscreateprofile_screen.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BusinessPageController.dart';

class WelcomeScreen extends StatelessWidget {
  BusinessController businessController = Get.put(BusinessController());
  WelcomeScreen({super.key});

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
                      padding: const EdgeInsets.symmetric(horizontal: 53),
                      child: Image.asset(
                        'assets/Group 48096138.png',
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    SvgPicture.asset('assets/t (4).svg'),
                    SizedBox(
                      height: 35,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 53),
                      child: Button(
                          width: double.infinity,
                          height: 64,
                          borderRadius: BorderRadius.circular(10),
                          child: Center(
                            child: Text(
                              'Start Free Trial',
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor),
                            ),
                          ),
                          onTap: () async {
                            await businessController.Subscription();
                            Get.to(() => BusinesscreateprofileScreen());
                          }),
                    )
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
