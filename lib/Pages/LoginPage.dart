import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordObscure = true;

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        home: new Scaffold(
            body: Container(
          decoration: getBackGroundBoxDecor(),
          child: new Column(
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              getTitleText(loginLabel),
              getUsernameTextField("Username"),
              getPasswordTextField(),
              getMatchParentWidthButton(loginLabel, () {
                navigateToSubPage(context, LoginPage());
              }, [ 0.0, 20.0]),
              getForgetPasswordText()
            ],
          ),
        )));
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
            style: TextStyle(fontSize: 19),
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
            style: TextStyle(fontSize: 19),
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
                        color: Colors.white,
                        decoration: TextDecoration.underline)))));
  }
}

Future navigateToSubPage(context, Widget w) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => w));
}
