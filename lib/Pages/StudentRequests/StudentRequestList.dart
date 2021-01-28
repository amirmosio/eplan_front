import 'dart:async';

import 'package:mhamrah/ConnectionService/StudentListSRV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/StudentRequests/StudentRequestContactElement.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';

import 'StudnetRequestListTitlePart.dart';

class StudentRequestListPage extends StatefulWidget {
  StudentRequestListPage({
    Key key,
  }) : super(key: key);

  @override
  StudentRequestListPageState createState() => StudentRequestListPageState();
}

class StudentRequestListPageState extends State<StudentRequestListPage> {
  StudentListSRV studentListSRV = StudentListSRV();
  List<ContactElement> studentListData = [];
  Timer socketTimer;
  bool loadingToggle = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  Consultant consultant;

  @override
  void initState() {
    super.initState();
    consultant = LSM.getConsultantSync();
    LSM.getConsultant().then((consultant) {
      setState(() {
        this.consultant = consultant;
      });

      /// Connection checker
      socketConnectionChecker(
              [consultant.username], this, () {}, fetchStudentRequestList)
          .then((value) {
        socketTimer = value;
      });
    });

    StudentListData data = LSM.getPendingStudentListDataSync();
    if (data != null) {
      studentListData = data.studentList;
      loadingToggle = false;
      fetchStudentRequestList(false, true, "");
    } else {
      fetchStudentRequestList(true, true, "");
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    double remainHeight = MediaQuery.of(context).size.height -
        ConsultantMainPageState.tabHeight -
        (100 - 35 + FirstPage.androidTitleBarHeight + 20);
    return new Container(
      color: prefix0.Theme.mainBG,
      height: MediaQuery.of(context).size.height -
          ConsultantMainPageState.tabHeight,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new StudentRequestListTitlePart(this),
          Expanded(
            child: SizedBox(),
          ),
          Container(
//            height: remainHeight,
            child: SingleChildScrollView(
              child: new Container(
                  height: remainHeight + 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedList(
                        key: _listKey,
                        initialItemCount: studentListData.length,
                        itemBuilder: (context, index, animation) {
                          return _buildStudentItem(context, index, animation);
                        },
                      ),
                      loadingToggle ? getPageLoadingProgress() : SizedBox(),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(
      BuildContext context, int index, Animation animation) {
//    TextStyle textStyle = new TextStyle(fontSize: 20);
    if (studentListData.length == 0) {
      return Container();
    } else if (studentListData.length <= index) {
      return _buildStudentItem(context, studentListData.length - 1, animation);
    }
    return SizeTransition(
        key: ValueKey(studentListData[index].username),
        sizeFactor: animation,
        axis: Axis.vertical,
        child: StudentRequestElement(studentListData[index], this, consultant));
//    return StudentElement(contactElement, slideMainPage);
  }

  void _addAnItem(index, ContactElement ce) {
    try {
      setState(() {
        studentListData.insert(index, ce);
      });
//    AnimatedList.of(context).insertItem(index);
      _listKey.currentState.insertItem(index);
    } catch (e) {}
  }

  void removeItemByUserName(String username) {
    if (studentListData.length != 0) {
      int index = -1;
      for (int i = 0; i < this.studentListData.length; i++) {
        if (studentListData[i].username == username) {
          index = i;
          break;
        }
      }
      if (index != -1) {
        _removeItemByIndex(index);
        StudentListData sld = StudentListData();
        sld.studentList = studentListData;
        LSM.setPendingStudentListData(sld);
      }
    }
  }

  void _removeItemByIndex(index) {
    try {
      _listKey.currentState.removeItem(
        index,
        (BuildContext context, Animation<double> animation) =>
            _buildStudentItem(context, index, animation),
        duration: const Duration(milliseconds: 300),
      );
      setState(() {
        studentListData.removeAt(index);
      });
    } catch (e) {}
  }

  void addNewContact(List<ContactElement> fetchedData) {
    Map oldDataAndHasToStayFlag = {};
    for (int i = 0; i < this.studentListData.length; i++) {
      oldDataAndHasToStayFlag[studentListData[i].username] = false;
    }
    for (int i = 0; i < fetchedData.length; i++) {
      if (!oldDataAndHasToStayFlag.keys.contains(fetchedData[i].username)) {
        _addAnItem(i, fetchedData[i]);
      }
      oldDataAndHasToStayFlag[fetchedData[i].username] = true;
    }
    for (int i = 0; i < oldDataAndHasToStayFlag.keys.length; i++) {
      String username = oldDataAndHasToStayFlag.keys.toList()[i];
      if (!oldDataAndHasToStayFlag[username]) {
        int index = -1;
        for (int i = 0; i < this.studentListData.length; i++) {
          if (studentListData[i].username == username) {
            index = i;
            break;
          }
        }
        if (index != -1) {
          _removeItemByIndex(index);
        }
      }
    }
  }

  void fetchStudentRequestList(
      bool withLoading, bool withResultSave, String searchText) {
    setState(() {
      if (withLoading) {
        loadingToggle = true;
      }
    });
    LSM.getConsultant().then((consultant) {
      studentListSRV
          .getPendingUserList(
              consultant.username, consultant.authentication_string, searchText)
          .then((resultListData) {
        if (resultListData == null) {
        } else {
          if (withResultSave) {
            LSM.setPendingStudentListData(resultListData);
          }
          setState(() {
            loadingToggle = false;
          });
          addNewContact(resultListData.studentList);
        }
      });
    });
  }

  @override
  void dispose() {
    if (socketTimer != null) {
      socketTimer.cancel();
    }
    super.dispose();
  }
}
