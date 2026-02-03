import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/bottombar.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BusinessPageController.dart';

import '../Business_Screens/analytics_screen.dart';
import '../Business_Screens/businessevents_screen.dart';
import '../Business_Screens/businessmessages_screen.dart';
import '../Business_Screens/choosepaymentmethod_screen.dart';
import '../Business_Screens/manageyoursubscription_screen.dart';
import '../Business_Screens/profileviewabout_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  BusinessController businessController = Get.put(BusinessController());

  @override
  void initState() {
    super.initState();
    businessController.GetBusinessPage();
    businessController.GetMYEvents();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // padding: EdgeInsets.zero,
                children: [
                  Column(
                    children: [
                      DrawerHeader(
                        margin: EdgeInsets.zero,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(17),
                              bottomRight: Radius.circular(17)),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(() => ProfileviewaboutScreen());
                          },
                          child: GetBuilder<BusinessController>(
                              id: "Activity_update",
                              builder: (_) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: NetworkImage(
                                            '${Apis.ip}${businessController.businessPageModel?.profile?.logo.toString()}',
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${businessController.businessPageModel?.profile?.name.toString()}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    SvgPicture.asset(
                                      'assets/Group 48095973.svg',
                                      height: 17,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  ],
                                );
                              }),
                        ),
                      ),
                      Divider(
                        thickness: 17,
                        color: Color(0xff4F78DA),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ListTile(
                        minTileHeight: 10,
                        leading: SvgPicture.asset(
                          'assets/event.svg',
                          height: 25,
                        ),
                        title: const Text(
                          'Events',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BusinesseventsScreen()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      ListTile(
                        minTileHeight: 10,
                        leading: SvgPicture.asset(
                          'assets/ana.svg',
                          height: 21,
                        ),
                        title: const Text(
                          'Analytics',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AnalyticsScreen()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      ListTile(
                        minTileHeight: 10,
                        leading: SvgPicture.asset(
                          'assets/Group 48096142.svg',
                          height: 24,
                        ),
                        title: const Text(
                          'Messages',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BusinessmessagesScreen2()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      ListTile(
                        minTileHeight: 10,
                        leading: SvgPicture.asset(
                          'assets/Group 48096146.svg',
                          height: 20,
                        ),
                        title: const Text(
                          'Manage Subscriptions',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ManageyoursubscriptionScreen()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      ListTile(
                        minTileHeight: 10,
                        leading: SvgPicture.asset(
                          'assets/Group 48096146 (1).svg',
                          height: 21,
                        ),
                        title: const Text(
                          'Payment Method',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChoosepaymentmethodScreen()));
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 23,
                      ),
                      GetBuilder<BusinessController>(
                          id: "Activity_update",
                          builder: (_) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Image.asset(
                                    'assets/Group 48096144.png',
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                  ),
                                  Positioned(
                                    top: 37,
                                    left: 0,
                                    right: 0,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Current Plan',
                                          style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        businessController.businessPageModel
                                                    ?.isPremium ==
                                                true
                                            ? Text(
                                                'Premium',
                                                style: TextStyle(
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff339003)),
                                              )
                                            : Text(
                                                'Free',
                                                style: TextStyle(
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xff339003)),
                                              ),
                                        businessController.businessPageModel
                                                    ?.isPremium ==
                                                true
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 30),
                                                child: Text(
                                                  'Enjoy the 1 month Unlimited Business Features',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              )
                                            : GetBuilder<BusinessController>(
                                                id: "Activity_update",
                                                builder: (controller) {
                                                  final current = controller
                                                          .businessEventListModel
                                                          ?.currentEvents
                                                          ?.length ??
                                                      0;
                                                  final past = controller
                                                          .businessEventListModel
                                                          ?.pastEvents
                                                          ?.length ??
                                                      0;
                                                  final live = controller
                                                          .businessEventListModel
                                                          ?.expiredEvents
                                                          ?.length ??
                                                      0;
                                                  final upcoming = controller
                                                          .businessEventListModel
                                                          ?.upcomingEvents
                                                          ?.length ??
                                                      0;

                                                  final total = current +
                                                      past +
                                                      live +
                                                      upcoming;

                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 30),
                                                    child: Text(
                                                      'You have $total/3 free events left this month.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                      ],
                                    ),
                                  ),
                                  businessController
                                              .businessPageModel?.isPremium ==
                                          true
                                      ? SizedBox()
                                      : Container(
                                          height: 50,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                              ),
                                              color: Color(0xff20235A)),
                                          child: Center(
                                            child: Image.asset(
                                                'assets/Upgrade Premium.png'),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          }),
                      SizedBox(
                        height: 23,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: InkWell(
                          onTap: () {
                            Get.offAll(() => BottomBar(screen: 4));
                          },
                          child: Container(
                            width: double.infinity,
                            height: 61,
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Back To App',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
