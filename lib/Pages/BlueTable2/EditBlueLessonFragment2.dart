import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/BlueTable2SRV.dart';
import 'package:mhamrah/Models/BlueTable2MV.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'BlueTable2.dart';

class EditBlueLessonFragment2 extends StatefulWidget {
  final BlueTable2State blueTable2State;
  final B2LessonPerDay lesson;

  const EditBlueLessonFragment2(this.blueTable2State, this.lesson, {Key key})
      : super(key: key);

  @override
  EditBlueLessonFragState createState() {
    return EditBlueLessonFragState(blueTable2State, lesson);
  }
}

class EditBlueLessonFragState extends State<EditBlueLessonFragment2> {
  BlueTable2SRV blueTable2SRV = BlueTable2SRV();

  //size things
  static double xSize;

  BlueTable2State blueTable2State;
  B2LessonPerDay lesson;

  //data things
  static TextEditingController lessonNameController;
  static TextEditingController predictedTestController;
  static TextEditingController finalTestController;
  static TextEditingController predictedTimeController;
  static TextEditingController finalTimeController;

  bool emptyFieldError = false;
  bool lessonNameErrorToggle = false;
  bool testPredictedErrorToggle = false;
  bool testFinalErrorToggle = false;
  bool timePredictedErrorToggle = false;
  bool timeFinalErrorToggle = false;
  bool applyButtonLoading = false;

  EditBlueLessonFragState(this.blueTable2State, this.lesson) {
    lessonNameController = new TextEditingController();
    predictedTestController = new TextEditingController();
    predictedTimeController = new TextEditingController();
    finalTestController = TextEditingController();
    finalTimeController = TextEditingController();

    lessonNameController.text = lesson.lessonName;
    predictedTestController.text = lesson.predictedTestNumber;
    finalTestController.text = lesson.finalTestNumber;
    predictedTimeController.text = lesson.predictedDurationTime;
    finalTimeController.text = lesson.finalDurationTime;
  }

