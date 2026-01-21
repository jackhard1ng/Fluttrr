import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fluttrr/Business_Screens/EditeEventScreen.dart';
import 'package:fluttrr/Business_Screens/createevent_screen.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Constants/drawer_screen.dart';
import 'package:fluttrr/Controller/BussinessPageController.dart';

import '../Models/BussinessModel/BusinessEventListModel.dart';
import 'businesseventdetails_screen.dart';

class BusinesseventsScreen extends StatefulWidget {
  const BusinesseventsScreen({super.key});

  @override
  State<BusinesseventsScreen> createState() => _BusinesseventsScreenState();
}

class _BusinesseventsScreenState extends State<BusinesseventsScreen> {
  BusinessController businessController = Get.put(BusinessController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  List<String> events = [
    'Live Events',
    'Upcoming Events',
    'Past Events',
    'Expired Events',
  ];

  @override
  void initState() {
    super.initState();
    businessController.GetMYEvents();
  }

  List<Event>? getCurrentEventsList() {
    switch (selectedIndex) {
      case 0:
        return businessController.businessEventListModel?.currentEvents;
      case 1:
        return businessController.businessEventListModel?.upcomingEvents;
      case 2:
        return businessController.businessEventListModel?.pastEvents;
      case 3:
        return businessController.businessEventListModel?.expiredEvents;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerScreen(),
      floatingActionButton: InkWell(
        onTap: () {
          Get.to(() => const CreateeventScreen());
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [
                Color(0xff007BFD),
                Color(0xff20235A),
              ])),
          child: Center(
            child: GradientText(
              'Create',
              colors: const [
                Color(0xfffaf8f8),
                Color(0xffffffff),
              ],
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(83),
          child: Businessappbar(
            scaffoldKey: _scaffoldKey,
          )),
      body: Obx(() {
        if (businessController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: GetBuilder<BusinessController>(
                id: "Activity_update",
                builder: (context) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Events',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // SvgPicture.asset('assets/gha.svg')
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(events.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 19),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: selectedIndex == index
                                    ? GradientText(
                                        events[index],
                                        colors: const [
                                          Color(0xff007BFD),
                                          Color(0xff20235A),
                                        ],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        events[index],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildEventsList(),
                    ],
                  );
                }),
          ),
        );
      }),
    );
  }

  Widget _buildEventsList() {
    final eventsList = getCurrentEventsList();

    if (eventsList == null || eventsList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            'No ${events[selectedIndex]} Found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: eventsList.length,
      itemBuilder: (BuildContext context, int index) {
        final event = eventsList[index];
        return InkWell(
          onTap: () {
            Get.to(() => BusinesseventdetailsScreen(
                  id: event.eventId.toString(),
                  event: event,
                ));
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 13, left: 20, right: 20),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 183,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          NetworkImage("${Apis.ip}${event.image.toString()}"),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 27,
                              backgroundImage: NetworkImage(
                                  '${Apis.ip}${event.creatorImage.toString()}'),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 170,
                                  child: Text(
                                    event.name ?? 'No Name',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/pin.svg',
                                      height: 14,
                                    ),
                                    const SizedBox(width: 7),
                                    SizedBox(
                                      width: 160,
                                      child: Text(
                                        event.location ?? 'No Location',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      event.dateTime != null
                                          ? '${_formatDate(event.dateTime!)}, '
                                          : 'No Date, ',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff00D4BD),
                                      ),
                                    ),
                                    Text(
                                      event.dateTime != null
                                          ? 'at ${_formatTime(event.dateTime!)}'
                                          : 'No Time',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff00D4BD),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                SizedBox(
                                  width: 279,
                                  child: Text(
                                    event.description ?? 'No Description',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: 26,
                                      width: 26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xff5A5A5A),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          size: 26,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  '${event.remainingSlots ?? 0}/${event.totalSlots ?? 0} Joined',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(() => EditEventScreen(event: event));
                        },
                        child: SvgPicture.asset(
                          'assets/Group 48096067.svg',
                          height: 27,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${_getWeekday(date.weekday)}, ${_getMonth(date.month)} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
