import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letschat/auth/login_screen.dart';
import 'package:letschat/screens/home_screen.dart';
import '../api/apis.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    Future.delayed(const Duration(seconds: 1), () {
      // exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white));

// if user have already logged in
      if (APIs.auth.currentUser != null) {
        log('\nUser : ${APIs.auth.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
      // move to homescreen
      else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome to Lets Chat"),
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              left: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('images/icon.png')),
          Positioned(
            bottom: mq.height * .15,
            right: mq.width * .1,
            width: mq.width * .8,
            height: mq.height * 0.07,
            child: const Text(
              "Made with ❤ at NITSRI",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Colors.black87, letterSpacing: .5),
            ),
          ),
        ],
      ),
    );
  }
}
