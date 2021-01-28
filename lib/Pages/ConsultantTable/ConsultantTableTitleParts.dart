import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantTableSRV.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/PDFSRV.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Pages/ConsultantTable/DayDetail.dart';
import 'package:mhamrah/Pages/ShareTable/ShareTableContactList.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Utils/StorageAndFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LessonPageTitleParts extends StatefulWidget {
  final ConsultantTableState c;
  final String lastTableName;

  LessonPageTitleParts(this.c, this.lastTableName);

  @override
  _LessonPageTitlePartState createState() =>
      _LessonPageTitlePartState(c, lastTableName);
}

class _LessonPageTitlePartState extends State<LessonPageTitleParts> {
  ConsultantTableSRV consultantTableSRV = new ConsultantTableSRV();
  PDFSRV pdfsrv = PDFSRV();
  ConnectionService httpRequestService = ConnectionService();
  int userType = 1;

//  List<String> daysDate;
//  List<int> daysCompletePercent;
  String _selectedValueForDropDown;
  String lastTableName;
  ConsultantTableState c;

  double xSize;
  double ySize;

  List<Widget> days;
  List<Widget> dayMarks = [];
  Map<String, bool> downloadLoading = {};

  _LessonPageTitlePartState(this.c, this.lastTableName) {
    _selectedValueForDropDown = lastTableName;
  }

  @override
  void initState() {
    super.initState();
    LSM.getUserMode().then((type) {
      setState(() {
        userType = type;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    days = getDays();
//    if (dayMarks == null) {
//      dayMarks = getDayMarks();
//    }
    return new Container(
      key: ValueKey(lastTableName),
      width: xSize,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [prefix0.Theme.titleBar2, prefix0.Theme.titleBar1]),
        color: prefix0.Theme.titleBar1,
        borderRadius: new BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(
                top: FirstPage.androidTitleBarHeight,
                bottom: 10,
                right: xSize * (4 / 100)),
            child: new Container(
              width: xSize * (96 / 100),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      decoration: new BoxDecoration(
                        color: userType == 0 ? prefix0.Theme.dayDetailBG : null,
                        borderRadius: new BorderRadius.all(Radius.circular(25)),
                      ),
                      padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          userType == 0 ||
                                  (userType == 1 && c.studentAccess && true)
                              ? Container(
                                  child: Icon(
                                    Icons.edit,
                                    color: prefix0.Theme.onTitleBarText,
                                    size: 20,
                                  ),
                                )
                              : SizedBox(),
                          new Container(
                            alignment: Alignment.centerLeft,
                            child: new Padding(
                              padding: EdgeInsets.only(
                                  top: 5, left: userType == 0 ? 0 : 10),
                              child: AutoSizeText(
                                c.consultantTableData.startDate == null
                                    ? ""
                                    : c.consultantTableData.startDate,
                                style: prefix0.getTextStyle(
                                    22, prefix0.Theme.onTitleBarText),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      if (userType == 0 ||
                          (userType == 1 && c.studentAccess && true)) {
                        c.showEditCreateNewPlanFrag(false);
                      }
                    },
                  ),
                  getDropDownButton(),
                ],
              ),
            ),
          ),
          new Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: days,
            ),
          ),
          new Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dayMarks,
            ),
          )
        ],
      ),
    );
  }

  Widget getDropDownButton() {
    List<String> planNames = c.totalPlans.getPlanListName();
    String selectedPlanInStudentMainPage =
        StudentMainPageState.selectedPlanName;
    StudentMainPageState.selectedPlanName =
        planNames.contains(selectedPlanInStudentMainPage)
            ? selectedPlanInStudentMainPage
            : _selectedValueForDropDown;
    return new Container(
      width: (MediaQuery.of(context).size.width) * (60 / 100),
      height: StudentMainPageState.appbarDropDownHeight,
      alignment: Alignment.center,
      decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(Radius.circular(10))),
      child: new Theme(
        data: Theme.of(context).copyWith(
          canvasColor: prefix0.Theme.titleBar1,
        ),
        child: new DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              value: planNames.contains(selectedPlanInStudentMainPage)
                  ? selectedPlanInStudentMainPage
                  : _selectedValueForDropDown,
              elevation: 2,
              onChanged: (newValue) {
                setState(() {
                  if (newValue == "+++") {
                    if (userType == 1) {
                      LSM.getStudent().then((student) {
                        if (student.checkValidDataForConsultantRequest()) {
                          c.showEditCreateNewPlanFrag(true);
                        } else {
                          showFlutterToastWithFlushBar(
                              completeInfoForCreatingTable);
                        }
                      });
                    } else {
                      c.showEditCreateNewPlanFrag(true);
                    }
                  } else {
                    c.changeWeekPlan(newValue);
                    _selectedValueForDropDown = newValue;
                    StudentMainPageState.selectedPlanName = newValue;
                  }
                });
              },
              isExpanded: false,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              items: (planNames +
                      (userType == 0 ||
                              (userType == 1 && c.studentAccess && true)
                          ? ["+++"]
                          : []))
                  .map((String value) {
                if (!downloadLoading.keys.contains(value)) {
                  downloadLoading[value] = false;
                }
                return new DropdownMenuItem<String>(
                    value: value,
                    key: ValueKey(value),
                    child: value == "+++"
                        ? Container(
                            height: 35,
                            child: Icon(
                              Icons.add_circle,
                              color: prefix0.Theme.onTitleBarText,
                            ),
                            alignment: Alignment.center,
                          )
                        : new Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        width: 48,
                                        height: 37,
                                        child: downloadLoading[value]
                                            ? getLoadingProgress()
                                            : Icon(
                                                Icons.cloud_download,
                                                color: prefix0
                                                    .Theme.onTitleBarText,
                                                size: 28,
                                              ),
                                        alignment: Alignment.center,
                                      ),
                                      onTap: () {
                                        downloadPdf(value);
                                      },
                                    ),
                                    Container(
//                                    width: xSize * (33 / 100),
                                      height: 35,
                                      alignment: Alignment.center,
                                      child: AutoSizeText(
                                        value,
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                        style: prefix0.getTextStyle(
                                            21, prefix0.Theme.onTitleBarText),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 0.5,
                                color: Colors.black,
                              )
                            ],
                          ));
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoadingProgress() {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        child: CircleAvatar(
          backgroundColor: Color.fromARGB(0, 0, 0, 0),
          child: CircularProgressIndicator(
            valueColor:
                new AlwaysStoppedAnimation<Color>(prefix0.Theme.onMainBGText),
          ),
          radius: 25,
        ),
        width: 25,
        height: 25,
      ),
    );
  }

  List<Widget> getDays() {
    List<Widget> result = [];
    for (int index = 0; index < daysType2.length; index++) {
      Widget day = DayDetail(c, null, null, index);
      GestureDetector w = new GestureDetector(
        child: day,
        onTap: () {
          selectDay(index);
        },
      );
      result.add(w);
    }
    return result;
  }

