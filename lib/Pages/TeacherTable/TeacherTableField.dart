import 'package:eplanfront/Pages/RegisterPage.dart';
import 'package:eplanfront/Values/Utils.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

class TeacherField extends StatefulWidget {
  TeacherField({Key key}) : super(key: key);

  @override
  _TeacherFieldState createState() => _TeacherFieldState();
}

class _TeacherFieldState extends State<TeacherField> {
  bool toggle;
  bool _doneFlag = true;

  Widget build(BuildContext context) {
    Widget fields = new Column(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.only(bottom: 2, top: 5, left: 5, right: 5),
          child: new Container(
            height: 40,
            color: Color.fromARGB(150, 255, 255, 255),
            child: new TextField(
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
              decoration: new InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ),
        new Padding(
          padding: EdgeInsets.only(top: 5, bottom: 2, left: 5, right: 5),
          child: new Container(
              height: 40,
              color: Color.fromARGB(150, 230, 230, 230),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.only(bottom: 2, top: 5, left: 10, right: 10),
                    child: new Container(
                      height: 40,
                      width: 60,
                      alignment: Alignment.topCenter,
                      color: Color.fromARGB(150, 255, 255, 255),
                      child: new TextField(
                        style: TextStyle(fontSize: 15),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration:
                            new InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                  Text(
                    '-',
                    style: TextStyle(color: CustomTheme.theme[3]),
                  ),
                  new Padding(
                    padding:
                        EdgeInsets.only(bottom: 2, top: 5, left: 10, right: 10),
                    child: new Container(
                      height: 40,
                      width: 60,
                      color: Color.fromARGB(150, 255, 255, 255),
                      child: new TextField(
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration:
                            new InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Icon(_doneFlag
                        ? Icons.check_box_outline_blank
                        : Icons.done_outline),
                    onTap: () {
                      setState(() {
                        _doneFlag = !_doneFlag;
                      });
                    },
                  )
                ],
              )),
        )
      ],
    );
    return new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          color: _doneFlag ? CustomTheme.theme[1] : CustomTheme.theme[2],
          borderRadius: new BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        width: 200,
        height: 100,
        margin: EdgeInsets.all(5),
        child: fields);
  }
}
