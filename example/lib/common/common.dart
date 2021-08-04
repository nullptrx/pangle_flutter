/*
 * Copyright (c) 2021 nullptrX
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

var kThemeStatus = PangleTheme.light;

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
