import 'dart:io';

import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ChatRoom/ConsultantChannel/ChannelChatScreenView.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/AppUtils.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatScreen.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'BlueTable1/BlueTable1.dart';
import 'BlueTable2/BlueTable2.dart';
import 'ChatRoom/ChatContactList.dart';
import 'StudentProfile/StudentProfile.dart';

/////////////////////// Demo Data ////////////////////

class StudentMainPage extends StatefulWidget {
  static String studentUsername;
  ConsultantTable teacherTable;
  Widget chatRoom;
  ChatContactList chatContactList;
  BlueTable1 studentTable1;
  BlueTable2 studentTable2;
  StudentProfile studentProfile;
  Widget currentPage;
  static StudentMainPageState state;
  static int selectedIndex = 0;

  StudentMainPage(studentUsername) {
    StudentMainPage.studentUsername = studentUsername;
  }

  @override
  StudentMainPageState createState() {
    state = StudentMainPageState();
    return state;
  }
}

class StudentMainPageState extends State<StudentMainPage> {
  static double appbarHeightPercent = 18;
  static double appbarDropDownHeight = 40;
  static List<int> pageQueue = [];
  static const kBottomNavigationBarHeight = 56.0;
  static String selectedPlanName = "";
  static int selectedDayIndex = 0;
  static bool sharePageCurrentRoute = false;
  static BuildContext sharedContext;

  StudentMainPageState();

