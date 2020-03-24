import 'package:eplanfront/Pages/RegisterPage.dart';
import 'package:eplanfront/Values/Utils.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';


class FirstPage extends StatefulWidget {
  FirstPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  BoxDecoration getBackGroundBoxDecor() {
    return BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/img/start_page.jpg"), fit: BoxFit.cover));
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        home: Container(
          decoration: getBackGroundBoxDecor(),
          child: new Column(
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
              getMatchParentWidthButton(registerLabel, () {
                navigateToSubPage(context, RegisterPage());
              }, [0.0, 20.0]),
              getMatchParentWidthButton(loginLabel, () {
                navigateToSubPage(context, LoginPage());
              }, [0.0, 20.0]),
              getIntroText()
            ],
          ),
        ));
  }

  Widget getIntroText() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
        child: Text("hello everyone\nwe are happy to see you here...",
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, color: Colors.white)));
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

  Text getButtonText(String text) {
    return Text(text, textDirection: TextDirection.ltr, style: buttonTextStyle);
  }
}