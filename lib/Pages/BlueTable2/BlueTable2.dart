import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/BlueTable2SRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Models/BlueTable2MV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Pages/BlueTable1/BlueTable1.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Pages/SharedTitlePart/EmptyTitlePart.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../StudentMainPage.dart';
import 'BlueTItlePart2.dart';
import 'CreateBlueLessonFragment2.dart';
import 'EditBlueLessonFragment2.dart';

class BlueTable2 extends StatefulWidget {
  Timer socketTimer;

  BlueTable2();

  @override
  BlueTable2State createState() {
    return BlueTable2State();
  }
}

class BlueTable2State extends State<BlueTable2> {
  BlueTable2SRV blueTable2SRV = new BlueTable2SRV();
  int userType = 0;
  double diameter;
  double cellWidth;
  double cellHeight;

  static B2DayPlan emptyPlan1 = B2DayPlan.getEmptyInitial(0, "", []);

  static BlueTable2Data b = BlueTable2Data.initialData(
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
      "");

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  static AllBlue2Tables totalBlueTables2 = AllBlue2Tables("", [b]);
  int selectedDay;
  bool _loadingTotalPageFlag = false;
  B2LessonPerDay selectedLessonColor;

  BlueTable2Data blueTable2Data;

  Widget createLessonFragment = new Container();
  bool _createLessonFragToggle = false;

  Widget editFragment = new Container();
  bool _editFragToggle = false;

