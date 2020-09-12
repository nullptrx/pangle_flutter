import 'package:flutter/material.dart';

const _textTheme = TextTheme(
  button: TextStyle(
    color: Colors.white,
  ),
);

final kThemeData = ThemeData(
  primaryColor: Color(0xFFFF4081),
  accentColor: Colors.white,
  accentTextTheme: _textTheme,
  primaryTextTheme: _textTheme,
  buttonTheme: ButtonThemeData(
    highlightColor: Colors.redAccent[400],
    buttonColor: Color(0xFFFF4081),
    textTheme: ButtonTextTheme.accent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  ),
  textTheme: TextTheme(),
);
