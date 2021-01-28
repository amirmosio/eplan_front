import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/StudentListSRV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/SlideMainPage.dart';
import 'package:mhamrah/Pages/StudentList/StudnetListTitlePart.dart';
import 'package:mhamrah/Pages/StudentList/StudentContactElement.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';

class StudentListPage extends StatefulWidget {
  final SlideMainPageState s;
  final ConsultantMainPageState c;

  StudentListPage(
    this.s,
    this.c, {
    Key key,
  }) : super(key: key);

  @override
  StudentListPageState createState() => StudentListPageState(s, c);
}

class StudentListPageState extends State<StudentListPage> {
  ConsultantMainPageState c;
  StudentListSRV studentListSRV = StudentListSRV();
  static ContactElement s = ContactElement();
  SlideMainPageState slideMainPage;
  bool loadingPage = false;
  List<ContactElement> studentListBackUpDataFroFilter = [];
  List<ContactElement> studentListData = [];
  List<ContactElement> subConsListData = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  Consultant consultant;

  Timer socketTimer;
  double subConsHeight = 45;
  String selectedSubConsUsername = "";
  bool deleteSubConsLoading = false;

  StudentListPageState(this.slideMainPage, this.c);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
              [consultant.username], this, () {}, fetchStudentList)
          .then((value) {
        socketTimer = value;
      });
    });

    StudentListData data = LSM.getAcceptedStudentListDataSync();
    if (data != null) {
      this.studentListBackUpDataFroFilter = []..addAll(data.studentList);
      this.studentListData = data.studentList;
      this.subConsListData = data.subConsList;
      fetchStudentList(false, true, "");
    } else {
      fetchStudentList(true, true, "");
    }
  }

  Widget getSubConsItemListWidget() {
    List<Widget> subCons = [];
    this.subConsListData.forEach((contact) {
      subCons.add(getSubConsItem(contact));
    });
    ContactElement mainCons = ContactElement();
    Consultant consultant = LSM.getConsultantSync();
    mainCons.username = consultant.username;
    mainCons.phone = consultant.phone;
    mainCons.name = "بدون پشتیبان";
    subCons.add(getSubConsItem(mainCons));

    ContactElement totalStudent = ContactElement();
    totalStudent.username = "";
    totalStudent.phone = "";
    totalStudent.name = "همه دانش آموزان";
    subCons.add(getSubConsItem(totalStudent));

    return Container(
      height: subConsHeight,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.2))),
      child: Padding(
        padding: EdgeInsets.only(top: 3, bottom: 3),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            children: subCons,
          ),
        ),
      ),
    );
  }

  Widget getSubConsItem(ContactElement contactElement) {
    bool selfSubCons =
        LSM.getConsultantSync().username == contactElement.username;
    bool totalStudent = contactElement.username == "";
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: selfSubCons || totalStudent
                  ? prefix0.Theme.lessonNameBG
                  : prefix0.Theme.startEndTimeItemsBG,
              border: Border.all(width: 0.2),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: AutoSizeText(
            contactElement.name,
            softWrap: true,
            wrapWords: true,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: prefix0.getTextStyle(
                16,
                selfSubCons || totalStudent
                    ? prefix0.Theme.onLessonNameBGText
                    : prefix0.Theme.onStartEndTimeItemBG),
          ),
        ),
      ),
      onLongPress: () {
        if (totalStudent) {
          showFlutterToastWithFlushBar(
              "برای مشاهده همه دانش اموز ها بر روی ایکون بزنید.",
              secsForDurations: 10);
        } else if (selfSubCons) {
          showFlutterToastWithFlushBar(
              "شما فقط می توانید پشتیبان های دیگرتان را حذف کنید.",
              secsForDurations: 10);
        } else {
          showSubConsDescription(contactElement);
        }
      },
      onTap: () {
        if (totalStudent) {
          filterStudentBySubCons("");
          showFlutterToastWithFlushBar("لیست همه دانش اموزان",
              secsForDurations: 10);
        } else if (selfSubCons) {
          filterStudentBySubCons(contactElement.username);
          showFlutterToastWithFlushBar(
              "لیست دانش اموزان " + contactElement.name,
              secsForDurations: 10);
        } else {
          filterStudentBySubCons(contactElement.username);
          showFlutterToastWithFlushBar(
              "لیست دانش اموزان با پشتیبانی " + contactElement.name,
              secsForDurations: 10);
        }
      },
    );
  }

  void showSubConsDescription(ContactElement contactElement) {
    Widget d = BackdropFilter(
        filter: prefix0.Theme.fragmentBGFilter,
        child: new AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setstate) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 250,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                      color: prefix0.Theme.settingBg),
