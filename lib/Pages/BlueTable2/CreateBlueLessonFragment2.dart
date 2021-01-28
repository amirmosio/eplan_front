import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/BlueTable2SRV.dart';
import 'package:mhamrah/Models/BlueTable2MV.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Pages/BlueTable1/BlueTable1.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Pages/ConsultantTable/LessonField.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../StudentMainPage.dart';
import 'BlueTable2.dart';

class CreateBlueLessonFragment2 extends StatefulWidget {
  final BlueTable2State blueTable2State;

  const CreateBlueLessonFragment2(this.blueTable2State, {Key key})
      : super(key: key);

  @override
  CreateBlueLessonFragState createState() {
    return CreateBlueLessonFragState(blueTable2State);
  }
}

class CreateBlueLessonFragState extends State<CreateBlueLessonFragment2> {
  BlueTable2SRV blueTable2SRV = BlueTable2SRV();

  //size things
  static double xSize;

  BlueTable2State blueTable2State;

  //data things
  static TextEditingController lessonNameController;
  List<int> selectedColor;
  static TextEditingController predictedTestController;
  static TextEditingController predictedTimeController;

  bool emptyFieldError = false;
  bool lessonNameErrorToggle = false;
  bool colorPickerErrorToggle = false;
  bool testErrorToggle = false;
  bool timeErrorToggle = false;
  bool applyButtonLoading = false;

  CreateBlueLessonFragState(this.blueTable2State) {
    lessonNameController = new TextEditingController();
    predictedTestController = new TextEditingController();
    predictedTimeController = new TextEditingController();
  }

