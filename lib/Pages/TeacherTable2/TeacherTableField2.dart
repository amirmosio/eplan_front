//import 'package:mhamrah/Pages/User/RegisterPage.dart';
//import 'package:mhamrah/Values/Utils.dart';
//import 'package:mhamrah/Values/string.dart';
//import 'package:mhamrah/Values/style.dart';
//import 'package:flutter/material.dart';
//
//class TeacherField2 extends StatefulWidget {
//  final double xSize;
//  final double ySize;
//
//  TeacherField2(this.xSize, this.ySize, {Key key}) : super(key: key);
//
//  @override
//  _TeacherFieldState2 createState() => _TeacherFieldState2(xSize, ySize);
//}
//
//class _TeacherFieldState2 extends State<TeacherField2> {
//  bool toggle;
//  bool _doneFlag = true;
//  final double xSize;
//  final double ySize;
//
//  _TeacherFieldState2(this.xSize, this.ySize);
//
//  Widget build(BuildContext context) {
//    return Container(
//      alignment: Alignment.center,
//      width: xSize,
//      height: ySize,
//      color: _doneFlag ? CustomTheme.theme[1] : CustomTheme.theme[2],
//      margin: EdgeInsets.all(4.0),
//      child: new Container(
//          child: new Column(
//        children: <Widget>[
//          new Container(
//            child: new TextField(
//              textAlign: TextAlign.center,
//              style: TextStyle(color: CustomTheme.theme[3]),
//            ),
//            height: ySize / 2,
//          ),
//          GestureDetector(
//            child: new Container(
//                height: ySize / 2,
//                width: xSize,
//                alignment: Alignment.centerRight,
//                child: Icon(_doneFlag
//                    ? Icons.check_box_outline_blank
//                    : Icons.done_outline)),
//            onTap: () {
//              setState(() {
//                _doneFlag = !_doneFlag;
//              });
//            },
//          )
//        ],
//      )),
//    );
//  }
//}