  Widget titleBar;

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
          widget.socketTimer = value;
        });
      } else {
        LSM.getStudent().then((student) {
          socketConnectionChecker([student.username], this, socketTableUpdater,
                  socketHttpUpdaterFunction)
              .then((value) {
            setState(() {
              widget.socketTimer = value;
            });
          });
        });
      }

      /// fetching data from local
      LSM
          .getBlue2AllTables(
        StudentMainPage.studentUsername,
      )
          .then((blue2AllTables) {
        if (blue2AllTables != null) {
          if (blue2AllTables.allTables.length != 0) {
            setState(() {
              totalBlueTables2 = blue2AllTables;
              blueTable2Data = totalBlueTables2.allTables.last;
              titleBar = BlueTitlePart2(totalBlueTables2.year, this);
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
    if (totalBlueTables2.allTables.length != 0) {
      if (totalBlueTables2
          .getPlanListName()
          .contains(StudentMainPageState.selectedPlanName)) {
        blueTable2Data = totalBlueTables2
            .getBlueTable2ByName(StudentMainPageState.selectedPlanName);
      } else {
        blueTable2Data = totalBlueTables2.allTables.last;
      }
    }
    selectedDay = StudentMainPageState.selectedDayIndex;
    cellWidth = MediaQuery.of(context).size.width * (19 / 100);
    cellHeight = MediaQuery.of(context).size.width * (13 / 100);
    diameter = max(85, MediaQuery.of(context).size.height * (11 / 100));
    return new Stack(
      children: <Widget>[
        new Container(
          color: prefix0.Theme.mainBG,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              titleBar == null
                  ? EmptyTitlePart(
                      "", ["", "", "", "", "", "", ""], null, null, this)
                  : titleBar,
              new Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _loadingTotalPageFlag
                        ? getLoadingBar()
                        : (blueTable2Data.name == emptyInitialPlanName
                            ? []
                            : [getLessonsCirclesColor(), getColoredTable()])),
              )
            ],
          ),
        ),
        new Visibility(
          child: createLessonFragment,
          visible: _createLessonFragToggle,
        ),
        new Visibility(
          child: editFragment,
          visible: _editFragToggle,
        ),
      ],
    );
  }

  Widget getColoredTable() {
    List<Widget> allRows = [];
    List<List<String>> dayPlan =
        blueTable2Data.daysSchedule[selectedDay].dayPlan;
    for (int i = 0; i < dayPlan.length; i++) {
      allRows.add(getColoredRow(i, dayPlan[i]));
    }
    return Expanded(
        child: new SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: allRows,
        ),
      ),
      scrollDirection: Axis.vertical,
    ));
  }

  Widget getColoredRow(int rowNumber, List<String> hourPlanList) {
    List<Widget> res = [];
    B2DayPlan b2dayPlan = blueTable2Data.daysSchedule[selectedDay];
    List<List<String>> dayPlan = b2dayPlan.dayPlan;
    res.add(getRowNumberText(rowNumber));
    for (int i = 0; i < hourPlanList.length; i++) {
      Widget w = GestureDetector(
        key: ValueKey(selectedDay.toString() +
            "-" +
            (rowNumber).toString() +
            i.toString()),
        child: getOneCell(b2dayPlan.getB2LessonPerDayByKey(hourPlanList[i]),
            rowNumber, i, hourPlanList[i]),
        onTap: () {
          if (selectedLessonColor != null && userType == 1) {
            setCellValue(rowNumber, i, selectedLessonColor.key);
          }
        },
        onLongPress: () {
          if (dayPlan[rowNumber][i] != null && userType == 1) {
            setCellValue(rowNumber, i, null);
          }
        },
      );
      res.add(w);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: res.reversed.toList(),
    );
  }

  void setCellValue(int rowIndex, int columnIndex, cellValue) async {
    B2DayPlan b2dayPlan = blueTable2Data.daysSchedule[selectedDay];
    List<List<String>> dayPlan = b2dayPlan.dayPlan;

    setState(() {
      dayPlan[rowIndex][columnIndex] = "...";
    });
    //TODO user account
    LSM.getStudent().then((student) {
      blueTable2SRV
          .changeBlue2Table(
              student.username,
              student.authentication_string,
              blueTable2Data.name,
              selectedDay,
              cellValue,
              rowIndex,
              columnIndex)
          .then((status) {
        if (status) {
          setState(() {
            dayPlan[rowIndex][columnIndex] = cellValue;
          });
          LSM.setBlue2AllTables(
              StudentMainPage.studentUsername, totalBlueTables2);
          notifyBlue2TableColor(rowIndex, columnIndex, cellValue);
        }
      });
    });
  }

  Widget getRowNumberText(int rowNumber) {
    BorderRadius tl = BorderRadius.only(topRight: Radius.circular(25));
    BorderRadius bl = BorderRadius.only(bottomRight: Radius.circular(25));
    BorderRadius res;
    if (rowNumber == 0) {
      res = tl;
    } else if (rowNumber == 23) {
      res = bl;
    } else {
      res = BorderRadius.only();
    }

    return Container(
      width: cellHeight,
      height: cellHeight,
      alignment: Alignment.center,
      child: AutoSizeText(
        rowNumber < 10 ? "0" + rowNumber.toString() : rowNumber.toString(),
        style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
      ),
      decoration: BoxDecoration(
          color: prefix0.Theme.blue2CellBG,
          borderRadius: res,
          border: BoxBorder.lerp(
              Border.all(color: prefix0.Theme.darkText, width: 0.1),
              Border.all(color: prefix0.Theme.darkText, width: 0.01),
              0)),
    );
  }

  Widget getOneCell(
      B2LessonPerDay b2lessonPerDay, int rowNumber, int columnNumber, key) {
    BorderRadius tr = BorderRadius.only(topLeft: Radius.circular(25));
    BorderRadius br = BorderRadius.only(bottomLeft: Radius.circular(25));

    BorderRadius res;
    if (rowNumber == 0 && columnNumber == 3) {
      res = tr;
    } else if (rowNumber == 23 && columnNumber == 3) {
      res = br;
    } else {
      res = new BorderRadius.only();
    }

    Color lessonColor;
    if (b2lessonPerDay != null) {
      lessonColor = getColorFromLesson(b2lessonPerDay);
    } else {
      lessonColor = prefix0.Theme.blue2CellBG;
    }
    return Container(
      width: cellWidth,
      height: cellHeight,
      child: key == "..."
          ? Container(
              width: cellHeight,
              height: cellHeight,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                  radius: 10,
                ),
              ),
            )
          : SizedBox(),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: prefix0.Theme.spreadRadius,
              blurRadius: prefix0.Theme.blurRadius + 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: res,
          color: lessonColor,
          border: BoxBorder.lerp(
              Border.all(color: prefix0.Theme.darkText, width: 0.1),
              Border.all(color: prefix0.Theme.darkText, width: 0.1),
              1)),
    );
  }

  void changeWeekPlan(String name) {
    setState(() {
      blueTable2Data = totalBlueTables2.getBlueTable2ByName(name);
    });
  }

  Widget getLessonsCirclesColor() {
    return Container(
      height: 10 + diameter + 10 - 1,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: new Padding(
          padding: EdgeInsets.all(5),
          child: new Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: diameter + 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: getAllLessonCircleList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getAllLessonCircleList() {
    List<Widget> res = [];
    List<B2LessonPerDay> lessons =
        blueTable2Data.daysSchedule[selectedDay].dayLessons;
    Map<String, double> dedicatedLessonsTime = blueTable2Data
        .daysSchedule[selectedDay]
        .getDedicatedTimeForAllLessons();
    for (int i = 0; i < lessons.length; i++) {
      var a = lessons[i];
      var b = dedicatedLessonsTime[lessons[i].key] ?? 0;
      res.add(getSingleLessonCircle(
          lessons[i], dedicatedLessonsTime[lessons[i].key] ?? 0));
    }
    res = res.reversed.toList();
//    if (userType == 1) {
//      res.insert(0, getAddLessonButton());
//    }
    return res;
  }

  Widget getSingleLessonCircle(
      B2LessonPerDay b2lessonPerDay, double dedicatedTime) {
    Color circleColors = getColorFromLesson(b2lessonPerDay);
    bool isSelected = false;
    if (selectedLessonColor != null &&
        b2lessonPerDay.key == selectedLessonColor.key) {
      isSelected = true;
    }
    return new GestureDetector(
      child: new Padding(
        padding: EdgeInsets.only(right: 3, left: 3),
        child: CircularPercentIndicator(
          radius: isSelected ? diameter : diameter - 10,
          percent: min(
              max(0.005, dedicatedTime / (b2lessonPerDay.getPredictedMinute()+1)),
              1.0),
          backgroundColor: Color.fromARGB(100, 200, 200, 200),
          progressColor: circleColors,
          center: Container(
            alignment: Alignment.center,
            width: isSelected ? diameter - 20 : diameter - 30,
            height: isSelected ? diameter - 20 : diameter - 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColors,
            ),
            child: AutoSizeText(
              b2lessonPerDay.lessonName,
              textAlign: TextAlign.center,
              softWrap: true,
              style: prefix0.getTextStyle(12, prefix0.Theme.darkText),
            ),
          ),
        ),
      ),
      onTap: () {
        if (userType == 1) {
          setState(() {
            selectedLessonColor = b2lessonPerDay;
          });
        }
      },
      onLongPress: () {
        setState(() {
          editFragment = EditBlueLessonFragment2(this, b2lessonPerDay);
          _editFragToggle = true;
          selectedLessonColor = b2lessonPerDay;
        });
      },
    );
  }

  void selectDayPlans(int index) {
    StudentMainPageState.selectedDayIndex = index;
    setState(() {
      selectedDay = index;
    });
  }

  Widget getAddLessonButton() {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(right: 5, left: 5),
        child: Icon(
          Icons.add_circle,
          color: prefix0.Theme.onMainBGText,
          size: 40,
        ),
      ),
      onTap: () {
        setState(() {
          createLessonFragment = CreateBlueLessonFragment2(this);
          _createLessonFragToggle = true;
        });
      },
    );
  }

  void closeCreateLessonFrag() {
    setState(() {
      _createLessonFragToggle = false;
    });
  }

  void closeEditLessonFrag() {
    setState(() {
      _editFragToggle = false;
    });
  }

  void addLessonCircleColor(B2LessonPerDay b2lessonPerDay) {
    setState(() {
      B2LessonPerDay newLessonPerDay =
          blueTable2Data.getNewPlanLesson(selectedDay);
      newLessonPerDay.predictedDurationTime = b2lessonPerDay.finalDurationTime;
      newLessonPerDay.predictedTestNumber = b2lessonPerDay.predictedTestNumber;
      newLessonPerDay.lessonName = b2lessonPerDay.lessonName;
      newLessonPerDay.lessonColor = b2lessonPerDay.lessonColor;
      _createLessonFragToggle = false;
    });
  }

  void editLessonColor(B2LessonPerDay b2lessonPerDay) {
    setState(() {
      _editFragToggle = false;
      _createLessonFragToggle = false;
      selectedLessonColor.lessonName = b2lessonPerDay.lessonName;
      selectedLessonColor.predictedTestNumber =
          b2lessonPerDay.predictedTestNumber;
      selectedLessonColor.finalTestNumber = b2lessonPerDay.finalTestNumber;
      selectedLessonColor.predictedDurationTime =
          b2lessonPerDay.predictedDurationTime;
      selectedLessonColor.finalDurationTime = b2lessonPerDay.finalDurationTime;
    });
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

  void socketHttpUpdaterFunction() {
    fetchAllTables(false);
  }

  void fetchAllTables(bool withLoading) {
    if (withLoading) {
      _loadingTotalPageFlag = true;
    }
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        blueTable2SRV
            .getAllTables(consultant.username, StudentMainPage.studentUsername,
                consultant.authentication_string)
            .then((blue2AllTables) {
          if (blue2AllTables != null) {
            LSM.setBlue2AllTables(
                StudentMainPage.studentUsername, blue2AllTables);
            if (blue2AllTables.allTables.length != 0) {
              setState(() {
                totalBlueTables2 = blue2AllTables;
                if (withLoading) {
                  _loadingTotalPageFlag = false;
                }
                blueTable2Data = totalBlueTables2.allTables.last;
                titleBar = BlueTitlePart2(totalBlueTables2.year, this);
              });
            } else {
              setState(() {
                titleBar = EmptyTitlePart(
                    "", ["", "", "", "", "", "", ""], null, null, this);
                totalBlueTables2 = AllBlue2Tables("", [b]);
                if (withLoading) {
                  _loadingTotalPageFlag = false;
                }
              });
            }
          }
        });
      });
    } else {
      LSM.getStudent().then((student) {
        blueTable2SRV
            .getAllTables(student.sub_consultant_username, student.username,
                student.authentication_string)
            .then((blue2AllTables) {
          if (blue2AllTables != null) {
            LSM.setBlue2AllTables(
                StudentMainPage.studentUsername, blue2AllTables);
            if (blue2AllTables.allTables.length != 0) {
              setState(() {
                totalBlueTables2 = blue2AllTables;
                if (withLoading) {
                  _loadingTotalPageFlag = false;
                }
                blueTable2Data = totalBlueTables2.allTables.last;
                titleBar = BlueTitlePart2(totalBlueTables2.year, this);
              });
            } else {
              setState(() {
                titleBar = EmptyTitlePart(
                    "", ["", "", "", "", "", "", ""], null, null, this);
                totalBlueTables2 = AllBlue2Tables("", [b]);
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
//      socketTableUpdater(ConnectionService.stream);
//    }
//    socketTimer = Timer.periodic(Duration(seconds: 3), (Timer t) {
//      if (ConnectionService.channel == null ||
//          (ConnectionService.channel.closeCode != null &&
//              ConnectionService.channel.closeReason != null)) {
//        Fluttertoast.showToast(
//            msg: connectionError,
//            toastLength: Toast.LENGTH_SHORT,
//            backgroundColor: prefix0.Theme.redBright,
//            gravity: ToastGravity.BOTTOM,
//            timeInSecForIosWeb: 3);
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
//        socketTableUpdater(ConnectionService.stream);
//        Fluttertoast.showToast(
//            msg: connectionStablished,
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.BOTTOM,
//            backgroundColor: prefix0.Theme.greenButton,
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
      } else if (s.requestType == "notify_blue2_table") {
        BlueTable2Data consultantTable =
            (s.requestData as Blue2TableSR).blueTable2Data;
        if (totalBlueTables2.getPlanListName().contains(consultantTable.name)) {
          setState(() {
            totalBlueTables2.updateSingleTable(consultantTable);
          });
          setStateTitleBar();
        } else {
          setState(() {
            totalBlueTables2.updateSingleTable(consultantTable);
          });
          setLast();
        }
        LSM.setBlue2AllTables(
            StudentMainPage.studentUsername, totalBlueTables2);
      } else if (s.requestType == "notify_blue2_color_table") {
        Blue2TableColorSR blue2tableColorSR =
            s.requestData as Blue2TableColorSR;
        BlueTable2Data selectedBlue2Table =
            totalBlueTables2.getBlueTable2ByName(blue2tableColorSR.tableName);
        int day = blue2tableColorSR.selectedDay;
        int hourIndex = blue2tableColorSR.hourIndex;
        int partIndex = blue2tableColorSR.partIndex;
        String value = blue2tableColorSR.value;
        setState(() {
          selectedBlue2Table.daysSchedule[day].dayPlan[hourIndex][partIndex] =
              value;
        });
        setStateTitleBar();
        LSM.setBlue2AllTables(
            StudentMainPage.studentUsername, totalBlueTables2);
      }
    });
  }

  void setStateTitleBar() {
    setState(() {
      titleBar = BlueTitlePart2(totalBlueTables2.year, this);
      StudentMainPageState.selectedPlanName = blueTable2Data.name;
    });
  }

  void setLast() {
    setState(() {
      blueTable2Data = totalBlueTables2.allTables.last;
      titleBar = BlueTitlePart2(totalBlueTables2.year, this);
      StudentMainPageState.selectedPlanName = blueTable2Data.name;
    });
  }

  void notifyBlue2Table(BlueTable2Data table) async {
    SocketNotifyingData s = SocketNotifyingData();
    s.requestType = "notify_blue2_table";
    Blue2TableSR csr = Blue2TableSR();
    csr.blueTable2Data = table;
    s.requestData = csr;
    if (userType == 0) {
      csr.studentUsername = StudentMainPage.studentUsername;
      ConnectionService.sendDataToSocket([StudentMainPage.studentUsername], s);
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        csr.studentUsername = student.username;
        ConnectionService.sendDataToSocket([student.username], s);
      });
    }
  }

  void notifyBlue2TableColor(int hourIndex, int partIndex, String value) async {
    SocketNotifyingData s = SocketNotifyingData();
    s.requestType = "notify_blue2_color_table";
    Blue2TableColorSR csr = Blue2TableColorSR();
    csr.selectedDay = selectedDay;
    csr.tableName = blueTable2Data.name;
    csr.value = value;
    csr.hourIndex = hourIndex;
    csr.partIndex = partIndex;
    s.requestData = csr;
    if (userType == 1) {
      LSM.getStudent().then((student) {
        csr.studentUsername = student.username;
        ConnectionService.sendDataToSocket([student.username], s);
      });
    }
  }

  @override
  void dispose() {
    if (widget.socketTimer != null) {
      widget.socketTimer.cancel();
    }
    super.dispose();
  }
}
