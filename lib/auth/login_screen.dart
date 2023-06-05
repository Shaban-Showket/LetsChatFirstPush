import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:letschat/api/apis.dart';
import 'package:letschat/screens/home_screen.dart';
import '../main.dart';
import '../helpers/dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // varibale to contrll animation
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(vsync: this)s;
    Future.delayed(const Duration(microseconds: 400), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  _handleGoogleBtnClick() {
    // for showing progessBar on login screen
    Dialogs.showProgessBar(context);
    _signInWithGoogle().then((user) async => {
          // for hiding progressBar
          Navigator.pop(context),
          // user!=null
          if (true)
            {
              log('\nUser: ${user.user}'),
              log('\nUserAdditionalInfo: ${user.additionalUserInfo}'),
              if (await APIs.userExits())
                {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()))
                }
              else
                {
                  await APIs.createUer().then((value) => {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()))
                      })
                }
            }
        });
  }

  Future<UserCredential> _signInWithGoogle() async {
    try {
// Checking for internet connection...
      await InternetAddress.lookup("google.com");

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log("\n_signInWithGoogle: $e");
      Dialogs.showSnackBar(context, "Something went Wrong (Check Internet!)");
      return await _signInWithGoogle(); //because null canot be returned ERROER
    }
  }

  // sign out function
  //     _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn.signOut();
  // }

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
          AnimatedPositioned(
              top: mq.height * .15,
              left: _isAnimate ? mq.width * .25 : mq.width * .5,
              width: mq.width * .5,
              duration: const Duration(seconds: 1),
              child: Image.asset('images/icon.png')),
          Positioned(
              bottom: mq.height * .15,
              right: mq.width * .1,
              width: mq.width * .8,
              height: mq.height * 0.07,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade300,
                    shape: const StadiumBorder(),
                    elevation: 1,
                  ),
                  onPressed: () {
                    _handleGoogleBtnClick();
                  },
                  icon: Image.asset(
                    'images/google.png',
                    height: mq.height * .06,
                  ),
                  label: RichText(
                    text: const TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 19),
                        children: [
                          TextSpan(text: "SignIn with "),
                          TextSpan(
                              text: "Google",
                              style: TextStyle(fontWeight: FontWeight.w500))
                        ]),
                  ))),
        ],
      ),
    );
  }
}
