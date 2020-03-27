import 'package:eplanfront/Pages/StudentMainPage.dart';
import 'package:eplanfront/Values/Utils.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

///////////// Demo data //////////////
final columns = 7;
final rows = 13;



List<List<String>> _makeData() {
  final List<List<String>> output = [];
  for (int i = 0; i < columns; i++) {
    final List<String> row = [];
    for (int j = 0; j < rows; j++) {
      row.add('T$i : L$j');
    }
    output.add(row);
  }
  return output;
}

/// Simple generator for column title
List<String> _makeTitleColumn() => List.generate(columns, (i) => days[i]);

/// Simple generator for row title
List<String> _makeTitleRow() => List.generate(rows, (i) => lessons[i]);

///////////////////// Demo data
class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordObscure = true;

  BoxDecoration getBackGroundBoxDecor() {
    return BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/img/start_page.jpg"), fit: BoxFit.cover));
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        home: new Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
//                decoration: getBackGroundBoxDecor(),
                child: new SingleChildScrollView(
                    child: new Column(
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    getTitleText(loginLabel),
                    getUsernameTextField("Username"),
                    getPasswordTextField(),
                    getMatchParentWidthButton(loginLabel, () {
                      navigateToSubPage(context, UserPage(data: _makeData(), titleColumn: _makeTitleColumn(), titleRow: _makeTitleRow()));
                    }, [0.0, 20.0]),
                    getForgetPasswordText()
                  ],
                )))));
  }

  void _toggle() {
    setState(() {
      _passwordObscure = !_passwordObscure;
    });
  }

  Widget getPasswordTextField() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 50),
        child: TextField(
            style: TextStyle(fontSize: 18),
            obscureText: _passwordObscure,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                  icon: Icon(
                      !_passwordObscure ? Icons.remove_red_eye : Icons.remove),
                  onPressed: _toggle),
              filled: true,
              fillColor: Color.fromARGB(120, 255, 255, 255),
              border: OutlineInputBorder(),
              labelText: 'Password',
            )));
  }

  Widget getUsernameTextField(String title) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: TextField(
            style: TextStyle(fontSize: 18),
            obscureText: false,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.supervisor_account),
              filled: true,
              fillColor: Color.fromARGB(120, 255, 255, 255),
              border: OutlineInputBorder(),
              labelText: title,
            )));
  }

  Widget getForgetPasswordText() {
    return new GestureDetector(
        onTap: () {}, //TODO
        child: new Center(
            child: new Padding(
                padding: EdgeInsets.all(5),
                child: Text(forgetPassSentence,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        decoration: TextDecoration.underline)))));
  }

  Widget getMatchParentWidthButton(String text, Function f, List margin) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20.0, margin[0], 20.0, margin[1]),
        child: SizedBox(
            width: double.infinity,
            height: 45,
            child: new RaisedButton(
              color: Colors.lightBlue,
              onPressed: f,
              child: getButtonText(text),
            )));
  }

  Text getButtonText(String text) {
    return Text(text, textDirection: TextDirection.ltr, style: buttonTextStyle);
  }
}
