import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantTableSRV.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/style.dart' as prefix1;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart' as c;

class CreateNewPlanFrag extends StatefulWidget {
  final ConsultantTableState consultantTableState;
  final bool createMode;

  const CreateNewPlanFrag(this.createMode, this.consultantTableState, {Key key})
      : super(key: key);

  @override
  _CreateNewPlanFragState createState() {
    return _CreateNewPlanFragState(consultantTableState, createMode);
  }
}

class _CreateNewPlanFragState extends State<CreateNewPlanFrag> {
  ConsultantTableSRV consultantTableSRV = ConsultantTableSRV();
  bool createMode;
  int userType = 1;

  //size things
  static double xSize;
  static double ySize;

  ConsultantTableState consultantTableState;

  //data things
  static TextEditingController _yearController;
  static TextEditingController _monthController;
  static TextEditingController _dayController;

  bool errorToggle = false;
  bool loadingToggle = false;

  _CreateNewPlanFragState(this.consultantTableState, this.createMode) {
    _yearController = new TextEditingController();
    _monthController = new TextEditingController();
    _dayController = new TextEditingController();
    if (!createMode) {
      _yearController.text =
          consultantTableState.consultantTableData.startDate.split('/')[0];
      _monthController.text =
          consultantTableState.consultantTableData.startDate.split('/')[1];
      _dayController.text =
          consultantTableState.consultantTableData.startDate.split('/')[2];
    }
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
    xSize = MediaQuery.of(context).size.width * (70 / 100);
    ySize = MediaQuery.of(context).size.width * (95 / 100);
    return new Align(
        child: GestureDetector(
      onTap: () {
        consultantTableState.closeCreateNewPlanFrag();
      },
      child: new Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        color: prefix1.Theme.fragmentBlurBackGround,
        child: new BackdropFilter(
          filter: prefix1.Theme.fragmentBGFilter,
          child: new Container(
            width: xSize,
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(Radius.circular(15)),
                color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                getPlanNewName(),
                getStartDateForNewPlanTextFeild(context),
                getApplyButton()
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget getPlanNewName() {
    String newName = "";
    if (createMode) {
      newName = consultantTableState.totalPlans.getNewWeekPlanName();
    } else {
      newName = consultantTableState.consultantTableData.name;
    }
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: AutoSizeText(newName,
            style: getTextStyle(20, prefix1.Theme.darkText)),
      ),
    );
  }

  Widget getStartDateForNewPlanTextFeild(context) {
    return new Container(
      width: xSize,
      height: 80,
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: new Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: xSize / 4,
                  child: TextField(
                    maxLines: 1,
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    style: prefix1.getTextStyle(16, prefix1.Theme.darkText),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(120, 255, 255, 255),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        labelText: 'روز',
                        hintText: '۲۵'),
                  ),
                ),
                Container(
                  width: xSize / 4,
                  child: TextField(
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    controller: _monthController,
                    style: prefix1.getTextStyle(16, prefix1.Theme.darkText),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(120, 255, 255, 255),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        labelText: 'ماه',
                        hintText: '۱۲'),
                  ),
                ),
                Container(
                  width: xSize / 4,
                  child: TextField(
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    controller: _yearController,
                    style: prefix1.getTextStyle(16, prefix1.Theme.darkText),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(120, 255, 255, 255),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        labelText: 'سال',
                        hintText: '۱۳۹۹'),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget getApplyButton() {
    return new GestureDetector(
      child: new Container(
        width: xSize,
        height: 45,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            color: errorToggle
                ? prefix1.Theme.titleBar1
                : prefix1.Theme.applyButton,
            borderRadius: new BorderRadius.all(Radius.circular(15))),
        child: loadingToggle
            ? getLoadingProgress()
            : AutoSizeText(
                "تایید",
                style: getTextStyle(18, prefix1.Theme.onMainBGText),
              ),
      ),
      onTap: () {
        if (loadingToggle) {
          return;
        }
        if (verifyInputData()) {
          if (createMode) {
            uploadNewTable();
          } else {
            editNewTableStartDate();
          }
        } else {
          setState(() {
            errorToggle = true;
          });
          Future.delayed(Duration(milliseconds: 300)).then((_) {
            setState(() {
              errorToggle = false;
            });
          });
        }
      },
    );
  }

  Widget getLoadingProgress() {
    return Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.only(right: 10, left: 10),
    );
  }

  void uploadNewTable() {
    setState(() {
      loadingToggle = true;
    });
    String validDate = get_valid_date();
    String newTableName = consultantTableState.totalPlans.getNewWeekPlanName();
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        consultantTableSRV
            .addNewTable(consultant.username, consultant.authentication_string,
                StudentMainPage.studentUsername, newTableName, validDate)
            .then((status) {
          if (status) {
            consultantTableState.createNewWeakPlan(validDate);

            setState(() {
              loadingToggle = false;
            });
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        consultantTableSRV
            .addNewTable(student.username, student.authentication_string,
                StudentMainPage.studentUsername, newTableName, validDate)
            .then((status) {
          if (status) {
            consultantTableState.createNewWeakPlan(validDate);

            setState(() {
              loadingToggle = false;
            });
          }
        });
      });
    }
  }

  void editNewTableStartDate() {
    setState(() {
      loadingToggle = true;
    });
    String validDate = get_valid_date();
    String newTableName = consultantTableState.consultantTableData.name;
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        consultantTableSRV
            .editTableStartDate(
                consultant.username,
                consultant.authentication_string,
                StudentMainPage.studentUsername,
                newTableName,
                validDate)
            .then((status) {
          if (status) {
            consultantTableState.editTableStartDate(validDate);

            setState(() {
              loadingToggle = false;
            });
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        consultantTableSRV
            .editTableStartDate(student.username, student.authentication_string,
                StudentMainPage.studentUsername, newTableName, validDate)
            .then((status) {
          if (status) {
            consultantTableState.editTableStartDate(validDate);

            setState(() {
              loadingToggle = false;
            });
          }
        });
      });
    }
  }

  String get_valid_date() {
    String years = replacePersianWithEnglishNumber(_yearController.text);
    String months = replacePersianWithEnglishNumber(_monthController.text);
    String days = replacePersianWithEnglishNumber(_dayController.text);
    String date = years + "/" + months + "/" + days;
    return date;
  }

  bool verifyInputData() {
    try {
      String years = replacePersianWithEnglishNumber(_yearController.text);
      String months = replacePersianWithEnglishNumber(_monthController.text);
      String days = replacePersianWithEnglishNumber(_dayController.text);

      int year = int.parse(years);
      int month = int.parse(months);
      int day = int.parse(days);
      if (year < 1398 || year > 1499) {
        return false;
      } else if (month > 12 || month < 1) {
        return false;
      } else {
        if (month <= 6) {
          if (day > 31 || day < 1) {
            return false;
          }
        } else {
          if (day > 30 || day < 1) {
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
