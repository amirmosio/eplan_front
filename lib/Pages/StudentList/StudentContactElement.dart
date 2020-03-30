import 'package:eplanfront/Pages/RegisterPage.dart';
import 'package:eplanfront/Values/Utils.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

import '../StudentMainPage.dart';

class StudentElement extends StatefulWidget {
  final String name;
  final String avatarURL;

  StudentElement(
    this.name,
    this.avatarURL, {
    Key key,
  }) : super(key: key);

  @override
  _StudentElementState createState() => _StudentElementState(name, avatarURL);
}

class _StudentElementState extends State<StudentElement> {
  String name;
  String avatarURL;
  final columns = 7;
  final rows = 13;

  _StudentElementState(this.name, this.avatarURL);

  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new Padding(
        padding: EdgeInsets.all(3),
        child: new Container(
          height: 65,
          decoration: new BoxDecoration(
              color: CustomTheme.theme[1],
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[getContactDetail(), getContactAvatar()],
          ),
        ),
      ),
      onTap: () {
        navigateToSubPage(
            context,
            UserPage(
                data: _makeData(),
                titleColumn: _makeTitleColumn(),
                titleRow: _makeTitleRow()));
      },
    );
  }

  List<String> _makeTitleColumn() => List.generate(columns, (i) => days[i]);

  /// Simple generator for row title
  List<String> _makeTitleRow() => List.generate(rows, (i) => lessons[i]);

  List<List<String>> _makeData() {
    final List<List<String>> output = [];
    for (int i = 0; i < columns; i++) {
      final List<String> row = [];
      for (int j = 0; j < rows; j++) {
        row.add('T$i : L$j');
      }
      output.add(row);
    }
    return output;
  }

  Widget getContactAvatar() {
    return new Container(
      color: CustomTheme.theme[1],
      margin: const EdgeInsets.all(10),
      child: new CircleAvatar(
        child: new Image.network(
            "http://res.cloudinary.com/kennyy/image/upload/v1531317427/avatar_z1rc6f.png"),
      ),
    );
  }

  Widget getContactDetail() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: new Column(children: <Widget>[new Text(
        name,
        style: TextStyle(fontSize: 15, color: CustomTheme.theme[0]),
      ),new Text("پایه:تجربی",style: TextStyle(fontSize: 14,color: CustomTheme.theme[0]),)])
    );
  }
}
