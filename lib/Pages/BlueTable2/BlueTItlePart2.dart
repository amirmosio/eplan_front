import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/Pages/BlueTable1/BlueTable1.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BlueTable2.dart';
import 'TitlePartDayDetail2.dart';

class BlueTitlePart2 extends StatefulWidget {
  final String year;
  final BlueTable2State b1;

  BlueTitlePart2(this.year, this.b1);

  @override
  _BlueTitlePartState2 createState() => _BlueTitlePartState2(year, b1);
}

class _BlueTitlePartState2 extends State<BlueTitlePart2> {
  String year;
  List<String> daysDate;
  String _selectedValueForDropDown;
  BlueTable2State b2;

  List<Widget> days;
  List<Widget> dayMarks = [];

  double xSize;
  double ySize;

  _BlueTitlePartState2(this.year, this.b2);

  @override
  Widget build(BuildContext context) {
    daysDate = b2.blueTable2Data.getDaysDate();
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    days = getDays();
//    if (dayMarks == null) {
//      dayMarks = getDayMarks();
//    }
    if (_selectedValueForDropDown == null) {
      _selectedValueForDropDown =
          BlueTable2State.totalBlueTables2.getPlanListName().last;
      print(_selectedValueForDropDown);
    }
    return new Container(
      width: MediaQuery.of(context).size.width,
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
                      padding: EdgeInsets.only(top: 5, left: 10),
                      child: AutoSizeText(
                        b2.blueTable2Data.startDate == null
                            ? ""
                            : b2.blueTable2Data.startDate,
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
    List<String> planNames = BlueTable2State.totalBlueTables2.getPlanListName();
    String selectedPlanInStudentMainPage =
        StudentMainPageState.selectedPlanName;
    return new Container(
      width: MediaQuery.of(context).size.width * (63 / 100) - 15,
      height: StudentMainPageState.appbarDropDownHeight,
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
              value: planNames.contains(selectedPlanInStudentMainPage)
                  ? selectedPlanInStudentMainPage
                  : _selectedValueForDropDown,
              elevation: 2,
              onChanged: (newValue) {
                setState(() {
                  if (newValue == "+++") {
//                                    c.showCreateNewPlanFrag();
                  } else {
                    b2.changeWeekPlan(newValue);
                    _selectedValueForDropDown = newValue;
                    StudentMainPageState.selectedPlanName = newValue;
                  }
                });
              },
              isExpanded: false,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: prefix0.Theme.onTitleBarText,
              ),
              items: (planNames).map((String value) {
                return new DropdownMenuItem<String>(
                    value: value,
                    key: ValueKey(value),
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
//                              width: xSize * (33 / 100),
                              height: 35,
                              alignment: Alignment.center,
                              child: new AutoSizeText(
                                " " + value + " ",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: prefix0.getTextStyle(
                                    21, prefix0.Theme.onTitleBarText),
                              ),
                            ),
                          ],
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

  List<Widget> getDays() {
    List<Widget> result = [];
    for (int index = 0; index < daysType2.length; index++) {
      Widget day =
          Blue2DayDetail(index, daysDate[daysType2.length - index - 1], b2);
      GestureDetector w = new GestureDetector(
        key: ValueKey((StudentMainPage.studentUsername ?? "") +
            "-" +
            b2.blueTable2Data.name +
            "-" +
            index.toString()),
        child: day,
        onTap: () {
          selectDay(index);
        },
      );
      result.add(w);
    }
    return result;
  }

  List<Widget> getDayMarks() {
    List<Widget> result = [];
    for (int index = 0; index < daysType2.length; index++) {
      Widget day;
      if (index == daysType2.length - 1) {
        day = getDayMark(Colors.black);
      } else {
        day = getDayMark(Colors.transparent);
      }
      result.add(day);
    }
    return result;
  }

  Widget getDayMark(color) {
    return new Padding(
      padding: EdgeInsets.all(5),
      child: new Container(
        height: 2,
        width: xSize / 9,
        color: color,
      ),
    );
  }

  void selectDay(int dayIndex) {
    b2.selectDayPlans(days.length - dayIndex - 1);
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
}
