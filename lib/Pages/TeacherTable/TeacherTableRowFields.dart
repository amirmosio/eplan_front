import 'dart:math';

import 'package:eplanfront/Values/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TableRowField extends StatefulWidget {
  final String dayName;
  final List<Widget> _fields = [];

  TableRowField({Key key, @required this.dayName}) : super(key: key);

  @override
  _TableRowFieldState createState() => _TableRowFieldState(dayName, _fields);

  List<Widget> getFields() {
    return _fields;
  }
}

class _TableRowFieldState extends State<TableRowField> {
  String dayName;
  List<Widget> _fields;

  _TableRowFieldState(this.dayName, this._fields);

  Widget build(BuildContext context) {
    return new Row(
      children: [getAddFieldIcon()] + _fields,
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

  Widget getRowElement(index) {
    return new Container(
      child: index == 0
          ? getAddFieldIcon()
          : (_fields.length + 1 == index
              ? getDay(dayName)
              : _fields[index - 1]),
      alignment: Alignment.centerRight,
    );
  }

  Widget getAddFieldIcon() {
    Widget icon = new RawMaterialButton(
      onPressed: () {
        setState(() {
          _fields.add(getEmptyFragment());
        });
      },
      child: new Icon(
        Icons.add,
        color: Colors.blue,
        size: 35.0,
      ),
      shape: new CircleBorder(),
      elevation: 2.0,
      fillColor: Colors.white,
      padding: const EdgeInsets.all(15.0),
    );
    return new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        width: 100,
        height: 100,
        margin: EdgeInsets.all(5),
        child: icon);
  }

  Widget getEmptyFragment() {
    Widget fields = new Column(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.only(bottom: 2, top: 5, left: 5, right: 5),
          child: new Container(
            height: 40,
            color: Color.fromARGB(150, 255, 255, 255),
            child: new TextField(
              style: TextStyle(fontSize: 15),
              decoration: new InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ),
        new Padding(
          padding: EdgeInsets.only(top: 5, bottom: 2, left: 5, right: 5),
          child: new Container(
              height: 40,
              color: Color.fromARGB(150, 255, 255, 255),
              child: new Row(
                children: <Widget>[
                  new Padding(
                    padding:
                        EdgeInsets.only(bottom: 2, top: 5, left: 10, right: 10),
                    child: new Container(
                      height: 40,
                      width: 70,
                      color: Color.fromARGB(150, 255, 255, 255),
                      child: new TextField(
                        style: TextStyle(fontSize: 15),
                        keyboardType: TextInputType.number,
                        decoration:
                            new InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                  Text('تا'),
                  new Padding(
                    padding:
                        EdgeInsets.only(bottom: 2, top: 5, left: 10, right: 10),
                    child: new Container(
                      height: 40,
                      width: 70,
                      color: Color.fromARGB(150, 255, 255, 255),
                      child: new TextField(
                        style: TextStyle(fontSize: 15),
                        keyboardType: TextInputType.number,
                        decoration:
                            new InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                ],
              )),
        )
      ],
    );
    return new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          color: Colors.lightBlue,
          borderRadius: new BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        width: 200,
        height: 100,
        margin: EdgeInsets.all(5),
        child: fields);
  }

  Widget getAllDays() {
    List<Widget> dayWidgets = [];
    days.forEach((day) => dayWidgets.add(getDay(day)));
    return new Column(children: dayWidgets);
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