//                height: MediaQuery.of(context).size.height * (20 / 100),
                  child: Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            height: 80,
                            width: double.maxFinite - 20,
                            child: AutoSizeText(
                              "نام و نام خانوادگی: " +
                                  contactElement.name +
                                  "\n" +
                                  "نام کاربری: " +
                                  contactElement.username +
                                  "\n" +
                                  "شماره تلفن: " +
                                  contactElement.phone,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: prefix0.getTextStyle(
                                  16, prefix0.Theme.onSettingText1),
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            height: 150,
                            width: double.maxFinite - 20,
                            child: AutoSizeText(
                              deleteSubConDescription,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: prefix0.getTextStyle(
                                  17, prefix0.Theme.onSettingText1),
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            height: 50,
                            width: double.maxFinite - 20,
                            child: AutoSizeText(
                              "ایا از حذف " +
                                  "این پشتیبان"
                                      " مطمئن هستید؟",
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: prefix0.getTextStyle(
                                  16, prefix0.Theme.onSettingText1),
                            ),
                          )),
                      GestureDetector(
                        child: Container(
                          width: double.maxFinite,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(25),
                                bottomLeft: Radius.circular(25),
                              ),
                              color: prefix0.Theme.titleBar1),
                          child: deleteSubConsLoading
                              ? getButtonLoadingProgress(r: 22, stroke: 2)
                              : AutoSizeText(
                                  "حذف",
                                  style: prefix0.getTextStyle(
                                      18, prefix0.Theme.onMainBGText),
                                ),
                        ),
                        onTap: () {
                          deleteSubCons(setstate, contactElement.username);
                        },
                      )
                    ],
                  ),
                )
              ],
            );
          }),
        ));
    showDialog(context: context, child: d, barrierDismissible: true);
  }

  void deleteSubCons(StateSetter stateSetter, String subConsUsername) {
    StudentListSRV studentListSRV = StudentListSRV();
    stateSetter(() {
      deleteSubConsLoading = true;
    });
    LSM.getConsultant().then((consultant) {
      studentListSRV
          .deleteSubConsultant(consultant.username,
              consultant.authentication_string, subConsUsername)
          .then((status) {
        stateSetter(() {
          deleteSubConsLoading = true;
        });
        if (status) {
          Navigator.of(context, rootNavigator: true).pop();
          fetchStudentList(true, true, "");
        }
      });
    });
  }

  Widget build(BuildContext context) {
    double remainHeight = MediaQuery.of(context).size.height -
        ConsultantMainPageState.tabHeight -
        (100 - 35 + FirstPage.androidTitleBarHeight) -
        subConsHeight;
    return new Container(
      color: prefix0.Theme.mainBG,
      height: MediaQuery.of(context).size.height -
          ConsultantMainPageState.tabHeight,
      width: MediaQuery.of(context).size.width,
      child: new Column(
        children: <Widget>[
          new StudentListTitlePart(this),
          getSubConsItemListWidget(),
          Container(
            height: remainHeight,
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
                    loadingPage ? getPageLoadingProgress() : SizedBox(),
                  ],
                )),
//            ),
          )
//            getBottomNavigationBar()
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
    return SlideTransition(
      key: ValueKey(studentListData[index].getContactKey()),
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: StudentElement(
          studentListData[index], slideMainPage, this, consultant),
    );
  }

  void _addAnItem(index, ContactElement ce) {
    try {
      setState(() {
        studentListData.insert(index, ce);
      });
      _listKey.currentState.insertItem(index);
    } catch (e) {}
  }

  void updateItemByUsername(ContactElement contactElement) {
    int index = -1;
    for (int i = 0; i < this.studentListData.length; i++) {
      if (studentListData[i].username == contactElement.username) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      setState(() {
        studentListData[index] = contactElement;
      });
      StudentListData sld = StudentListData();
      sld.studentList = studentListData;
    }
  }

  void removeItemByUserName(String username) {
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
      try {
        studentListData.removeAt(index);
      } catch (e) {}
    } catch (e) {}
  }

  void filterStudentBySubCons(String subConsUsername) {
    if (subConsUsername == "") {
      updateAnimatedList(studentListBackUpDataFroFilter, updateBackup: false);
    } else {
      List<ContactElement> res = [];
      studentListBackUpDataFroFilter.forEach((element) {
        if (element.subConsUsername == subConsUsername) {
          res.add(element);
        }
      });
      updateAnimatedList(res, updateBackup: false);
    }
  }

  void updateAnimatedList(List<ContactElement> fetchedData,
      {bool updateBackup = true}) {
    Map oldDataAndHasToStayFlag = {};
    for (int i = 0; i < this.studentListData.length; i++) {
      oldDataAndHasToStayFlag[studentListData[i].username] = false;
    }
    for (int i = 0; i < fetchedData.length; i++) {
      if (!oldDataAndHasToStayFlag.keys.contains(fetchedData[i].username)) {
        _addAnItem(i, fetchedData[i]);
      } else {
        updateItemByUsername(fetchedData[i]);
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
    if (updateBackup) {
      studentListBackUpDataFroFilter = []..addAll(studentListData);
    }
  }

  void fetchStudentList(
      bool withLoading, bool withSaveResult, String search_text) {
    setState(() {
      if (withLoading) {
        loadingPage = true;
      }
    });
    LSM.getConsultant().then((consultant) {
      studentListSRV
          .getAcceptedStudentList(consultant.username,
              consultant.authentication_string, search_text)
          .then((resultListData) {
        setState(() {
          loadingPage = false;
        });
        if (resultListData == null) {
        } else {
          if (withSaveResult) {
            LSM.setAcceptedStudentListData(resultListData);
          }
          updateAnimatedList(resultListData.studentList);
          setState(() {
            subConsListData = resultListData.subConsList;
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
}
