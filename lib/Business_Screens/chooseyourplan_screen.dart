import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';

import 'choosepaymentmethod_screen.dart';

class ChooseyourplanScreen extends StatefulWidget {
  const ChooseyourplanScreen({super.key});

  @override
  State<ChooseyourplanScreen> createState() => _ChooseyourplanScreenState();
}

class _ChooseyourplanScreenState extends State<ChooseyourplanScreen> {
  bool? isChecked = false;
  int selectedIndex = 0;
  List myPlansImages = [
    'assets/Group 48096193 (1).png',
    'assets/Group 48096194.png',
  ];
  List myPlansPrice = [
    '0',
    '99',
  ];
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
        title: Text('Plans'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                itemCount: 2,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisExtent: 300),
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          width: double.infinity,
                          height: 256,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: GradientBoxBorder(
                                width: 4,
                                gradient: selectedIndex == index
                                    ? lefttorightgradient
                                    : LinearGradient(colors: [
                                        Colors.transparent,
                                        Colors.transparent
                                      ])),
                            color: Color(0xffF1F1F1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              top: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  myPlansImages[index],
                                  height: 90,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/yyy.svg'),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Text(
                                        myPlansPrice[index],
                                        style: TextStyle(
                                            fontSize: 49,
                                            fontWeight: FontWeight.w600,
                                            color: lightBlue),
                                      ),
                                    ),
                                    Text(
                                      '/month',
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      selectedIndex == index
                          ? Container(
                              height: 35,
                              width: 110,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: lefttorightgradient),
                              child: Center(
                                child: Text(
                                  'For Business',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: whiteColor),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              color: Color(0xffF1F1F1),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 20, bottom: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Features',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Post unlimited events',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Featured Spot',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Placement Custom Branding',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Verified Badge',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Free',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SvgPicture.asset('assets/close.svg', height: 22),
                            SizedBox(
                              height: 20,
                            ),
                            SvgPicture.asset('assets/close.svg', height: 22),
                            SizedBox(
                              height: 20,
                            ),
                            SvgPicture.asset('assets/close.svg', height: 22),
                            SizedBox(
                              height: 20,
                            ),
                            SvgPicture.asset('assets/close.svg', height: 22),
                          ],
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Column(
                          children: [
                            Text(
                              'Premium',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SvgPicture.asset('assets/tick.svg'),
                            SizedBox(
                              height: 20,
                            ),
                            SvgPicture.asset('assets/tick.svg'),
                            SizedBox(
                              height: 20,
                            ),
                            SvgPicture.asset('assets/tick.svg'),
                            SizedBox(
                              height: 20,
                            ),
                            SvgPicture.asset('assets/tick.svg'),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      activeColor: lightBlue,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value;
                        });
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'By joining, you agree to our',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            ' privacy policy',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: lightBlue),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'and ',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'terms of service',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: lightBlue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              thickness: 3,
              color: Color(0xffF1F1F1),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Button(
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
                    if (isChecked == false) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.info(
                          message: "please Accept Policy.",
                        ),
                      );
                      return;
                    }
                    Get.to(() => ChoosepaymentmethodScreen());
                  }),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Billed ',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Monthly,',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: lightBlue),
                ),
                Text(
                  ' cancel anytime',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
