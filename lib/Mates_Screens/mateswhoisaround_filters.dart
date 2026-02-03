import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Controller/MatesController.dart';

GlobalKey<FormState> formKey = GlobalKey<FormState>();

class MateswhoisaroundFilters extends StatefulWidget {
  const MateswhoisaroundFilters({
    super.key,
  });

  @override
  State<MateswhoisaroundFilters> createState() =>
      _MateswhoisaroundFiltersState();
}

class _MateswhoisaroundFiltersState extends State<MateswhoisaroundFilters> {
  Matescontroller matescontroller = Get.put(Matescontroller());
  ValueChanged<int>? onDeleted;
  String? SelectedGender;
  String? SelectedStatus;
  String? Maxage;
  String? Minage;

  double value = 0;
  int selectedIndex = 3;
  List gender = [
    'Male',
    'Female',
    'Non-Binary',
    'All',
  ];
  int statusIndex = 2;
  List travelerAndLocalStatus = [
    'Local',
    'traveler',
    'All',
  ];
  double start = 30.0;
  double end = 50.0;
  final List<String> _taglist = [];
  final TextEditingController _tagController = TextEditingController();
  final List<String> _taglisthobbies = [];
  final TextEditingController _taghobbiesController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).cardColor,
          toolbarHeight: 75,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(gradient: lefttorightgradient),
              ),
            ],
          ),
          leadingWidth: 60,
          title: Text('Mate Filters:'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 21),
              child: SvgPicture.asset(
                'assets/Group 48096193.svg',
                height: 25,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 21),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Gender:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffF1F1F1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GridView.builder(
                        itemCount: gender.length,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 0,
                                mainAxisExtent: 41),
                        itemBuilder: (_, index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            SelectedGender = gender[selectedIndex];
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: selectedIndex == index
                                    ? lefttorightgradient
                                    : LinearGradient(colors: [
                                        Color(0xffF1F1F1),
                                        Color(0xffF1F1F1),
                                      ]),
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                              child: Text(
                                gender[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: selectedIndex == index
                                      ? whiteColor
                                      : discriptionColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Traveler/Local Status:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffF1F1F1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GridView.builder(
                        itemCount: travelerAndLocalStatus.length,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 0,
                                mainAxisExtent: 41),
                        itemBuilder: (_, index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              statusIndex = index;
                            });
                            SelectedStatus = travelerAndLocalStatus[index];
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: statusIndex == index
                                    ? lefttorightgradient
                                    : LinearGradient(colors: [
                                        Color(0xffF1F1F1),
                                        Color(0xffF1F1F1),
                                      ]),
                                borderRadius: BorderRadius.circular(30)),
                            child: Center(
                              child: Text(
                                travelerAndLocalStatus[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: statusIndex == index
                                      ? whiteColor
                                      : discriptionColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Age:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
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
                          "Between ${start.toStringAsFixed(0)} to ${end.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: discriptionColor,
                          ),
                        ),
                      ),
                      // GradientSlider(
                      //   thumbAsset: 'assets/union-jack-flag-background.png',
                      //   thumbHeight: 30,
                      //   thumbWidth: 30,
                      //   trackBorder: 1,
                      //   trackBorderColor: Colors.black,
                      //   activeTrackGradient: lefttorightgradient,
                      //   slider: Slider(
                      //       value: value,
                      //       onChanged: (double val) {
                      //         setState(() {
                      //           value = val;
                      //         });
                      //       }),
                      // )
                      RangeSlider(
                        activeColor: Color(0xff339003),

                        values: RangeValues(start, end),
                        // labels: RangeLabels(start.toString(), end.toString()),
                        onChanged: (value) {
                          setState(() {
                            start = value.start;
                            end = value.end;
                          });
                        },
                        min: 0,
                        max: 100,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 15,
              ),
              Text(
                'Languages:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TextFormField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffF1F1F1),
                          hintText: "Search For Lannguages.....",
                          suffixIcon: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/s.svg',
                                height: 23,
                              ),
                            ],
                          ),
                          hintStyle:
                              TextStyle(fontSize: 14, color: discriptionColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      // Add item to the list
                      if (_tagController.text.isNotEmpty) {
                        setState(() {
                          _taglist.add(_tagController.text.trim());
                          _tagController.clear();
                        });
                      }
                    },
                    child: Container(
                      height: 47,
                      width: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: lefttorightgradient),
                      child: Center(
                        child: Text(
                          'Add',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: whiteColor),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              // Display List of Chips for Equipment
              Wrap(
                spacing: 3.0,
                runSpacing: 4.0,
                children: List.generate(
                  _taglist.length,
                  (index) => Chip(
                    avatar: SvgPicture.asset(
                      'assets/Group 48096194.svg',
                      height: 17,
                      color: Theme.of(context).primaryColor,
                    ),
                    color:
                        WidgetStatePropertyAll(Colors.green.withOpacity(0.3)),
                    label: Text(_taglist[index]),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        _taglist.removeAt(index); // Remove item from the list
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              Text(
                'Interests & Hobbies:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TextFormField(
                        controller: _taghobbiesController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffF1F1F1),
                          hintText: "Search For Interests & Hobbies.....",
                          hintStyle:
                              TextStyle(fontSize: 14, color: discriptionColor),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      // Add item to the list
                      if (_taghobbiesController.text.isNotEmpty) {
                        setState(() {
                          _taglisthobbies
                              .add(_taghobbiesController.text.trim());
                          _taghobbiesController.clear();
                        });
                      }
                    },
                    child: Container(
                      height: 47,
                      width: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: lefttorightgradient),
                      child: Center(
                        child: Text(
                          'Add',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: whiteColor),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              // Display List of Chips for Equipment
              Wrap(
                spacing: 3.0,
                runSpacing: 4.0,
                children: List.generate(
                  _taglisthobbies.length,
                  (index) => Chip(
                    avatar: SvgPicture.asset(
                      'assets/sss (2).svg',
                      height: 17,
                    ),
                    color:
                        WidgetStatePropertyAll(Colors.green.withOpacity(0.3)),
                    label: Text(_taglisthobbies[index]),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        _taglisthobbies
                            .removeAt(index); // Remove item from the list
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    borderRadius: BorderRadius.circular(10),
                    height: 60,
                    width: 130,
                    onTap: () async {
                      await matescontroller.MatesFilter(
                          start.toString(),
                          end.toString(),
                          SelectedStatus.toString(),
                          SelectedGender.toString(),
                          _taglist,
                          "",
                          _taglisthobbies);
                      Get.back();
                    },
                    child: const Center(
                        child: Text(
                      'Save',
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    )),
                  ),
                ],
              ),
              SizedBox(
                height: 17,
              ),
            ]),
          ),
        ));
  }
}
