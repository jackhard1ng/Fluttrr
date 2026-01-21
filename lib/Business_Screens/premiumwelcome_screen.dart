import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';

import 'chooseyourplan_screen.dart';

class PremiumwelcomeScreen extends StatelessWidget {
  const PremiumwelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0xff4F78DA),
                Color(0xff339003),
              ])),
            )
          ],
        ),
        elevation: 0,
        shadowColor: Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: Icon(
          Icons.arrow_back,
          color: Theme.of(context).primaryColor,
        ),
        title: Text('Premium'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 27,
                  color: Theme.of(context).primaryColor,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  child: Container(
                    height: 9,
                    width: 9,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, gradient: lefttorightgradient),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/pre.png',
                height: 130,
              ),
              SizedBox(
                height: 30,
              ),
              SvgPicture.asset('assets/www.svg'),
              SizedBox(
                height: 20,
              ),
              Text(
                'Unlock Premium Features & Grow Your Business!',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: double.infinity,
                color: Color(0xffF1F1F1),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/Group 48096151.svg'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Post unlimited events',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SvgPicture.asset('assets/Group 48096151 (1).svg'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Featured Spot',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SvgPicture.asset('assets/Group 48096151 (2).svg'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Placement Custom Branding',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SvgPicture.asset('assets/Group 48096151 (3).svg'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Verified Badge',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Button(
                  height: 57,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Text(
                      'Start Your 3 Months-Free Trial',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: whiteColor),
                    ),
                  ),
                  onTap: () {
                    Get.to(() => ChooseyourplanScreen());
                  }),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
