import 'package:flutter/material.dart';

final _defaultLightTheme = ThemeData.light();
final _defaultDarkTheme = ThemeData.dark();


final lightTheme = _defaultLightTheme.copyWith(
  textTheme: _defaultLightTheme.textTheme.copyWith(
    button: TextStyle(color: Colors.white,),
  ),
);
final darkTheme = _defaultDarkTheme.copyWith(
  scaffoldBackgroundColor: Colors.black12,
  hintColor: Colors.grey,
  primaryColor: Colors.lightBlue,
);
