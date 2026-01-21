import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttrr/Constants/utils.dart';

// home screen wipe cards
List<Widget> cards = [
  Container(
    width: double.infinity,
    height: 410,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.transparent,
      image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage(
          'assets/Group 48095821.png',
        ),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundImage:
                    AssetImage('assets/union-jack-flag-background.png'),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Harry, 24, Male',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: whiteColor),
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      SvgPicture.asset(
                        'assets/Vector (2).svg',
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
                      color: Color(0xff4F78DA),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/h.svg',
                            height: 13,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Local',
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
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/Group 48095816.svg',
                height: 41,
              ),
              SizedBox(
                width: 30,
              ),
              SvgPicture.asset(
                'assets/Group 48095815.svg',
                height: 41,
              ),
            ],
          ),
        )
      ],
    ),
  ),
  Container(
    width: double.infinity,
    height: 410,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.transparent,
      image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage(
          'assets/Group 48095821.png',
        ),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundImage:
                    AssetImage('assets/union-jack-flag-background.png'),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hassan, 24, Male',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: whiteColor),
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      SvgPicture.asset(
                        'assets/Vector (2).svg',
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/Group 48095816.svg',
                height: 41,
              ),
              SizedBox(
                width: 30,
              ),
              SvgPicture.asset(
                'assets/Group 48095815.svg',
                height: 41,
              ),
            ],
          ),
        )
      ],
    ),
  ),
];

// home screen  daily activities

class DailyActivities {
  final String image;
  final String location;
  final String time;
  final String title;
  final String discription;

  DailyActivities(
    this.image,
    this.location,
    this.time,
    this.title,
    this.discription,
  );
}

final List<DailyActivities> dailyActivities = [
  DailyActivities(
      'assets/woman-doing-yoga-garden.png',
      'Central Park, Meadow Area',
      '11:45 AM',
      'Sunrise Yoga in the Park',
      'Start your day with a rejuvenating yoga session surrounded by nature.'),
  DailyActivities(
      'assets/woman-doing-yoga-garden.png',
      'Central Park, Meadow Area',
      '11:45 AM',
      'Sunrise Yoga in the Park',
      'Start your day with a rejuvenating yoga session surrounded by nature.'),
  DailyActivities(
      'assets/woman-doing-yoga-garden.png',
      'Central Park, Meadow Area',
      '11:45 AM',
      'Sunrise Yoga in the Park',
      'Start your day with a rejuvenating yoga session surrounded by nature.'),
];

// home screen  upcomming activities

class UpcommingActivities {
  final String image;
  final String profile;
  final String adventure;
  final String location;
  final String date;
  final String time;
  final String discription;

  UpcommingActivities(
    this.image,
    this.profile,
    this.adventure,
    this.location,
    this.date,
    this.time,
    this.discription,
  );
}

final List<UpcommingActivities> upcommingActivities = [
  UpcommingActivities(
    'assets/Group 48095849.png',
    'assets/ttt.png',
    'Hiking Adventure',
    'Green Valley National Park',
    'Sunday, February 9, 2025,',
    ' at 8:00 AM',
    'Escape into nature and enjoy a refreshing hiking adventure! Join fellow enthusiasts for a scenic trail featuring lush greenery.',
  ),
  UpcommingActivities(
    'assets/Group 48095848 (1).png',
    'assets/fantasy-shooting-star-landscape-night.png',
    'Stargazing and Mindfulness Night',
    'Hilltop Observatory, East Ridge',
    'Friday, February 23, 2025,',
    ' 8:00 AM',
    'Unwind under the stars! This event combines guided mindfulness meditation with a tour of constellations.',
  ),
];

// Mate’s Interests & Hobbies

class InterestsHobbies {
  final String image;
  final String title;

  InterestsHobbies(
    this.image,
    this.title,
  );
}

final List<InterestsHobbies> interestsHobbies = [
  InterestsHobbies(
    'assets/Group 48095832.svg',
    'Drawing',
  ),
  InterestsHobbies(
    'assets/Group 48096191.svg',
    'Music',
  ),
];

