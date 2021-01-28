//import 'dart:math';
//
//import 'package:mhamrah/Pages/TeacherTable/TeacherTableField.dart';
//import 'package:mhamrah/Values/Models.dart';
//import 'package:mhamrah/Values/string.dart';
//import 'package:mhamrah/Values/style.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//
//class TableRowField extends StatefulWidget {
//  final String dayName;
//  final List<Widget> _fields = [];
//  final MaxFieldNumber _maxField;
//  final Function setMaxState;
//
//  TableRowField(this.setMaxState, this._maxField,
//      {Key key, @required this.dayName})
//      : super(key: key);
//
//  @override
//  _TableRowFieldState createState() =>
//      _TableRowFieldState(_maxField, dayName, _fields, setMaxState);
//
//  List<Widget> getFields() {
//    return _fields;
//  }
//}
//
//class _TableRowFieldState extends State<TableRowField> {
//  String dayName;
//  List<Widget> _fields;
//  MaxFieldNumber _maxField;
//  Function setMaxState;
//
//  _TableRowFieldState(
//      this._maxField, this.dayName, this._fields, this.setMaxState);
//
//  Widget build(BuildContext context) {
//    return new Container(
//      width: (_maxField.max) * 210.0 + 120,
//      alignment: Alignment.centerRight,
//      child: new Row(
//        children: [getAddFieldIcon()] + _fields,
//        mainAxisSize: MainAxisSize.max,
//        mainAxisAlignment: MainAxisAlignment.end,
//      ),
//    );
//  }
//
//  Widget getAddFieldIcon() {
//    Widget icon = new RawMaterialButton(
//      onPressed: () {
//        setState(() {
//          _fields.add(TeacherField());
//          setMaxState(_fields.length);
//        });
//      },
//      child: new Icon(
//        Icons.add,
//        color: CustomTheme.theme[4],
//        size: 35.0,
//      ),
//      shape: new CircleBorder(),
//      elevation: 2.0,
//      fillColor: Colors.white,
//      padding: const EdgeInsets.all(15.0),
//    );
//    return new Container(
//        alignment: Alignment.center,
//        decoration: new BoxDecoration(
//          borderRadius: new BorderRadius.all(
//            Radius.circular(10),
//          ),
//        ),
//        width: 100,
//        height: 100,
//        margin: EdgeInsets.all(5),
//        child: icon);
//  }
//}
