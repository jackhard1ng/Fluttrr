import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fluttrr/Activities_Screens/SavedActivites.dart';
import 'package:fluttrr/Activities_Screens/activities_filters.dart';
import 'package:fluttrr/Activities_Screens/myactivities_screen.dart';
import 'package:fluttrr/Constants/bottombar.dart';
import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Constants/utils.dart';

import '../Constants/Apis_Constants.dart';
import '../Constants/button.dart';
import '../Controller/AcitivityController.dart';
import 'MapViewScreen.dart';

class ActivitiesexploreScreen extends StatefulWidget {
  const ActivitiesexploreScreen({super.key});

  @override
  State<ActivitiesexploreScreen> createState() =>
      _ActivitiesexploreScreenState();
}

class _ActivitiesexploreScreenState extends State<ActivitiesexploreScreen> {
  Acitivitycontroller acitivitycontroller = Get.put(Acitivitycontroller());
  final _fromTop = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acitivitycontroller.ActivitieList();
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime =
        DateTime.parse(dateTimeString).toLocal(); // Convert to local time
    String formattedDate = DateFormat("MMMM d, y 'at' h:mm a").format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(75), child: CustomAppbar()),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 106),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.to(() => BottomBar(screen: 2));
                            },
                            child: Container(
                              height: 39,
                              width: 100,
                              decoration: BoxDecoration(
                                gradient: lefttorightgradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: Text(
                                'Explore',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor),
                              )),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(() => MyActivitiesScreen());
                            },
                            child: Container(
                              height: 39,
                              width: 100,
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: Text(
                                'Created',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Get.to(() => Savedactivites());
                            },
                            child: Container(
                              height: 39,
                              width: 100,
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: Text(
                                'Saved',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 39,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => BottomBar(screen: 2));
                          },
                          child: SvgPicture.asset(
                            'assets/Group 48095856.svg',
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(
                          width: 14,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => ActivityMapScreen());
                          },
                          child: SvgPicture.asset(
                            'assets/Group 48095880.svg',
                            color: Theme.of(context).primaryColor,
                            height: 21,
                          ),
                        ),
                        SizedBox(
                          width: 14,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => ActivitiesFilters());
                          },
                          child: SvgPicture.asset(
                            'assets/d.svg',
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: SizedBox(
                  height: 410,
                  width: double.infinity,
                  child: CardSwiper(
                      cardsCount:
                          acitivitycontroller.activityListModel?.data?.length ??
                              0,
                      cardBuilder: (context, index, percentThresholdX,
                          percentThresholdY) {
                        final name = acitivitycontroller
                                .activityListModel?.data?[index].name ??
                            "No Name";
                        final location = acitivitycontroller
                                .activityListModel?.data?[index].location ??
                            "No specific location";
                        final description = acitivitycontroller
                                .activityListModel?.data?[index].description ??
                            "No Description";
                        final imageList = acitivitycontroller
                            .activityListModel?.data?[index].image;
                        final image =
                            (imageList != null && imageList.isNotEmpty)
                                ? imageList[0]
                                : "No image";
                        final totalSlots = acitivitycontroller
                                .activityListModel?.data?[index].totalSlots
                                ?.toString() ??
                            "0";
                        final date = acitivitycontroller
                                .activityListModel?.data?[index].dateTime
                                ?.toString() ??
                            "0";
                        final paid = acitivitycontroller
                                .activityListModel?.data?[index].eventType ??
                            "Free";
                        final remainingSlots = acitivitycontroller
                                .activityListModel?.data?[index].remainingSlots
                                ?.toString() ??
                            "0";
                        final id = acitivitycontroller
                                .activityListModel?.data?[index].activityId
                                ?.toString() ??
                            "0";
                        final eventid = acitivitycontroller
                                .activityListModel?.data?[index].eventId
                                ?.toString() ??
                            "0";
                        final join = acitivitycontroller
                            .activityListModel?.data?[index].userJoined;
                        final creatorimage = acitivitycontroller
                            .activityListModel?.data?[index].creatorImage[0]
                            .toString();
                        return Container(
                          width: double.infinity,
                          height: 410,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                "${Apis.ip}$image",
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black.withOpacity(
                                  0.4), // Dark overlay for readability
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/Group 48095897.svg',
                                        height: 21,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      SvgPicture.asset(
                                        'assets/Group 48095896.svg',
                                        height: 21,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      SvgPicture.asset(
                                        'assets/Group.svg',
                                        height: 21,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 13, right: 13, bottom: 13),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 33,
                                            backgroundImage: NetworkImage(
                                                "${Apis.ip}${creatorimage.toString()}"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 170,
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/pin.svg',
                                                    height: 14,
                                                  ),
                                                  SizedBox(
                                                    width: 7,
                                                  ),
                                                  SizedBox(
                                                    width: 180,
                                                    child: Text(
                                                      location,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    formatDateTime(date),
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xff00D4BD)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        description,
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    height: 33,
                                                    width: 33,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Color(0xff5A5A5A)),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 30,
                                                        color: whiteColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 7,
                                              ),
                                              Text(
                                                '${int.parse(totalSlots) - int.parse(remainingSlots)}/$totalSlots Joined',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: whiteColor),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 13,
                                      ),
                                      acitivitycontroller.activityListModel
                                                  ?.data?[index].userJoined ==
                                              true
                                          ? Row(
                                              children: [
                                                InkWell(
                                                    onTap: () async {
                                                      await acitivitycontroller
                                                          .LeaveEvent(eventid);
                                                      await acitivitycontroller
                                                          .ActivitieList();
                                                    },
                                                    child: _buildButton(
                                                        "Leave", Colors.red)),
                                                SizedBox(width: 10),
                                                InkWell(
                                                    onTap: () async {},
                                                    child: _buildButtonWithIcon(
                                                        "Joined",
                                                        Colors.green)),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 37,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      color: Colors.black54),
                                                  child: Center(
                                                    child: Text(
                                                      'Skip',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: whiteColor),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 13,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    bool event = paid == null
                                                        ? false
                                                        : true;
                                                    final iD = paid == null
                                                        ? id
                                                        : eventid;
                                                    print(
                                                        "The event is : $event");
                                                    alertBox(iD, event);
                                                  },
                                                  child: Container(
                                                    height: 37,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        color:
                                                            Color(0xff007BFD)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Join',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  whiteColor),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        SvgPicture.asset(
                                                            'assets/Group 48096111.svg')
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  void confirmJoinalertBox(String id, bool event) {
    Acitivitycontroller acitivitycontroller = Get.put(Acitivitycontroller());
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: Offset(0, -1),
            end: Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 400),
      barrierColor: Colors.black.withOpacity(0.6),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(13.0)),
                  color: Theme.of(context).cardColor,
                ),
                width: 430,
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close),
                          ),
                        ],
                      ),
                      Text(
                        'How many people are joining?',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 13),
                      Text(
                        "Joining alone? Just leave it at 1. Adjust if you're bringing company!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 19),
                      Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xffD9D9D9),
                        ),
                        child: Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: acitivitycontroller.decrementCounter,
                                  child: Container(
                                    height: 56,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors
                                          .blue, // Change to match your theme
                                    ),
                                    child: Center(
                                      child: Text(
                                        '-1',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${acitivitycontroller.counter.value}',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                InkWell(
                                  onTap: acitivitycontroller.incrementCounter,
                                  child: Container(
                                    height: 56,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors
                                          .blue, // Change to match your theme
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+1',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(height: 19),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                          minimumSize: Size(170, 43),
                        ),
                        onPressed: () async {
                          print(
                              'the send slots are : ${acitivitycontroller.counter.value}');
                          await acitivitycontroller.joinActivity(
                              id, acitivitycontroller.counter.toString());
                          await acitivitycontroller.ActivitieList();
                          Navigator.pop(
                              context); // Close dialog after confirming
                        },
                        child: Text(
                          'Confirm & Join',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 19),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  alertBox(String id, bool event) {
    showGeneralDialog(
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(
                    begin: Offset(0, _fromTop ? -1 : 1),
                    end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        barrierColor: Colors.black.withOpacity(0.6),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Dialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                // backgroundColor: Colors.black,
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(13.0)),
                        color: Theme.of(context).cardColor),
                    width: 430,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.close))
                              ],
                            ),
                            Text(
                              'Activity Conformation',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 13,
                            ),
                            Text(
                              "We're thrilled to have you as well as any guests, if any, join us for this activity. Enjoy this event!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 19,
                            ),
                            Button(
                              borderRadius: BorderRadius.circular(9),
                              height: 43,
                              width: 170,
                              onTap: () async {
                                if (event) {
                                  print("the event call is success");
                                  await acitivitycontroller.joinEvent(id);
                                  await acitivitycontroller.ActivitieList();
                                } else {
                                  confirmJoinalertBox(id, event);
                                }
                              },
                              child: Center(
                                  child: event
                                      ? Text(
                                          'Join Event',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        )
                                      : Text(
                                          'Join Activity',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        )),
                            ),
                            SizedBox(
                              height: 19,
                            ),
                          ]),
                    )));
          });
        });
  }

  Widget _buildButton(String text, Color color) {
    return Container(
      height: 40,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildButtonWithIcon(String text, Color color) {
    return Container(
      height: 40,
      width: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(width: 5),
          SvgPicture.asset('assets/Group 48096111.svg'),
        ],
      ),
    );
  }
}
