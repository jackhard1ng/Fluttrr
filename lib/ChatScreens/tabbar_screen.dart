import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:fluttrr/ChatScreens/GroupChatList.dart';

import 'package:fluttrr/Constants/utils.dart';

import '../Controller/ChatsListController.dart';
import 'BusinessChatList.dart';
import 'chat_list.dart';

class TabbarScreen extends StatefulWidget {
  const TabbarScreen({super.key});

  @override
  State<TabbarScreen> createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen>
    with SingleTickerProviderStateMixin {
  final ChatsListController controller = Get.put(ChatsListController());

  late TabController _controller;
  @override
  void initState() {
    _controller = TabController(length: 4, vsync: this, initialIndex: 0);
    controller.Chatlist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).cardColor,
          toolbarHeight: 75,
          leadingWidth: 60,
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 20,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/Union.svg',
                  color: Theme.of(context).primaryColor,
                  height: 21,
                ),
              ],
            ),
          ),
          title: SizedBox(
            height: 38,
            child: TextFormField(
              style: TextStyle(fontSize: 13, color: Colors.black),
              cursorHeight: 15,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).hoverColor,
                enabled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                border: InputBorder.none,
                prefixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/Vector.svg',
                      height: 17,
                    )
                  ],
                ),
                hintText: 'Find friends, activities, or places nearby..',
                hintStyle: TextStyle(
                  fontSize: 9,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          actions: [
            SvgPicture.asset(
              'assets/Vector (1).svg',
              height: 25,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(
              width: 13,
            ),
            TextButton(
              onPressed: () {
                // Get.offAll(() => LoginScreen());
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 20,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(51),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 49,
                        color: Color(0xffF1F1F1),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: TabBar(
                            isScrollable: true, // Enable scroll
                            controller: _controller,
                            labelColor: lightBlue,
                            unselectedLabelColor:
                                Theme.of(context).primaryColor,
                            indicatorColor: Color(0xff20235A),
                            dividerColor: Color(0xffF1F1F1),
                            tabs: [
                              Tab(
                                child: Text(
                                  'All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Mates Chats',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Activity Group Chats',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Business Chats',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: [
            ChatList(),
            ChatList(),
            Groupchatlist(),
            BusinessmessagesScreen()
          ],
        ),
      ),
    );
  }
}
