import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/ProfileScreens/ChangePasswordScreen.dart';

import 'NotificationPreference.dart';

class SettingsandprivacyScreen extends StatefulWidget {
  const SettingsandprivacyScreen({super.key});

  @override
  State<SettingsandprivacyScreen> createState() =>
      _SettingsandprivacyScreenState();
}

class _SettingsandprivacyScreenState extends State<SettingsandprivacyScreen> {
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
          'Setting & privacy',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.to(() => NotificationsPreferenceScreen());
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SvgPicture.asset(
                    'assets/bel.svg',
                    color: Theme.of(context).primaryColor,
                    height: 23,
                  ),
                  title: Text('Notification preferences'),
                  trailing: Icon(Icons.arrow_forward_ios_outlined),
                ),
              ),
              Divider(
                thickness: 1.3,
                color: Color(0xffF1F1F1),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                'Account security',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 7,
              ),
              InkWell(
                onTap: () {
                  Get.to(() => ChangePasswordScreen());
                },
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SvgPicture.asset(
                    'assets/loc.svg',
                    color: Theme.of(context).primaryColor,
                    height: 21,
                  ),
                  title: Text('Change Password'),
                  trailing: Icon(Icons.arrow_forward_ios_outlined),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SvgPicture.asset(
                  'assets/Group 48095992.svg',
                  color: Theme.of(context).primaryColor,
                  height: 21,
                ),
                title: Text('Two-factor authentication'),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              Divider(
                thickness: 1.3,
                color: Color(0xffF1F1F1),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                'Data and privacy controls',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 7,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SvgPicture.asset(
                  'assets/pri.svg',
                  color: Theme.of(context).primaryColor,
                  height: 21,
                ),
                title: Text('Transfer Data With Qr code'),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                'Delete Account',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffB20000)),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