//
//  List<Widget> getDayMarks() {
//    List<Widget> result = [];
//    for (int index = 0; index < daysType2.length; index++) {
//      Widget day;
//      if (index == daysType2.length - 1) {
//        day = getDayMark(Colors.black);
//      } else {
//        day = getDayMark(Colors.transparent);
//      }
//      result.add(day);
//    }
//    return result;
//  }

//  Widget getDayMark(color) {
//    return new Padding(
//      padding: EdgeInsets.all(5),
//      child: new Container(
//        height: 2,
//        width: xSize / 9,
//        color: color,
//      ),
//    );
//  }

  void setLastTable() {
    setState(() {
      _selectedValueForDropDown = c.totalPlans.getPlanListName().last;
    });
  }

  void selectDay(int dayIndex) {
    c.selectDayPlans(days.length - dayIndex - 1);
//    List<Widget> dayMarks = [];
//    for (int index = 0; index < days.length; index++) {
//      if (dayIndex == index) {
//        dayMarks.add(getDayMark(Colors.black));
//      } else {
//        dayMarks.add(getDayMark(Colors.transparent));
//      }
//    }
    setState(() {
      this.dayMarks = dayMarks;
    });
  }

  void downloadPdf(String tableName) {
    setState(() {
      downloadLoading[tableName] = true;
    });
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        pdfsrv
            .generatePDFToken(
                consultant.username,
                StudentMainPage.studentUsername,
                consultant.authentication_string,
                tableName)
            .then((token) {
          if (token != null) {
            String url = httpRequestService.getConsultantPdfURL(
                consultant.username,
                StudentMainPage.studentUsername,
                tableName,
                token);

            String folder = StorageFolders.pdfChartAndTablesFiles;
            String fileName =
                tableName + " - " + StudentMainPage.studentUsername;
            saveAndOpenFile(url, folder, fileName, popDialogOnDone: false)
                .then((value) {
              setState(() {
                downloadLoading[tableName] = false;
              });
            });
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        pdfsrv
            .generatePDFToken(student.username, student.username,
                student.authentication_string, tableName)
            .then((token) {
          if (token != null) {
            String url = httpRequestService.getConsultantPdfURL(
                student.username, student.username, tableName, token);
            setState(() {
              downloadLoading[tableName] = false;
            });
            String folder = StorageFolders.pdfChartAndTablesFiles;
            String fileName =
                tableName + " - " + StudentMainPage.studentUsername;
            saveAndOpenFile(url, folder, fileName, popDialogOnDone: false)
                .then((value) {});
          }
        });
      });
    }
  }
}
