import 'package:eplanfront/Values/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

TextStyle buttonTextStyle = TextStyle(fontSize: 22.0, color: Colors.black);

BoxDecoration getBackGroundBoxDecor() {
  return BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/img/start_page.jpg"), fit: BoxFit.cover));
}

Widget getTitleText(String title) {
  return new Padding(
      padding: EdgeInsets.fromLTRB(30, 50, 30, 50),
      child: new Center(
          child: Text(title,
              style: TextStyle(fontSize: 25, color: Colors.white))));
}

Widget getIntroText() {
  return new Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
      child: Text("hello everyone\nwe are happy to see you here...",
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, color: Colors.white)));
}

Text getButtonText(String text) {
  return Text(text, textDirection: TextDirection.ltr, style: buttonTextStyle);
}

Widget getMatchParentWidthButton(String text, Function f, List margin) {
  return new Padding(
      padding: EdgeInsets.fromLTRB(20.0, margin[0], 20.0, margin[1]),
      child: SizedBox(
          width: double.infinity,
          height: 45,
          child: new RaisedButton(
            onPressed: f,
            child: getButtonText(text),
          )));
}
