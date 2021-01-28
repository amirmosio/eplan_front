import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BlueTable1.dart';

class DailySumLessonField extends StatefulWidget {
  final BlueTable1State b;

  DailySumLessonField(this.b);

  @override
  DailySumLessonFieldState createState() => DailySumLessonFieldState(b);
}

class DailySumLessonFieldState extends State<DailySumLessonField> {
  B1LessonPlanPerDay l;
  final BlueTable1State b;

  bool detailToggle = false;

  DailySumLessonFieldState(this.b);

  @override
  Widget build(BuildContext context) {
    l = B1LessonPlanPerDay();
    l.lessonName = "مجموع روزانه";
    l.durationTime = convertMinuteToTimeString(
        b.blueTable1Data.daysSchedule[b.selectedDay].getTotalDayTimeMinute());
    List<int> test =
        b.blueTable1Data.daysSchedule[b.selectedDay].getTotalDayTest();
    l.testNumber = test[0].toString();
    l.wrongTestNumber = test[1].toString();
    l.rightTestNumber = test[2].toString();
    l.emptyTestNumber = test[3].toString();
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 0),
          child: Container(
            height: 0.5,
            color: prefix0.Theme.greyTimeLine,
          ),
        ),
        GestureDetector(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              !list_motefareghe.contains(l.lessonName)
                  ? getTestNumberWidget(l.testNumber, context)
                  : SizedBox(),
              getTimeWidget(l.durationTime, context),
              DailySumLesson(
                l.lessonName,
              ),
            ],
          ),
          onTap: () {
            setState(() {
              detailToggle = !detailToggle;
            });
          },
        ),
        detailToggle ? getDetail() : SizedBox(),
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 0),
          child: Container(
            color: prefix0.Theme.greyTimeLine,
            height: 0.5,
          ),
        ),
      ],
    );
  }

  Widget getDetail() {
    return Padding(
      padding: EdgeInsets.only(right: 0, left: 0, top: 5, bottom: 5),
      child: Container(
        width: MediaQuery.of(context).size.width * (85 / 100) + 25,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getWrongTest(),
            getRightTest(),
            getEmptyTest(),
            Padding(
              padding: EdgeInsets.only(right: 0, left: 0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: prefix0.Theme.onMainBGText,
              ),
            ),
            getTotalScore()
          ],
        ),
      ),
    );
  }

  Widget getWrongTest() {
    String english = replacePersianWithEnglishNumber(l.wrongTestNumber);
    return new Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: new Container(
          height: 35,
          width: MediaQuery.of(context).size.width * (19 / 100),
          decoration: new BoxDecoration(
//            boxShadow: [
//              BoxShadow(
//                color: prefix0.Theme.shadowColor,
//                spreadRadius: prefix0.Theme.spreadRadius,
//                blurRadius: prefix0.Theme.blurRadius,
//                offset: Offset(0, 3), // changes position of shadow
//              ),
//            ],
            color: prefix0.Theme.startEndTimeItemsBG,
            borderRadius: new BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Icon(
                Icons.clear,
                color: Colors.red,
                size: 20,
              ),
              AutoSizeText(
                english,
                style: prefix0.getTextStyle(18, prefix0.Theme.onStartEndTimeItemBG),
              ),
            ],
          )),
    );
  }

  Widget getRightTest() {
    String english = replacePersianWithEnglishNumber(l.rightTestNumber);
    return new Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: new Container(
          height: 35,
          width: MediaQuery.of(context).size.width * (19 / 100),
          decoration: new BoxDecoration(
//            boxShadow: [
//              BoxShadow(
//                color: prefix0.Theme.shadowColor,
//                spreadRadius: prefix0.Theme.spreadRadius,
//                blurRadius: prefix0.Theme.blurRadius,
//                offset: Offset(0, 3), // changes position of shadow
//              ),
//            ],
            color: prefix0.Theme.startEndTimeItemsBG,
            borderRadius: new BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Icon(
                Icons.done,
                color: Colors.green,
                size: 20,
              ),
              AutoSizeText(
                english,
                style: prefix0.getTextStyle(18, prefix0.Theme.onStartEndTimeItemBG),
              ),
            ],
          )),
    );
  }

  Widget getEmptyTest() {
    String english = replacePersianWithEnglishNumber(l.emptyTestNumber);

    return new Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: new Container(
          height: 35,
          width: MediaQuery.of(context).size.width * (19 / 100),
          decoration: new BoxDecoration(
//            boxShadow: [
//              BoxShadow(
//                color: prefix0.Theme.shadowColor,
//                spreadRadius: prefix0.Theme.spreadRadius,
//                blurRadius: prefix0.Theme.blurRadius,
//                offset: Offset(0, 3), // changes position of shadow
//              ),
//            ],
            color: prefix0.Theme.startEndTimeItemsBG,
            borderRadius: new BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            children: [
              Icon(
                Icons.crop_square,
                color: Colors.yellow,
                size: 20,
              ),
              AutoSizeText(
                english,
                style: prefix0.getTextStyle(18, prefix0.Theme.onStartEndTimeItemBG),
              ),
            ],
          )),
    );
  }

  Widget getTotalScore() {
    return new Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: new Container(
          height: 35,
          width: MediaQuery.of(context).size.width * (17 / 100),
          decoration: new BoxDecoration(
//            boxShadow: [
//              BoxShadow(
//                color: prefix0.Theme.shadowColor,
//                spreadRadius: prefix0.Theme.spreadRadius,
//                blurRadius: prefix0.Theme.blurRadius,
//                offset: Offset(0, 3), // changes position of shadow
//              ),
//            ],
            color: prefix0.Theme.startEndTimeItemsBG,
            borderRadius: new BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                getTotalScorePercent().toString() + " %",
                style: prefix0.getTextStyle(16, prefix0.Theme.onStartEndTimeItemBG),
              ),
            ],
          )),
    );
  }

  int getTotalScorePercent() {
    int wrong = getNumberFromIntegerString(l.wrongTestNumber);
    int right = getNumberFromIntegerString(l.rightTestNumber);
    int empty = getNumberFromIntegerString(l.emptyTestNumber);
    int total = wrong + right + empty;
    if (total == 0) {
      return 0;
    } else {
      return (((right - (wrong / 3)) / total) * 100).round();
    }
  }

  int getNumberFromIntegerString(String text) {
    text = replacePersianWithEnglishNumber(text);
    text = text.trim();
    if (text == "") {
      return 0;
    } else {
      try {
        int a = int.parse(text);
        return a;
      } catch (e) {
        return 0;
      }
    }
  }

  Widget getTimeWidget(String time, BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: new Container(
        height: 35,
        width: MediaQuery.of(context).size.width * (20 / 100),
        decoration: new BoxDecoration(
//          boxShadow: [
//            BoxShadow(
//              color: prefix0.Theme.shadowColor,
//              spreadRadius: prefix0.Theme.spreadRadius,
//              blurRadius: prefix0.Theme.blurRadius,
//              offset: Offset(0, 3), // changes position of shadow
//            ),
//          ],
          color: prefix0.Theme.startEndTimeItemsBG,
          borderRadius: new BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: AutoSizeText(l.durationTime,
            style: prefix0.getTextStyle(18, prefix0.Theme.onStartEndTimeItemBG)),
      ),
    );
  }

  Widget getTestNumberWidget(String time, BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: new Container(
        height: 35,
        width: MediaQuery.of(context).size.width * (17 / 100),
        decoration: new BoxDecoration(
//          boxShadow: [
//            BoxShadow(
//              color: prefix0.Theme.shadowColor,
//              spreadRadius: prefix0.Theme.spreadRadius,
//              blurRadius: prefix0.Theme.blurRadius,
//              offset: Offset(0, 3), // changes position of shadow
//            ),
//          ],
          color: prefix0.Theme.startEndTimeItemsBG,
          borderRadius: new BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: AutoSizeText(
          l.testNumber,
          style: prefix0.getTextStyle(18, prefix0.Theme.onStartEndTimeItemBG),
        ),
      ),
    );
  }
}

class DailySumLesson extends StatelessWidget {
  final String lessonName;

  DailySumLesson(this.lessonName);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.all(5),
      child: new Container(
        width: MediaQuery.of(context).size.width * (49 / 100),
        height: 50,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
//          boxShadow: [
//            BoxShadow(
//              color: prefix0.Theme.shadowColor,
//              spreadRadius: prefix0.Theme.spreadRadius,
//              blurRadius: prefix0.Theme.blurRadius,
//              offset: Offset(0, 3), // changes position of shadow
//            ),
//          ],
          color: prefix0.Theme.lessonNameBG,
          borderRadius: new BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: AutoSizeText(
          lessonName,
          style: prefix0.getTextStyle(20, prefix0.Theme.onLessonNameBGText),
        ),
      ),
    );
  }
}
