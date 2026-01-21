import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:fluttrr/Constants/utils.dart';

class TotalmatchesScreen extends StatefulWidget {
  const TotalmatchesScreen({super.key});

  @override
  State<TotalmatchesScreen> createState() => _TotalmatchesScreenState();
}

class _TotalmatchesScreenState extends State<TotalmatchesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: Icon(
          Icons.arrow_back,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          'Total Matches',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 15),
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: GradientBoxBorder(
                              gradient: toptobottomgradient, width: 2.1),
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(colors: [
                            Color(0xff4F78DA),
                            Color(0xff000000).withOpacity(0.49),
                          ])),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              CircleAvatar(
                                radius: 33,
                                backgroundImage:
                                    AssetImage('assets/Group 48096083.png'),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 17,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: whiteColor),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Center(
                                              child: Text(
                                            'Loves Hiking',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff930000)),
                                          )),
                                        ),
                                      ),
                                      Text(
                                        '      Online',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff339003)),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Muhammad Ali Khan, 24',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: whiteColor),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      SvgPicture.asset(
                                        'assets/verify.svg',
                                        height: 19,
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Container(
                                    height: 27,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Color(0xff339003),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/Vector (3).svg',
                                            height: 13,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Traveler',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: whiteColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child:
                                SvgPicture.asset('assets/Group 48096085.svg'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
