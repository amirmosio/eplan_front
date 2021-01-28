//import 'package:mhamrah/Values/string.dart';
//import 'package:mhamrah/Values/style.dart';
//import 'package:flutter/material.dart';
//
//import 'TeacherTableField2.dart';
//
//class TeacherTable2 extends StatefulWidget {
//  TeacherTable2({Key key, this.title}) : super(key: key);
//
//  final String title;
//
//  @override
//  _BlueTableState createState() => _BlueTableState();
//}
//
//class _BlueTableState extends State<TeacherTable2> {
//  bool toggle;
//  double xSize = 150.0;
//  double ySize = 80.0;
//
//  List<Widget> _buildCells(int count) {
//    return List.generate(
//      count,
//      (index) => TeacherField2(xSize, ySize),
//    );
//  }
//
//  List<Widget> _getHoursPartRow() {
//    return List.generate(
//      hoursPart.length + 1,
//      (index) => Container(
//        alignment: Alignment.center,
//        width: xSize,
//        height: ySize,
//        color: Colors.white,
//        margin: EdgeInsets.all(4.0),
//        child: index == 0
//            ? Text("جمع", style: TextStyle(fontSize: 15))
//            : Text(hoursPart[hoursPart.length - (index)],
//                style: TextStyle(fontSize: 15)),
//      ),
//    );
//  }
//
//  List<Widget> _getDays() {
//    return List.generate(
//      days.length + 2,
//      (index) => Container(
//        alignment: Alignment.center,
//        width: xSize,
//        height: ySize,
//        color: Colors.white,
//        margin: EdgeInsets.all(4.0),
//        child: index == 0
//            ? Text("", style: TextStyle(fontSize: 15))
//            : index == days.length + 1
//                ? Text("جمع", style: TextStyle(fontSize: 15))
//                : Text(days[index - 1], style: TextStyle(fontSize: 15)),
//      ),
//    );
//  }
//
//  List<Widget> _buildRows(int count) {
//    return List.generate(
//      count,
//      (index) => Row(
//        children:
//            index == 0 ? _getHoursPartRow() : _buildCells(hoursPart.length + 1),
//      ),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return SingleChildScrollView(
//      child: Row(
//        crossAxisAlignment: CrossAxisAlignment.end,
//        mainAxisAlignment: MainAxisAlignment.start,
//        children: <Widget>[
//          Flexible(
//            child: SingleChildScrollView(
//              scrollDirection: Axis.horizontal,
//              reverse: true,
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: _buildRows(days.length + 2),
//              ),
//            ),
//          ),
//          Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: _getDays(),
//          ),
//        ],
//      ),
//    );
//  }
//}
