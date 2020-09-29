import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Ourtheme {
  Color _lightgreen = Color.fromARGB(255, 213, 235, 220);
  Color _lightgrey = Color.fromARGB(255, 164, 164, 164);
  Color _darkgrey = Color.fromARGB(255, 119, 224, 135);
  Color _green = Colors.greenAccent[100];

  ThemeData buildTheme() {
    return ThemeData(
      canvasColor: _lightgreen,
      primaryColor: _green,
      accentColor: _lightgrey,
      secondaryHeaderColor: _darkgrey,
      hintColor: _lightgrey,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(
            color: _lightgrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(
            color: _lightgreen,
          ),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _darkgrey,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        minWidth: 200,
        height: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
