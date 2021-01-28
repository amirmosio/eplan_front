import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantTableSRV.dart';
import 'package:mhamrah/ConnectionService/DateTime.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Models/SocketNotifingModel.dart';
import 'package:mhamrah/Pages/ConsultantTable/LessonField.dart';
import 'package:mhamrah/Pages/ShareTable/ShareTableContactList.dart';
import 'package:mhamrah/Pages/SharedTitlePart/EmptyTitlePart.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'ConsultantTableTitleParts.dart';
import 'CreateNewPlanFrag.dart';
import 'EditCreateFragment.dart';
import 'EditDeleteFragment.dart';

class ConsultantTable extends StatefulWidget {
  ConsultantTable({Key key}) : super(key: key);

  @override
  ConsultantTableState createState() => ConsultantTableState();
}

class ConsultantTableState extends State<ConsultantTable> {
  int userType = 1;
  bool studentAccess = false;
  bool isParentAccount = false;
  double xSize = 0;
  ConsultantTableSRV consultantTableSRV = ConsultantTableSRV();
  static CDayPlan emptyPlan = CDayPlan.initialData(0, "", []);
  TextEditingController scoreController = TextEditingController();
  bool dailyScoreErrorToggle = false;

  static ConsultantTableModel weekPlan1 = ConsultantTableModel.initialData(
      emptyInitialPlanName,
      [
        emptyPlan,
        emptyPlan,
        emptyPlan,
        emptyPlan,
        emptyPlan,
        emptyPlan,
        emptyPlan,
      ],
      "");
  ConsultantAllTables totalPlans = ConsultantAllTables("", [weekPlan1]);

  ConsultantTableModel consultantTableData;

  bool _createEditWidgetToggle = false;
  bool _createEditWidgetIsOpaque = false;
  bool _deleteEditWidgetToggle = false;

  //just inner class field for edit/create top widget
  Widget _createEditFrag = new Container();
  bool createOrEditMode;
  CLessonPlanPerDay _selectedLessonForFragment;

  Widget _createNewPlanFrag = new Container();
  bool createNewPlanFragToggle = false;

  int selectedDay;
  bool _loadingFlag = false;

  Widget titleBar;
  Timer socketTimer;

