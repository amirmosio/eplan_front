import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/BlueTable1SRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/BlueTable1MV.dart' as prefix0;
import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/BlueTable1/BlueTitlePart1.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Pages/SharedTitlePart/EmptyTitlePart.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix1;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../StudentMainPage.dart';
import 'BlueLessonField1.dart';
import 'DailySumLessonField.dart';

class BlueTable1 extends StatefulWidget {
  BlueTable1({Key key}) : super(key: key);

  @override
  BlueTable1State createState() => BlueTable1State();
}

class BlueTable1State extends State<BlueTable1> {
  int userType = 0;
  bool parentAccount = false;
  BlueTable1SRV blueTable1SRV = new BlueTable1SRV();
  static B1DayPlan emptyPlan1 = B1DayPlan.getEmptyInitial(0, "");

  static BlueTable1Data b = BlueTable1Data.initialData(
      emptyInitialPlanNameInBlueTables,
      [
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
      ],
      "",
      "");

  static prefix0.AllBlue1Tables totalBlue1Tables =
      prefix0.AllBlue1Tables("", [b]);

  prefix0.BlueTable1Data blueTable1Data;

  int selectedDay = 0;
  bool _loadingTotalPageFlag = false;
  bool _loadingForSavingTableFlag = false;
  bool saveFlag = false;
  bool saveErrorFlag = false;

  Widget titleBar;
  Timer socketTimer;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDay = 0;
    LSM.getUserMode().then((type) {
      setState(() {
        userType = type;
      });

      /// socket connection checker
      if (userType == 0) {
        socketConnectionChecker([StudentMainPage.studentUsername], this,
                socketTableUpdater, socketHttpUpdaterFunction)
            .then((value) {
          socketTimer = value;
        });
      } else {
        LSM.getStudent().then((student) {
          socketConnectionChecker([student.username], this, socketTableUpdater,
                  socketHttpUpdaterFunction)
              .then((value) {
            socketTimer = value;
          });
          setState(() {
            parentAccount = student.parent != "";
          });
        });
      }

      /// fetching data
      LSM
          .getBlue1AllTables(StudentMainPage.studentUsername)
          .then((blue1AllTables) {
        if (blue1AllTables != null) {
          if (blue1AllTables.allTables.length != 0) {
            setState(() {
              totalBlue1Tables = blue1AllTables;
              blueTable1Data = totalBlue1Tables.allTables.last;
              titleBar = BlueTitlePart1(totalBlue1Tables.year, this);
            });
          }
          fetchAllTables(false);
        } else {
          fetchAllTables(true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (totalBlue1Tables.allTables.length != 0) {
      if (totalBlue1Tables
          .getPlanListName()
          .contains(StudentMainPageState.selectedPlanName)) {
        blueTable1Data = totalBlue1Tables
            .getBlueTable1ByName(StudentMainPageState.selectedPlanName);
      } else {
        blueTable1Data = totalBlue1Tables.allTables.last;
      }
    }
    selectedDay = StudentMainPageState.selectedDayIndex;
    double ySize = MediaQuery.of(context).size.height;
    Widget w = new Container(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          titleBar == null
              ? EmptyTitlePart(
                  "", ["", "", "", "", "", "", ""], null, this, null)
              : titleBar,
          Container(
            height: 4,
          ),
          Expanded(
            flex: 0,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                new Container(
                  height: ySize -
                      FirstPage.androidTitleBarHeight -
                      StudentMainPageState.appbarDropDownHeight -
                      10 -
                      ySize * (9.3 / 100) -
                      10 -
                      17 -
                      7 -
                      StudentMainPageState.kBottomNavigationBarHeight -
                      4 -
                      ySize * (1 / 100),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      key: ValueKey("lessonRows"),
                      mainAxisSize: MainAxisSize.min,
                      children: _loadingTotalPageFlag
                          ? getLoadingBar()
                          : getLessonRows(blueTable1Data) +
                              [
                                GestureDetector(
                                    child: Container(
                                  height: 80,
                                ))
                              ],
                    ),
                  ),
                ),
                getBottomWidgets(),
              ],
            ),
          )
        ],
      ),
//        scrollDirection: Axis.vertical,
    );
    return new Container(
      height: ySize - StudentMainPageState.kBottomNavigationBarHeight,
      color: prefix1.Theme.mainBG,
      child: userType == 0
          ? Container(child: w)
          : SingleChildScrollView(scrollDirection: Axis.vertical, child: w),
    );
  }

  List<GestureDetector> getLessonRows(prefix0.BlueTable1Data b1) {
    List<GestureDetector> result = [];
    List<prefix0.B1LessonPlanPerDay> dayPlans =
        b1.daysSchedule[selectedDay].dayLessonPlans;
    for (int index = 0; index < dayPlans.length; index++) {
      prefix0.B1LessonPlanPerDay lesson = dayPlans[index];
      if (lesson.lessonName == "کلاس") {
        result.add(getDaySumLessonRow());
      }
      Widget w = getLessonFieldRow(lesson);
      result.add(w);
    }
    return result;
  }

  Widget getDaySumLessonRow() {
    Widget lessonWidget = Visibility(
      key: ValueKey("daySum"),
      child: DailySumLessonField(this),
    );
    Widget w = new GestureDetector(
      child: lessonWidget,
      key: ValueKey("daySum"),
    );
    return w;
  }

