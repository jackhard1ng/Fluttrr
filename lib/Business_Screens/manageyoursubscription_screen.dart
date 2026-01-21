import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Constants/drawer_screen.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BussinessPageController.dart';

import 'choosepaymentmethod_screen.dart';

class ManageyoursubscriptionScreen extends StatefulWidget {
  const ManageyoursubscriptionScreen({super.key});

  @override
  State<ManageyoursubscriptionScreen> createState() =>
      _ManageyoursubscriptionScreenState();
}

class _ManageyoursubscriptionScreenState
    extends State<ManageyoursubscriptionScreen> {
  BusinessController businessController = Get.put(BusinessController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    businessController.GetBusinessPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerScreen(),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(83),
          child: Businessappbar(
            scaffoldKey: _scaffoldKey,
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: GetBuilder<BusinessController>(
              id: "Activity_update",
              builder: (context) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Your Subscription ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        width: double.infinity,
                        height: 266,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: GradientBoxBorder(
                              width: 3, gradient: lefttorightgradient),
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
                              Text(
                                'Current Plan',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Image.asset(
                                'assets/Group 48096195.png',
                                height: 70,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset('assets/yyy.svg'),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Text(
                                      '99',
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
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffF1F1F1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Billling Date',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Automatically deducted From your account next month.03/24/2025',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffF1F1F1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Billling History',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: 5,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '03/24/2025',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Text(
                                            '\$99/month',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 13),
                                          child: Text(
                                            'Paid',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.green),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GradientText(
                                  'View All ',
                                  colors: [
                                    Color(0xff007BFD),
                                    Color(0xff20235A),
                                  ],
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if (businessController
                                      .businessPageModel?.isPremium ==
                                  true) {
                                await businessController.CancelSubscription();
                                await businessController.GetBusinessPage();
                              } else {
                                Get.to(() => ChoosepaymentmethodScreen());
                              }
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: businessController
                                            .businessPageModel?.isPremium ==
                                        true
                                    ? Color(0xffD90000)
                                    : Colors.green,
                              ),
                              child: Center(
                                child: Text(
                                  businessController
                                              .businessPageModel?.isPremium ==
                                          true
                                      ? 'Cancel Subscription'
                                      : 'Update Subscription',
                                  style: TextStyle(color: whiteColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text('Update Payment Information'),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