  bool wakeUpTimeLoading = false;
  bool dailyConsultantScore = false;

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
            studentAccess = student.student_access;
//            parentAccount = student.parent != "";
          });
        });
      }

      /// fetching data from local file
      LSM
          .getConsultantAllTables(StudentMainPage.studentUsername)
          .then((consultantAllTables) {
        if (consultantAllTables != null) {
          setState(() {
            if (consultantAllTables.allTables.length != 0) {
              totalPlans = consultantAllTables;
              consultantTableData = totalPlans.allTables.last;
              titleBar =
                  LessonPageTitleParts(this, totalPlans.getPlanListName().last);
            }
            if (StudentMainPageState.selectedPlanName == "" &&
                consultantTableData != null) {
              StudentMainPageState.selectedPlanName = consultantTableData.name;
              fetchAllTables(false, true, false);
            } else {
              fetchAllTables(false, false, false);
            }
          });
        } else {
          fetchAllTables(true, true, false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (totalPlans.allTables.length != 0) {
      if (totalPlans
          .getPlanListName()
          .contains(StudentMainPageState.selectedPlanName)) {
        consultantTableData = totalPlans
            .getConsultantTableByName(StudentMainPageState.selectedPlanName);
      } else {
        consultantTableData = totalPlans.allTables.last;
      }
    }
    selectedDay = StudentMainPageState.selectedDayIndex;
    xSize = MediaQuery.of(context).size.width;
    double x = (92 / 100) * xSize;
    return WillPopScope(
      child: Scaffold(
        floatingActionButton: userType != 0 ||
                consultantTableData.name == emptyInitialPlanName ||
                _createEditWidgetToggle ||
                _deleteEditWidgetToggle
            ? SizedBox()
            : Container(
                width: 80,
                height: 50,
                child: FloatingActionButton(
                  backgroundColor: prefix0.Theme.applyButton,
                  child: GestureDetector(
                    child: Container(
                      width: 35,
                      height: 35,
                      child: Icon(
                        Icons.share,
                        color: prefix0.Theme.onMainBGText,
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                  onPressed: () {
                    StudentMainPageState.sharePageCurrentRoute = true;
                    navigateToSubPage(
                        context,
                        ShareTableStudentList(
                            totalPlans.getConsultantTableByName(
                                consultantTableData.name),
                            this));
                    try {
                      socketTimer.cancel();
                    } catch (e) {}
                  },
                ),
              ),
        body: new Stack(
          children: <Widget>[
            new Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: prefix0.Theme.mainBG,
              child: new Padding(
                padding: EdgeInsets.only(
                  left: x,
                  right: xSize - x - 2,
                ),
                child: new Container(
                  color: _loadingFlag
                      ? prefix0.Theme.mainBG
                      : prefix0.Theme.greyTimeLine,
                  width: 2,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),
            new Container(
              color: Colors.transparent,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  titleBar == null
                      ? EmptyTitlePart(
                          "", ["", "", "", "", "", "", ""], this, null, null)
                      : titleBar,
                  new Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          getDayDescriptionDetail(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: (_loadingFlag
                                ? getLoadingBar()
                                : getLessonRows() +
                                    ((userType == 0 ||
                                                (userType == 1 &&
                                                    studentAccess &&
                                                    true)) &&
                                            consultantTableData.name !=
                                                emptyInitialPlanName
                                        ? [getAddIcon()]
                                        : [])),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            new Visibility(
              child: _createEditFrag,
              visible: _createEditWidgetToggle,
            ),
            new Visibility(
              child: EditDeleteFragment(this),
              visible: _deleteEditWidgetToggle,
            ),
            new Visibility(
              child: _createNewPlanFrag,
              visible: createNewPlanFragToggle,
            )
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  void toggleCreateEditWidget(bool showOrHide) {
    if (showOrHide) {
      setState(() {
        _createEditWidgetToggle = true;
        _createEditWidgetIsOpaque = true;
      });
    } else {
      setState(() {
        _createEditWidgetToggle = false;
        _createEditWidgetIsOpaque = false;
      });
    }
  }

  List<GestureDetector> getLessonRows() {
    List<GestureDetector> result = [];
    List<CLessonPlanPerDay> dayPlans =
        consultantTableData.daysSchedule[selectedDay].dayLessonPlans;
    for (int index = 0; index < dayPlans.length; index++) {
      CLessonPlanPerDay lesson = dayPlans[index];
      Widget w = getLessonFieldRow(lesson);
      result.add(w);
    }
    return result;
  }

  void notifyIsCompleteChangeIsLessonField() {
    setState(() {
      titleBar = LessonPageTitleParts(this, totalPlans.getPlanListName().last);
    });
  }

  Widget getLessonFieldRow(CLessonPlanPerDay lessonPlanPerDay) {
    Widget lessonWidget = Visibility(
      key: ValueKey(lessonPlanPerDay.key),
      child: LessonFieldRow(lessonPlanPerDay, this),
    );
    Widget w = new GestureDetector(
      child: lessonWidget,
      key: ValueKey(lessonPlanPerDay.hashCode),
      onLongPress: () {
        if (userType == 0 || (userType == 1 && studentAccess && true)) {
          setState(() {
            _selectedLessonForFragment = lessonPlanPerDay;
            _deleteEditWidgetToggle = !_deleteEditWidgetToggle;
          });
        }
      },
    );
    return w;
  }

  void closeCreateEditFrag() {
    toggleCreateEditWidget(false);
  }

  void updateStudentAccess() {
    LSM.getUserMode().then((value) {
      if (value == 1) {
        LSM.getStudent().then((student) {
          setState(() {
            studentAccess = student.student_access;
          });
        });
      }
    });
  }

  void closeDeleteEditFrag() {
    setState(() {
      _deleteEditWidgetToggle = false;
    });
  }

  void showEditLessonFragment() {
    setState(() {
      createOrEditMode = false;
      _createEditFrag = EditCreateFragment(_selectedLessonForFragment, this);
      toggleCreateEditWidget(true);
      _deleteEditWidgetToggle = false;
    });
  }

  void showEditCreateNewPlanFrag(bool createMode) {
    setState(() {
      _createNewPlanFrag = CreateNewPlanFrag(createMode, this);
      createNewPlanFragToggle = true;
      _deleteEditWidgetToggle = false;
    });
  }

  void AddLessonWidget(CLessonPlanPerDay data) {
    setState(() {
      CLessonPlanPerDay l = consultantTableData.planNewDayPlan(selectedDay);
      l.startTime = data.startTime;
      l.endTime = data.endTime;
      l.lessonName = data.lessonName;
      l.description = data.description;
      l.hasVoiceFile = data.hasVoiceFile;
      l.importance = data.importance;
      toggleCreateEditWidget(false);
    });
    LSM.setConsultantAllTables(StudentMainPage.studentUsername, totalPlans);
  }

  void updateLessonWidget(CLessonPlanPerDay data) {
    setState(() {
      data.key = _selectedLessonForFragment.key;
      consultantTableData.updateLessonPerDay(selectedDay, data);
      toggleCreateEditWidget(false);
      titleBar = LessonPageTitleParts(this, totalPlans.getPlanListName().last);
      StudentMainPageState.selectedPlanName = consultantTableData.name;
    });
    LSM.setConsultantAllTables(StudentMainPage.studentUsername, totalPlans);
  }

  void deleteLesson() {
    String selectKey = _selectedLessonForFragment.key;
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        consultantTableSRV
            .deleteLessonField(
                consultant.username,
                StudentMainPage.studentUsername,
                consultant.authentication_string,
                selectKey,
                consultantTableData.name)
            .then((status) {
          if (status['success']) {
            int deleteIndex =
                consultantTableData.deleteLessonPerDay(selectedDay, selectKey);
            notifyConsultantTable(consultantTableData);
            setState(() {
              _deleteEditWidgetToggle = false;
            });
            LSM.setConsultantAllTables(
                StudentMainPage.studentUsername, totalPlans);
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        consultantTableSRV
            .deleteLessonField(
                student.username,
                student.username,
                student.authentication_string,
                selectKey,
                consultantTableData.name)
            .then((status) {
          if (status['success']) {
            int deleteIndex =
                consultantTableData.deleteLessonPerDay(selectedDay, selectKey);
            notifyConsultantTable(consultantTableData);
            setState(() {
              _deleteEditWidgetToggle = false;
            });
            LSM.setConsultantAllTables(
                StudentMainPage.studentUsername, totalPlans);
          } else {
            if (status['error'] == "student access limited by bossconsultant") {
              student.student_access = false;
              LSM.updateStudentInfo(student);
              closeDeleteEditFrag();
              updateStudentAccess();
              showFlutterToastWithFlushBar(accessDeniedForStudentChange);
            }
          }
        });
      });
    }
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

  Widget descriptionDetailDailyLoadingBar() {
    Widget w = new Padding(
      padding: EdgeInsets.only(top: 0),
      child: new Container(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
    return w;
  }

  Widget getAddIcon() {
    return new GestureDetector(
      child: Container(
        padding: EdgeInsets.only(top: 10),
        width: MediaQuery.of(context).size.width * (65 / 100),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: new Container(
                height: 2,
                decoration: BoxDecoration(color: prefix0.Theme.greyTimeLine),
              ),
            ),
            GestureDetector(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: prefix0.Theme.addIconBg),
                  ),
                  new Icon(
                    Icons.add_circle,
                    color: prefix0.Theme.lessonNameBG,
                    size: 50,
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  createOrEditMode = true;
                  _createEditFrag =
                      new EditCreateFragment(CLessonPlanPerDay(), this);
                  toggleCreateEditWidget(true);
                  _deleteEditWidgetToggle = false;
                });
              },
            ),
            Expanded(
              child: new Container(
                height: 2,
                decoration: BoxDecoration(color: prefix0.Theme.greyTimeLine),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectDayPlans(int index) {
//    if (userType == 0) {
//      if (consultantTableData.daysSchedule[index].dayLessonPlans.length == 0) {
//        int lastFullPlanIndex = -1;
//        for (int i = 0; i < index; i++) {
//          if (consultantTableData.daysSchedule[i].dayLessonPlans.length != 0) {
//            lastFullPlanIndex = i;
//          }
//        }
//        setState(() {
//          if (lastFullPlanIndex != -1) {
//            CDayPlan copyPlan = consultantTableData
//                .daysSchedule[lastFullPlanIndex]
//                .getHalfCopyOfDayPlan(index);
//            consultantTableData.daysSchedule[index].dayLessonPlans =
//                copyPlan.dayLessonPlans;
//          }
//        });
//      }
//    }
    StudentMainPageState.selectedDayIndex = index;
    setState(() {
      selectedDay = index;
    });
  }

  void createNewWeakPlan(String startDate) {
    setState(() {
      createNewPlanFragToggle = false;
    });
    consultantTableData = totalPlans.allTables.last;
    notifyConsultantTable(consultantTableData);
    fetchAllTables(false, true, true);
  }

  void editTableStartDate(String startDate) {
    setState(() {
      createNewPlanFragToggle = false;
      consultantTableData.startDate = startDate;
    });
    notifyConsultantTable(consultantTableData);
    setStateTitleBar();
    fetchAllTables(false, false, false);
  }

  void closeCreateNewPlanFrag() {
    setState(() {
      createNewPlanFragToggle = false;
    });
  }

  void changeWeekPlan(String name) {
    setState(() {
      consultantTableData = totalPlans.getConsultantTableByName(name);
    });
  }

  void socketHttpUpdaterFunction() {
    fetchAllTables(false, false, true);
  }

  void fetchAllTables(
      bool withLoading, bool setLast, bool notifyLastTableCreation) {
    if (withLoading) {
      _loadingFlag = true;
    }
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        consultantTableSRV
            .getAllTables(consultant.username, StudentMainPage.studentUsername,
                consultant.authentication_string)
            .then((consultantAllTables) {
          if (consultantAllTables != null) {
            LSM.setConsultantAllTables(
                StudentMainPage.studentUsername, consultantAllTables);
            if (consultantAllTables.allTables.length != 0) {
              setState(() {
                totalPlans = consultantAllTables;
                if (notifyLastTableCreation) {
                  notifyConsultantTable(consultantAllTables.getLast());
                }
                if (withLoading) {
                  _loadingFlag = false;
                }
                if (setLast) {
                  consultantTableData = totalPlans.allTables.last;
                  titleBar = LessonPageTitleParts(
                      this, totalPlans.getPlanListName().last);
                  StudentMainPageState.selectedPlanName =
                      consultantTableData.name;
                } else {
                  setStateTitleBar();
                }
              });
            } else {
              setState(() {
                titleBar = EmptyTitlePart(
                    "", ["", "", "", "", "", "", ""], this, null, null);
                totalPlans = ConsultantAllTables("", [weekPlan1]);
                if (withLoading) {
                  _loadingFlag = false;
                }
              });
            }
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        consultantTableSRV
            .getAllTables(student.sub_consultant_username, student.username,
                student.authentication_string)
            .then((consultantAllTables) {
          if (consultantAllTables != null) {
            LSM.setConsultantAllTables(
                StudentMainPage.studentUsername, consultantAllTables);
            student.student_access = consultantAllTables.studentAccess;
            setState(() {
              studentAccess = consultantAllTables.studentAccess;
            });
            LSM.updateStudentInfo(student);
            if (consultantAllTables.allTables.length != 0) {
              setState(() {
                totalPlans = consultantAllTables;
                if (notifyLastTableCreation) {
                  notifyConsultantTable(consultantAllTables.getLast());
                }
                if (withLoading) {
                  _loadingFlag = false;
                }
                if (setLast) {
                  consultantTableData = totalPlans.allTables.last;
                  titleBar = LessonPageTitleParts(
                      this, totalPlans.getPlanListName().last);
                  StudentMainPageState.selectedPlanName =
                      consultantTableData.name;
                } else {
                  setStateTitleBar();
                }
              });
            } else {
              setState(() {
                titleBar = EmptyTitlePart(
                    "", ["", "", "", "", "", "", ""], this, null, null);
                totalPlans = ConsultantAllTables("", [weekPlan1]);
                if (withLoading) {
                  _loadingFlag = false;
                }
              });
            }
          }
        });
      });
    }
  }

  Widget getDayDescriptionDetail() {
    return Column(
      key: ValueKey(StudentMainPage.studentUsername +
          consultantTableData.name +
          selectedDay.toString()),
      children: [getPresentMark(), getDailyConsultantScore()],
    );
  }

  Widget getPresentMark() {
    String studentPresentMark =
        consultantTableData.daysSchedule[selectedDay].dailyWakeUpTime;
    return Padding(
      padding: EdgeInsets.only(
          right: xSize * (5 / 100), left: xSize * (5 / 100), top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: prefix0.Theme.cDesBG,
          boxShadow: [
            BoxShadow(
              color: prefix0.Theme.shadowColor,
              spreadRadius: prefix0.Theme.spreadRadius,
              blurRadius: prefix0.Theme.blurRadius,
              offset: Offset(0, 3), // changes position of shadow
            )
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
                padding: EdgeInsets.only(left: 15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    studentPresentMark == ""
                        ? GestureDetector(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  border: Border.all()),
                            ),
                            onTap: () {
                              if (userType == 1) {
                                setState(() {
                                  wakeUpTimeLoading = true;
                                });
                                ConnectionService.checkInternet()
                                    .then((status) {
                                  if (status) {
                                    int day = selectedDay;
                                    checkCurrentDay(
                                            day,
                                            consultantTableData.startDate,
                                            consultantTableData.getDaysDate())
                                        .then((accessStatus) {
                                      if (accessStatus == 1) {
                                        updateConsultantTableForDescriptionDetail(
                                            day);
                                      } else {
                                        setState(() {
                                          wakeUpTimeLoading = false;
                                        });
                                        showFlutterToastWithFlushBar(
                                            presentMarkInvalidDateWakeUp);
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      wakeUpTimeLoading = false;
                                    });
                                    showFlutterToastWithFlushBar(
                                        notInternetConnection);
                                  }
                                });
                              } else {
                                showFlutterToastWithFlushBar(
                                    studentsOnlyForPresentTime);
                              }
                            },
                          )
                        : GestureDetector(
                            child: Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  color: prefix0.Theme.cDesBG,
                                  boxShadow: [
                                    BoxShadow(
                                      color: prefix0.Theme.shadowColor,
                                      spreadRadius: prefix0.Theme.spreadRadius,
                                      blurRadius: prefix0.Theme.blurRadius,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    )
                                  ],
                                  border: Border.all(color: Colors.green)),
                              child: Icon(
                                Icons.done_outline,
                                color: prefix0.Theme.cDeswakyUpIcon,
                              ),
                            ),
                            onTap: () {
                              if (userType == 1) {
                                setState(() {
                                  wakeUpTimeLoading = true;
                                });
                                ConnectionService.checkInternet()
                                    .then((status) {
                                  if (status) {
                                    int day = selectedDay;
                                    checkCurrentDay(
                                            day,
                                            consultantTableData.startDate,
                                            consultantTableData.getDaysDate())
                                        .then((accessStatus) {
                                      if (accessStatus == 1) {
                                        updateConsultantTableForDescriptionDetail(
                                            day);
                                      } else {
                                        setState(() {
                                          wakeUpTimeLoading = false;
                                        });
                                        showFlutterToastWithFlushBar(
                                            presentMarkInvalidDateWakeUp);
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      wakeUpTimeLoading = false;
                                    });
                                    showFlutterToastWithFlushBar(
                                        notInternetConnection);
                                  }
                                });
                              } else {
                                showFlutterToastWithFlushBar(
                                    studentsOnlyForPresentTime);
                              }
                            },
                          ),
                    wakeUpTimeLoading
                        ? descriptionDetailDailyLoadingBar()
                        : SizedBox()
                  ],
                )),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: AutoSizeText(
                          presentMarkTime,
                          style:
                              prefix0.getTextStyle(18, prefix0.Theme.cDesTitle),
                        ),
                      )
                    ],
                  ),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 10, right: 10),
                          child: Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width / 2,
                            color: prefix0.Theme.cDesSplitLine,
                          ),
                        )
                      ]),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: AutoSizeText(
                          studentPresentMark == ""
                              ? emptyPresentTime
                              : studentPresentMark,
                          textDirection: TextDirection.rtl,
                          style: prefix0.getTextStyle(
                              15, prefix0.Theme.cDesValue,
                              fontWeight: FontWeight.w100),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getDailyConsultantScore() {
    String studentPresentMark =
        consultantTableData.daysSchedule[selectedDay].dailyScore;
    scoreController.text = studentPresentMark;
    return Padding(
      padding: EdgeInsets.only(
          right: xSize * (5 / 100), left: xSize * (5 / 100), top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: prefix0.Theme.cDesBG,
          boxShadow: [
            BoxShadow(
              color: prefix0.Theme.shadowColor,
              spreadRadius: prefix0.Theme.spreadRadius,
              blurRadius: prefix0.Theme.blurRadius,
              offset: Offset(0, 3), // changes position of shadow
            )
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            userType == 0
                ? Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Stack(alignment: Alignment.center, children: [
                      GestureDetector(
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                              border: Border.all()),
                          child: AutoSizeText(
                            dailyConsultantScore ? "" : "ثبت",
                            style: prefix0.getTextStyle(
                                18, prefix0.Theme.cDesApply),
                          ),
                        ),
                        onTap: () {
                          updateConsultantTableForDescriptionDetail(
                              selectedDay);
                        },
                      ),
                      dailyConsultantScore
                          ? descriptionDetailDailyLoadingBar()
                          : SizedBox()
                    ]))
                : SizedBox(
                    width: 50,
                    height: 50,
                  ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: AutoSizeText(
                          dailyStudentScore,
                          style:
                              prefix0.getTextStyle(18, prefix0.Theme.cDesTitle),
                        ),
                      )
                    ],
                  ),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 10, right: 10),
                          child: Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width / 2,
                            color: prefix0.Theme.cDesSplitLine,
                          ),
                        )
                      ]),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      userType == 0
                          ? Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: Container(
                                width: 90,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  color: prefix0.Theme.cDesBG,
                                  boxShadow: [
                                    BoxShadow(
                                      color: prefix0.Theme.shadowColor,
                                      spreadRadius: prefix0.Theme.spreadRadius,
                                      blurRadius: prefix0.Theme.blurRadius,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    )
                                  ],
                                ),
                                child: TextField(
                                  controller: scoreController,
                                  onChanged: (value) {},
                                  textAlign: TextAlign.center,
                                  style: prefix0.getTextStyle(
                                      17,
                                      dailyScoreErrorToggle
                                          ? prefix0.Theme.cDesValue
                                          : prefix0.Theme.cDesValue),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      fillColor: prefix0.Theme.cDesBG,
                                      border: InputBorder.none,
                                      hintText: "-----",
                                      hintStyle: prefix0.getTextStyle(
                                          16, prefix0.Theme.cDesValue)),
                                ),
                              ))
                          : Padding(
                              padding: EdgeInsets.only(bottom: 5),
                              child: AutoSizeText(
                                studentPresentMark == ""
                                    ? emptyPresentScore
                                    : studentPresentMark,
                                textDirection: TextDirection.rtl,
                                style: prefix0.getTextStyle(
                                    15, prefix0.Theme.cDesValue,
                                    fontWeight: FontWeight.w100),
                              ),
                            )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void updateConsultantTableForDescriptionDetail(int day) async {
    if (userType == 0) {
      setState(() {
        dailyConsultantScore = true;
      });
      String oldValue = consultantTableData.daysSchedule[day].dailyScore;
      consultantTableData.daysSchedule[day].dailyScore = scoreController.text;
      LSM.getConsultant().then((consultant) {
        consultantTableSRV
            .update_all_table(
                consultant.username,
                consultant.authentication_string,
                StudentMainPage.studentUsername,
                consultantTableData)
            .then((status) {
          setState(() {
            dailyConsultantScore = false;
          });
          if (status) {
            LSM.setConsultantAllTables(
                StudentMainPage.studentUsername, totalPlans);
            notifyConsultantTable(consultantTableData);
            setState(() {});
          } else {
            setState(() {
              consultantTableData.daysSchedule[day].dailyScore = oldValue;
            });
          }
        });
      });
    } else if (userType == 1) {
      String oldValue = consultantTableData.daysSchedule[day].dailyWakeUpTime;
      if (consultantTableData.daysSchedule[day].dailyWakeUpTime == "") {
        DateTimeService dateTime = DateTimeService();
        String currentTime =
            (await dateTime.getDateTime())['result']["time"] ?? "";
//        String currentTime = getCurrentTimeString();
        String hour = currentTime.split(":")[0];
        String minute = currentTime.split(":")[1];
        minute = currentTime.length == 1 ? "0" + minute : minute;
        consultantTableData.daysSchedule[day].dailyWakeUpTime =
            hour + ":" + minute;
      } else {
        consultantTableData.daysSchedule[day].dailyWakeUpTime = "";
      }
      LSM.getStudent().then((student) {
        consultantTableSRV
            .update_present_time(
                student.username,
                student.authentication_string,
                StudentMainPage.studentUsername,
                consultantTableData.name,
                day,
                consultantTableData.daysSchedule[day].dailyWakeUpTime)
            .then((status) {
          setState(() {
            wakeUpTimeLoading = false;
          });
          if (status['success']) {
            LSM.setConsultantAllTables(
                StudentMainPage.studentUsername, totalPlans);
            notifyConsultantTable(consultantTableData);
            setState(() {});
          } else {
            setState(() {
              consultantTableData.daysSchedule[day].dailyWakeUpTime = oldValue;
            });
          }
        });
      });
    }
  }

  void socketTableUpdater() async {
    Stream stream = ConnectionService.stream;
    stream.listen((message) {
      message = improveStringJsonFromSocket(message);
      SocketNotifyingData s =
          SocketNotifyingData.fromJson(json.decode(message));
      if (s.requestType == "submit_message") {
        //TODO
      } else if (s.requestType == "notify_consultant_table") {
        ConsultantTableModel consultantTable =
            (s.requestData as ConsultantTableSR).consultantTableModel;
        if (totalPlans.getPlanListName().contains(consultantTable.name)) {
          setState(() {
            totalPlans.updateSingleTable(consultantTable);
          });
          setStateTitleBar();
        } else {
          setState(() {
            totalPlans.updateSingleTable(consultantTable);
          });
          setLast();
        }
      }
    });
  }

  void setStateTitleBar() {
    setState(() {
      titleBar = LessonPageTitleParts(this, totalPlans.getPlanListName().last);
      StudentMainPageState.selectedPlanName = consultantTableData.name;
    });
  }

  void setLast() {
    setState(() {
      consultantTableData = totalPlans.allTables.last;
      titleBar = LessonPageTitleParts(this, totalPlans.getPlanListName().last);
      StudentMainPageState.selectedPlanName = consultantTableData.name;
    });
  }

  void notifyConsultantTable(ConsultantTableModel table) {
    SocketNotifyingData s = SocketNotifyingData();
    s.requestType = "notify_consultant_table";
    ConsultantTableSR csr = ConsultantTableSR();
    csr.consultantTableModel = table;
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
