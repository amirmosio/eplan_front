import 'package:eplanfront/Pages/RegisterPage.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'LoginPage.dart';

MyApp myApp = MyApp();

void main() => runApp(myApp);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class FirstPage extends StatefulWidget {
  FirstPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
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
              }, [ 0.0, 20.0]),
              getIntroText()
            ],
          ),
        ));
  }
}

Future navigateToSubPage(context, Widget w) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => w));
}
