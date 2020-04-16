import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/ui/components/app_logo.dart';
import 'package:flash_chat/ui/components/primary_button.dart';
import 'package:flash_chat/ui/screens/chat_screen.dart';
import 'package:flash_chat/ui/screens/registration_screen.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static final String name = 'WelcomeScreen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auth.currentUser().then((user) {
      if (user != null) {
        Navigator.pushNamed(context, ChatScreen.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: AppLogo.tag,
                  child: AppLogo(
                    height: 60.0,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                  speed: Duration(
                    milliseconds: 500,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            PrimaryButton(
              text: 'Log in',
              onTap: () {
                Navigator.pushNamed(context, LoginScreen.name);
              },
              color: Colors.lightBlueAccent,
            ),
            PrimaryButton(
              text: 'Register',
              onTap: () {
                Navigator.pushNamed(context, RegistrationScreen.name);
              },
              color: Colors.lightBlue,
            ),
          ],
        ),
      ),
    );
  }
}