  double circleRadius = 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width * (80 / 100);
    return new Align(
        child: new GestureDetector(
      onTap: () {
        blueTable2State.closeEditLessonFrag();
      },
      child: new Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        color: prefix0.Theme.fragmentBlurBackGround,
        child: BackdropFilter(
          filter: prefix0.Theme.fragmentBGFilter,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
//              getSingleLessonCircle(lesson),
              new Container(
                width: xSize,
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(15)),
                    color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    blueTable2State.userType == 1
                        ? getLessonNameTextField(context)
                        : SizedBox(),
                    getTestNumber(),
                    getTime(),
                    blueTable2State.userType == 1
                        ? getApplyButton()
                        : SizedBox()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget getLessonNameTextField(context) {
    return new Padding(
      padding: EdgeInsets.only(top: 15, left: 5, right: 5, bottom: 8),
      child: new Container(
        height: 55,
        width: xSize,
        alignment: Alignment.center,
        child: new Directionality(
            textDirection: TextDirection.rtl,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(
                  "نام درس: ",
                  textDirection: TextDirection.rtl,
                  style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
                ),
                new Container(
                  alignment: Alignment.center,
                  width: xSize * (64 / 100),
                  child: TextField(
                    controller: lessonNameController,
                    style: prefix0.getTextStyle(18, prefix0.Theme.darkText),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(120, 255, 255, 255),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(
                            color: lessonNameErrorToggle
                                ? prefix0.Theme.titleBar1
                                : prefix0.Theme.brightBlack,
                            width: 1),
                        borderRadius: new BorderRadius.all(Radius.circular(25)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      hintText: 'نام درس',
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget getTestNumber() {
    return new Padding(
      padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: xSize * (24 / 100),
            height: 45,
            alignment: Alignment.center,
            child: blueTable2State.userType == 1
                ? TextField(
                    maxLines: 1,
                    controller: finalTestController,
                    style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(120, 255, 255, 255),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(
                            color: testFinalErrorToggle
                                ? prefix0.Theme.titleBar1
                                : prefix0.Theme.brightBlack,
                            width: 1),
                        borderRadius: new BorderRadius.all(Radius.circular(25)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      labelText: "نهایی",
                    ),
                  )
                : AutoSizeText(
                    "نهایی: " + finalTestController.text,
                    textDirection: TextDirection.rtl,
                    style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
                  ),
          ),
          Container(
            width: xSize * (28 / 100),
            height: 45,
            alignment: Alignment.center,
            child: blueTable2State.userType == 1
                ? TextField(
                    maxLines: 1,
                    controller: predictedTestController,
                    style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(120, 255, 255, 255),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(
                            color: testPredictedErrorToggle
                                ? prefix0.Theme.titleBar1
                                : prefix0.Theme.brightBlack,
                            width: 1),
                        borderRadius: new BorderRadius.all(Radius.circular(25)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      labelText: "پیشبینی",
                    ),
                  )
                : AutoSizeText(
                    "پیشبینی: " + predictedTestController.text,
                    textDirection: TextDirection.rtl,
                    style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
                  ),
          ),
          AutoSizeText(
            "تعداد تست:",
            textDirection: TextDirection.rtl,
            style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
          )
        ],
      ),
    );
  }

  B2LessonPerDay getFragmentData() {
    B2LessonPerDay l = B2LessonPerDay();
    l.lessonName = (lessonNameController.text);
    l.predictedTestNumber = predictedTestController.text;
    l.finalTestNumber = finalTestController.text;
    l.predictedDurationTime = predictedTimeController.text;
    l.finalDurationTime = finalTimeController.text;
    l.lessonColor = lesson.lessonColor;
    return l;
  }

  Widget getTime() {
    return new Padding(
      padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: xSize * (24 / 100),
            height: 45,
            alignment: Alignment.center,
            child:
                blueTable2State.userType == 1
                    ? TextField(
                        maxLines: 1,
                        controller: finalTimeController,
                        style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromARGB(120, 255, 255, 255),
                            enabledBorder: OutlineInputBorder(
                              borderSide: new BorderSide(
                                  color: timeFinalErrorToggle
                                      ? prefix0.Theme.titleBar1
                                      : prefix0.Theme.brightBlack,
                                  width: 1),
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(25)),
                            ),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            labelText: 'نهایی',
                            hintText: "--:--"),
                      )
                    : AutoSizeText(
                        "نهایی: " + finalTimeController.text,
                        textDirection: TextDirection.rtl,
                        style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
                      ),
          ),
          Container(
            width: xSize * (28 / 100),
            height: 45,
            alignment: Alignment.center,
            child: blueTable2State.userType == 1
                ? TextField(
                    maxLines: 1,
                    controller: predictedTimeController,
                    style: prefix0.getTextStyle(15, prefix0.Theme.darkText),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(120, 255, 255, 255),
                      enabledBorder: OutlineInputBorder(
                        borderSide: new BorderSide(
                            color: timePredictedErrorToggle
                                ? prefix0.Theme.titleBar1
                                : prefix0.Theme.brightBlack,
                            width: 1),
                        borderRadius: new BorderRadius.all(Radius.circular(25)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      labelText: 'پیشبینی',
                      hintText: "--:--",
                    ),
                  )
                : AutoSizeText(
                    "پیشبینی: " + predictedTimeController.text,
                    textDirection: TextDirection.rtl,
                    style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
                  ),
          ),
          AutoSizeText("زمان مطالعه:",
              textDirection: TextDirection.rtl,
              style: prefix0.getTextStyle(16, prefix0.Theme.darkText))
        ],
      ),
    );
  }

  Widget getApplyButton() {
    return new GestureDetector(
      child: new Padding(
        padding: EdgeInsets.all(0),
        child: new Container(
          width: double.infinity,
          height: 45,
          alignment: Alignment.center,
          decoration: new BoxDecoration(
              color: emptyFieldError
                  ? prefix0.Theme.titleBar1
                  : prefix0.Theme.applyButton,
              borderRadius: new BorderRadius.all(Radius.circular(15))),
          child: applyButtonLoading
              ? getLoadingProgress()
              : AutoSizeText(
                  applyLabel,
                  style: prefix0.getTextStyle(20, prefix0.Theme.onMainBGText),
                ),
        ),
      ),
      onTap: () {
        if (validateInput() && !applyButtonLoading) {
          updateLessonField();
        } else {
          setState(() {
            emptyFieldError = true;
          });
          Future.delayed(Duration(seconds: 1)).then((_) {
            setState(() {
              emptyFieldError = false;
            });
          });
        }
      },
    );
  }

  bool validateInput() {
    bool result = true;
    if (!checkEmptyAllowTime(predictedTimeController.text)) {
      result = false;
      setState(() {
        timePredictedErrorToggle = true;
      });
      Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          timePredictedErrorToggle = false;
        });
      });
    }
    if (!checkEmptyAllowTime(finalTimeController.text)) {
      result = false;
      setState(() {
        timeFinalErrorToggle = true;
      });
      Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          timeFinalErrorToggle = false;
        });
      });
    }
    if (!checkEmptyAllowTestNumber(predictedTestController.text)) {
      result = false;
      setState(() {
        testPredictedErrorToggle = true;
      });
      Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          testPredictedErrorToggle = false;
        });
      });
    }
    if (!checkEmptyAllowTestNumber(finalTestController.text)) {
      result = false;
      setState(() {
        testFinalErrorToggle = true;
      });
      Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          testFinalErrorToggle = false;
        });
      });
    }
    if (lessonNameController.text == null || lessonNameController.text == "") {
      result = false;
      setState(() {
        lessonNameErrorToggle = true;
      });
      Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          lessonNameErrorToggle = false;
        });
      });
    }
    return result;
  }

  Widget getLoadingProgress() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: CircularProgressIndicator(),
      width: 50,
      height: 35,
    );
  }

