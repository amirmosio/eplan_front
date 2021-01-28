//import 'package:mhamrah/Pages/TeacherTable/TeacherTableRowFields.dart';
//import 'package:mhamrah/Values/Models.dart';
//import 'package:mhamrah/Values/string.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart' as math;
//import 'dart:math';
//
//import 'package:flutter/material.dart';
//
//class TeacherTable extends StatefulWidget {
//  final List<Widget> _fieldsRows = [];
//
//  TeacherTable({Key key}) : super(key: key);
//
//  @override
//  _TeacherTableState createState() =>
//      _TeacherTableState(_fieldsRows);
//
//  List<Widget> getFieldsRows() {
//    return _fieldsRows;
//  }
//}
//
//class _TeacherTableState extends State<TeacherTable> {
//  List<Widget> _fieldRows;
//  MaxFieldNumber _maxField = MaxFieldNumber();
//
//  _TeacherTableState(this._fieldRows);
//
//  Widget build(BuildContext context) {
//    _fieldRows = getTeacherFieldList();
//    return new Container(
//      alignment: Alignment.bottomRight,
//      child: new SingleChildScrollView(
//        child: new SingleChildScrollView(
//          child: new Row(
//            mainAxisAlignment: MainAxisAlignment.end,
//            children: <Widget>[
//              new Container(
//                child: new Column(
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    mainAxisSize: MainAxisSize.max,
//                    children: _fieldRows),
//                alignment: Alignment.bottomRight,
//              ),
//              new Column(
//                children: getAllDays(),
//              ),
//            ],
//          ),
//          scrollDirection: Axis.horizontal,
//        ),
//        scrollDirection: Axis.vertical,
//      ),
//    );
//  }
//
//  List<Widget> getTeacherFieldList() {
//    List<Widget> addIcons = [];
//    for (int index = 0; index < days.length; index++) {
//      addIcons.add(
//          TableRowField(increaseMaxField, _maxField, dayName: days[index]));
//    }
//    return addIcons;
//  }
//
//  void increaseMaxField(int max) {
//    setState(() {
//      if (max > _maxField.max) {
//        _maxField.max  = max;
//      }
//    });
//  }
//
//  List<Widget> getAllDays() {
//    List<Widget> dayWidgets = [];
//    days.forEach((day) => dayWidgets.add(getDay(day)));
//    return dayWidgets;
//  }
//
//  Widget getDay(String day) {
//    Widget text = Transform.rotate(
//      angle: pi / 2,
//      child: new Text(
//        day,
//        style: new TextStyle(color: Colors.black, fontSize: 15),
//        textDirection: TextDirection.rtl,
//      ),
//    );
//    return new Container(
//        alignment: Alignment.center,
//        decoration: new BoxDecoration(
//          color: Colors.grey,
//          borderRadius: new BorderRadius.all(
//            Radius.circular(10),
//          ),
//        ),
//        width: 70,
//        height: 100,
//        margin: EdgeInsets.all(5),
//        child: text);
//  }
//}
