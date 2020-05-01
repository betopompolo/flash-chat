import 'dart:ui';

import 'package:flash_chat/ui/screens/chat_list_screen.dart';
import 'package:flash_chat/ui/screens/chat_screen.dart';
import 'package:flash_chat/ui/screens/login_screen.dart';
import 'package:flash_chat/ui/screens/new_chat_screen.dart';
import 'package:flash_chat/ui/screens/registration_screen.dart';
import 'package:flash_chat/ui/screens/welcome_screen.dart';
import 'package:flash_chat/ui/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(FlashChatApp());
}

class FlashChatApp extends StatefulWidget {
  @override
  _FlashChatAppState createState() => _FlashChatAppState();
}

class _FlashChatAppState extends State<FlashChatApp> with WidgetsBindingObserver {
  ThemeData _appTheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appTheme = _getTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _appTheme,
      initialRoute: WelcomeScreen.name,
      routes: {
        ChatScreen.name: (context) => ChatScreen(),
        LoginScreen.name: (context) => LoginScreen(),
        RegistrationScreen.name: (context) => RegistrationScreen(),
        WelcomeScreen.name: (context) => WelcomeScreen(),
        NewChatScreen.name: (context) => NewChatScreen(),
        ChatListScreen.name: (context) => ChatListScreen(),
      },
    );
  }

  _getTheme() {
    final isPlatformUsingDarkTheme = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
    return isPlatformUsingDarkTheme ? darkTheme : lightTheme;
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      _appTheme = _getTheme();
    });
  }
}