  bool hideBlue2Table() {
    int type = LSM.getUserModeSync();
    if (type == 0) {
      return LSM.getConsultantSettingSync().hideBlue2Table;
    } else if (type == 1) {
      return LSM.getStudentSettingSync().hideBlue2Table;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageQueue.add(0);
    if (hideBlue2Table()) {
      StudentMainPage.selectedIndex = 3;
    } else {
      StudentMainPage.selectedIndex = 4;
    }
    if (FirstPage.userType == 1) {
      checkNewApplicationVersion();
//      sendAppUsageData();
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Builder(
        builder: (BuildContext context) {
          FirstPage.mainContext = context;
          return WillPopScope(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: ImageIcon(
                            AssetImage("assets/img/5.png"),
                          ),
                          label: kIsWeb ? "....." : 'پروفایل',
                        ),
                        BottomNavigationBarItem(
                          icon: ImageIcon(
                            AssetImage("assets/img/3.png"),
                          ),
                          label: kIsWeb ? "....." : 'گفتگو',
                        ),
                      ] +
                      (!hideBlue2Table()
                          ? [
                              BottomNavigationBarItem(
                                icon: ImageIcon(
                                  AssetImage("assets/img/2.png"),
                                ),
                                label: kIsWeb ? "....." : 'دفترچه ۲',
                              )
                            ]
                          : []) +
                      [
                        BottomNavigationBarItem(
                          icon: ImageIcon(
                            AssetImage("assets/img/2.png"),
                          ),
                          label: kIsWeb ? "....." : 'دفترچه ۱',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.schedule),
                          label: kIsWeb ? "....." : 'برنامه هفتگی',
                        ),
                      ],
                  currentIndex: StudentMainPage.selectedIndex,
                  selectedItemColor: Colors.amber[800],
                  onTap: _onItemTapped,
                  unselectedItemColor: Colors.green,
                  selectedIconTheme:
                      IconThemeData(size: 26, color: prefix0.Theme.darkText),
                  unselectedIconTheme:
                      IconThemeData(color: prefix0.Theme.darkText, size: 23),
                  selectedLabelStyle:
                      prefix0.getTextStyle(12, prefix0.Theme.darkText),
                ),
                body: Container(
                  color: prefix0.Theme.mainBG,
                  child: Container(
                    child: widget.currentPage == null
                        ? getConsultantTable()
                        : widget.currentPage,
                  ),
                ),
              ),
            ),
            onWillPop: () async {
              if (sharePageCurrentRoute) {
                navigateToSubPage(
                    sharedContext,
                    SlideMainPage(
                        defaultStudentUsername:
                            StudentMainPage.studentUsername));
                StudentMainPageState.sharePageCurrentRoute = false;
                return false;
              }
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
            },
          );
        },
      ),
    );
  }

  void changePage(int index) {
    if (hideBlue2Table()) {
      changePageWithOutBlue2Table(index);
    } else {
      changePageWithBlue2Table(index);
    }
  }

  void changePageWithBlue2Table(int index) {
    if (index == 0) {
      _studentProState();
    } else if (index == 1) {
      _chatContactList();
    } else if (index == 2) {
      _studentTable2State();
    } else if (index == 3) {
      _studentTable1State();
    } else if (index == 4) {
      _teacherTable();
    }
    setState(() {
      StudentMainPage.selectedIndex = index;
    });
  }

  void changePageWithOutBlue2Table(int index) {
    if (index == 0) {
      _studentProState();
    } else if (index == 1) {
      _chatContactList();
    } else if (index == 2) {
      _studentTable1State();
    } else if (index == 3) {
      _teacherTable();
    }
    setState(() {
      StudentMainPage.selectedIndex = index;
    });
  }

  void popToLoginPage() {
    Navigator.of(context, rootNavigator: true)
        .popUntil(ModalRoute.withName('/'));
    navigateToSubPage(context, FirstPage());
  }

  void _onItemTapped(int index) {
    StudentMainPageState.pageQueue = [StudentMainPage.selectedIndex];
    changePage(index);
  }

  void _teacherTable() {
    if (widget.teacherTable == null) {
      widget.teacherTable = getConsultantTable();
    }
    setState(() {
      widget.currentPage = widget.teacherTable;
    });
  }

  void _studentTable1State() {
    if (widget.studentTable1 == null) {
      widget.studentTable1 = BlueTable1();
    }
    setState(() {
      widget.currentPage = widget.studentTable1;
    });
  }

  void _studentTable2State() {
    if (widget.studentTable2 == null) {
      widget.studentTable2 = BlueTable2();
    }
    setState(() {
      widget.currentPage = widget.studentTable2;
    });
  }

  void _chatRoomState(List<String> usernames) {
    usernames.sort();
    if (widget.chatRoom != null && widget.chatRoom is ChatScreen) {
      if ((widget.chatRoom as ChatScreen).usernames.join(",") !=
          usernames.join(",")) {
        widget.chatRoom = ChatScreen(
          this,
          usernames,
          key: ValueKey(usernames.join(",")),
        );
      }
    } else {
      widget.chatRoom = ChatScreen(this, usernames);
    }

    setState(() {
      widget.currentPage = widget.chatRoom;
    });
  }

  void _channelRoomState(String consUsernames) {
    widget.chatRoom = ChannelChatScreenView(this, consUsernames);
    setState(() {
      widget.currentPage = widget.chatRoom;
    });
  }

  void _chatContactList() {
    if (widget.chatContactList == null) {
      widget.chatContactList = ChatContactList(this);
    }
    setState(() {
      widget.currentPage = widget.chatContactList;
    });
  }

  void chatRoomPage(List<String> usernames) {
    if (hideBlue2Table()) {
      StudentMainPageState.pageQueue.add(1);
    } else {
      StudentMainPageState.pageQueue.add(2);
    }
    _chatRoomState(usernames);
  }

  void studentChannelPage(String consUsername) {
    if (hideBlue2Table()) {
      StudentMainPageState.pageQueue.add(1);
    } else {
      StudentMainPageState.pageQueue.add(2);
    }
    _channelRoomState(consUsername);
  }

  void chatContactListPage() {
    _chatContactList();
  }

  void _studentProState() {
    if (widget.studentProfile == null) {
      widget.studentProfile = StudentProfile(this);
    }
    setState(() {
      widget.currentPage = widget.studentProfile;
    });
  }

  Widget getConsultantTable() {
    return ConsultantTable();
  }
}
