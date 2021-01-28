import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/Pages/ConsultantProfile/ConsultantProfile.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:mhamrah/Pages/StudentList/StudentList.dart';
import 'package:mhamrah/Pages/StudentRequests/StudentRequestList.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/AppUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ChatRoom/ConsultantChannel/ConsChannelChatScreen.dart';

class ConsultantMainPage extends StatefulWidget {
  final SlideMainPageState s;
  final int startPage;

  ConsultantMainPage(this.s, this.startPage);

  @override
  ConsultantMainPageState createState() =>
      ConsultantMainPageState(s, startPage);
}

class ConsultantMainPageState extends State<ConsultantMainPage> {
  Widget _currentPage;
  SlideMainPageState s;
  int _selectedIndex = 3;
  static double tabHeight = 65;

  Widget _studentList;
  Widget _channelChat;
  Widget _studentRequestList;
  Widget _consultantProfile;
  static List<int> pageQueue = [];

  ConsultantMainPageState(this.s, this._selectedIndex);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _studentList = StudentListPage(s, this);
    _channelChat = ConsultantChannelChatScreen();
    _consultantProfile = ConsultantProfile();
    _studentRequestList = StudentRequestListPage();
    if (_selectedIndex == 0) {
      _currentPage = _consultantProfile;
    } else if (_selectedIndex == 1) {
      _currentPage = _channelChat;
    } else if (_selectedIndex == 2) {
      _currentPage = _studentRequestList;
    } else if (_selectedIndex == 3) {
      _currentPage = _studentList;
    }

    if (FirstPage.userType == 0) {
      checkNewApplicationVersion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (BuildContext context) {
      FirstPage.mainContext = context;
      return WillPopScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            resizeToAvoidBottomPadding: false,
            body: new Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: new Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: _currentPage,
                  ),
                  getBottomNavigationBar()
                ],
              ),
            ),
          ),
        ),
        onWillPop: onWillPop,
      );
    }));
  }

  Future<bool> onWillPop() async {
    int prevPage = -1;
    if (pageQueue.length > 1) {
      prevPage = pageQueue[pageQueue.length - 1];
      pageQueue.removeLast();
    } else if (pageQueue.length == 1) {
      if (pageQueue[0] == -1) {
        exit(0);
      } else {
        prevPage = pageQueue[0];
        pageQueue.removeLast();
      }
    } else {
      pageQueue.add(-1);
      Future.delayed(Duration(seconds: 3)).then((_) {
        setState(() {
          pageQueue.removeLast();
        });
      });
      showFlutterToast(doublePressExitWarning);
    }
    if (prevPage != -1) {
      changePage(prevPage);
    }
    return false;
  }

  void studentRequest() {
    if (_studentRequestList == null) {
      _studentRequestList = StudentRequestListPage();
    }
    setState(() {
      _currentPage = _studentRequestList;
    });
  }

  void studentList() {
    if (_studentList == null) {
      _studentList = StudentListPage(s, this);
    }
    setState(() {
      _currentPage = _studentList;
    });
  }

  void consultantChannelChatScreen() {
    if (_studentList == null) {
      _channelChat = ConsultantChannelChatScreen();
    }
    setState(() {
      _currentPage = _channelChat;
    });
  }

  void consultantProfile() {
    if (_consultantProfile == null) {
      _consultantProfile = ConsultantProfile();
    }
    setState(() {
      _currentPage = _consultantProfile;
    });
  }

  Widget getBottomNavigationBar() {
    return new Container(
      height: tabHeight,
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: _selectedIndex == 0 ? Colors.black : Colors.grey,
                size: 35,
              ),
              title: AutoSizeText("3")),
          BottomNavigationBarItem(
              icon: Icon(Icons.message,
                  color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                  size: 30),
              title: AutoSizeText("2")),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
                color: _selectedIndex == 2 ? Colors.black : Colors.grey,
                size: 40,
              ),
              title: AutoSizeText("1")),
          BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color: _selectedIndex == 3 ? Colors.black : Colors.grey,
                  size: 30),
              title: AutoSizeText("0")),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        selectedLabelStyle: getTextStyle(15, Colors.blue),
        onTap: _onItemTapped,
        unselectedItemColor: Colors.green,
      ),
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(Radius.circular(15))),
    );
  }

  void changePage(int index) {
    if (index == 0) {
      consultantProfile();
    } else if (index == 1) {
      consultantChannelChatScreen();
    } else if (index == 2) {
      studentRequest();
    } else if (index == 3) {
      studentList();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    pageQueue = [_selectedIndex];
    changePage(index);
  }
}