// Languages

class LanguagesData {
  final String image;
  final String title;

  LanguagesData(
    this.image,
    this.title,
  );
}

final List<LanguagesData> languagesData = [
  LanguagesData(
    'assets/blabber_svgrepo.com.svg',
    'English',
  ),
  LanguagesData(
    'assets/blabber_svgrepo.com.svg',
    'Arabic',
  ),
];

// Mate’s Location

class MateLocation {
  final String flag;
  final String title;

  MateLocation(
    this.flag,
    this.title,
  );
}

final List<MateLocation> mateLocation = [
  MateLocation(
    'assets/union-jack-flag-background.png',
    'Birmingham, UK',
  ),
];
// Activities( Dicover Activities )

class DicoverActivitiesData {
  final String image;
  final String profile;
  final String adventure;
  final String location;
  final String date;
  final String time;
  final String discription;
  final Widget paid;

  DicoverActivitiesData(this.image, this.profile, this.adventure, this.location,
      this.date, this.time, this.discription, this.paid);
}

final List<DicoverActivitiesData> dicoverActivitiesData = [
  DicoverActivitiesData(
    'assets/Group 48095849.png',
    'assets/ttt.png',
    'Hiking Adventure',
    'Green Valley National Park',
    'Sunday, February 9, 2025,',
    ' at 8:00 AM',
    'Escape into nature and enjoy a refreshing hiking adventure! Join fellow enthusiasts for a scenic trail featuring lush greenery.',
    Container(
      height: 23,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(7)),
          gradient: lefttorightgradient),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Paid',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: whiteColor,
              ),
            )
          ],
        ),
      ),
    ),
  ),
  DicoverActivitiesData(
    'assets/Group 48095848 (1).png',
    'assets/fantasy-shooting-star-landscape-night.png',
    'Stargazing and Mindfulness Night',
    'Hilltop Observatory, East Ridge',
    'Friday, February 23, 2025,',
    ' 8:00 AM',
    'Unwind under the stars! This event combines guided mindfulness meditation with a tour of constellations.',
    Container(),
  ),
  DicoverActivitiesData(
    'assets/Group 48095849.png',
    'assets/ttt.png',
    'Hiking Adventure',
    'Green Valley National Park',
    'Sunday, February 9, 2025,',
    ' at 8:00 AM',
    'Escape into nature and enjoy a refreshing hiking adventure! Join fellow enthusiasts for a scenic trail featuring lush greenery.',
    Container(),
  ),
  DicoverActivitiesData(
    'assets/Group 48095848 (1).png',
    'assets/fantasy-shooting-star-landscape-night.png',
    'Stargazing and Mindfulness Night',
    'Hilltop Observatory, East Ridge',
    'Friday, February 23, 2025,',
    ' 8:00 AM',
    'Unwind under the stars! This event combines guided mindfulness meditation with a tour of constellations.',
    Container(),
  ),
];

