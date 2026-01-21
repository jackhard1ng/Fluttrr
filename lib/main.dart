import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fluttrr/auth_screens/splash_screen.dart'; // Fixed import
import 'package:fluttrr/constants/theme_data.dart'; // Fixed import
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/push_notifications.dart'; // Fixed path (lowercase 's' if needed)
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.requestPermission();
  final token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");

  await PushNotificationService.initialize();

  await Hive.initFlutter();
  await Hive.openBox('chatBox');
  await Hive.openBox('deleted_messages');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FluttrrApp());
}

class FluttrrApp extends StatelessWidget {
  const FluttrrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) => ResponsiveBreakpoints.builder(
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1200, name: DESKTOP),
        ],
        child: child!,
      ),
      themeMode: ThemeMode.system,
      darkTheme: ThemeNotifier().darkTheme,
      debugShowCheckedModeBanner: false,
      title: 'Fluttrr',
      theme: ThemeNotifier().lightTheme,
      home: const SplashScreen(),
    );
  }
}
