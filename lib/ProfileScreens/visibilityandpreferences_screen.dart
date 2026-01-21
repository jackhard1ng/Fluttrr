import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:fluttrr/Controller/PrivacyProfileController.dart';

class VisibilityandpreferencesScreen extends StatefulWidget {
  const VisibilityandpreferencesScreen({super.key});

  @override
  State<VisibilityandpreferencesScreen> createState() =>
      _VisibilityandpreferencesScreenState();
}

class _VisibilityandpreferencesScreenState
    extends State<VisibilityandpreferencesScreen> {
  Privacyprofilecontroller controller = Get.put(Privacyprofilecontroller());
  bool status = false;
  bool status2 = false;
  bool status3 = false;
  bool status4 = false;
  bool status5 = false;
  bool status6 = false;
  bool status7 = false;
  double start = 18.0;
  double end = 50.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.GetPrivacy();
    if (controller.Privacymodel?.privacy != null) {
      start = double.tryParse(
              controller.Privacymodel!.privacy!.ageRangeMin.toString()) ??
          start;
      end = double.tryParse(
              controller.Privacymodel!.privacy!.ageRangeMax.toString()) ??
          end;
    }
  }

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
          'Visibility and Preferences',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: GetBuilder<Privacyprofilecontroller>(
              id: "Profile_update",
              builder: (_) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customize how others see your profile with personalized visibility settings.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).indicatorColor),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Traveler and Local status',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Traveler',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FlutterSwitch(
                          width: 56.0,
                          height: 30.0,
                          toggleSize: 30.0,
                          value: controller.Privacymodel?.privacy?.traveller ??
                              false,
                          padding: 1,
                          borderRadius: 30.0,
                          showOnOff: false,
                          activeToggleColor: Color(0xff0F172A),
                          onToggle: (val) async {
                            bool travler =
                                controller.Privacymodel!.privacy!.traveller ==
                                        false
                                    ? true
                                    : false;
                            print("$travler");
                            await controller.UpdatePrivacy(
                                travler,
                                controller.Privacymodel?.privacy?.local ??
                                    false,
                                controller.Privacymodel?.privacy?.male ?? false,
                                controller.Privacymodel?.privacy?.female ??
                                    false,
                                controller.Privacymodel?.privacy?.nonBinary ??
                                    false,
                                controller.Privacymodel?.privacy?.everyone ??
                                    false,
                                controller.Privacymodel?.privacy?.privateMode ??
                                    false,
                                end,
                                start);
                            await controller.GetPrivacy();
                            setState(() {
                              status = val;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'your travel profile to match your journey-control how fellow travelers and locals see you.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).indicatorColor),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Local',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FlutterSwitch(
                          width: 56.0,
                          height: 30.0,
                          toggleSize: 30.0,
                          value:
                              controller.Privacymodel?.privacy?.local ?? false,
                          padding: 1,
                          borderRadius: 30.0,
                          showOnOff: false,
                          activeToggleColor: Color(0xff0F172A),
                          onToggle: (val) async {
                            bool local =
                                controller.Privacymodel!.privacy!.local == false
                                    ? true
                                    : false;
                            print("$local");
                            await controller.UpdatePrivacy(
                                controller.Privacymodel?.privacy?.traveller ??
                                    false,
                                local,
                                controller.Privacymodel?.privacy?.male ?? false,
                                controller.Privacymodel?.privacy?.female ??
                                    false,
                                controller.Privacymodel?.privacy?.nonBinary ??
                                    false,
                                controller.Privacymodel?.privacy?.everyone ??
                                    false,
                                controller.Privacymodel?.privacy?.privateMode ??
                                    false,
                                end,
                                start);
                            await controller.GetPrivacy();
                            setState(() {
                              status2 = val;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'your travel profile to match your journey-control how fellow travelers and locals see you.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).indicatorColor),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Age Range',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Between $start to $end",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).indicatorColor,
                      ),
                    ),
                    RangeSlider(
                      activeColor: Colors.blue,
                      values: RangeValues(start, end),
                      min: 0,
                      max: 100,
                      divisions: 20, // Optional: Adds discrete steps
                      labels: RangeLabels(start.toString(), end.toString()),
                      onChanged: (RangeValues value) async {
                        await controller.UpdatePrivacy(
                            controller.Privacymodel?.privacy?.traveller ??
                                false,
                            controller.Privacymodel?.privacy?.local ?? false,
                            controller.Privacymodel?.privacy?.male ?? false,
                            controller.Privacymodel?.privacy?.female ?? false,
                            controller.Privacymodel?.privacy?.nonBinary ??
                                false,
                            controller.Privacymodel?.privacy?.everyone ?? false,
                            controller.Privacymodel?.privacy?.privateMode ??
                                false,
                            end,
                            start);
                        await controller.GetPrivacy();
                        setState(() {
                          start = value.start;
                          end = value.end;
                        });
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Genders',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Male',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FlutterSwitch(
                          width: 56.0,
                          height: 30.0,
                          toggleSize: 30.0,
                          value:
                              controller.Privacymodel?.privacy?.male ?? false,
                          padding: 1,
                          borderRadius: 30.0,
                          showOnOff: false,
                          activeToggleColor: Color(0xff0F172A),
                          onToggle: (val) async {
                            bool male =
                                controller.Privacymodel!.privacy!.male == false
                                    ? true
                                    : false;
                            print("$male");
                            await controller.UpdatePrivacy(
                                controller.Privacymodel?.privacy?.traveller ??
                                    false,
                                controller.Privacymodel?.privacy?.local ??
                                    false,
                                male,
                                controller.Privacymodel?.privacy?.female ??
                                    false,
                                controller.Privacymodel?.privacy?.nonBinary ??
                                    false,
                                controller.Privacymodel?.privacy?.everyone ??
                                    false,
                                controller.Privacymodel?.privacy?.privateMode ??
                                    false,
                                end,
                                start);
                            await controller.GetPrivacy();
                            setState(() {
                              status3 = val;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Adjust how your profile is displayed to others with visibility settings tailored for males.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).indicatorColor),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Female',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FlutterSwitch(
                          width: 56.0,
                          height: 30.0,
                          toggleSize: 30.0,
                          value:
                              controller.Privacymodel?.privacy?.female ?? false,
                          padding: 1,
                          borderRadius: 30.0,
                          showOnOff: false,
                          activeToggleColor: Color(0xff0F172A),
                          onToggle: (val) async {
                            bool female =
                                controller.Privacymodel!.privacy!.female ==
                                        false
                                    ? true
                                    : false;
                            print("$female");
                            await controller.UpdatePrivacy(
                                controller.Privacymodel?.privacy?.traveller ??
                                    false,
                                controller.Privacymodel?.privacy?.local ??
                                    false,
                                controller.Privacymodel?.privacy?.male ?? false,
                                female,
                                controller.Privacymodel?.privacy?.nonBinary ??
                                    false,
                                controller.Privacymodel?.privacy?.everyone ??
                                    false,
                                controller.Privacymodel?.privacy?.privateMode ??
                                    false,
                                end,
                                start);
                            await controller.GetPrivacy();
                            setState(() {
                              status4 = val;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Manage how your profile is viewed by others with visibility settings designed for females.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).indicatorColor),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Everyone',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FlutterSwitch(
                          width: 56.0,
                          height: 30.0,
                          toggleSize: 30.0,
                          value: controller.Privacymodel?.privacy?.everyone ??
                              false,
                          padding: 1,
                          borderRadius: 30.0,
                          showOnOff: false,
                          activeToggleColor: Color(0xff0F172A),
                          onToggle: (val) async {
                            bool everyone =
                                controller.Privacymodel!.privacy!.everyone ==
                                        false
                                    ? true
                                    : false;
                            print("$everyone");
                            await controller.UpdatePrivacy(
                                controller.Privacymodel?.privacy?.traveller ??
                                    false,
                                controller.Privacymodel?.privacy?.local ??
                                    false,
                                controller.Privacymodel?.privacy?.male ?? false,
                                controller.Privacymodel?.privacy?.female ??
                                    false,
                                controller.Privacymodel?.privacy?.nonBinary ??
                                    false,
                                everyone,
                                controller.Privacymodel?.privacy?.privateMode ??
                                    false,
                                end,
                                start);
                            await controller.GetPrivacy();
                            setState(() {
                              status5 = val;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Adjust how your profile is displayed to others with visibility settings tailored for Everyone.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).indicatorColor),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Non-binary',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FlutterSwitch(
                          width: 56.0,
                          height: 30.0,
                          toggleSize: 30.0,
                          value: controller.Privacymodel?.privacy?.nonBinary ??
                              false,
                          padding: 1,
                          borderRadius: 30.0,
                          showOnOff: false,
                          activeToggleColor: Color(0xff0F172A),
                          onToggle: (val) async {
                            bool nonbinary =
                                controller.Privacymodel!.privacy!.nonBinary ==
                                        false
                                    ? true
                                    : false;
                            print("$nonbinary");
                            await controller.UpdatePrivacy(
                                controller.Privacymodel?.privacy?.traveller ??
                                    false,
                                controller.Privacymodel?.privacy?.local ??
                                    false,
                                controller.Privacymodel?.privacy?.male ?? false,
                                controller.Privacymodel?.privacy?.female ??
                                    false,
                                nonbinary,
                                controller.Privacymodel?.privacy?.everyone ??
                                    false,
                                controller.Privacymodel?.privacy?.privateMode ??
                                    false,
                                end,
                                start);
                            await controller.GetPrivacy();
                            setState(() {
                              status6 = val;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Customize your profile visibility with inclusive settings designed for non-binary individuals, ensuring control over who sees your information and activity.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).indicatorColor),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'Private Mode',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hide Profile',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FlutterSwitch(
                          width: 56.0,
                          height: 30.0,
                          toggleSize: 30.0,
                          value:
                              controller.Privacymodel?.privacy?.privateMode ??
                                  false,
                          padding: 1,
                          borderRadius: 30.0,
                          showOnOff: false,
                          activeToggleColor: Color(0xff0F172A),
                          onToggle: (val) async {
                            bool hideProfile =
                                controller.Privacymodel!.privacy!.nonBinary ==
                                        false
                                    ? true
                                    : false;
                            print("$hideProfile");
                            await controller.UpdatePrivacy(
                                controller.Privacymodel?.privacy?.traveller ??
                                    false,
                                controller.Privacymodel?.privacy?.local ??
                                    false,
                                controller.Privacymodel?.privacy?.male ?? false,
                                controller.Privacymodel?.privacy?.female ??
                                    false,
                                controller.Privacymodel?.privacy?.nonBinary ??
                                    false,
                                controller.Privacymodel?.privacy?.everyone ??
                                    false,
                                hideProfile,
                                end,
                                start);
                            await controller.GetPrivacy();
                            setState(() {
                              status7 = val;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'When enabled, your profile is hidden from discovery. Only people you connect with directly can view your profile.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).indicatorColor),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
