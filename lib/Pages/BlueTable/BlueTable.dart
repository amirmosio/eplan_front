import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/material.dart';

class BlueTable extends StatefulWidget {
  BlueTable({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BlueTableState createState() => _BlueTableState();
}

class _BlueTableState extends State<BlueTable> with TickerProviderStateMixin {
  bool toggle;
  double xSize = 100.0;
  double ySize = 88.0;

  @override
  void initState() {
    super.initState();
    toggle = true;
  }

  List<Widget> _buildCells(int count) {
    return List.generate(
      count,
          (index) =>
          Container(
            alignment: Alignment.center,
            width: xSize,
            height: ySize,
            color: CustomTheme.theme[1],
            margin: EdgeInsets.all(4.0),
            child: new Container(
                child: new Column(
                  children: <Widget>[
                    new Container(child: new TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CustomTheme.theme[3]),
                    ), height: ySize / 2,),
                    new Container(child: new TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CustomTheme.theme[3]),
                    ), height: ySize / 2,),
                  ],
                )),
          ),
    );
  }

  List<Widget> _getDaysRow() {
    return List.generate(
      days.length + 1,
          (index) =>
          Container(
            alignment: Alignment.center,
            width: xSize,
            height: ySize,
            color: Colors.white,
            margin: EdgeInsets.all(4.0),
            child: index == 0
                ? Text("جمع", style: TextStyle(fontSize: 15))
                : Text(
                days[days.length - (index)], style: TextStyle(fontSize: 15)),
          ),
    );
  }

  List<Widget> _getLessons() {
    return List.generate(
      lessons.length + 2,
          (index) =>
          Container(
            alignment: Alignment.center,
            width: xSize,
            height: ySize,
            color: Colors.white,
            margin: EdgeInsets.all(4.0),
            child: index == 0
                ? Text("", style: TextStyle(fontSize: 15))
                : index == lessons.length + 1
                ? Text("جمع", style: TextStyle(fontSize: 15))
                : Text(lessons[index - 1], style: TextStyle(fontSize: 15)),
          ),
    );
  }

  List<Widget> _buildRows(int count) {
    return List.generate(
      count,
          (index) =>
          Row(
            children: index == 0 ? _getDaysRow() : _buildCells(days.length + 1),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildRows(lessons.length + 2),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getLessons(),
          ),
        ],
      ),
    );
  }
}
