import 'package:eplanfront/Pages/Chart/StudentStudyChart.dart';
import 'package:eplanfront/Pages/ChatRoom/chatscreen.dart';
import 'package:eplanfront/Pages/TeacherProfile.dart';
import 'package:eplanfront/Pages/TeacherTable/TeacherTable.dart';
import 'package:eplanfront/Values/Models.dart';
import 'package:eplanfront/Values/string.dart';
import 'package:eplanfront/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:web_socket_channel/io.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'BlueTable/BlueTable.dart';

/////////////////////// Demo Data ////////////////////

List<OrdinalSales> barData = [
  new OrdinalSales("شنبه", 13),
  new OrdinalSales("یک شنبه", 12),
  new OrdinalSales("دو شنبه", 3),
  new OrdinalSales("سه شنبه", 8),
  new OrdinalSales("چهارشنبه", 10),
  new OrdinalSales("پنج شنبه", 6),
  new OrdinalSales("جمعه", 10),
];

List<LinearSales> pieData = [
  new LinearSales("ریاضی", 100, charts.Color.fromHex(code: "#505050")),
  new LinearSales("ادبیات", 75, charts.Color.fromHex(code: "#646464")),
  new LinearSales("علوم", 25, charts.Color.fromHex(code: "#787878")),
  new LinearSales("زبان انگلیسی", 80, charts.Color.fromHex(code: "#8c8c8c")),
  new LinearSales("عربی", 5, charts.Color.fromHex(code: "#a0a0a0")),
  new LinearSales("شیمی", 25, charts.Color.fromHex(code: "#b4b4b4"))
];

final channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
String username = "Mostafa";

String teacherName = "Mostafa Amiri";
String proURL =
    "http://res.cloudinary.com/kennyy/image/upload/v1531317427/avatar_z1rc6f.png";
String bio = "سلام" +
    "\n" +
    "من مشاور برای دانش اموزان کنکوری عزیز هستم." +
    "\n" +
    "تمام هدف من بالا بردن کارایی دانش اموزان برای امادگی نهایی ست.";

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
  int _selectedIndex = 0;

  Widget teacherTable;
  Widget chatRoom;
  Widget studentTable;
  Widget studentStudyChart;
  Widget teacherProfile;

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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text(
              _currentTitle == null ? blueNoteBook : _currentTitle,
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: CustomTheme.theme[4],
            centerTitle: true,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule, color: Colors.green),
                title: Text('برنامه مشاور'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.note, color: Colors.lightBlue),
                title: Text('دفترچه برنامه ریزی'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message, color: Colors.orange),
                title: Text('گفتگو'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart, color: Colors.black),
                title: Text('نمودارها'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_box, color: Colors.pink),
                title: Text('پروفایل'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
            unselectedItemColor: Colors.green,
          ),
          body: new Container(
            child: _currentPage == null ? TeacherTableFields() : _currentPage,
            color: CustomTheme.theme[0],
          )),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      _teacherTable();
    } else if (index == 1) {
      _studentTableState();
    } else if (index == 2) {
      _chatRoomState();
    } else if (index == 3) {
      _studentChartState();
    } else if (index == 4) {
      _teacherProState();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget getNewStickyTable() {
//    return StickyHeadersTable(
//      columnsLength: titleColumn.length,
//      rowsLength: titleRow.length,
//      columnsTitleBuilder: (i) => Text(titleColumn[i]),
//      rowsTitleBuilder: (i) => Text(
//        titleRow[i],
//        textAlign: TextAlign.center,
//      ),
//      contentCellBuilder: (i, j) =>
//          Container(height: 50, width: 50, child: TextField()),
//      legendCell: Text(''),
//    );
    return BlueTable();
  }

  void _teacherTable() {
    if (teacherTable == null) {
      teacherTable = TeacherTableFields();
    }
    setState(() {
      _currentTitle = teacherTableTitle;
      _currentPage = teacherTable;
    });
  }

  void _studentTableState() {
    if (studentTable == null) {
      studentTable = getNewStickyTable();
    }
    setState(() {
      _currentTitle = blueNoteBook;
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

  void _teacherProState() {
    if (teacherProfile == null) {
      teacherProfile = new TeacherProfile(
          teacherName: teacherName, teacherBio: bio, teacherProFileURL: proURL);
    }
    setState(() {
      _currentTitle = teacherProfileTitle;
      _currentPage = teacherProfile;
    });
  }
}
