import 'package:eplanfront/Pages/RegisterPage.dart';
import 'package:eplanfront/Pages/StudentList/StudentContactElement.dart';
import 'package:eplanfront/Pages/StudentList/SubTeacherStudent.dart';
import 'package:eplanfront/Values/Utils.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

class StudentList extends StatefulWidget {
  StudentList({
    Key key,
  }) : super(key: key);

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  static String subTeacher1 = "حامد";
  static List<Widget> students1 = [
    StudentElement("amir hossein", ""),
    StudentElement("hesam", ""),
    StudentElement("مصطفی", ""),
  ];
  static String subTeacher2 = "محمد";
  static List<Widget> students2 = [
    StudentElement("mahdi", ""),
    StudentElement("علی", "")
  ];

  static SubTeacherStudent s1 = SubTeacherStudent(subTeacher1, students1);
  static SubTeacherStudent s2 = SubTeacherStudent(subTeacher2, students2);

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("دانش آموزان"),
          backgroundColor: CustomTheme.theme[2],
          centerTitle: true,
          actions: <Widget>[Icon(Icons.settings)],
        ),
        body: new Container(
          color: CustomTheme.theme[0],
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: new SingleChildScrollView(
            child: new Column(
              verticalDirection: VerticalDirection.down,
              children: <Widget>[s1,s2],
            ),
          ),
        ),
      ),
    );
  }
}