//  Widget getSingleLessonCircle(B2LessonPerDay b2lessonPerDay) {
//    Color circleColors = getLessonColor(b2lessonPerDay.lessonName);
//    return new Padding(
//      padding: EdgeInsets.only(right: 3, left: 3, bottom: 20),
//      child: CircularPercentIndicator(
//        radius: circleRadius,
//        percent: blueTable2State
//            .blueTable2Data.daysSchedule[blueTable2State.selectedDay]
//            .getDedicatedTimeForAllLessons(b2lessonPerDay),
//        backgroundColor: Color.fromARGB(100, 200, 200, 200),
//        progressColor: circleColors,
//        center: Container(
//          alignment: Alignment.center,
//          width: circleRadius - 20,
//          height: circleRadius - 20,
//          decoration: BoxDecoration(
//            shape: BoxShape.circle,
//            color: circleColors,
//          ),
//          child: AutoSizeText(
//            b2lessonPerDay.lessonName,
//            textAlign: TextAlign.center,
//            style: prefix0.getTextStyle(15, prefix0.Theme.blackText),
//          ),
//        ),
//      ),
//    );
//  }

  void updateLessonField() {
    setState(() {
      applyButtonLoading = true;
    });
    B2LessonPerDay b2lessonPerDay = getFragmentData();
    b2lessonPerDay.key = lesson.key;
    //TODO student
    LSM.getStudent().then((student) {
      blueTable2SRV
          .editLesson(StudentMainPage.studentUsername, "12345678",
              blueTable2State.blueTable2Data.name, b2lessonPerDay)
          .then((status) {
        /// update widget state
        blueTable2State.editLessonColor(b2lessonPerDay);

        /// notify with socket
        blueTable2State.notifyBlue2Table(blueTable2State.blueTable2Data);
        setState(() {
          applyButtonLoading = false;
        });
      });
    });
  }
}
