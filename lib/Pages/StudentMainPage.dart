import 'package:eplanfront/Pages/Chart/StudentStudyChart.dart';
import 'package:eplanfront/Pages/ChatRoom/chatscreen.dart';
import 'package:eplanfront/Values/Models.dart';
import 'package:eplanfront/Values/Utils.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:flutter/material.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:web_socket_channel/io.dart';

/////////////////////// Demo Data ////////////////////

List<OrdinalSales> barData = [
  new OrdinalSales("شنبه", 20),
  new OrdinalSales("یک شنبه", 22),
  new OrdinalSales("دو شنبه", 24),
  new OrdinalSales("سه شنبه", 20),
  new OrdinalSales("چهارشنبه", 22),
  new OrdinalSales("پنج شنبه", 24),
  new OrdinalSales("جمعه", 20),
];

List<LinearSales> pieData = [
  new LinearSales("ریاضی", 100),
  new LinearSales("ادبیات", 75),
  new LinearSales("علوم", 25),
  new LinearSales("زبان انگلیسی", 80),
  new LinearSales("عربی", 5),
  new LinearSales("شیمی", 25)
];

final channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
String username = "Mostafa";

//////////////////// Demo Data /////////////////////////

class UserPage extends StatefulWidget {
  UserPage(
      {@required this.data,
      @required this.titleColumn,
      @required this.titleRow});

  final List<List<String>> data;
  final List<String> titleColumn;
  final List<String> titleRow;

  @override
  _UserPageState createState() =>
      _UserPageState(data: data, titleColumn: titleColumn, titleRow: titleRow);
}

class _UserPageState extends State<UserPage> {
  Widget _currentPage;
  String _currentTitle;
  ChatScreen chatRoom;
  StickyHeadersTable studentTable;
  StudentStudyChart studentStudyChart;

  _UserPageState(
      {@required this.data,
      @required this.titleColumn,
      @required this.titleRow});

  final List<List<String>> data;
  final List<String> titleColumn;
  final List<String> titleRow;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text(_currentTitle == null ? tableTitle : _currentTitle),
            backgroundColor: Colors.lightBlue,
          ),
          bottomNavigationBar: new Container(
              color: Colors.lightBlue,
              height: 50.0,
              alignment: Alignment.center,
              child: new BottomAppBar(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.home, color: Colors.black),
                      onPressed: () {
                        _studentTableState();
                      },
                    ),
                    new IconButton(
                        icon: new Icon(Icons.message, color: Colors.black),
                        onPressed: () {
                          _chatRoomState();
                        }),
                    new IconButton(
                        icon: new Icon(Icons.show_chart, color: Colors.black),
                        onPressed: () {
                          _studentChartState();
                        }),
                    new IconButton(
                        icon: new Icon(Icons.account_box, color: Colors.black),
                        onPressed: null)
                  ],
                ),
              )),
          body: _currentPage == null ? getNewStickyTable() : _currentPage),
    );
  }

  Widget getNewStickyTable() {
    return StickyHeadersTable(
      columnsLength: titleColumn.length,
      rowsLength: titleRow.length,
      columnsTitleBuilder: (i) => Text(titleColumn[i]),
      rowsTitleBuilder: (i) => Text(titleRow[i]),
      contentCellBuilder: (i, j) =>
          Container(height: 50, width: 50, child: TextField()),
      legendCell: Text(' '),
    );
  }

  void _studentTableState() {
    if (studentTable == null) {
      studentTable = getNewStickyTable();
    }
    setState(() {
      _currentTitle = tableTitle;
      _currentPage = studentTable;
    });
  }

  void _chatRoomState() {
    if (chatRoom == null) {
      chatRoom = ChatScreen(username: username, channel: channel);
    }

    setState(() {
      _currentTitle = username;
      _currentPage = chatRoom;
    });
  }

  void _studentChartState() {
    if (studentStudyChart == null) {
      studentStudyChart = new StudentStudyChart(
          title: chartTitle, pieChartData: pieData, barChartData: barData);
    }
    setState(() {
      _currentTitle = chartTitle;
      _currentPage = studentStudyChart;
    });
  }
}
