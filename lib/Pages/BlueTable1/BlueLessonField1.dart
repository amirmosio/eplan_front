import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BlueTable1.dart';

class BlueLessonField1 extends StatefulWidget {
  final B1LessonPlanPerDay l;
  final BlueTable1State b;

  BlueLessonField1(this.l, this.b);

  @override
  _LessonFieldRowState createState() => _LessonFieldRowState(l, b);
}

class _LessonFieldRowState extends State<BlueLessonField1> {
  B1LessonPlanPerDay l;
  final BlueTable1State b;
  int userType = 0;
  TextEditingController _totalTestNumberController;
  TextEditingController _wrongTestNumberController;
  TextEditingController _rightTestNumberController;
  TextEditingController _emptyTestNumberController;

  TextEditingController _durationTimeController;
  String durationText;

  bool textNumberErrorToggle = false;
  bool wrongTextNumberErrorToggle = false;
  bool rightTNumberErrorToggle = false;
  bool emptyTestNumberErrorToggle = false;

  bool timeErrorToggle = false;

  bool detainToggle = false;

  _LessonFieldRowState(this.l, this.b) {
    _totalTestNumberController = TextEditingController();
    _wrongTestNumberController = TextEditingController();
    _rightTestNumberController = TextEditingController();
    _emptyTestNumberController = TextEditingController();

    _durationTimeController = TextEditingController();

    _totalTestNumberController.text = l.testNumber ?? "";
    _wrongTestNumberController.text = l.wrongTestNumber ?? "";
    _rightTestNumberController.text = l.rightTestNumber ?? "";
    _emptyTestNumberController.text = l.emptyTestNumber ?? "";
    _durationTimeController.text = l.durationTime ?? "";
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    userType = LSM.getUserModeSync();
    _durationTimeController.addListener(triggerUpdate);
    _totalTestNumberController.addListener(triggerUpdate);
  }

