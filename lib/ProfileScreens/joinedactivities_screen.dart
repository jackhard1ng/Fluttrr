import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fluttrr/Controller/ProfileController.dart';

import '../Activities_Screens/eventsdetails_screen.dart';
import '../Constants/Apis_Constants.dart';
import '../Controller/ActivityController.dart';

class JoinedactivitiesScreen extends StatefulWidget {
  const JoinedactivitiesScreen({super.key});

  @override
  State<JoinedactivitiesScreen> createState() => _JoinedactivitiesScreenState();
}

class _JoinedactivitiesScreenState extends State<JoinedactivitiesScreen> {
  ProfileController profileController = Get.put(ProfileController());
  ActivityController activityController = Get.put(ActivityController());
  @override
  void initState() {
    super.initState();
    profileController.JoinedActivitesList();
  }

  String formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat("MMMM d, y 'at' h:mm a").format(dateTime);
    } catch (e) {
      return ""; // Return empty string if parsing fails
    }
  }

  final _fromTop = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: InkWell(
      //   onTap: () {
      //     Get.to(() => CreateactivityScreen());
      //   },
      //   child: Container(
      //     height: 70,
      //     width: 70,
      //     decoration: BoxDecoration(
      //         color: Colors.blue,
      //         shape: BoxShape.circle,
      //         gradient: LinearGradient(colors: [
      //           Color(0xff007BFD),
      //           Color(0xff20235A),
      //         ])
      //     ),
      //     child: Center(
      //       child: GradientText(
      //         'Create',
      //         colors: [
      //           Color(0xfffaf8f8),
      //           Color(0xffffffff),
      //         ],
      //         style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      //       ),
      //     ),
      //   ),
      // ),
      appBar: AppBar(
        title: Text("Total Activites"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: GetBuilder<ProfileController>(
              id: "Profile_update",
              builder: (_) {
                return Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GetBuilder<ActivityController>(
                      id: "Activity_update",
                      builder: (context) {
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: profileController
                                  .joinedActivitesModel?.activities?.length ??
                              0,
                          itemBuilder: (BuildContext context, int index) {
                            final name = profileController.joinedActivitesModel
                                    ?.activities?[index].name ??
                                "No Name";
                            final location = profileController
                                    .joinedActivitesModel
                                    ?.activities?[index]
                                    .location ??
                                "No specific location";
                            final description = profileController
                                    .joinedActivitesModel
                                    ?.activities?[index]
                                    .description ??
                                "No Description";
                            final imageList = profileController
                                .joinedActivitesModel?.activities?[index].image;
                            final image =
                                (imageList != null && imageList.isNotEmpty)
                                    ? imageList[0]
                                    : "No image";
                            final totalSlots = profileController
                                    .joinedActivitesModel
                                    ?.activities?[index]
                                    .slot
                                    .toString() ??
                                "0";
                            final date = profileController.joinedActivitesModel
                                    ?.activities?[index].dateTime
                                    ?.toString() ??
                                "0";
                            // final time =  activityController.myActivityModel?.activities?[index].time?.toString() ?? "0";
                            // final paid = activityController.myActivityModel?.activities?[index].;
                            final remainingSlots = profileController
                                    .joinedActivitesModel
                                    ?.activities?[index]
                                    .remainingSlots
                                    ?.toString() ??
                                "0";
                            final id = profileController.joinedActivitesModel
                                    ?.activities?[index].activityId
                                    ?.toString() ??
                                "0";

                            return InkWell(
                              onTap: () {
                                Get.to(() => EventsdetailsScreen(
                                      id: id,
                                      event: false,
                                      datetime: date,
                                      joined: false,
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
                                          image:
                                              NetworkImage("${Apis.ip}$image"),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.black.withOpacity(
                                              0.4), // Dark overlay for readability
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 27,
                                                  backgroundImage: AssetImage(
                                                      "assets/Group 48095849.png"),
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
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
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
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xff00D4BD),
                                                      ),
                                                    ),
                                                    SizedBox(height: 3),
                                                    SizedBox(
                                                      width: 279,
                                                      child: Text(
                                                        description,
                                                        style: TextStyle(
                                                            fontSize: 9,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: 26,
                                                      width: 26,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Color(0xff5A5A5A),
                                                      ),
                                                      child: Center(
                                                        child: Icon(Icons.add,
                                                            size: 26,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    SizedBox(width: 7),
                                                    Text(
                                                      '${int.parse(totalSlots) - int.parse(remainingSlots)}/$totalSlots Joined',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                        onTap: () async {
                                                          await activityController
                                                              .LeaveActivity(
                                                                  id);
                                                          await activityController
                                                              .ActivitieList();
                                                        },
                                                        child: _buildButton(
                                                            "Leave",
                                                            Colors.red)),
                                                    SizedBox(width: 10),
                                                    InkWell(
                                                        onTap: () async {},
                                                        child:
                                                            _buildButtonWithIcon(
                                                                "Joined",
                                                                Colors.green)),
                                                  ],
                                                )
                                                // Row(
                                                //   children: [
                                                //     _buildButton("Skip", Colors.black54),
                                                //     SizedBox(width: 10),
                                                //     _buildButtonWithIcon("Join", Color(0xff007BFD)),
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Paid / Free Badge
                                    // Positioned(
                                    //   top: 0,
                                    //   left: 0,
                                    //   child: Container(
                                    //     height: 23,
                                    //     padding: const EdgeInsets.symmetric(horizontal: 13),
                                    //     decoration: BoxDecoration(
                                    //       borderRadius: BorderRadius.only(topLeft: Radius.circular(7)),
                                    //       gradient: lefttorightgradient,
                                    //     ),
                                    //     child: Center(
                                    //       child: Text(
                                    //         paid,
                                    //         style: TextStyle(
                                    //           fontSize: 11,
                                    //           fontWeight: FontWeight.bold,
                                    //           color: Colors.white,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),

                                    // Icons on Top-Right
                                    Positioned(
                                      top: 13,
                                      right: 13,
                                      child: Row(
                                        children: [
                                          _buildIcon(
                                              'assets/Group 48095897.svg'),
                                          SizedBox(width: 16),
                                          _buildIcon(
                                              'assets/Group 48095896.svg'),
                                          SizedBox(width: 16),
                                          _buildIcon('assets/Group.svg'),
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
                );
              }),
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
}
