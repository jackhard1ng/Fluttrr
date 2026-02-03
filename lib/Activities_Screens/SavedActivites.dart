import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Activities_Screens/activitiesexplore_screen.dart';
import 'package:fluttrr/Activities_Screens/eventsdetails_screen.dart';
import 'package:fluttrr/Activities_Screens/myactivities_screen.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Constants/utils.dart';

import '../Constants/bottombar.dart';
import '../Constants/button.dart';
import '../Controller/ActivityController.dart';
import 'activities_filters.dart';

class Savedactivites extends StatefulWidget {
  const Savedactivites({super.key});

  @override
  State<Savedactivites> createState() => _SavedactivitesState();
}

class _SavedactivitesState extends State<Savedactivites> {
  ActivityController activityController = Get.put(ActivityController());
  @override
  void initState() {
    super.initState();
    activityController.SaveList();
  }

  final _fromTop = true;

  String formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat("MMMM d, y 'at' h:mm a").format(dateTime);
    } catch (e) {
      return ""; // Return empty string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(75), child: CustomAppbar()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            children: [
              Stack(
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
                                color: lightBlue.withOpacity(0.6),
                                // gradient: lefttorightgradient,
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
                                gradient: lefttorightgradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                  child: Text(
                                'Saved',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
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
                            Get.to(() => MyActivitiesScreen());
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
                            Get.to(() => ActivitiesexploreScreen());
                          },
                          child: SvgPicture.asset(
                            'assets/p.svg',
                            color: Theme.of(context).primaryColor,
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
              SizedBox(
                height: 10,
              ),
              GetBuilder<ActivityController>(
                id: "Activity_update",
                builder: (context) {
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                        activityController.savedEventsResponse?.data?.length ??
                            0,
                    itemBuilder: (BuildContext context, int index) {
                      final name = activityController
                              .savedEventsResponse?.data?[index].name ??
                          "No Name";
                      final location = activityController
                              .savedEventsResponse?.data?[index].location ??
                          "No specific location";
                      final description = activityController
                              .savedEventsResponse?.data?[index].description ??
                          "No Description";
                      final imageList = activityController
                          .savedEventsResponse?.data?[index].image?[0];
                      final image = (imageList != null && imageList.isNotEmpty)
                          ? imageList[0]
                          : "No image";
                      final totalSlots = activityController
                              .savedEventsResponse?.data?[index].totalSlots
                              ?.toString() ??
                          "0";
                      final date = activityController
                              .savedEventsResponse?.data?[index].dateTime
                              ?.toString() ??
                          "0";
                      final paid = activityController
                          .savedEventsResponse?.data?[index].eventType;
                      final remainingSlots = activityController
                              .savedEventsResponse?.data?[index].remainingSlots
                              ?.toString() ??
                          "0";
                      final id = activityController
                              .savedEventsResponse?.data?[index].id
                              ?.toString() ??
                          "0";
                      final eventid = activityController
                              .savedEventsResponse?.data?[index].id
                              ?.toString() ??
                          "0";
                      final join = activityController
                          .savedEventsResponse?.data?[index].userJoined;
                      final creatoriamge = activityController
                          .savedEventsResponse
                          ?.data?[index]
                          .creator
                          ?.profileImage?[0]
                          .toString();

                      print("the every card with name $name is id has : $id");
                      // print("the join event : $join");

                      return InkWell(
                        onTap: () {
                          Get.to(() => EventsdetailsScreen(
                                id: id,
                                datetime: date,
                                event: paid == null ? false : true,
                                joined: join == true ? true : false,
                                like: false,
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 13),
                          child: Stack(
                            children: [
                              // Background Image with Dark Overlay
                              Container(
                                width: double.infinity,
                                height: 183,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage("${Apis.ip}$imageList"),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black.withOpacity(
                                        0.4), // Dark overlay for readability
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 27,
                                            backgroundImage: NetworkImage(
                                                "${Apis.ip}$creatoriamge"),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 170,
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 7),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      'assets/pin.svg',
                                                      height: 14),
                                                  SizedBox(width: 7),
                                                  SizedBox(
                                                    width: 160,
                                                    child: Text(
                                                      location,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                formatDateTime(date),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff00D4BD),
                                                ),
                                              ),
                                              SizedBox(height: 3),
                                              SizedBox(
                                                width: 279,
                                                child: Text(
                                                  description,
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 26,
                                                width: 26,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xff5A5A5A),
                                                ),
                                                child: Center(
                                                  child: Icon(Icons.add,
                                                      size: 26,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 7),
                                              Text(
                                                '${int.parse(totalSlots) - int.parse(remainingSlots)}/$totalSlots Joined',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          activityController
                                                      .savedEventsResponse
                                                      ?.data?[index]
                                                      .userJoined ==
                                                  true
                                              ? _buildButton(
                                                  "Joined", Colors.green)
                                              : Row(
                                                  children: [
                                                    _buildButton(
                                                        "Skip", Colors.black54),
                                                    SizedBox(width: 10),
                                                    InkWell(
                                                        onTap: () async {
                                                          bool event =
                                                              paid == null
                                                                  ? false
                                                                  : true;
                                                          // final iD =paid==null? id:eventid;
                                                          print(
                                                              "The event is : $event");
                                                          alertBox(id, event);
                                                        },
                                                        child:
                                                            _buildButtonWithIcon(
                                                                "Join",
                                                                Color(
                                                                    0xff007BFD))),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Paid / Free Badge
                              paid == null
                                  ? SizedBox()
                                  : Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        height: 23,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 13),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(7)),
                                          gradient: lefttorightgradient,
                                        ),
                                        child: Center(
                                          child: Text(
                                            paid.toString(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                              // Icons on Top-Right
                              Positioned(
                                top: 13,
                                right: 13,
                                child: Row(
                                  children: [
                                    _buildIcon('assets/Group 48095897.svg'),
                                    SizedBox(width: 16),
                                    _buildIcon('assets/Group 48095896.svg'),
                                    SizedBox(width: 16),
                                    InkWell(
                                        onTap: () async {
                                          await activityController
                                              .saveActivity(id);
                                        },
                                        child: _buildIcon('assets/Group.svg')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color) {
    return Container(
      height: 21,
      width: 49,
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
      height: 21,
      width: 57,
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

  Widget _buildIcon(String assetPath) {
    return SvgPicture.asset(assetPath, height: 21);
  }

  void confirmJoinalertBox(String id, bool event) {
    ActivityController activityController = Get.put(ActivityController());
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
                                  onTap: activityController.decrementCounter,
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
                                  '${activityController.counter.value}',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                InkWell(
                                  onTap: activityController.incrementCounter,
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
                              'the send slots are : ${activityController.counter.value}');
                          await activityController.joinActivity(
                              id, activityController.counter.toString());
                          await activityController.ActivitieList();
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
                                  await activityController.joinEvent(id);
                                  await activityController.ActivitieList();
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
}
