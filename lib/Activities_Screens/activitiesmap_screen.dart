import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttrr/Constants/utils.dart';

class ActivitiesMapScreen extends StatefulWidget {
  const ActivitiesMapScreen({super.key});

  @override
  State<ActivitiesMapScreen> createState() => _ActivitiesMapScreenState();
}

class _ActivitiesMapScreenState extends State<ActivitiesMapScreen> {
  final _fromTop = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: PreferredSize(
      //     preferredSize: Size.fromHeight(75), child: CustomAppbar()),
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
                          Container(
                            height: 39,
                            width: 100,
                            decoration: BoxDecoration(
                              color: lightBlue.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                                child: Text(
                              'Explore',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
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
                          SizedBox(
                            width: 10,
                          ),
                          Container(
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
                                  color: whiteColor),
                            )),
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
                        SvgPicture.asset(
                          'assets/Group 48095856.svg',
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(
                          width: 14,
                        ),
                        SvgPicture.asset(
                          'assets/Group 48095856.svg',
                          color: Theme.of(context).primaryColor,
                          height: 21,
                        ),
                        SizedBox(
                          width: 14,
                        ),
                        InkWell(
                          onTap: () {
                            alertBox();
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/Group 48096192.png'),
                    ),
                  ),
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

  alertBox() {
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
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 290,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13),
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/ttt (2).png'),
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
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Sunday, February 4, 2025, at 8:00 AM ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff339003),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '2h ',
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
                                    'Hiking Adventure',
                                    style: TextStyle(
                                      fontSize: 19,
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
                                        'Green Valley National Park',
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
                                    'Escape into nature and enjoy a refreshing hiking adventure! Join fellow enthusiasts for a scenic trail featuring lush greenery.',
                                    style: TextStyle(
                                      color: Theme.of(context).indicatorColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    ' 50 View · 15 Interested ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).indicatorColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Stack(
                                            children: [
                                              CircleAvatar(
                                                radius: 17,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 17),
                                                child: CircleAvatar(
                                                  radius: 17,
                                                  backgroundColor:
                                                      Colors.purple,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 34),
                                                child: CircleAvatar(
                                                  radius: 17,
                                                  backgroundColor: Colors.blue,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 53),
                                                child: CircleAvatar(
                                                  radius: 17,
                                                  backgroundColor: Colors.amber,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            ' 08/10 Joined',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 27,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: lightBlue),
                                        child: Center(
                                          child: Text(
                                            'Join Now',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: whiteColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Close',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xffAA0000),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                ],
                              )),
                        ])));
          });
        });
  }
}