  void triggerUpdate() {
    String testNumber = _totalTestNumberController.text;
    String time = _durationTimeController.text;
    B1LessonPlanPerDay newLesson = B1LessonPlanPerDay();
    newLesson.lessonName = l.lessonName;
    newLesson.testNumber = testNumber;
    newLesson.durationTime = time;
    newLesson.key = l.key;
    b.updateLesson(newLesson);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Opacity(
                child: getTestNumberWidget(l.testNumber),
                opacity: !list_motefareghe.contains(l.lessonName) ? 1 : 0,
              ),
              getTimeWidget(l.durationTime),
              Blue1LessonName(
                l.lessonName,
              ),
            ],
          ),
          onTap: () {
            setState(() {
              detainToggle = !detainToggle;
            });
          },
        ),
        detainToggle && !list_motefareghe.contains(l.lessonName)
            ? getDetail()
            : SizedBox(),
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

  Widget getTimeWidget(String time) {
    if (!checkEmptyAllowTime(_durationTimeController.text)) {
      timeErrorToggle = true;
    } else {
      timeErrorToggle = false;
    }
    return new Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: new Container(
        height: 35,
        width: MediaQuery.of(context).size.width * (20 / 100),
        decoration: new BoxDecoration(
          color: prefix0.Theme.startEndTimeItemsBG,
          borderRadius: new BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: (userType == 1 &&
                b.blueTable1Data.name != emptyInitialPlanName &&
                !b.parentAccount)
            ? TextField(
                textAlign: TextAlign.center,
                controller: _durationTimeController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  value = getTimeString(
                      value, durationText == null ? "" : durationText);
                  durationText = value;
                  _durationTimeController.value = TextEditingValue(
                    text: value,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: value.length),
                    ),
                  );
                  l.durationTime = _durationTimeController.text;
                  b.setSaveFlagToNeeded();
                  if (!checkEmptyAllowTime(value)) {
                    setState(() {
                      timeErrorToggle = true;
                    });
                  } else {
                    setState(() {
                      timeErrorToggle = false;
                    });
                  }
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "--:--",
                    hintStyle: prefix0.getTextStyle(
                        16, prefix0.Theme.onStartEndTimeItemBG)),
                style: prefix0.getTextStyle(
                    17,
                    timeErrorToggle
                        ? prefix0.Theme.onItemErrorTextBG
                        : prefix0.Theme.onStartEndTimeItemBG),
              )
            : AutoSizeText(_durationTimeController.text,
                style: prefix0.getTextStyle(
                    18, prefix0.Theme.onStartEndTimeItemBG)),
      ),
    );
  }

  String getTimeString(String value, String controller) {
    if (value.length < controller.length) {
      return value;
    }
    value = value.replaceAll(":", "").replaceAll("-", "").replaceAll(" ", "");
    if (value.length < 2) {
      return value;
    } else if (value.length == 2) {
      value = value + " : ";
    } else {
      value = value.substring(0, 2) +
          " : " +
          value.substring(2, min(4, value.length));
    }
    return value;
  }

  Widget getTestNumberWidget(String time) {
    String english =
        replacePersianWithEnglishNumber(_totalTestNumberController.text);
    try {
      if (_totalTestNumberController.text == "") {
        textNumberErrorToggle = false;
      } else {
        int.parse(english);
        textNumberErrorToggle = false;
      }
    } catch (Exception) {
      textNumberErrorToggle = true;
    }
    return new Padding(
      padding: EdgeInsets.only(right: 5, left: 5),
      child: new Container(
        height: 35,
        width: MediaQuery.of(context).size.width * (17 / 100),
        decoration: new BoxDecoration(
          color: prefix0.Theme.startEndTimeItemsBG,
          borderRadius: new BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: (userType == 1 &&
                !b.parentAccount &&
                !list_motefareghe.contains(l.lessonName) &&
                b.blueTable1Data.name != emptyInitialPlanName)
            ? TextField(
                controller: _totalTestNumberController,
                onChanged: (value) {
                  b.setSaveFlagToNeeded();

                  l.testNumber = _totalTestNumberController.text;

                  String english = replacePersianWithEnglishNumber(value);
                  try {
                    if (value == "") {
                      setState(() {
                        textNumberErrorToggle = false;
                      });
                    } else {
                      int.parse(english);
                      setState(() {
                        textNumberErrorToggle = false;
                      });
                    }
                  } catch (Exception) {
                    setState(() {
                      textNumberErrorToggle = true;
                    });
                  }
                },
                textAlign: TextAlign.center,
                style: prefix0.getTextStyle(
                    17,
                    textNumberErrorToggle
                        ? prefix0.Theme.onItemErrorTextBG
                        : prefix0.Theme.onStartEndTimeItemBG),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "---",
                    hintStyle: prefix0.getTextStyle(
                        16, prefix0.Theme.onStartEndTimeItemBG)),
              )
            : AutoSizeText(
                _totalTestNumberController.text,
                style: prefix0.getTextStyle(
                    18, prefix0.Theme.onStartEndTimeItemBG),
              ),
      ),
    );
  }

  void setTotalTest() {
    int wrong = getNumberFromIntegerString(_wrongTestNumberController.text);
    int right = getNumberFromIntegerString(_rightTestNumberController.text);
    int empty = getNumberFromIntegerString(_emptyTestNumberController.text);
    int total = wrong + right + empty;
    setState(() {
      l.testNumber = total.toString();
      _totalTestNumberController.text = total.toString();
    });
  }

  Widget getWrongTest() {
    String english =
        replacePersianWithEnglishNumber(_wrongTestNumberController.text);
    try {
      if (_wrongTestNumberController.text == "") {
        wrongTextNumberErrorToggle = false;
      } else {
        int.parse(english);
        wrongTextNumberErrorToggle = false;
      }
    } catch (Exception) {
      wrongTextNumberErrorToggle = true;
    }
    return new Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: new Container(
          height: 35,
          width: MediaQuery.of(context).size.width * (19 / 100),
          decoration: new BoxDecoration(
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
              (userType == 1 &&
                      !b.parentAccount &&
                      !list_motefareghe.contains(l.lessonName) &&
                      b.blueTable1Data.name != emptyInitialPlanName)
                  ? Container(
                      width:
                          MediaQuery.of(context).size.width * (19 / 100) - 40,
                      child: TextField(
                        controller: _wrongTestNumberController,
                        onChanged: (value) {
                          b.setSaveFlagToNeeded();
                          l.wrongTestNumber = _wrongTestNumberController.text;
                          setTotalTest();

                          String english =
                              replacePersianWithEnglishNumber(value);
                          try {
                            if (value == "") {
                              setState(() {
                                wrongTextNumberErrorToggle = false;
                              });
                            } else {
                              int.parse(english);
                              setState(() {
                                wrongTextNumberErrorToggle = false;
                              });
                            }
                          } catch (Exception) {
                            setState(() {
                              wrongTextNumberErrorToggle = true;
                            });
                          }
                        },
                        textAlign: TextAlign.center,
                        style: prefix0.getTextStyle(
                            17,
                            wrongTextNumberErrorToggle
                                ? prefix0.Theme.onItemErrorTextBG
                                : prefix0.Theme.onStartEndTimeItemBG),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "---",
                            hintStyle: prefix0.getTextStyle(
                                16, prefix0.Theme.onStartEndTimeItemBG)),
                      ),
                    )
                  : AutoSizeText(
                      _wrongTestNumberController.text,
                      style: prefix0.getTextStyle(
                          18, prefix0.Theme.onStartEndTimeItemBG),
                    ),
            ],
          )),
    );
  }

  Widget getRightTest() {
    String english =
        replacePersianWithEnglishNumber(_rightTestNumberController.text);
    try {
      if (_rightTestNumberController.text == "") {
        rightTNumberErrorToggle = false;
      } else {
        int.parse(english);
        rightTNumberErrorToggle = false;
      }
    } catch (Exception) {
      rightTNumberErrorToggle = true;
    }
    return new Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: new Container(
          height: 35,
          width: MediaQuery.of(context).size.width * (19 / 100),
          decoration: new BoxDecoration(
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
              (userType == 1 &&
                      !b.parentAccount &&
                      !list_motefareghe.contains(l.lessonName) &&
                      b.blueTable1Data.name != emptyInitialPlanName)
                  ? Container(
                      width:
                          MediaQuery.of(context).size.width * (19 / 100) - 40,
                      child: TextField(
                        controller: _rightTestNumberController,
                        onChanged: (value) {
                          b.setSaveFlagToNeeded();
                          l.rightTestNumber = _rightTestNumberController.text;
                          setTotalTest();
                          String english =
                              replacePersianWithEnglishNumber(value);
                          try {
                            if (value == "") {
                              setState(() {
                                rightTNumberErrorToggle = false;
                              });
                            } else {
                              int.parse(english);
                              setState(() {
                                rightTNumberErrorToggle = false;
                              });
                            }
                          } catch (Exception) {
                            setState(() {
                              rightTNumberErrorToggle = true;
                            });
                          }
                        },
                        textAlign: TextAlign.center,
                        style: prefix0.getTextStyle(
                            17,
                            rightTNumberErrorToggle
                                ? prefix0.Theme.onItemErrorTextBG
                                : prefix0.Theme.onStartEndTimeItemBG),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "---",
                            hintStyle: prefix0.getTextStyle(
                                16, prefix0.Theme.onStartEndTimeItemBG)),
                      ),
                    )
                  : AutoSizeText(
                      _rightTestNumberController.text,
                      style: prefix0.getTextStyle(
                          18, prefix0.Theme.onStartEndTimeItemBG),
                    ),
            ],
          )),
    );
  }

  Widget getEmptyTest() {
    String english =
        replacePersianWithEnglishNumber(_emptyTestNumberController.text);
    try {
      if (_emptyTestNumberController.text == "") {
        emptyTestNumberErrorToggle = false;
      } else {
        int.parse(english);
        emptyTestNumberErrorToggle = false;
      }
    } catch (Exception) {
      emptyTestNumberErrorToggle = true;
    }

    return new Padding(
      padding: EdgeInsets.only(right: 0, left: 0),
      child: new Container(
          height: 35,
          width: MediaQuery.of(context).size.width * (19 / 100),
          decoration: new BoxDecoration(
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
              (userType == 1 &&
                      !list_motefareghe.contains(l.lessonName) &&
                      b.blueTable1Data.name != emptyInitialPlanName)
                  ? Container(
                      width:
                          MediaQuery.of(context).size.width * (19 / 100) - 40,
                      child: TextField(
                        controller: _emptyTestNumberController,
                        onChanged: (value) {
                          b.setSaveFlagToNeeded();
                          l.emptyTestNumber = _emptyTestNumberController.text;
                          setTotalTest();
                          String english =
                              replacePersianWithEnglishNumber(value);
                          try {
                            if (value == "") {
                              setState(() {
                                emptyTestNumberErrorToggle = false;
                              });
                            } else {
                              int.parse(english);
                              setState(() {
                                emptyTestNumberErrorToggle = false;
                              });
                            }
                          } catch (Exception) {
                            setState(() {
                              emptyTestNumberErrorToggle = true;
                            });
                          }
                        },
                        textAlign: TextAlign.center,
                        style: prefix0.getTextStyle(
                            17,
                            emptyTestNumberErrorToggle
                                ? prefix0.Theme.onItemErrorTextBG
                                : prefix0.Theme.onStartEndTimeItemBG),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "---",
                            hintStyle: prefix0.getTextStyle(
                                16, prefix0.Theme.onStartEndTimeItemBG)),
                      ),
                    )
                  : AutoSizeText(
                      _emptyTestNumberController.text,
                      style: prefix0.getTextStyle(
                          18, prefix0.Theme.onStartEndTimeItemBG),
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
                style: prefix0.getTextStyle(
                    16, prefix0.Theme.onStartEndTimeItemBG),
              ),
            ],
          )),
    );
  }

  int getTotalScorePercent() {
    int wrong = getNumberFromIntegerString(_wrongTestNumberController.text);
    int right = getNumberFromIntegerString(_rightTestNumberController.text);
    int empty = getNumberFromIntegerString(_emptyTestNumberController.text);
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
}

class Blue1LessonName extends StatefulWidget {
  final String lessonName;

  Blue1LessonName(this.lessonName);

  @override
  _Blue1LessonNameState createState() => _Blue1LessonNameState(lessonName);
}

class _Blue1LessonNameState extends State<Blue1LessonName> {
  String lessonName;

  _Blue1LessonNameState(
    this.lessonName,
  );

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.all(5),
      child: new Container(
        width: MediaQuery.of(context).size.width * (49 / 100),
        height: 50,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
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
