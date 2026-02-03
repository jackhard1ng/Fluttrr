import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fluttrr/Activities_Screens/comments_screen.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/bottombar.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/BusinessPageController.dart';
import 'package:fluttrr/Controller/ProfileController.dart';

import '../Constants/button.dart';
import '../Controller/ActivityController.dart';

class EventsdetailsScreen extends StatefulWidget {
  final String id;
  final bool event;
  final bool like;
  final String datetime;
  final bool joined;
  const EventsdetailsScreen(
      {super.key,
      required this.id,
      required this.event,
      required this.datetime,
      required this.joined,
      required this.like});

  @override
  State<EventsdetailsScreen> createState() => _EventsdetailsScreenState();
}

class _EventsdetailsScreenState extends State<EventsdetailsScreen> {
  ActivityController activityController = Get.put(ActivityController());
  BusinessController businessController = Get.put(BusinessController());
  ProfileController profileController = Get.put(ProfileController());
  final _fromTop = true;

  @override
  void initState() {
    super.initState();
    profileController.GetProfile();
    if (widget.event) {
      activityController.EventDetails(widget.id);
      activityController.ViewFollowBusiness(widget.id);
      activityController.CLickFollowBusiness(widget.id);
    } else {
      activityController.ActivitieDetails(widget.id);
    }
  }

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
    print(
        "The data for the both : ${activityController.eventModel?.dateTime}");
    return Scaffold(
      body: SingleChildScrollView(
        child: GetBuilder<ActivityController>(
            id: "Activity_update",
            builder: (_) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 66, left: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Text(
                          'Events Details',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 23,
                  ),
                  Container(
                    width: double.infinity,
                    height: 290,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            '${Apis.ip}${activityController.eventModel?.images?[0].toString()}'),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(21.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                'assets/Group 48095897.svg',
                                height: 21,
                                color:
                                    widget.like ? Colors.green : Colors.white,
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
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDateTime(widget.datetime),
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xff339003),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${activityController.eventModel?.totalTime.toString()} ',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: lightBlue),
                                ),
                                SvgPicture.asset(
                                  'assets/timer.svg',
                                  color: lightBlue,
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          '${activityController.eventModel?.name.toString()}',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/pin.svg',
                              height: 13,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              '${activityController.eventModel?.location.toString()}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: lightBlue,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          '${activityController.eventModel?.description.toString()}',
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        // Text(
                        //   ' 50 View · 15 Interested ',
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     color: Theme.of(context).indicatorColor,
                        //   ),
                        // ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 17),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.purple,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 34),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 53),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  ' ${(activityController.eventModel?.totalSlots ?? 0) - (activityController.eventModel?.remainingSlots ?? 0)}/${activityController.eventModel?.totalSlots.toString()} Joined',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            widget.joined
                                ? Container(
                                    height: 30,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.green),
                                    child: Center(
                                      child: Text(
                                        'Joined',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: whiteColor),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      alertBox(widget.id, widget.event);
                                    },
                                    child: Container(
                                      height: 30,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: lightBlue),
                                      child: Center(
                                        child: Text(
                                          'Join Now',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: whiteColor),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(
                          height: 19,
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => CommentsScreen(
                                  id: widget.id,
                                  event: widget.event,
                                ));
                          },
                          child: Container(
                            height: 41,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffF1F1F1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/Group 48096093.svg'),
                                Text(
                                  ' Comments',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: discriptionColor),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 6,
                    color: Color(0xffF1F1F1),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  widget.event == false
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Text(
                                'Meet Host',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                  widget.event == false
                      ? SizedBox()
                      : SizedBox(
                          height: 10,
                        ),
                  widget.event == false
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Color(0xffF1F1F1), width: 3)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 17),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 119,
                                        width: 119,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Color(0xffF1F1F1),
                                                width: 3)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(9.0),
                                          child: Image.network(
                                              '${Apis.ip}${activityController.eventModel?.businessProfile?.logo.toString()}'),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${activityController.eventModel?.businessProfile?.name.toString()}',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${activityController.eventModel?.businessProfile?.totalEventsCreated.toString()} Past Events | ${activityController.eventModel?.businessProfile?.totalFollowers.toString()} followers',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .indicatorColor),
                                          ),
                                          SizedBox(
                                            width: 203,
                                            child: Text(
                                              '${activityController.eventModel?.businessProfile?.description.toString()}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Theme.of(context)
                                                      .indicatorColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final follow = activityController
                                                  .eventModel
                                                  ?.businessProfile
                                                  ?.isFollowedByCurrentUser ??
                                              false;

                                          if (follow) {
                                            await activityController
                                                .unFollowBusiness(
                                                    activityController
                                                            .eventModel
                                                            ?.businessProfile
                                                            ?.id
                                                            .toString() ??
                                                        "");
                                            await activityController
                                                .EventDetails(widget.id);
                                          } else {
                                            await activityController
                                                .FollowBusiness(
                                                    activityController
                                                            .eventModel
                                                            ?.businessProfile
                                                            ?.id
                                                            .toString() ??
                                                        "");
                                            await activityController
                                                .EventDetails(widget.id);
                                          }
                                        },
                                        child: Container(
                                          height: 33,
                                          width: 110,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: activityController
                                                        .eventModel
                                                        ?.businessProfile
                                                        ?.isFollowedByCurrentUser ==
                                                    true
                                                ? Colors.green
                                                : lightBlue,
                                          ),
                                          child: Center(
                                            child: Text(
                                              activityController
                                                          .eventModel
                                                          ?.businessProfile
                                                          ?.isFollowedByCurrentUser ==
                                                      true
                                                  ? 'Following'
                                                  : 'Follow',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: whiteColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 17,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          await businessController
                                              .StartBusinessChats(
                                                  profileController
                                                          .profile?.userId
                                                          .toString() ??
                                                      "",
                                                  activityController.eventModel
                                                          ?.businessProfile?.id
                                                          .toString() ??
                                                      "",
                                                  "Hallo!");
                                          Get.offAll(
                                              () => BottomBar(screen: 3));
                                        },
                                        child: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Color(0xffF1F1F1),
                                                    width: 3)),
                                            child: SvgPicture.asset(
                                                'assets/cha.svg')),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  widget.event == false
                      ? SizedBox()
                      : SizedBox(
                          height: 30,
                        ),
                ],
              );
            }),
      ),
    );
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
