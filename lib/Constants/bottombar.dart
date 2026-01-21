import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttrr/Constants/utils.dart';
import 'package:fluttrr/Home_Screen/home_screen.dart';
import 'package:fluttrr/Mates_Screens/mateswhoisaround_screen.dart';
import '../Activities_Screens/activitiesdiscover_screen.dart';
import '../ChatScreens/tabbar_screen.dart';
import '../ProfileScreens/profile_screen.dart';

class BottomBar extends StatefulWidget {
  final int screen; // Index of the initial screen
  const BottomBar({super.key, required this.screen});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int _selectedIndex;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    MateswhoisaroundScreen(),
    ActivitiesdiscoverScreen(),
    TabbarScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the selected index with the value passed through the constructor
    _selectedIndex = widget.screen;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            width: double.infinity,
            decoration: BoxDecoration(gradient: lefttorightgradient),
          ),
          SizedBox(
            height: 70,
            child: BottomNavigationBar(
              elevation: 0,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset(
                    'assets/homebottom.svg',
                  ),
                  icon: SvgPicture.asset(
                    'assets/h3.svg',
                    color: Theme.of(context).primaryColor,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset('assets/matesbottom.svg'),
                  icon: SvgPicture.asset(
                    'assets/p3 (2).svg',
                    color: Theme.of(context).primaryColor,
                  ),
                  label: 'Mates',
                ),
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset('assets/activitiesbottom.svg'),
                  icon: SvgPicture.asset(
                    'assets/icons Q2 (1).svg',
                    color: Theme.of(context).primaryColor,
                  ),
                  label: 'Activities',
                ),
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset('assets/chatbottom.svg'),
                  icon: SvgPicture.asset(
                    'assets/c1.svg',
                    color: Theme.of(context).primaryColor,
                  ),
                  label: 'Chats',
                ),
                BottomNavigationBarItem(
                  activeIcon: SvgPicture.asset(
                    'assets/profilebotttom.svg',
                    height: 27,
                  ),
                  icon: SvgPicture.asset(
                    height: 27,
                    'assets/m1.svg',
                    color: Theme.of(context).primaryColor,
                  ),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              // elevation: 5,

              selectedItemColor: Color(0xff1b3695),
              unselectedItemColor: Theme.of(context).primaryColor,
              unselectedLabelStyle: const TextStyle(color: Colors.black),

              showUnselectedLabels: true,
              onTap: _onItemTapped,
              selectedFontSize: 10,
              unselectedFontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
