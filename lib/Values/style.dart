import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class CustomTheme {
  static List<Color> theme = DarkTheme3.theme;
}

class DarkTheme1 {//internet theme with
  static List<Color> theme = [
    Color.fromARGB(255, 34, 40, 49), //back ground
    Color.fromARGB(255, 57, 62, 70), //items
    Color.fromARGB(255, 0, 173, 181),
    Color.fromARGB(255, 238, 238, 238), //button and text
    Color.fromARGB(255, 0, 173, 181), //appbar
  ];
}

class DarkTheme2 {
  static List<Color> theme = [
    Color.fromARGB(255, 34, 40, 49), //back ground
    Color.fromARGB(255, 192, 192, 192),
    Color.fromARGB(255, 0, 173, 181),
    Color.fromARGB(255, 238, 238, 238), //button and text
    Color.fromARGB(255, 0, 173, 181), //appbar
  ];
}

class DarkTheme3 {//Ali's dark theme
  static List<Color> theme = [
    Color.fromARGB(255, 18, 18, 18), //back ground
    Color.fromARGB(255, 212, 211, 213),
    Color.fromARGB(255, 0, 173, 181),
    Color.fromARGB(255, 238, 238, 238), //button and text
    Color.fromARGB(255, 0, 173, 181), //appbar
  ];
}

TextStyle buttonTextStyle = TextStyle(fontSize: 22.0, color: Colors.black);

charts.TextStyleSpec chartLabelTextStyle =
    new charts.TextStyleSpec(fontSize: 14, color: charts.MaterialPalette.white);

Widget getTitleText(String title) {
  return new Padding(
      padding: EdgeInsets.fromLTRB(30, 50, 30, 50),
      child: new Center(
          child: Text(title,
              style: TextStyle(fontSize: 25, color: CustomTheme.theme[3]))));
}
