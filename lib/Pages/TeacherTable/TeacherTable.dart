import 'package:eplanfront/Pages/TeacherTable/TeacherTableRowFields.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as math;
import 'dart:math';

import 'package:flutter/material.dart';

class TeacherTableFields extends StatefulWidget {
  final List<Widget> _fieldsRows = [];

  TeacherTableFields({Key key}) : super(key: key);

  @override
  _TeacherTableFieldsState createState() =>
      _TeacherTableFieldsState(_fieldsRows);

  List<Widget> getFieldsRows() {
    return _fieldsRows;
  }
}

class _TeacherTableFieldsState extends State<TeacherTableFields> {
  List<Widget> _fieldRows;

  _TeacherTableFieldsState(this._fieldRows);

  Widget build(BuildContext context) {
    _fieldRows = getTeacherFieldList();
    return new Container(
      alignment: Alignment.bottomRight,
      child: new SingleChildScrollView(
        child: new SingleChildScrollView(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Container(
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _fieldRows),
                alignment: Alignment.bottomRight,
              ),
              new Column(
                children: getAllDays(),
              ),
            ],
          ),
          scrollDirection: Axis.horizontal,
        ),
        scrollDirection: Axis.vertical,
      ),
    );
  }

  List<Widget> getTeacherFieldList() {
    List<Widget> addIcons = [];
    for (int index = 0; index < days.length; index++) {
      addIcons.add(TableRowField(dayName: days[index]));
    }
    return addIcons;
  }

  List<Widget> getAllDays() {
    List<Widget> dayWidgets = [];
    days.forEach((day) => dayWidgets.add(getDay(day)));
    return dayWidgets;
  }

  Widget getDay(String day) {
    Widget text = Transform.rotate(
      angle: pi / 2,
      child: new Text(
        day,
        style: new TextStyle(color: Colors.black, fontSize: 17),
        textDirection: TextDirection.rtl,
      ),
    );
    return new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          color: Colors.lightBlue,
          borderRadius: new BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        width: 60,
        height: 100,
        margin: EdgeInsets.all(5),
        child: text);
  }
}
