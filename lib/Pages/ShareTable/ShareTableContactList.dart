import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantTableSRV.dart';
import 'package:mhamrah/ConnectionService/StudentListSRV.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Pages/ShareTable/ShareContactElement.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../SlideMainPage.dart';
import 'ShareTitlePart.dart';

class ShareTableStudentList extends StatefulWidget {
  final ConsultantTableModel consTable;
  final ConsultantTableState consultantTableState;

  ShareTableStudentList(
    this.consTable,
    this.consultantTableState, {
    Key key,
  }) : super(key: key);

  @override
  ShareStudentListPageState createState() => ShareStudentListPageState();
}

class ShareStudentListPageState extends State<ShareTableStudentList> {
  StudentListSRV studentListSRV = StudentListSRV();
  ConsultantTableSRV consultantTableSRV = ConsultantTableSRV();
  static ContactElement s = ContactElement();

  List<ShareContactElement> studentList = [];
  Timer socketTimer;
  bool loadingToggle = false;
  bool sendLoadingToggle = false;

  ShareStudentListPageState();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    /// Connection checker
//    LSM.getConsultant().then((consultant) {
//      socketConnectionChecker(
//              [consultant.username], this, () {}, fetchStudentList)
//          .then((value) {
//        socketTimer = value;
//      });
//    });
    LSM.getAcceptedStudentListData().then((studentListData) {
      if (studentListData != null) {
        List<ContactElement> studentList = studentListData.studentList;
        List<ShareContactElement> studentResultList = [];
        for (int i = 0; i < studentList.length; i++) {
          studentResultList.add(ShareContactElement(studentList[i]));
        }
        this.studentList = studentResultList;
        fetchStudentList(false, true, "");
      } else {
        fetchStudentList(true, true, "");
      }
    });
    StudentMainPageState.sharedContext = context;
  }

  List<String> getSelectedStudentUsernames() {
    List<String> usernames = [];

    for (int i = 0; i < studentList.length; i++) {
      if (studentList[i].selecterdToggle) {
        usernames.add(studentList[i].studentContactElement.username);
      }
    }
    return usernames;
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: WillPopScope(
          child: new Container(
            color: prefix0.Theme.mainBG,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: new Column(
              children: <Widget>[
                new ShareTableContactListTitlePart(this),
                new Expanded(
                  child: new SingleChildScrollView(
                    child: loadingToggle
                        ? getPageLoadingBar()
                        : new Column(
                            verticalDirection: VerticalDirection.down,
                            children: studentList,
                          ),
                  ),
                ),
//            getBottomNavigationBar()
              ],
            ),
          ),
          onWillPop: () {
//            Navigator.pop(context);
//            print("closing share page");
//            socketTimer.cancel();
          },
        ),
        floatingActionButton: Container(
          width: 80,
          height: 50,
          child: FloatingActionButton(
            backgroundColor: prefix0.Theme.applyButton,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                sendLoadingToggle
                    ? getSendLoadingBar()
                    : Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.send),
                      ),
              ],
            ),
            onPressed: () {
              if (getSelectedStudentUsernames().length != 0) {
                shareConsTable();
              } else {
                StudentMainPageState.sharedContext = context;
                navigateToSubPage(
                    context,
                    SlideMainPage(
                        defaultStudentUsername:
                            StudentMainPage.studentUsername));
                StudentMainPageState.sharePageCurrentRoute = false;
              }
            },
          ),
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      ),
    );
  }

  Widget getPageLoadingBar() {
    Widget w = new Padding(
      padding: EdgeInsets.only(top: 100),
      child: new Container(
        height: 150,
        width: 150,
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
    return w;
  }

  Widget getSendLoadingBar() {
    return new Padding(
      padding: EdgeInsets.all(0),
      child: new Container(
        padding: EdgeInsets.all(10),
        child: CircularProgressIndicator(),
      ),
    );
  }

  void fetchStudentList(
      bool withLoading, bool withSaveResult, String search_text) {
    setState(() {
      if (withLoading) {
        loadingToggle = true;
      }
    });
    LSM.getConsultant().then((consultant) {
      studentListSRV
          .getAcceptedStudentList(consultant.username,
              consultant.authentication_string, search_text)
          .then((resultListData) {
        if (resultListData == null) {
        } else {
          List<ContactElement> studentListData = resultListData.studentList;
          if (withSaveResult) {
            LSM.setAcceptedStudentListData(resultListData);
          }
          List<ShareContactElement> studentResultList = [];
          for (int i = 0; i < studentListData.length; i++) {
            studentResultList.add(ShareContactElement(studentListData[i]));
          }
          setState(() {
            studentList = studentResultList;
            loadingToggle = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    print("is socket timer in student list stopping");
    print(socketTimer);
    if (socketTimer != null) {
      socketTimer.cancel();
    }
    super.dispose();
  }

  void shareConsTable() {
    setState(() {
      sendLoadingToggle = true;
    });
    LSM.getConsultant().then((consultant) {
      consultantTableSRV
          .shareConsultantTableWithStudentList(
              consultant.username,
              consultant.authentication_string,
              getSelectedStudentUsernames(),
              widget.consTable)
          .then((status) {
        setState(() {
          sendLoadingToggle = false;
        });
        if (status) {
          try {
            socketTimer.cancel();
          } catch (e) {}
          navigateToSubPage(
              context,
              SlideMainPage(
                  defaultStudentUsername: StudentMainPage.studentUsername));
          StudentMainPageState.sharePageCurrentRoute = false;
          widget.consultantTableState.fetchAllTables(true, true, true);
        }
      });
    });
  }
}
