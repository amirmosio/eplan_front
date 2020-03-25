import 'package:eplanfront/Values/Utils.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
//              decoration: getBackGroundBoxDecor(),
              child: new SingleChildScrollView(
                  child: new Column(
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  getTitleText(registerLabel),
                  getSimpleTextField(
                      "Complete Name", Icon(Icons.person), [10.0, 0.0]),
                  getSimpleTextField(
                      "City", Icon(Icons.location_city), [10.0, 0.0]),
                  getSimpleTextField("Mail", Icon(Icons.mail), [10.0, 0.0]),
                  getSimpleTextField(
                      "Teacher Username", Icon(Icons.person), [10.0, 0.0]),
//                      new Spacer(),
                  getSimpleTextField(
                      "Username", Icon(Icons.supervisor_account), [40.0, 20.0]),
                  getPasswordTextField("Password", [0.0, 10.0]),
                  getPasswordTextField("Confirm Password", [0.0, 5.0]),
                  new Container(
                      child: new Column(
                    verticalDirection: VerticalDirection.up,
                    children: <Widget>[
                      getForgetPasswordText(),
                      getMatchParentWidthButton(registerLabel, () {
                        navigateToSubPage(context, RegisterPage());
                      }, [20.0, 10.0])
                    ],
                  ))
                ],
              ))),
        ));
  }

  void _toggle() {
    setState(() {
      _passwordObscure = !_passwordObscure;
    });
  }

  Widget getPasswordTextField(String text, List margin) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20, margin[0], 20, margin[1]),
        child: TextFormField(
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
              labelText: text,
            )));
  }

  Widget getSimpleTextField(String title, Icon prefixIcon, List margin) {
    return new Padding(
        padding: EdgeInsets.fromLTRB(20, margin[0], 20, margin[1]),
        child: TextField(
            style: TextStyle(fontSize: 18),
            obscureText: false,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
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
                padding: EdgeInsets.fromLTRB(5, 0, 5, 20),
                child: Text(haveAccount,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
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
        ),
      ),
    );
  }

  Text getButtonText(String text) {
    return Text(text, textDirection: TextDirection.ltr, style: buttonTextStyle);
  }
}
