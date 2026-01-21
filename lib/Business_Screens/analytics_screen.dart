import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:fluttrr/Constants/Apis_Constants.dart';
import 'package:fluttrr/Constants/custom_appbar.dart';
import 'package:fluttrr/Controller/BussinessPageController.dart';
import 'package:fluttrr/Models/BussinessModel/AnalyticsModel.dart';

import '../Constants/drawer_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final BusinessController businessController = Get.put(BusinessController());
  int selectedIndex = 0;
  final List<String> analyticsPeriods = ['Today', '7 Days', '30 Days'];

  @override
  void initState() {
    super.initState();
    businessController.GetBussinessAnalytics();
    businessController.TopEvents();
  }

  Total? getCurrentAnalytics() {
    final analytics = businessController.analyticsModel?.analytics;
    if (analytics == null) return null;

    switch (selectedIndex) {
      case 0: // Today
        return analytics.daily ?? analytics.total;
      case 1: // 7 Days
        return analytics.weekly ?? analytics.total;
      case 2: // 30 Days
        return analytics.monthly ?? analytics.total;
      default:
        return analytics.total;
    }
  }

  Widget _buildAnalyticsCard({
    required String title,
    required int? value,
    required bool isPositive,
    required Color backgroundColor,
  }) {
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final color =
        isPositive ? const Color(0xff339003) : const Color(0xffE53636);
    final percentageText =
        isPositive ? '10%' : '5%'; // Replace with actual API data

    return Container(
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor.withOpacity(0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    value?.toString() ?? '0',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: color.withOpacity(0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        Text(
                          percentageText,
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          icon,
                          size: 16,
                          color: color,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerScreen(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(83),
        child: Businessappbar(
          scaffoldKey: _scaffoldKey,
        ),
      ),
      body: Obx(() {
        final analytics = getCurrentAnalytics();
        final isLoading = businessController.isLoading.value;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: const Text(
                    'Analytics',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: analyticsPeriods.length,
                    itemBuilder: (BuildContext context, int index) {
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
                                  analyticsPeriods[index],
                                  colors: const [
                                    Color(0xff007BFD),
                                    Color(0xff20235A),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  analyticsPeriods[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnalyticsCard(
                              title: 'Total Followers',
                              value: analytics?.followers,
                              isPositive: false, // Set based on your API data
                              backgroundColor: const Color(0xff339003),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildAnalyticsCard(
                              title: 'Total Views',
                              value: analytics?.views,
                              isPositive: true, // Set based on your API data
                              backgroundColor: const Color(0xffFFB331),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnalyticsCard(
                              title: 'Total Clicks',
                              value: analytics?.clicks,
                              isPositive: true, // Set based on your API data
                              backgroundColor: const Color(0xff0097A5),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildAnalyticsCard(
                              title: 'Total Joined',
                              value: analytics?.joins,
                              isPositive: true, // Set based on your API data
                              backgroundColor: const Color(0xff00D4BD),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/Group 72.png'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: const Text(
                    'Top Views Events',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      businessController.topEventModel?.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    var event = businessController.topEventModel?.data?[index];

                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 13, left: 20, right: 20),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 183,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    "${Apis.ip}${event?.image}" ??
                                        'https://via.placeholder.com/150'),
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 27,
                                        backgroundImage: NetworkImage(
                                            'https://via.placeholder.com/50'), // Replace with actual profile image if available
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 170,
                                            child: Text(
                                              event?.name ?? 'Event Name',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/pin.svg',
                                                height: 14,
                                              ),
                                              const SizedBox(width: 7),
                                              SizedBox(
                                                width: 160,
                                                child: Text(
                                                  event?.location ??
                                                      'Event Location',
                                                  style: TextStyle(
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
                                                'Event Date:', // Replace with actual date
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff00D4BD),
                                                ),
                                              ),
                                              Text(
                                                ' at Event Time', // Replace with actual time
                                                style: TextStyle(
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
                                              event?.description ??
                                                  'No description available.',
                                              style: TextStyle(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                  color: Color(0xff5A5A5A),
                                                ),
                                                child: Center(
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
                                            '${event?.remainingSlots ?? 0}/${event?.totalSlots ?? 0} Joined',
                                            style: TextStyle(
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
                            padding: const EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SvgPicture.asset(
                                  'assets/Group 48096067.svg',
                                  height: 27,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
