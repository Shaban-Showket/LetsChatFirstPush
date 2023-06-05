import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:letschat/screens/splash_screen.dart';
import 'firebase_options.dart';

// global object for accessing device screen size
late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // enter full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // setting the app orientation to portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lets Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 19),
            centerTitle: true,
            elevation: 1,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black)),
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

// channels
  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For showing message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');

  log('\nNotification Channel Result $result');
}
