import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/Pages/BlueTable1/BlueTable1.dart';
import 'package:mhamrah/Pages/BlueTable2/BlueTable2.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Pages/ConsultantTable/DayDetail.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../BlueTable1/TitlePartDayDetail1.dart';
import '../StudentMainPage.dart';

class EmptyTitlePart extends StatefulWidget {
  final String year;
  final List<String> daysDate;
  final ConsultantTableState c;
  final BlueTable1State b1;
  final BlueTable2State b2;

  EmptyTitlePart(this.year, this.daysDate, this.c, this.b1, this.b2);

  @override
  _EmptyTitlePartState1 createState() =>
      _EmptyTitlePartState1(year, daysDate, c, b1, b2);
}

class _EmptyTitlePartState1 extends State<EmptyTitlePart> {
  String year;
  List<String> daysDate;
  String _selectedValueForDropDown;
  ConsultantTableState c;
  BlueTable1State b1;
  BlueTable2State b2;
  int userType = 1;

  List<Widget> days;
  List<Widget> dayMarks = [];

  _EmptyTitlePartState1(this.year, this.daysDate, this.c, this.b1, this.b2);

  double xSize;
  double ySize;

  List<String> planNames;

  @override
  void initState() {
    LSM.getUserMode().then((userType) {
      setState(() {
        this.userType = userType;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    days = getDays();

    if (c == null) {
      planNames = BlueTable1State.totalBlue1Tables.getPlanListName();
      _selectedValueForDropDown = planNames.last;
    } else if (c != null) {
      planNames = c.totalPlans.getPlanListName();
      _selectedValueForDropDown = planNames.last;
    }
    return new Container(
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
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(
                top: FirstPage.androidTitleBarHeight,
                bottom: 10,
                right: xSize * (4 / 100)),
            child: new Container(
              width: xSize * (96 / 100),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Container(
                    width: MediaQuery.of(context).size.width * (33 / 100),
                    alignment: Alignment.centerLeft,
                    child: new Padding(
                      padding: EdgeInsets.only(top: 10, left: 10),
                      child: AutoSizeText(
                        "",
                        style: prefix0.getTextStyle(
                            22, prefix0.Theme.onTitleBarText),
                      ),
                    ),
                  ),
                  getDropDownButton()
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
    return new Container(
      width: MediaQuery.of(context).size.width * (63 / 100) - 15,
      height: 40,
      alignment: Alignment.center,
      decoration: new BoxDecoration(
          color: prefix0.Theme.dayDetailBG,
          borderRadius: new BorderRadius.all(Radius.circular(20))),
      child: new Theme(
        data: Theme.of(context).copyWith(
          canvasColor: prefix0.Theme.titleBar1,
        ),
        child: new DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              value: _selectedValueForDropDown,
              elevation: 2,
              onChanged: (newValue) {
                setState(() {
                  if (newValue == "+++") {
                    if (userType == 1) {
                      LSM.getStudent().then((student) {
                        if (student.checkValidDataForConsultantRequest()) {
                          c.showEditCreateNewPlanFrag(true);
                        } else {
                          showFlutterToastWithFlushBar(completeInfoForCreatingTable);
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
                      ((userType == 0 ||
                              (c != null &&
                                  userType == 1 &&
                                  c.studentAccess &&
                                  true))
                          ? ["+++"]
                          : []))
                  .map((String value) {
                return new DropdownMenuItem<String>(
                    value: value,
                    key: ValueKey(value),
                    child: value == "+++"
                        ? Container(
                            height: 35,
                            child: Icon(Icons.add_circle),
                            alignment: Alignment.center,
                          )
                        : new Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
//                                    width: xSize * (33 / 100),
                                    height: 35,
                                    alignment: Alignment.center,
                                    child: AutoSizeText(
                                      "  " + value,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      style: prefix0.getTextStyle(
                                          21, prefix0.Theme.onTitleBarText),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ));
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getDays() {
    List<Widget> result = [];
    for (int index = 0; index < daysType2.length; index++) {
      Widget day = DayDetail(c, b1, b2, index);
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

  void selectDay(int dayIndex) {
    if (c != null) {
      c.selectDayPlans(days.length - dayIndex - 1);
    } else if (b1 != null) {
      b1.selectDayPlans(days.length - dayIndex - 1);
    } else if (b2 != null) {
      b2.selectDayPlans(days.length - dayIndex - 1);
    }
    setState(() {
      this.dayMarks = dayMarks;
    });
  }
}
