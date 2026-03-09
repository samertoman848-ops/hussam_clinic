import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData().copyWith(
        primaryColor: Colors.pinkAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
          titleLarge: TextStyle(
            fontSize: 30.0,
            color: Colors.pinkAccent,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.0,
            color: Colors.pinkAccent,
          ),
          bodyLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: Colors.pink,
        ));
  }
}
