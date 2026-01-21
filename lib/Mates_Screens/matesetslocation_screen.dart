import 'package:flutter/material.dart';
import 'package:gradient_slider/gradient_slider.dart';
import 'package:fluttrr/Constants/utils.dart';

class Matesetslocationscreen extends StatefulWidget {
  const Matesetslocationscreen({super.key});

  @override
  State<Matesetslocationscreen> createState() => _MatesetslocationscreenState();
}

class _MatesetslocationscreenState extends State<Matesetslocationscreen> {
  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        child: SafeArea(
            bottom: false,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 600,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            'assets/Screenshot_20250120-160105 (1).png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 21,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 19),
                      child: Row(
                        children: [
                          Text(
                            'Set Location:',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 19,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 19),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffF1F1F1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 21),
                                child: Text(
                                  'Current Location to 25Km',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: discriptionColor,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  GradientSlider(
                                    thumbAsset: 'assets/aaaa.png',
                                    thumbHeight: 21,
                                    thumbWidth: 21,
                                    trackBorder: 0,
                                    trackBorderColor: Colors.transparent,
                                    inactiveTrackColor: Color(0xffDADADA),
                                    activeTrackGradient: lefttorightgradient,
                                    slider: Slider(
                                        value: value,
                                        onChanged: (double val) {
                                          setState(() {
                                            value = val;
                                          });
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 23),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '1Km',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: discriptionColor,
                                          ),
                                        ),
                                        Text(
                                          '50Km',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: discriptionColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 19,
                    ),
                    Text('Set Now'),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            )));
  }
}