// Activities( Dicover Activities - Swip view )
List<Widget> exploreActivitiescards = [
  Container(
    width: double.infinity,
    height: 410,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.transparent,
      image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage(
          'assets/Group 48095878.png',
        ),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(
                'assets/Group 48095897.svg',
                height: 21,
              ),
              SizedBox(
                width: 16,
              ),
              SvgPicture.asset(
                'assets/Group 48095896.svg',
                height: 21,
              ),
              SizedBox(
                width: 16,
              ),
              SvgPicture.asset(
                'assets/Group.svg',
                height: 21,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 13, right: 13, bottom: 13),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 33,
                    backgroundImage:
                        AssetImage('assets/woman-doing-yoga-garden.png'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 170,
                        child: Text(
                          'Hiking Adventure',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/pin.svg',
                            height: 14,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          SizedBox(
                            width: 180,
                            child: Text(
                              'Green Valley National Park',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Text(
                            'Sunday, February 4, 2025,',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff00D4BD)),
                          ),
                          Text(
                            ' at 8:00 AM',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff00D4BD)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Escape into nature and enjoy a refreshing hiking adventure! Join fellow enthusiasts for a scenic trail featuring lush greenery.',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              SizedBox(
                height: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 33,
                            width: 33,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff5A5A5A)),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 30,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        '08/10 Joined',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: whiteColor),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 13,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 37,
                    width: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black54),
                    child: Center(
                      child: Text(
                        'Skip',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: whiteColor),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 13,
                  ),
                  Container(
                    height: 37,
                    width: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xff007BFD)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Join',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: whiteColor),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset('assets/Group 48096111.svg')
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
  Container(
    width: double.infinity,
    height: 410,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.transparent,
      image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage(
          'assets/Group 48095878.png',
        ),
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgPicture.asset(
                'assets/Group 48095897.svg',
                height: 21,
              ),
              SizedBox(
                width: 16,
              ),
              SvgPicture.asset(
                'assets/Group 48095896.svg',
                height: 21,
              ),
              SizedBox(
                width: 16,
              ),
              SvgPicture.asset(
                'assets/Group.svg',
                height: 21,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 13, right: 13, bottom: 13),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 33,
                    backgroundImage:
                        AssetImage('assets/woman-doing-yoga-garden.png'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 170,
                        child: Text(
                          'Hiking Adventure',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/pin.svg',
                            height: 14,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          SizedBox(
                            width: 180,
                            child: Text(
                              'Green Valley National Park',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Text(
                            'Sunday, February 4, 2025,',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff00D4BD)),
                          ),
                          Text(
                            ' at 8:00 AM',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff00D4BD)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Escape into nature and enjoy a refreshing hiking adventure! Join fellow enthusiasts for a scenic trail featuring lush greenery.',
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              SizedBox(
                height: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 33,
                            width: 33,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff5A5A5A)),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 30,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        '08/10 Joined',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: whiteColor),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 13,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 37,
                    width: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black54),
                    child: Center(
                      child: Text(
                        'Skip',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: whiteColor),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 13,
                  ),
                  Container(
                    height: 37,
                    width: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Color(0xff007BFD)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Join',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: whiteColor),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset('assets/Group 48096111.svg')
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
];

// Profile screen( Joined Activities )

class JoinedActivitiesData {
  final String image;
  final String profile;
  final String adventure;
  final String location;
  final String date;
  final String time;
  final String discription;

  JoinedActivitiesData(
    this.image,
    this.profile,
    this.adventure,
    this.location,
    this.date,
    this.time,
    this.discription,
  );
}

final List<JoinedActivitiesData> joinedActivitiesData = [
  JoinedActivitiesData(
    'assets/Group 48095849.png',
    'assets/ttt.png',
    'Hiking Adventure',
    'Green Valley National Park',
    'Sunday, February 9, 2025,',
    ' at 8:00 AM',
    'Escape into nature and enjoy a refreshing hiking adventure! Join fellow enthusiasts for a scenic trail featuring lush greenery.',
  ),
  JoinedActivitiesData(
    'assets/Group 48095848 (1).png',
    'assets/fantasy-shooting-star-landscape-night.png',
    'Stargazing and Mindfulness Night',
    'Hilltop Observatory, East Ridge',
    'Friday, February 23, 2025,',
    ' 8:00 AM',
    'Unwind under the stars! This event combines guided mindfulness meditation with a tour of constellations.',
  ),
  JoinedActivitiesData(
    'assets/Group 48095849.png',
    'assets/ttt.png',
    'Hiking Adventure',
    'Green Valley National Park',
    'Sunday, February 9, 2025,',
    ' at 8:00 AM',
    'Escape into nature and enjoy a refreshing hiking adventure! Join fellow enthusiasts for a scenic trail featuring lush greenery.',
  ),
  JoinedActivitiesData(
    'assets/Group 48095848 (1).png',
    'assets/fantasy-shooting-star-landscape-night.png',
    'Stargazing and Mindfulness Night',
    'Hilltop Observatory, East Ridge',
    'Friday, February 23, 2025,',
    ' 8:00 AM',
    'Unwind under the stars! This event combines guided mindfulness meditation with a tour of constellations.',
  ),
];

