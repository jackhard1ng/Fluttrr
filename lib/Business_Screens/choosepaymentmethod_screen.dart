import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/drawer_screen.dart';
import 'package:fluttrr/Constants/listdata.dart';
import 'package:fluttrr/Constants/utils.dart';

import '../Services/StripePayment.dart';

class ChoosepaymentmethodScreen extends StatefulWidget {
  const ChoosepaymentmethodScreen({super.key});

  @override
  State<ChoosepaymentmethodScreen> createState() =>
      _ChoosepaymentmethodScreenState();
}

class _ChoosepaymentmethodScreenState extends State<ChoosepaymentmethodScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerScreen(),
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
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor,
          ),
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
            ListView.builder(
                shrinkWrap: true,
                itemCount: paymentMethod.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 13, left: 20, right: 20),
                      child: ListTile(
                          minTileHeight: 70,
                          tileColor: Color(0xffF1F1F1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          leading: SvgPicture.asset(paymentMethod[index].image),
                          trailing: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selectedIndex == index
                                    ? lefttorightgradient
                                    : LinearGradient(
                                        colors: [whiteColor, whiteColor])),
                          ),
                          title: Text(
                            paymentMethod[index].name,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          )),
                    ),
                  );
                }),
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
                      'Continue',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: whiteColor),
                    ),
                  ),
                  onTap: () async {
                    final stripeService = StripeServiceNew(
                        stripePublishableKey:
                            'pk_test_51R5suzGjraIK7CHERf44ONvZRfXCtzWTqEdmvVz55tAmjAb3HT1BuZETQOVVOWtxjz1PHECbShsgCSoBkDuWFOUd001fCbmWtt');
                    final result = await stripeService.completePaymentFlow(
                      amount: 9999, // $10.00 in cents
                      currency: 'usd',
                      merchantDisplayName: 'TripMates',
                    );

                    if (result['success']) {
                      // Payment successful
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment successful!')));
                    } else {
                      // Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${result['error']}')));
                    }
                  }),
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
