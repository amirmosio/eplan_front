import 'package:eplanfront/Pages/RegisterPage.dart';
import 'package:eplanfront/Pages/StudentList/StudentContactElement.dart';
import 'package:eplanfront/Values/Utils.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

class SubTeacherStudent extends StatefulWidget {
  final String subTeacherName;
  final List<Widget> students;

  SubTeacherStudent(
    this.subTeacherName,
    this.students, {
    Key key,
  }) : super(key: key);

  @override
  _SubTeacherStudentState createState() =>
      _SubTeacherStudentState(subTeacherName, students);
}

class _SubTeacherStudentState extends State<SubTeacherStudent> {
  String subTeacherName;
  bool _visibleFlag = false;
  List<Widget> students;

  _SubTeacherStudentState(this.subTeacherName, this.students);

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        getSubTeacherTitle(),
        new Visibility(
          child: new Container(
//            color: CustomTheme.theme[1],
            child: new Column(
              verticalDirection: VerticalDirection.down,
              children: students,
            ),
          ),
          visible: _visibleFlag,
        )
      ],
    );
  }

  Widget getSubTeacherTitle() {
    return new GestureDetector(
      child: new Padding(
        padding: EdgeInsets.all(5),
        child: new Container(
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
              color: CustomTheme.theme[2],
              borderRadius: new BorderRadius.all(Radius.circular(5))),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  subTeacherName,
                  style: TextStyle(color: CustomTheme.theme[3], fontSize: 18),
                ),
                Icon(
                  _visibleFlag ? Icons.arrow_upward : Icons.arrow_downward,
                  color: CustomTheme.theme[3],
                ),
              ]),
        ),
      ),
      onTap: () {
        setState(() {
          _visibleFlag = !_visibleFlag;
        });
      },
    );
  }
}
