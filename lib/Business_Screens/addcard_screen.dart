import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';

class AddcardScreen extends StatefulWidget {
  const AddcardScreen({super.key});

  @override
  State<AddcardScreen> createState() => _AddcardScreenState();
}

class _AddcardScreenState extends State<AddcardScreen> {
  int selectedIndex = 0;
  bool? isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 3,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0xff4F78DA),
                Color(0xff339003),
              ])),
            )
          ],
        ),
        elevation: 0,
        shadowColor: Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: Icon(
          Icons.arrow_back,
          color: Theme.of(context).primaryColor,
        ),
        title: Text('Payments'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 27,
                  color: Theme.of(context).primaryColor,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  child: Container(
                    height: 9,
                    width: 9,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, gradient: lefttorightgradient),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 13, left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                    border: GradientBoxBorder(gradient: lefttorightgradient),
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                    minTileHeight: 70,
                    tileColor: Color(0xffF1F1F1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    leading: SvgPicture.asset('assets/Group 48096151 (4).svg',
                        color: lightBlue),
                    trailing: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: lightBlue),
                    ),
                    title: Text(
                      'Credit Card',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: lightBlue),
                    )),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: lefttorightgradient.withOpacity(0.5)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Information',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 13,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        // controller: controller,
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor),
                        cursorHeight: 23,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: whiteColor,
                          enabled: true,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          prefixIcon: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/vis.png',
                                height: 10,
                              ),
                            ],
                          ),
                          border: InputBorder.none,
                          hintText: 'Card Number',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Color(0xff7B7575)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              // controller: controller,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor),
                              cursorHeight: 23,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: whiteColor,
                                enabled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                border: InputBorder.none,
                                hintText: 'MM/YY',
                                hintStyle: TextStyle(
                                    fontSize: 14, color: Color(0xff7B7575)),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              // controller: controller,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor),
                              cursorHeight: 23,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: whiteColor,
                                enabled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(
                                      'assets/Group 48096151 (4).svg',
                                      color: lightBlue),
                                ),
                                border: InputBorder.none,
                                hintText: 'CVC',
                                hintStyle: TextStyle(
                                    fontSize: 14, color: Color(0xff7B7575)),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                    minTileHeight: 70,
                    tileColor: Color(0xffF1F1F1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    leading: SvgPicture.asset(
                      'assets/Group 48096151 (5).svg',
                    ),
                    trailing: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: whiteColor),
                    ),
                    title: Text(
                      'Stripe',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                    minTileHeight: 70,
                    tileColor: Color(0xffF1F1F1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    leading: SvgPicture.asset(
                      'assets/paypal.svg',
                    ),
                    trailing: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: whiteColor),
                    ),
                    title: Text(
                      'Paypal',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value;
                        });
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'I agree to Tripmates',
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            '  terms of conditions',
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: lightBlue),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            ' & ',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'auto recursive subscription',
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w400,
                                color: lightBlue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Button(
                  height: 57,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Text(
                      'Confirm & Save Payment Method',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: whiteColor),
                    ),
                  ),
                  onTap: () {}),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
