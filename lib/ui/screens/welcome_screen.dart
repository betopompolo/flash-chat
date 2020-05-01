import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/bloc/user.dart';
import 'package:flash_chat/bloc/user_bloc.dart';
import 'package:flash_chat/ui/components/app_logo.dart';
import 'package:flash_chat/ui/components/primary_button.dart';
import 'package:flash_chat/ui/screens/chat_list_screen.dart';
import 'package:flash_chat/ui/screens/registration_screen.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static final String name = 'WelcomeScreen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _userBloc = UserBloc();
  StreamSubscription<User> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _userBloc.authUserStream.listen(_handleAuthChange);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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

  _handleAuthChange(User user) {
    if (user == null) {
      return;
    }

    Navigator.pushNamed(
      context, 
      ChatListScreen.name,
    );
  }
}


