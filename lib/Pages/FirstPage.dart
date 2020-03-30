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

class _FirstPageState extends State<FirstPage> with TickerProviderStateMixin {
  bool toggle;

  @override
  void initState() {
    super.initState();
    toggle = true;
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        home: Container(
          child: new Column(
            verticalDirection: VerticalDirection.up,
            children: <Widget>[getStartAnimation(), getIntroText()],
          ),
          color: CustomTheme.theme[0],
        ));
  }

  Widget getIntroText() {
    return new Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height / 2,
      child: new Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
        child: Text(
          "hello everyone\nwe are happy \n to see you here...",
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: CustomTheme.theme[3]),
        ),
      ),
    );
  }

  Widget getStartAnimation() {
    return new Container(
      height: MediaQuery.of(context).size.height / 2,
      child: AnimatedCrossFade(
        firstChild: getStartButton(),
        secondChild: new Container(
          height: MediaQuery.of(context).size.height / 2,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              getMatchParentWidthButton(registerLabel, () {
                navigateToSubPage(context, RegisterPage());
              }, [0.0, 20.0]),
              getMatchParentWidthButton(loginLabel, () {
                navigateToSubPage(context, LoginPage());
              }, [0.0, 20.0]),
            ],
          ),
          alignment: Alignment.center,
        ),
        duration: const Duration(milliseconds: 500),
        crossFadeState:
            toggle ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      ),
    );
  }

  Widget getStartButton() {
    return GestureDetector(
        onTap: () {
          setState(() {
            toggle = !toggle;
          });
        },
        child: new Container(
          child: Icon(
            Icons.play_circle_filled,
            size: 150,
            color: CustomTheme.theme[2],
          ),
          padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
        ));
  }

  Widget getMatchParentWidthButton(String text, Function f, List margin) {
    return new Container(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: new Padding(
        padding: EdgeInsets.fromLTRB(20.0, margin[0], 20.0, margin[1]),
        child: SizedBox(
          width: double.infinity,
          height: 45,
          child: new RaisedButton(
            color: CustomTheme.theme[3],
            onPressed: f,
            child: getButtonText(text),
          ),
        ),
      ),
    );
  }

  Text getButtonText(String text) {
    return Text(text, textDirection: TextDirection.ltr, style: buttonTextStyle);
  }
}