//
//  Widget getWeekSumLessonRow() {
//    B1LessonPlanPerDay lessonPlanPerDay = prefix0.B1LessonPlanPerDay();
//    lessonPlanPerDay.lessonName = "مجموع هفتگی";
//    lessonPlanPerDay.durationTime = convertMinuteToTimeString(
//        blueTable1Data.daysSchedule[selectedDay].getTotalDayTimeMinute());
//    lessonPlanPerDay.testNumber =
//        blueTable1Data.daysSchedule[selectedDay].getTotalDayTest().toString();
//    Widget lessonWidget = Visibility(
//      key: ValueKey("daySum"),
//      child: DailySumLessonField(lessonPlanPerDay),
//    );
//    Widget w = new GestureDetector(
//      child: Container(child: lessonWidget, color: Colors.black),
//      key: ValueKey("daySum"),
//    );
//    return w;
//  }

  Widget getLessonFieldRow(prefix0.B1LessonPlanPerDay lessonPlanPerDay) {
    Widget lessonWidget = Visibility(
      key: ValueKey(blueTable1Data.name +
          "-" +
          lessonPlanPerDay.hashCode.toString() +
          "-" +
          lessonPlanPerDay.key),
      child: BlueLessonField1(lessonPlanPerDay, this),
    );
    Widget w = new GestureDetector(
      child: lessonWidget,
      key: ValueKey(blueTable1Data.name +
          "-" +
          lessonPlanPerDay.hashCode.toString() +
          "-" +
          lessonPlanPerDay.key),
    );
    return w;
  }

  Widget getBottomWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        (userType == 0 ||
                blueTable1Data.name == emptyInitialPlanName ||
                parentAccount)
            ? getConsultantSumWidget()
            : getStudentSumWidget(),
        userType == 1 &&
                blueTable1Data.name != emptyInitialPlanName &&
                !parentAccount
            ? getSaveButton()
            : SizedBox()
      ],
    );
  }

  Widget getStudentSumWidget() {
    int totalWeekTest = 0;
    int totalWeekTime = 0;
    for (int i = 0; i < 7; i++) {
      totalWeekTime += blueTable1Data.daysSchedule[i].getTotalDayTimeMinute();
      totalWeekTest += blueTable1Data.daysSchedule[i].getTotalDayTest()[0];
    }
    String totalWeekTestString = totalWeekTest.toString();
    String totalWeekTimeString = convertMinuteToTimeString(totalWeekTime);
    return GestureDetector(
      child: new Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.only(right: 5, left: 5),
          height: MediaQuery.of(context).size.height * (8.5 / 100),
          width: MediaQuery.of(context).size.width * (65 / 100),
          decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: prefix1.Theme.shadowColor,
                  spreadRadius: prefix1.Theme.spreadRadius,
                  blurRadius: prefix1.Theme.blurRadius,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              color: prefix1.Theme.startEndTimeItemsBG),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                color: Color.fromARGB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.only(right: 0, left: 0),
                      child: AutoSizeText(
                        "تعداد تست",
                        textDirection: TextDirection.rtl,
                        style: prefix1.getTextStyle(
                            16, prefix1.Theme.onMainBGText),
                      ),
                    ),
                    new Padding(
                      padding: EdgeInsets.only(left: 3, right: 3),
                      child: AutoSizeText(
                        totalWeekTestString,
                        textDirection: TextDirection.rtl,
                        style: prefix1.getTextStyle(
                            17, prefix1.Theme.onMainBGText),
                      ),
                    )
                  ],
                ),
              ),
              new Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: Container(
                  width: 2,
                  color: Colors.white,
                ),
              ),
              Container(
                color: Color.fromARGB(0, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.only(right: 0, left: 0),
                      child: AutoSizeText(
                        "زمان مطالعه",
                        textDirection: TextDirection.rtl,
                        style: prefix1.getTextStyle(
                            16, prefix1.Theme.onMainBGText),
                      ),
                    ),
                    new Padding(
                      padding: EdgeInsets.only(left: 3, right: 3),
                      child: AutoSizeText(
                        totalWeekTimeString,
                        textDirection: TextDirection.ltr,
                        style: prefix1.getTextStyle(
                            17, prefix1.Theme.onMainBGText),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 0, left: 0),
                child: AutoSizeText(
                  "مجموع: ",
                  textDirection: TextDirection.rtl,
                  style: prefix1.getTextStyle(17, prefix1.Theme.onMainBGText),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        showTotalWeek();
      },
    );
  }

  Widget getConsultantSumWidget() {
    int totalWeekTest = 0;
    int totalWeekTime = 0;
    for (int i = 0; i < 7; i++) {
      totalWeekTime += blueTable1Data.daysSchedule[i].getTotalDayTimeMinute();
      totalWeekTest += blueTable1Data.daysSchedule[i].getTotalDayTest()[0];
    }
    String totalWeekTestString = totalWeekTest.toString();
    String totalWeekTimeString = convertMinuteToTimeString(totalWeekTime);
    return GestureDetector(
      child: new Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.only(right: 5, left: 5),
          height: MediaQuery.of(context).size.height * (8 / 100),
          width: MediaQuery.of(context).size.width * (95 / 100),
          decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: prefix1.Theme.shadowColor,
                  spreadRadius: prefix1.Theme.spreadRadius,
                  blurRadius: prefix1.Theme.blurRadius,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              color: prefix1.Theme.startEndTimeItemsBG),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(right: 5, left: 5),
                    child: AutoSizeText(
                      "تعداد تست",
                      textDirection: TextDirection.rtl,
                      style:
                          prefix1.getTextStyle(16, prefix1.Theme.onMainBGText),
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(3),
                    child: AutoSizeText(
                      totalWeekTestString,
                      textDirection: TextDirection.rtl,
                      style:
                          prefix1.getTextStyle(17, prefix1.Theme.onMainBGText),
                    ),
                  )
                ],
              ),
              new Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: Container(
                  width: 2,
                  color: Colors.white,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(right: 5, left: 5),
                    child: AutoSizeText(
                      "زمان مطالعه",
                      textDirection: TextDirection.rtl,
                      style:
                          prefix1.getTextStyle(16, prefix1.Theme.onMainBGText),
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(3),
                    child: AutoSizeText(
                      totalWeekTimeString,
                      textDirection: TextDirection.ltr,
                      style:
                          prefix1.getTextStyle(17, prefix1.Theme.onMainBGText),
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: AutoSizeText(
                  "مجموع : ",
                  textDirection: TextDirection.rtl,
                  style: prefix1.getTextStyle(24, prefix1.Theme.onMainBGText),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        showTotalWeek();
      },
    );
  }

  Widget getLoadingProgressForSavingTable() {
    return Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.only(right: 10, left: 10),
    );
  }

  void setSaveFlagToNeeded() {
    setState(() {
      saveFlag = true;
    });
  }

  Widget getSaveButton() {
    return GestureDetector(
      child: new Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
          height: MediaQuery.of(context).size.height * (8 / 100),
          width: MediaQuery.of(context).size.width * (25 / 100),
          decoration: new BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: prefix1.Theme.shadowColor,
                  spreadRadius: prefix1.Theme.spreadRadius,
                  blurRadius: prefix1.Theme.blurRadius,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
              color: saveErrorFlag
                  ? prefix1.Theme.warningAndErrorBG
                  : saveFlag
                      ? prefix1.Theme.applyButton
                      : prefix1.Theme.startEndTimeItemsBG),
          alignment: Alignment.center,
          child: _loadingForSavingTableFlag
              ? getLoadingProgressForSavingTable()
              : Padding(
                  padding: EdgeInsets.only(right: 8, left: 8),
                  child: AutoSizeText(
                    "ذخیره",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontSize: 18, color: prefix1.Theme.onMainBGText),
                  ),
                ),
        ),
      ),
      onTap: uploadTableInDataBase,
    );
  }

  void selectDayPlans(int index) {
    clearOtherDaysBadInputData();
    StudentMainPageState.selectedDayIndex = index;
    setState(() {
      selectedDay = index;
    });
  }

  void updateLesson(prefix0.B1LessonPlanPerDay b1lessonPlanPerDay) {
    setState(() {
      blueTable1Data.updateLessonPerDay(selectedDay, b1lessonPlanPerDay);
    });
  }

  void showTotalWeek() {
    Widget d = BackdropFilter(
      filter: prefix1.Theme.fragmentBGFilter,
      child: new AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        content: GestureDetector(
          child: new Container(
            alignment: Alignment.center,
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * (80 / 100),
            color: Color.fromARGB(0, 0, 0, 0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: AutoSizeText(
                        "مجموع هفته",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: prefix1.Theme.onTotalSumBlue1TableBg),
                      ),
                      decoration: BoxDecoration(
                        color: prefix1.Theme.totalSumBlue1TableBg,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                    )),
                GestureDetector(
                  child: new Container(
                    height: MediaQuery.of(context).size.height * (55 / 100),
                    width: MediaQuery.of(context).size.width * (90 / 100),
                    decoration: BoxDecoration(
                      color: prefix1.Theme.totalSumBlue1TableBg,
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: getLessonTimeRow(),
                      ),
                      scrollDirection: Axis.vertical,
                    ),
                  ),
                  onTap: () {},
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
    );
    showDialog(context: context, child: d, barrierDismissible: true);
  }

  List<Widget> getLessonTimeRow() {
    double minScreen = 361;
    double xSize = MediaQuery.of(context).size.width;
    List<Widget> res = [];
    Map<String, int> data = blueTable1Data.getTotalLessonsTime();
    Map<String, int> data2 = blueTable1Data.getTotalLessonsTestNumber();
    List<String> keys = data.keys.toList();
    for (int k = 0;
        k < blueTable1Data.daysSchedule[0].dayLessonPlans.length;
        k++) {
      try {
        String lessonName =
            blueTable1Data.daysSchedule[0].dayLessonPlans[k].lessonName;
        String testNumber = data2[lessonName].toString();
        String time = convertMinuteToTimeString(data[lessonName]);
        Widget w = Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                          padding: EdgeInsets.only(top: 10, right: 3, left: 3),
                          child: Container(
                            width: xSize * (10 / 100),
                            child: AutoSizeText(
                              testNumber,
                              textAlign: TextAlign.start,
                              textDirection: TextDirection.rtl,
                              style: getTextStyle(
                                  18, prefix1.Theme.onTotalSumBlue1TableBg),
                            ),
                          )),
                      new Padding(
                          padding: EdgeInsets.only(top: 10, left: 3, right: 3),
                          child: Container(
                            width: xSize * (18 / 100),
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              time,
                              textAlign: TextAlign.start,
                              textDirection: TextDirection.ltr,
                              style: getTextStyle(
                                  18, prefix1.Theme.onTotalSumBlue1TableBg),
                            ),
                          )),
                    ],
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    constraints: BoxConstraints(
                        minWidth: xSize * (23 / 100),
                        maxWidth: xSize * (31 / 100)),
                    child: AutoSizeText(
                      blueTable1Data
                          .daysSchedule[0].dayLessonPlans[k].lessonName,
                      softWrap: true,
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                      wrapWords: true,
                      minFontSize: 10,
                      overflow: TextOverflow.clip,
                      style: prefix1.getTextStyle(xSize < minScreen ? 16 : 18,
                          prefix1.Theme.onTotalSumBlue1TableBg),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              child: Container(
                height: 0.2,
                color: prefix1.Theme.onMainBGText,
              ),
              padding: EdgeInsets.only(left: 10, right: 10),
            )
          ],
        );
        res.add(w);
      } catch (Exception) {}
    }
    return res;
  }

  List<Widget> getLoadingBar() {
    List<Widget> res = [];
    Widget w = new Padding(
      padding: EdgeInsets.only(top: 100),
      child: new Container(
        height: 150,
        width: 150,
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
    res.add(w);
    return res;
  }

//  void uploadTableInDataBase() {
//    setState(() {
//      _loadingForSavingTableFlag = true;
//    });
//    LSM.getStudent().then((student) {
//      blueTable1SRV
//          .updateWholeTable(
//              student.username, student.authentication_string, blueTable1Data)
//          .then((status) {
//        if (status != null) {
//          setState(() {
//            _loadingForSavingTableFlag = false;
//          });
//        }
//      });
//    });
//  }TODO the true function in the end just delete below function after you upgrade this

  void changeWeekPlan(String name) {
    setState(() {
      blueTable1Data = totalBlue1Tables.getBlueTable1ByName(name);
    });
  }

  void clearOtherDaysBadInputData() {
    for (int dayIndex = 0;
        dayIndex < blueTable1Data.daysSchedule.length;
        dayIndex++) {
      List<prefix0.B1LessonPlanPerDay> lessonList =
          blueTable1Data.daysSchedule[dayIndex].dayLessonPlans;
      for (int lessonIndex = 0;
          lessonIndex < lessonList.length;
          lessonIndex++) {
        if (!checkEmptyAllowTime(lessonList[lessonIndex].durationTime)) {
          lessonList[lessonIndex].durationTime = "";
        }
        if (!checkEmptyAllowTestNumber(lessonList[lessonIndex].testNumber)) {
          lessonList[lessonIndex].testNumber = "";
        }
      }
    }
  }

  void uploadTableInDataBase() {
    if (!checkCorrectDataInputForTimeAndTestNumber()) {
      setState(() {
        saveErrorFlag = true;
      });
      Future.delayed(Duration(milliseconds: 250)).then((_) {
        setState(() {
          saveErrorFlag = false;
        });
      });
    } else {
      setState(() {
        _loadingForSavingTableFlag = true;
      });
      LSM.getStudent().then((student) {
        blueTable1SRV
            .updateWholeTable(StudentMainPage.studentUsername,
                student.authentication_string, blueTable1Data)
            .then((status) {
          if (status != null) {
            setState(() {
              saveFlag = false;
              notifyConsultantTable(blueTable1Data);
              _loadingForSavingTableFlag = false;
            });
          }
        });
      });
    }
  }

  bool checkCorrectDataInputForTimeAndTestNumber() {
    for (int dayIndex = 0;
        dayIndex < blueTable1Data.daysSchedule.length;
        dayIndex++) {
      List<prefix0.B1LessonPlanPerDay> lessonList =
          blueTable1Data.daysSchedule[dayIndex].dayLessonPlans;
      for (int lessonIndex = 0;
          lessonIndex < lessonList.length;
          lessonIndex++) {
        if (!checkEmptyAllowTime(lessonList[lessonIndex].durationTime)) {
          return false;
        }
        if (!checkEmptyAllowTestNumber(lessonList[lessonIndex].testNumber)) {
          return false;
        }
        if (!checkEmptyAllowTestNumber(
            lessonList[lessonIndex].wrongTestNumber)) {
          return false;
        }
        if (!checkEmptyAllowTestNumber(
            lessonList[lessonIndex].rightTestNumber)) {
          return false;
        }
        if (!checkEmptyAllowTestNumber(
            lessonList[lessonIndex].emptyTestNumber)) {
          return false;
        }
      }
    }
    return true;
  }

  void socketHttpUpdaterFunction() {
    fetchAllTables(false);
  }

  void fetchAllTables(bool withLoading) {
    if (withLoading) {
      _loadingTotalPageFlag = true;
    }
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        blueTable1SRV
            .getAllTables(consultant.username, StudentMainPage.studentUsername,
                consultant.authentication_string)
            .then((blue1AllTables) {
          if (blue1AllTables != null) {
            LSM.setBlue1AllTables(
                StudentMainPage.studentUsername, blue1AllTables);
            if (blue1AllTables.allTables.length != 0) {
              setState(() {
                totalBlue1Tables = blue1AllTables;
                if (withLoading) {
                  _loadingTotalPageFlag = false;
                }
                blueTable1Data = totalBlue1Tables.allTables.last;
                titleBar = BlueTitlePart1(totalBlue1Tables.year, this);
              });
            } else {
              setState(() {
                titleBar = EmptyTitlePart(
                    "", ["", "", "", "", "", "", ""], null, this, null);
                totalBlue1Tables = prefix0.AllBlue1Tables("", [b]);
                if (withLoading) {
                  _loadingTotalPageFlag = false;
                }
              });
            }
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        blueTable1SRV
            .getAllTables(student.sub_consultant_username, student.username,
                student.authentication_string)
            .then((blue1AllTables) {
          if (blue1AllTables != null) {
            LSM.setBlue1AllTables(
                StudentMainPage.studentUsername, blue1AllTables);
            if (blue1AllTables.allTables.length != 0) {
              setState(() {
                totalBlue1Tables = blue1AllTables;

                if (withLoading) {
                  _loadingTotalPageFlag = false;
                }
                blueTable1Data = totalBlue1Tables.allTables.last;
                titleBar = BlueTitlePart1(totalBlue1Tables.year, this);
              });
            } else {
              setState(() {
                titleBar = EmptyTitlePart(
                    "", ["", "", "", "", "", "", ""], null, this, null);
                totalBlue1Tables = prefix0.AllBlue1Tables("", [b]);
                if (withLoading) {
                  _loadingTotalPageFlag = false;
                }
              });
            }
          }
        });
      });
    }
  }

//
//  void socketConnectionChecker() async {
//    bool connectNow = false;
//    if (userType == 0) {
//      if (ConnectionService.channel == null ||
//          (ConnectionService.channel.closeCode != null &&
//              ConnectionService.channel.closeReason != null)) {
//        ConnectionService.openSocket([StudentMainPage.studentUsername]);
//      }
//    } else if (userType == 1) {
//      LSM.getStudent().then((student) {
//        if (ConnectionService.channel == null ||
//            (ConnectionService.channel.closeCode != null &&
//                ConnectionService.channel.closeReason != null)) {
//          ConnectionService.openSocket([student.username]);
//        }
//      });
//    }
//    if (ConnectionService.stream != null) {
//      socketTableUpdater();
//    }
//    socketTimer = Timer.periodic(Duration(seconds: 4), (Timer t) {
//      if (ConnectionService.channel == null ||
//          (ConnectionService.channel.closeCode != null &&
//              ConnectionService.channel.closeReason != null)) {
//        Fluttertoast.showToast(
//            msg: connectionError,
//            toastLength: Toast.LENGTH_SHORT,
//            backgroundColor: prefix1.Theme.redBright,
//            gravity: ToastGravity.BOTTOM,
//            timeInSecForIosWeb: 4);
//        if (userType == 0) {
//          ConnectionService.openSocket([StudentMainPage.studentUsername]);
//        } else if (userType == 1) {
//          LSM.getStudent().then((student) {
//            ConnectionService.openSocket([student.username]);
//          });
//        }
//        setState(() {});
//        connectNow = true;
//      } else if (ConnectionService.channel != null &&
//          ConnectionService.channel.closeCode == null &&
//          connectNow) {
//        socketTableUpdater();
//        Fluttertoast.showToast(
//            msg: connectionStablished,
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.BOTTOM,
//            backgroundColor: prefix1.Theme.greenButton,
//            timeInSecForIosWeb: 4);
//        connectNow = false;
//        setState(() {});
//      } else {
//        if (userType == 0) {
//          ConnectionService.getOpenChannel([StudentMainPage.studentUsername]);
//        } else if (userType == 1) {
//          LSM.getStudent().then((student) {
//            ConnectionService.getOpenChannel([student.username]);
//          });
//        }
//      }
//    });
//  }

  void socketTableUpdater() async {
    Stream stream = ConnectionService.stream;
    stream.listen((message) {
      message = improveStringJsonFromSocket(message);
      SocketNotifyingData s =
          SocketNotifyingData.fromJson(json.decode(message));
      if (s.requestType == "submit_message") {
        //TODO
      } else if (s.requestType == "notify_blue1_table") {
        prefix0.BlueTable1Data consultantTable =
            (s.requestData as Blue1TableSR).blueTable1Data;
        if (totalBlue1Tables.getPlanListName().contains(consultantTable.name)) {
          setState(() {
            totalBlue1Tables.updateSingleTable(consultantTable);
          });
          setStateTitleBar();
        } else {
          setState(() {
            totalBlue1Tables.updateSingleTable(consultantTable);
          });
          setLast();
        }
      }
    });
  }

  void setStateTitleBar() {
    setState(() {
      titleBar = BlueTitlePart1(totalBlue1Tables.year, this);
      StudentMainPageState.selectedPlanName = blueTable1Data.name;
    });
  }

  void setLast() {
    setState(() {
      blueTable1Data = totalBlue1Tables.allTables.last;
      titleBar = BlueTitlePart1(totalBlue1Tables.year, this);
      StudentMainPageState.selectedPlanName = blueTable1Data.name;
    });
  }

  void notifyConsultantTable(BlueTable1Data table) {
    SocketNotifyingData s = SocketNotifyingData();
    s.requestType = "notify_blue1_table";
    Blue1TableSR csr = Blue1TableSR();
    csr.blueTable1Data = table;
    s.requestData = csr;
    if (userType == 0) {
      ConnectionService.sendDataToSocket([StudentMainPage.studentUsername], s);
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        ConnectionService.sendDataToSocket([student.username], s);
      });
    }
  }

  @override
  void dispose() {
    if (socketTimer != null) {
      socketTimer.cancel();
    }
    super.dispose();
  }
}
