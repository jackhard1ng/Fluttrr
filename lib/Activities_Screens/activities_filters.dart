import 'package:date_time_picker/date_time_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_slider/gradient_slider.dart';
import 'package:fluttrr/Constants/button.dart';
import 'package:fluttrr/Constants/utils.dart';

import '../Controller/AcitivityController.dart';

class ActivitiesFilters extends StatefulWidget {
  const ActivitiesFilters({
    super.key,
  });

  @override
  State<ActivitiesFilters> createState() => _ActivitiesFiltersState();
}

class _ActivitiesFiltersState extends State<ActivitiesFilters> {
  Acitivitycontroller acitivitycontroller = Get.put(Acitivitycontroller());
  ValueChanged<int>? onDeleted;

  double value = 0;
  int selectedIndex = 0;
  List gender = [
    'Male',
    'Female',
    'Non-Binary',
    'All',
  ];
  int statusIndex = 0;
  List travelerAndLocalStatus = [
    'Local',
    'Traveler',
    'All',
  ];
  double start = 30.0;
  double end = 50.0;
  final List<String> _taglist = [];
  final TextEditingController _tagController = TextEditingController();
  final List<String> _taglisthobbies = [];
  final TextEditingController _taghobbiesController = TextEditingController();
  final List<String> sizeofGroup = [
    'Large',
    'Medium',
    'Small',
  ];
  String? date;

  String? selectedsizeofGroup;
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
        title: Text('Activities Filters:'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activities Type:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
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
                        style: TextStyle(color: Colors.black),
                        controller: _taghobbiesController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 13),
                          suffixIcon: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/s.svg',
                                height: 23,
                              ),
                            ],
                          ),
                          filled: true,
                          fillColor: Color(0xffF1F1F1),
                          hintText: "Activities Type...",
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
                          color: lightBlue),
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
                  ),
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
                    // avatar: SvgPicture.asset(
                    //   'assets/sss (2).svg',
                    //   height: 17,
                    // ),
                    color: WidgetStatePropertyAll(Colors.blue.withOpacity(0.3)),
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
              SizedBox(height: 19),
              Text(
                'Date And Time:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(
                height: 10,
              ),
              DateTimePicker(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: SvgPicture.asset('assets/Group 48096197.svg'),
                  ),
                  filled: true,
                  fillColor: Color(0xffF1F1F1),
                  prefixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/Group 48096193 (1).svg')
                    ],
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                ),
                type: DateTimePickerType.dateTime,
                dateMask: 'MMMM d, yyyy h:mm a',
                initialValue: DateTime.now().toString(),
                firstDate: DateTime(1960),
                lastDate: DateTime(2100),
                dateLabelText: 'Date',
                timeLabelText: "Hour",
                selectableDayPredicate: (date) {
                  // Disable weekend days to select from the calendar
                  if (date.weekday == 6 || date.weekday == 7) {
                    return false;
                  }

                  return true;
                },
                onChanged: (val) {},
                validator: (val) {
                  setState(() {
                    date = val;
                  });
                  return null;
                },
                onSaved: (val) {},
              ),
              SizedBox(height: 19),
              Text(
                'Distance From Current Location:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
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
                          'Current Location to 7.5Miles',
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
                            padding: const EdgeInsets.symmetric(horizontal: 23),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '1Miles',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: discriptionColor,
                                  ),
                                ),
                                Text(
                                  '30Miles',
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
              SizedBox(height: 19),
              Text(
                'Size of Group:',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  iconStyleData: IconStyleData(
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 19),
                      child: SvgPicture.asset('assets/drop.svg'),
                    ),
                  ),
                  isExpanded: true,
                  hint: const Row(
                    children: [
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          'Select',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  items: sizeofGroup
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Text(
                                item,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ))
                      .toList(),
                  value: selectedsizeofGroup,
                  onChanged: (value) {
                    setState(
                      () {
                        selectedsizeofGroup = value;
                      },
                    );
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 60,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 7, right: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: Color(0xffF1F1F1),
                    ),
                    elevation: 0,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            17,
                          ),
                          bottomRight: Radius.circular(17)),
                      color: Colors.white,
                    ),
                    offset: const Offset(-20, 0),
                    scrollbarTheme: const ScrollbarThemeData(
                      radius: Radius.circular(40),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.only(left: 30, right: 7),
                  ),
                ),
              ),

              SizedBox(
                height: 33,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    borderRadius: BorderRadius.circular(10),
                    height: 60,
                    width: 130,
                    onTap: () async {
                      await acitivitycontroller.FilterActivity(
                          _taglisthobbies[0],
                          date.toString(),
                          "",
                          value.toString());
                      Get.back();
                    },
                    child: const Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