  B2LessonPerDay getFragmentData() {
    B2LessonPerDay l = B2LessonPerDay();
    l.lessonName = (lessonNameController.text);
    l.lessonColor = selectedColor;
    l.predictedTestNumber = predictedTestController.text;
    l.predictedDurationTime = predictedTimeController.text;
    return l;
  }

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width * (80 / 100);
    return new Align(
        child: new GestureDetector(
      child: new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          color: prefix0.Theme.fragmentBlurBackGround,
          child: new BackdropFilter(
            filter: prefix0.Theme.fragmentBGFilter,
            child: new Container(
              width: xSize,
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(Radius.circular(15)),
                  color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  getLessonNameTextField(context),
                  getColorPicker(context),
                  getPredictedTestNumber(),
                  getPredictedTime(),
                  getApplyButton()
                ],
              ),
            ),
          )),
      onTap: () {
        setState(() {
          blueTable2State.closeCreateLessonFrag();
        });
      },
    ));
  }

  Widget getLessonNameTextField(context) {
    return new Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 5),
      child: new Container(
        height: 50,
        child: new Directionality(
          textDirection: TextDirection.rtl,
          child: new Container(
            child: TextField(
              maxLines: 1,
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
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  labelText: 'نام درس',
                  hintStyle: prefix0.getTextStyle(
                      20,
                      !lessonNameErrorToggle
                          ? prefix0.Theme.titleBar1
                          : prefix0.Theme.mildGrey)),
            ),
          ),
        ),
      ),
    );
  }

  Widget getColorPicker(context) {
    return new Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 5),
      child: new Container(
        height: 50,
        decoration: BoxDecoration(
            borderRadius: new BorderRadius.all(Radius.circular(20)),
//          border:
//              BoxBorder.lerp(Border.all(width: 0.5), Border.all(width: 0.5), 1),
            border: Border.all(
                color: colorPickerErrorToggle
                    ? prefix0.Theme.titleBar1
                    : prefix0.Theme.mildGrey)),
        child: new Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getColorIcons(),
              ),
              scrollDirection: Axis.horizontal,
            )),
      ),
    );
  }

  List<Widget> getColorIcons() {
    List<Widget> res = [];
    for (int cIndex = 0; cIndex < newLessonColorsForBlue2Table.length; cIndex++) {
      Color color = Color.fromARGB(
          newLessonColorsForBlue2Table[cIndex][0],
          newLessonColorsForBlue2Table[cIndex][1],
          newLessonColorsForBlue2Table[cIndex][2],
          newLessonColorsForBlue2Table[cIndex][3]);
      bool isSelected = false;
      if (newLessonColorsForBlue2Table[cIndex] == selectedColor) {
        isSelected = true;
      }
      Widget colorIcon = GestureDetector(
        child: Icon(
          Icons.fiber_manual_record,
          color: color,
          size: isSelected ? 45 : 30,
        ),
        onTap: () {
          setState(() {
            selectedColor = newLessonColorsForBlue2Table[cIndex];
          });
        },
      );
      res.add(colorIcon);
    }
    return res;
  }

  Widget getPredictedTestNumber() {
    return new Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: xSize * (25 / 100),
            height: 50,
            alignment: Alignment.center,
            child: TextField(
              maxLines: 1,
              controller: predictedTestController,
              style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(120, 255, 255, 255),
                  enabledBorder: OutlineInputBorder(
                    borderSide: new BorderSide(
                        color: testErrorToggle
                            ? prefix0.Theme.titleBar1
                            : prefix0.Theme.brightBlack,
                        width: 1),
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  hintText: "---",
                  hintStyle: prefix0.getTextStyle(
                      16,
                      testErrorToggle
                          ? prefix0.Theme.titleBar1
                          : prefix0.Theme.mildGrey)),
            ),
          ),
          AutoSizeText("پیشبینی تعداد تست:",
              textDirection: TextDirection.rtl,
              style: prefix0.getTextStyle(16, prefix0.Theme.darkText))
        ],
      ),
    );
  }

  Widget getPredictedTime() {
    return new Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      child: new Container(
        width: xSize,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: xSize * (25 / 100),
              height: 50,
              child: TextField(
                maxLines: 1,
                controller: predictedTimeController,
                style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(120, 255, 255, 255),
                    enabledBorder: OutlineInputBorder(
                      borderSide: new BorderSide(
                          color: timeErrorToggle
                              ? prefix0.Theme.titleBar1
                              : prefix0.Theme.brightBlack,
                          width: 1),
                      borderRadius: new BorderRadius.all(Radius.circular(25)),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    hintText: '--:--',
                    hintStyle: prefix0.getTextStyle(
                        16,
                        timeErrorToggle
                            ? prefix0.Theme.titleBar1
                            : prefix0.Theme.mildGrey)),
              ),
            ),
            AutoSizeText("پیشبینی زمان مطالعه:",
                textDirection: TextDirection.rtl,
                style: prefix0.getTextStyle(16, prefix0.Theme.darkText))
          ],
        ),
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
          addNewLesson();
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

  Widget getLoadingProgress() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: CircularProgressIndicator(),
      width: 50,
      height: 35,
    );
  }

  bool validateInput() {
    bool result = true;
    if (!checkEmptyAllowTime(predictedTimeController.text)) {
      result = false;
      setState(() {
        timeErrorToggle = true;
      });
      Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          timeErrorToggle = false;
        });
      });
    }
    if (!checkEmptyAllowTestNumber(predictedTestController.text)) {
      result = false;
      setState(() {
        testErrorToggle = true;
      });
      Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          testErrorToggle = false;
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
    if (selectedColor == null) {
      result = false;
      setState(() {
        colorPickerErrorToggle = true;
      });
      Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          colorPickerErrorToggle = false;
        });
      });
    }
    return result;
  }

  void addNewLesson() {
    setState(() {
      applyButtonLoading = true;
    });
    B2LessonPerDay b2lessonPerDay = getFragmentData();
    b2lessonPerDay.key =
        blueTable2State.blueTable2Data.getNewKey(blueTable2State.selectedDay);
    //TODO student
    LSM.getStudent().then((student) {
      blueTable2SRV
          .addLesson(StudentMainPage.studentUsername, "12345678",
              blueTable2State.blueTable2Data.name, b2lessonPerDay)
          .then((status) {
        if (status) {
          /// update widget state
          blueTable2State.addLessonCircleColor(b2lessonPerDay);

          /// notify with socket
          blueTable2State.notifyBlue2Table(blueTable2State.blueTable2Data);
          setState(() {
            applyButtonLoading = false;
          });
        }else{
          showErrorToast();
        }
      });
    });
  }
}