// Profile screen( Linked Accounts )

class LinkedAccountsData {
  final String image;
  final String name;
  final String discription;
  final String linkButton;

  LinkedAccountsData(
    this.image,
    this.name,
    this.discription,
    this.linkButton,
  );
}

final List<LinkedAccountsData> linkedAccountsData = [
  LinkedAccountsData(
    'assets/Group 48096191.png',
    'Instagram',
    'Allow users to display their favorite photos or curated travel highlights directly on their profile.',
    'Link',
  ),
  LinkedAccountsData(
    'assets/lin.png',
    'Linkedin',
    'Ideal for professional travelers, enabling them to share work trip experiences or network with others.',
    'Unink',
  ),
  LinkedAccountsData(
    'assets/Group 48096193.png',
    'Spotify',
    'Showcase favorite playlists or songs to highlight personal music tastes.',
    'Unink',
  ),
];

// Profile screen( All Achievements )

class AchievementsData {
  final String bandge;
  final String name;
  final String discription;
  final Widget status;

  AchievementsData(
    this.bandge,
    this.name,
    this.discription,
    this.status,
  );
}

final List<AchievementsData> achievementsData = [
  AchievementsData(
    'assets/first meet up badge.png',
    'First Meetup',
    'Attend First Meetup with mate',
    Text(
      'Claimed',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xff007BFD),
      ),
    ),
  ),
  AchievementsData(
    'assets/first meet up badge.png',
    'First Meetup',
    'Attend First Meetup with mate',
    Text(
      'Claimed',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xff007BFD),
      ),
    ),
  ),
  AchievementsData(
    'assets/first meet up badge.png',
    'First Meetup',
    'Attend First Meetup with mate',
    Text(
      'Claimed',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xff007BFD),
      ),
    ),
  ),
  AchievementsData(
    'assets/first meet up badge.png',
    'First Meetup',
    'Attend First Meetup with mate',
    Text(
      'Claimed',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xff007BFD),
      ),
    ),
  ),
];

// Profile screen( LeaderboardData )

class LeaderboardData {
  final String profile;
  final String name;
  final String discription;
  final String leaderboard;
  final Color color;

  LeaderboardData(
    this.profile,
    this.name,
    this.discription,
    this.leaderboard,
    this.color,
  );
}

final List<LeaderboardData> leaderboardData = [
  LeaderboardData(
    'assets/Group 48096083.png',
    'Muhammad Ali Khan',
    '@AliKhan',
    'assets/crown_svgrepo.com.png',
    Color(
      0xff64A940,
    ),
  ),
  LeaderboardData(
    'assets/Group 48096083.png',
    'Muhammad Ali Khan',
    '@AliKhan',
    'assets/crown_svgrepo.com.png',
    Color(
      0xff6B97FF,
    ),
  ),
  LeaderboardData(
    'assets/Group 48096083.png',
    'Muhammad Ali Khan',
    '@AliKhan',
    'assets/crown_svgrepo.com.png',
    Color(
      0xffB0B0F1,
    ),
  ),
  LeaderboardData(
    'assets/Group 48096083.png',
    'Muhammad Ali Khan',
    '@AliKhan',
    'assets/crown_svgrepo.com.png',
    Color(
      0xffF1F1F1,
    ),
  ),
];

// Choose Payment Method (Premium)

class PaymentMethod {
  final String image;
  final String name;

  PaymentMethod(
    this.image,
    this.name,
  );
}

final List<PaymentMethod> paymentMethod = [
  PaymentMethod(
    'assets/Group 48096151 (4).svg',
    'Credit Card',
  ),
  PaymentMethod(
    'assets/Group 48096151 (5).svg',
    'Stripe',
  ),
  PaymentMethod(
    'assets/paypal.svg',
    'Paypal',
  ),
];
