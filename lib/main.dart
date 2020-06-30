import 'package:flash_chat/domain/user_bloc.dart';
import 'package:flash_chat/ui/screens/chat_list_screen.dart';
import 'package:flash_chat/ui/screens/chat_screen.dart';
import 'package:flash_chat/ui/screens/login_screen.dart';
import 'package:flash_chat/ui/screens/new_chat_screen.dart';
import 'package:flash_chat/ui/screens/registration_screen.dart';
import 'package:flash_chat/ui/screens/welcome_screen.dart';
import 'package:flash_chat/ui/theme.dart';
import 'package:flutter/material.dart';

import 'ui/components/bloc_provider.dart';

void main() {
  runApp(FlashChatApp());
}

class FlashChatApp extends StatefulWidget {
  @override
  _FlashChatAppState createState() => _FlashChatAppState();
}

class _FlashChatAppState extends State<FlashChatApp> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
      child: MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        initialRoute: WelcomeScreen.name,
        routes: {
          ChatScreen.name: (context) => ChatScreen(),
          LoginScreen.name: (context) => LoginScreen(),
          RegistrationScreen.name: (context) => RegistrationScreen(),
          WelcomeScreen.name: (context) => WelcomeScreen(),
          NewChatScreen.name: (context) => NewChatScreen(),
          ChatListScreen.name: (context) => ChatListScreen(),
        },
        themeMode: ThemeMode.system,
      ),
      bloc: UserBloc(),
    );
  }
}
