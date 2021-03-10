import 'package:flutter/material.dart';

const _textTheme = TextTheme(
  button: TextStyle(
    color: Colors.white,
  ),
);

final kThemeData = ThemeData(
  primaryColor: Color(0xFFFF4081),
  buttonColor: Colors.redAccent[400],
  accentColor: Colors.white,
  accentTextTheme: _textTheme,
  primaryTextTheme: _textTheme,
  buttonTheme: ButtonThemeData(
    highlightColor: Colors.redAccent[400],
    buttonColor: Color(0xFFFF4081),
    textTheme: ButtonTextTheme.accent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      onPrimary: Colors.white,
      primary: Color(0xFFFF4081),
      // minimumSize: Size(88, 36),
      // padding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    ),
  ),
  textTheme: TextTheme(),
);
