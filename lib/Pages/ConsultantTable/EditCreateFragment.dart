import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:io' as io;

import 'package:auto_direction/auto_direction.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantTableSRV.dart';
import 'package:mhamrah/Models/ChatMV.dart';
import 'package:mhamrah/Models/ConsultantTableMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ConsultantTable/ConsultantTable.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix1;
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file/local.dart';

import '../StudentMainPage.dart';

class EditCreateFragment extends StatefulWidget {
  final CLessonPlanPerDay cLessonPlanPerDay;
  final LocalFileSystem localFileSystem;
  final ConsultantTableState consultantTableState;

  EditCreateFragment(this.cLessonPlanPerDay, this.consultantTableState,
      {Key key, localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _EditCreateFragmentState createState() {
    return _EditCreateFragmentState(cLessonPlanPerDay, consultantTableState);
  }
}

class _EditCreateFragmentState extends State<EditCreateFragment> {
  ConsultantTableSRV consultantTableSRV = new ConsultantTableSRV();
  ConsultantSetting consultantSettingOrDefault = new ConsultantSetting();
  int userType = 0;

  //size things
  static double xSize;
  static double ySize;

  CLessonPlanPerDay cLessonPlanPerDay;
  ConsultantTableState consultantTableState;

  //data things
  static TextEditingController lessonNameController;
  String lessonNameText;
  static TextEditingController descriptionController;
  String descriptionText;

  static TextEditingController startController;
  String startText;

  static TextEditingController endController;
  String endText;

  static bool _importance = false;
  bool _loadingToggle = false;
  bool canBeVolumeTable = false;

  bool lessonNameErrorToggle = false;
  bool buttonErrorToggle = false;
  bool startTimeErrorToggle = false;
  bool endTimeErrorToggle = false;

  /// voice recorder
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _recorderStatus = RecordingStatus.Stopped;
  io.File recordedVoice;
  Timer recorderTimer;
  bool hadVoiceBefore = false;

  _EditCreateFragmentState(this.cLessonPlanPerDay, this.consultantTableState) {
    lessonNameController = new TextEditingController();
    descriptionController = new TextEditingController();
    startController = new TextEditingController();
    endController = new TextEditingController();
    _importance = false;
    lessonNameController.text = cLessonPlanPerDay.lessonName;
    descriptionController.text =
        (cLessonPlanPerDay.description ?? "").replaceAll("\\n", "\n");
    startController.text = cLessonPlanPerDay.startTime;
    endController.text = cLessonPlanPerDay.endTime;
    _importance = cLessonPlanPerDay.importance;
  }

  CLessonPlanPerDay getFragmentData() {
    CLessonPlanPerDay l = CLessonPlanPerDay();
    l.startTime = (startController.text);
    l.endTime = (endController.text);
    l.lessonName = (lessonNameController.text);
    l.description = (descriptionController.text);
    l.importance = (_importance);
    if (!consultantSettingOrDefault.timeVolumeConsultantTableMode) {
      l.startTime = "";
    } else {
      l.startTime = startController.text;
    }
    if (hadVoiceBefore) {
      l.hasVoiceFile = true;
      l.voiceFile = null;
    } else if (recordedVoice == null) {
      l.hasVoiceFile = false;
      l.voiceFile = null;
    } else {
      l.voiceFile = CustomFile();
      l.voiceFile.fileBytes = recordedVoice.readAsBytesSync();
      l.voiceFile.fileNameOrPath = recordedVoice.path;
      l.hasVoiceFile = true;
    }
    return l;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
    LSM.getConsultantSetting().then((setting) {
      setState(() {
        this.consultantSettingOrDefault = setting;
      });
      if (!setting.variableTime) {
        loadSuggestionTime();
      }
    });
    LSM.getUserMode().then((userType) {
      setState(() {
        this.userType = userType;
      });
    });
    canBeVolumeTable =
        consultantTableState.consultantTableData.canBeVolumeBaseTable();
    if (cLessonPlanPerDay.hasVoiceFile) {
      hadVoiceBefore = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width * (70 / 100);
    ySize = MediaQuery.of(context).size.width * (95 / 100);
    return new Align(
      child: GestureDetector(
        onTap: () {
          consultantTableState.closeCreateEditFrag();
        },
        child: new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          color: prefix0.Theme.fragmentBlurBackGround,
          child: new BackdropFilter(
            filter: prefix0.Theme.fragmentBGFilter,
            child: GestureDetector(
              onTap: () {},
              child: new Container(
                width: xSize,
                decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(Radius.circular(15)),
                    color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    getLessonNameTextField(context),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              new BorderRadius.all(Radius.circular(25)),
                          border: Border.all(color: prefix0.Theme.greyTimeLine),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            getDescriptionTextField(context),
                            !kIsWeb ? getVoiceRecorder() : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    consultantSettingOrDefault.timeVolumeConsultantTableMode
                        ? getTimeTypeStartEndTextField(context)
                        : getVolumeTypeTimeTextField(context),
                    getSwitchButton(),
                    getApplyButton()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loadSuggestionTime() {
    ConsultantTableModel currentTable =
        consultantTableState.consultantTableData;
    if (consultantTableState.selectedDay != 0) {
      int prevDay = consultantTableState.selectedDay - 1;
      for (int i = prevDay; i >= 0; i--) {
        List<CLessonPlanPerDay> prevDayLessons =
            currentTable.daysSchedule[i].dayLessonPlans;
        int currentCount = currentTable
            .daysSchedule[consultantTableState.selectedDay]
            .dayLessonPlans
            .length;
        if (currentCount < prevDayLessons.length) {
          CLessonPlanPerDay alg = prevDayLessons[currentCount];
          setState(() {
            startController.text = alg.startTime;
            endController.text = alg.endTime;
          });
          break;
        }
      }
    }
  }

  Widget getLessonNameTextField(context) {
    return new Container(
      width: xSize,
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: new Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
            child: AutoDirection(
              text: lessonNameText == null || lessonNameText == ""
                  ? "ب"
                  : lessonNameText,
              child: TextField(
                maxLines: 1,
                controller: lessonNameController,
                style: prefix0.getTextStyle(18, prefix0.Theme.darkText),
                onChanged: (value) {
                  setState(() {
                    lessonNameText = lessonNameController.text;
                  });
                  lessonNameController.value = TextEditingValue(
                    text: value,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: value.length),
                    ),
                  );
                  if (value != null && value != "") {
                    setState(() {
                      lessonNameErrorToggle = false;
                    });
                  }
                },
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
                    borderRadius: new BorderRadius.all(Radius.circular(25)),
                  ),
                  labelText: 'نام درس',
                ),
              ),
            )),
      ),
    );
  }

  Widget getDescriptionTextField(context) {
    return new Container(
      width: xSize,
      child: new Directionality(
        textDirection: TextDirection.rtl,
        child: new Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: AutoDirection(
              text: descriptionText == null || descriptionText == ""
                  ? "ب"
                  : descriptionText,
              child: TextField(
//                textAlign: TextAlign.right,
                controller: descriptionController,
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    descriptionText =
                        value.replaceAll("\n", " ").replaceAll("\\n", " ");
                  });
                },
                style: prefix0.getTextStyle(16, prefix0.Theme.darkText),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(120, 255, 255, 255),
                  border: InputBorder.none,
                  labelText: 'توضیحات',
                ),
              ),
            )),
      ),
    );
  }

  Widget getTimeTypeStartEndTextField(context) {
    return new Container(
      width: xSize,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Container(
            width: xSize * (40 / 100),
            height: 70,
            child: new Directionality(
              textDirection: TextDirection.rtl,
              child: new Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: endController,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  textDirection: TextDirection.ltr,
                  style: prefix0.getTextStyle(18, prefix0.Theme.darkText),
                  onChanged: (value) {
                    value =
                        getTimeString(value, endText == null ? "" : endText);
                    endText = value;
                    endController.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      ),
                    );
                    if (checkTime(value)) {
                      setState(() {
                        endTimeErrorToggle = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "--:--",
                    labelText: "پایان",
                    fillColor: Color.fromARGB(120, 255, 255, 255),
                    enabledBorder: OutlineInputBorder(
                      borderSide: new BorderSide(
                          color: endTimeErrorToggle
                              ? prefix0.Theme.titleBar1
                              : prefix0.Theme.brightBlack,
                          width: 1),
                      borderRadius: new BorderRadius.all(Radius.circular(25)),
                    ),
                    border: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.red, width: 1),
                      borderRadius: new BorderRadius.all(Radius.circular(25)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          new Container(
            width: xSize * (40 / 100),
            height: 70,
            child: new Directionality(
              textDirection: TextDirection.rtl,
              child: new Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: startController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  style: prefix0.getTextStyle(18, prefix0.Theme.darkText),
                  onChanged: (value) {
                    value = getTimeString(
                        value, startText == null ? "" : startText);
                    startText = value;
                    startController.value = TextEditingValue(
                      text: value,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      ),
                    );
                    if (checkTime(value)) {
                      setState(() {
                        startTimeErrorToggle = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "--:--",
                    labelText: "شروع",
                    fillColor: Color.fromARGB(120, 255, 255, 255),
                    enabledBorder: OutlineInputBorder(
                      borderSide: new BorderSide(
                          color: startTimeErrorToggle
                              ? prefix0.Theme.titleBar1
                              : prefix0.Theme.brightBlack,
                          width: 1),
                      borderRadius: new BorderRadius.all(Radius.circular(25)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: new BorderRadius.all(Radius.circular(25)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
      value = value + ":";
    } else {
      value = value.substring(0, 2) +
          ":" +
          value.substring(2, min(4, value.length));
    }
    return value;
  }

  Widget getVolumeTypeTimeTextField(context) {
    return new Container(
      width: xSize,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            alignment: Alignment.bottomCenter,
            width: xSize * (40 / 100),
            height: 45,
            child: TextField(
              textAlign: TextAlign.center,
              controller: endController,
              textDirection: TextDirection.ltr,
              style: prefix0.getTextStyle(17, prefix0.Theme.darkText),
              onChanged: (value) {
                if (checkTime(value)) {
                  setState(() {
                    endTimeErrorToggle = false;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                hintText: "--:--",
                hintStyle: prefix0.getTextStyle(16, prefix0.Theme.darkText),
                alignLabelWithHint: true,
                fillColor: prefix0.Theme.onMainBGText,
                enabledBorder: OutlineInputBorder(
                  borderSide: new BorderSide(
                      color: endTimeErrorToggle
                          ? prefix0.Theme.titleBar1
                          : prefix0.Theme.brightBlack,
                      width: 1),
                  borderRadius: new BorderRadius.all(Radius.circular(15)),
                ),
                border: OutlineInputBorder(
                  borderRadius: new BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
          ),
          new Container(
              width: xSize * (20 / 100),
              height: 70,
              alignment: Alignment.center,
              child: AutoSizeText(
                timeVolumeTypeTableLabel,
                style: prefix0.getTextStyle(18, prefix0.Theme.darkText),
              )),
        ],
      ),
    );
  }

  bool checkTime(String time) {
    String value2 = replacePersianWithEnglishNumber(time);
    RegExp regex = RegExp(r"^[0-9]?[0-9]:[0-9]?[0-9]$", caseSensitive: true);
    if (!regex.hasMatch(value2)) {
      return false;
    } else {
      return true;
    }
  }

  bool checkAllowEmptyTime(String time) {
    if (time == "") {
      return true;
    }
    String value2 = replacePersianWithEnglishNumber(time);
    RegExp regex = RegExp(r"^[0-9]?[0-9]:[0-9]?[0-9]$", caseSensitive: true);
    if (!regex.hasMatch(value2)) {
      return false;
    } else {
      return true;
    }
  }

  Widget getSwitchButton() {
    return new Container(
      width: xSize * (70 / 100),
      height: 50,
      padding: EdgeInsets.only(bottom: 5),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            height: 50,
            width: 60,
            child: Switch(
              value: _importance,
              activeTrackColor: Colors.lightGreen,
              activeColor: prefix0.Theme.applyButton,
              onChanged: (value) {
                setState(() {
                  _importance = value;
                });
              },
            ),
          ),
          new Container(
            child: AutoSizeText(
              "اهمیت: ",
              textDirection: TextDirection.rtl,
              style: getTextStyle(15, prefix0.Theme.darkText),
            ),
          ),
        ],
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
            color: buttonErrorToggle
                ? prefix0.Theme.titleBar1
                : prefix0.Theme.applyButton,
            borderRadius: new BorderRadius.all(Radius.circular(15))),
        child: _loadingToggle
            ? getLoadingProgress()
            : Text(
                "تایید",
                style: getTextStyle(20, prefix0.Theme.onMainBGText),
              ),
      ),
      onTap: () {
        if (verifyInputData()) {
          setState(() {
            buttonErrorToggle = true;
          });
          Future.delayed(Duration(milliseconds: 250)).then((_) {
            setState(() {
              buttonErrorToggle = false;
            });
          });
        } else {
          if (consultantTableState.createOrEditMode) {
            uploadNewLesson();
          } else {
            editHereAndInDataBaseNewLesson();
          }
        }
      },
    );
  }

  void uploadNewLesson() {
    setState(() {
      _loadingToggle = true;
    });
    CLessonPlanPerDay c = getFragmentData();
    c.key = consultantTableState.consultantTableData
        .getNewDayPlanKey(consultantTableState.selectedDay);
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        consultantTableSRV
            .addLessonField(
                consultant.username,
                StudentMainPage.studentUsername,
                consultant.authentication_string,
                c,
                consultantTableState.consultantTableData.name)
            .then((status) {
          if (status['success']) {
            /// handle widget change
            consultantTableState.AddLessonWidget(c);

            /// socket
            consultantTableState.notifyConsultantTable(
                consultantTableState.consultantTableData);

            /// handle loading
            setState(() {
              _loadingToggle = false;
            });
          } else {
            _loadingToggle = false;
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        consultantTableSRV
            .addLessonField(
                student.username,
                student.username,
                student.authentication_string,
                c,
                consultantTableState.consultantTableData.name)
            .then((status) {
          if (status['success']) {
            /// handle widget change
            consultantTableState.AddLessonWidget(c);

            /// socket
            consultantTableState.notifyConsultantTable(
                consultantTableState.consultantTableData);

            /// handle loading
            setState(() {
              _loadingToggle = false;
            });
          } else {
            if (status['error'] == "student access limited by bossconsultant") {
              student.student_access = false;
              LSM.updateStudentInfo(student);
              consultantTableState.closeCreateEditFrag();
              consultantTableState.updateStudentAccess();
              showFlutterToastWithFlushBar(accessDeniedForStudentChange);
            } else {
              _loadingToggle = false;
            }
          }
        });
      });
    }
  }

  void editHereAndInDataBaseNewLesson() {
    setState(() {
      /// check later
      _loadingToggle = true;
    });
    CLessonPlanPerDay data = getFragmentData();
    data.key = cLessonPlanPerDay.key;
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        consultantTableSRV
            .update_lesson_field(
                consultant.username,
                StudentMainPage.studentUsername,
                consultant.authentication_string,
                data,
                consultantTableState.consultantTableData.name)
            .then((status) {
          if (status['success']) {
            /// handle widget change
            consultantTableState.updateLessonWidget(data);

            /// socket
            consultantTableState.notifyConsultantTable(
                consultantTableState.consultantTableData);

            /// handle loading
            setState(() {
              _loadingToggle = false;
            });
          } else {
            if (status['error'] ==
                "student access limited by bossconsultant") {}
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        consultantTableSRV
            .update_lesson_field(
                student.username,
                student.username,
                student.authentication_string,
                data,
                consultantTableState.consultantTableData.name)
            .then((status) {
          if (status['success']) {
            /// handle widget change
            consultantTableState.updateLessonWidget(data);

            /// socket
            consultantTableState.notifyConsultantTable(
                consultantTableState.consultantTableData);

            /// handle loading
            setState(() {
              _loadingToggle = false;
            });
          } else {
            if (status['error'] == "student access limited by bossconsultant") {
              student.student_access = false;
              LSM.updateStudentInfo(student);
              consultantTableState.closeCreateEditFrag();
              consultantTableState.updateStudentAccess();
              showFlutterToastWithFlushBar(accessDeniedForStudentChange);
            }
          }
        });
      });
    }
  }

  Widget getLoadingProgress() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: CircularProgressIndicator(),
      width: 50,
      height: 35,
    );
  }

  bool verifyInputData() {
    String lessonName = lessonNameController.text;
    String startTime;
    if (consultantSettingOrDefault.timeVolumeConsultantTableMode ||
        !canBeVolumeTable) {
      startTime = startController.text;
    } else {
      startTime = "";
    }
    String endTime = endController.text;
    bool result = false;
    if (!checkAllowEmptyTime(startTime)) {
      setState(() {
        startTimeErrorToggle = true;
      });
      result = true;
    }
    if (((consultantSettingOrDefault.timeVolumeConsultantTableMode ||
                !canBeVolumeTable) &&
            !checkAllowEmptyTime(endTime)) ||
        (!(consultantSettingOrDefault.timeVolumeConsultantTableMode ||
                canBeVolumeTable) &&
            !checkAllowEmptyTime(endTime))) {
      setState(() {
        endTimeErrorToggle = true;
      });
      result = true;
    }
    if (lessonName == "" || lessonName == null) {
      result = true;
      setState(() {
        lessonNameErrorToggle = true;
      });
    }
    if (_recorderStatus == RecordingStatus.Recording) {
      result = true;
    }

    return result;
  }

  Widget getVoiceRecorder() {
    bool initialState = hadVoiceBefore;
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 5),
      child: new Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: prefix0.Theme.greyTimeLine),
            borderRadius: BorderRadius.all(Radius.circular(25))),
        child: new Container(
          height: 45,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Container(
                        padding: EdgeInsets.only(bottom: 2),
                        alignment: Alignment.center,
                        child: new IconButton(
                          icon: new Icon(
                            Icons.delete_outline,
                            color:
                                (_recorderStatus == RecordingStatus.Stopped &&
                                            recordedVoice != null) ||
                                        initialState
                                    ? prefix0.Theme.warningAndErrorBG
                                    : prefix0.Theme.greyTimeLine,
                          ),
                          onPressed: () {
                            cancelDeleteVoice();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: AutoSizeText(
                          _recorderStatus == RecordingStatus.Recording
                              ? "Recording..."
                              : "Recorded",
                          style: prefix0.getTextStyle(
                              16,
                              (_recorderStatus == RecordingStatus.Stopped &&
                                          recordedVoice != null) ||
                                      initialState
                                  ? prefix0.Theme.blueIcon
                                  : prefix0.Theme.greyTimeLine),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (_recorderStatus == RecordingStatus.Stopped &&
                          recordedVoice == null) &&
                      !initialState
                  ? Container(
                      padding: EdgeInsets.all(2),
                      child: new IconButton(
                        icon: new Icon(
                          Icons.keyboard_voice,
                          color: prefix0.Theme.blueIcon,
                        ),
                        onPressed: () {
                          /// start recording
                          startRecording();
                        },
                      ),
                    )
                  : _recorderStatus == RecordingStatus.Recording &&
                          !initialState
                      ? Container(
                          padding: EdgeInsets.all(2),
                          child: new IconButton(
                            icon: new Icon(
                              Icons.stop,
                              color: prefix0.Theme.redBright,
                            ),
                            onPressed: () {
                              /// pause recording;
                              pauseRecording();
                            },
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(2),
                          child: new IconButton(
                            icon: new Icon(
                              Icons.keyboard_voice,
                              color: prefix0.Theme.greyTimeLine,
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  void startRecording() {
    setState(() {
      _recorderStatus = RecordingStatus.Recording;
    });
    _start();

    /// todo
  }

  Future<bool> pauseRecording() async {
    await _recorder.pause();
    _stop().then((value) {
      setState(() {
        _recorderStatus = RecordingStatus.Stopped;
        hadVoiceBefore = false;
      });
    });
    return false;
  }

  void cancelDeleteVoice() {
    setState(() {
      recordedVoice = null;
      hadVoiceBefore = false;
      _recorderStatus = RecordingStatus.Stopped;
    });
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 0);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _recorderStatus = current.status;
          _recorderStatus = RecordingStatus.Stopped;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {}
  }

  _start() async {
    try {
      await _recorder.start();
//      var recording = await _recorder.current(channel: 0);
//      setState(() {
//        _current = recording;
//      });

      const tick = const Duration(milliseconds: 50);
      recorderTimer = new Timer.periodic(tick, (Timer t) {
        if (_recorderStatus == RecordingStatus.Stopped ||
            _recorderStatus == RecordingStatus.Paused) {
          t.cancel();
        }

//        var current = _recorder.current(channel: 0).then((current) {
//          setState(() {
//            _current = current;
//            _recorderStatus = _current.status;
//          });
//        });
      });
    } catch (e) {}
  }

  Future<File> _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    recordedVoice = file;
    return file;
  }
}
