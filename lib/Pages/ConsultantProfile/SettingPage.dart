import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantProfileSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix1;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ConsultantProfile.dart';

class ConsultantSettingFrag extends StatefulWidget {
  final ConsultantProfileState consultantProfileState;

  ConsultantSettingFrag(this.consultantProfileState, {Key key})
      : super(key: key);

  @override
  ConsultantSettingState createState() =>
      ConsultantSettingState(consultantProfileState);
}

class ConsultantSettingState extends State<ConsultantSettingFrag> {
  ConsultantProfileSRV consultantProfileSRV = new ConsultantProfileSRV();
  final ConsultantProfileState consultantProfileState;
  ConsultantSetting consultantSetting = ConsultantSetting();
  int consultantType = 0;
  String selectedTheme = "";
  double colorPickerHeight = 70;

  ///0 means bossConsultant and  1 means subConsultant

  bool subConsAccessLoading = false;
  bool studentAccessLoading = false;
  bool cTableTimeTypeAccessLoading = false;
  bool cTableTypeLoading = false;
  bool hideBlue2TableLoading = false;

  ConsultantSettingState(this.consultantProfileState);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    LSM.getConsultantSetting().then((inputSetting) {
      if (inputSetting == null) {
        setState(() {
          consultantSetting = new ConsultantSetting();
        });
      } else {
        setState(() {
          consultantSetting = inputSetting;
        });
      }
      setState(() {
        selectedTheme = LSM.getThemeSync();
      });
    });
    LSM.getConsultant().then((consultant) {
      setState(() {
        if (consultant.boss_consultant_username == "" ||
            consultant.boss_consultant_username == null) {
          this.consultantType = 0;
        } else {
          this.consultantType = 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double xsize = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Container(
            alignment: Alignment.center,
            width: xsize > 350 ? 350 : xsize,
            height: consultantType == 1
                ? 160 + colorPickerHeight
                : 220 + colorPickerHeight,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                getTitleText(),
//                getSwitchSettingField(
//                    subConsAccessSettingLabel,
//                    activeSubConsAccessDes,
//                    deActiveSubConsAccessDesc,
//                    changeSubConsAccess,
//                    consultantSetting.subConsAccess,
//                    subConsAccessLoading),
                consultantType == 1
                    ? SizedBox()
                    : getSwitchSettingField(
                        studentAccessSettingLabel,
                        activeStudentAccessDes,
                        deActiveStudentAccessDesc,
                        changeStudentAccess,
                        consultantSetting.studentAccess,
                        studentAccessLoading),
//                getSwitchSettingField(
//                    autoTimeFillSettingLabel,
//                    activeTimeDes,
//                    deActiveTiemDes,
//                    changeVariableTime,
//                    consultantSetting.variableTime,
//                    cTableTimeTypeAccessLoading),
//                getSwitchSettingField(
//                    consultantTableType,
//                    activeTypeDes,
//                    deActiveTypeDes,
//                    changeConsTableMode,
//                    consultantSetting.timeVolumeConsultantTableMode,
//                    cTableTypeLoading),
                getSwitchSettingField(
                    hideBlue2TableLabel,
                    hideBlue2ActiveDes,
                    hideBlue2DeActiveDes,
                    blue2TableAvailability,
                    consultantSetting.hideBlue2Table,
                    hideBlue2TableLoading),
                getThemeColorPicker()
              ],
            ))
      ],
    );
  }

  void blue2TableAvailability(bool value) {
    setState(() {
      hideBlue2TableLoading = true;
    });
    consultantSetting.hideBlue2Table = value;

    LSM.getConsultant().then((consultant) {
      consultantProfileSRV
          .changeSetting(consultant.username, consultant.authentication_string,
              'all', json.encode(consultantSetting.toJson()))
          .then((status) {
        if (status) {
          setState(() {
            consultantSetting.hideBlue2Table = value;
            hideBlue2TableLoading = false;
          });
          LSM.setConsultantSetting(consultantSetting);
          consultantProfileState.setState(() {});
        } else {
          setState(() {
            consultantSetting.hideBlue2Table = !value;
            hideBlue2TableLoading = false;
          });
        }
      });
    });
  }

  Widget getThemeColorPicker() {
    return new Padding(
      padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 5),
      child: new Container(
        height: colorPickerHeight - 15,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.all(Radius.circular(20)),
          border:
              BoxBorder.lerp(Border.all(width: 0.5), Border.all(width: 0.5), 1),
        ),
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
    for (int cIndex = 0; cIndex < prefix1.Theme.themes.keys.length; cIndex++) {
      String themeName = prefix1.Theme.themes.keys.toList()[cIndex];
      List<dynamic> colorNumbers = prefix1.Theme.themes[themeName];
      Color color = Color.fromARGB(
          colorNumbers[0], colorNumbers[1], colorNumbers[2], colorNumbers[3]);
      bool isSelected = false;
      if (themeName == selectedTheme) {
        isSelected = true;
      }
      Widget colorIcon = GestureDetector(
        child: Icon(
          Icons.fiber_manual_record,
          color: color,
          size: isSelected ? 50 : 35,
        ),
        onTap: () {
          setState(() {
            selectedTheme = themeName;
          });
          consultantProfileState.setState(() {
            prefix1.Theme.changeThemeByName(themeName);
          });
          consultantSetting.theme = selectedTheme;
          LSM.setConsultantSetting(consultantSetting);
          LSM.setTheme(selectedTheme);
        },
      );
      res.add(colorIcon);
    }
    return res;
  }

  void changeColor() async {
    prefix1.Theme.titleBar1 = Color.fromARGB(100, 255, 150, 0);
    consultantProfileState.setState(() {});
  }

  Widget getTitleText() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        child: AutoSizeText(
          consultantSettingLabel,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: getTextStyle(25, prefix1.Theme.blueIcon),
        ),
      ),
    );
  }

  void changeSubConsAccess(bool value) {
    setState(() {
      subConsAccessLoading = true;
    });
    consultantSetting.subConsAccess = value;
    LSM.getConsultant().then((consultant) {
      consultantProfileSRV
          .changeSetting(consultant.username, consultant.authentication_string,
              'all', json.encode(consultantSetting.toJson()))
          .then((status) {
        if (status) {
          setState(() {
            consultantSetting.subConsAccess = value;
            subConsAccessLoading = false;
          });
          LSM.setConsultantSetting(consultantSetting);
        } else {
          setState(() {
            consultantSetting.subConsAccess = !value;
            subConsAccessLoading = false;
          });
        }
      });
    });
  }

  void changeStudentAccess(bool value) {
    setState(() {
      studentAccessLoading = true;
    });
    consultantSetting.studentAccess = value;
    LSM.getConsultant().then((consultant) {
      consultantProfileSRV
          .changeSetting(consultant.username, consultant.authentication_string,
              'all', json.encode(consultantSetting.toJson()))
          .then((status) {
        if (status) {
          setState(() {
            consultantSetting.studentAccess = value;
            studentAccessLoading = false;
          });
          LSM.setConsultantSetting(consultantSetting);
        } else {
          setState(() {
            consultantSetting.studentAccess = !value;
            studentAccessLoading = false;
          });
        }
      });
    });
  }

  void changeConsTableMode(bool value) {
    setState(() {
      cTableTypeLoading = true;
    });
    consultantSetting.timeVolumeConsultantTableMode = value;

    LSM.getConsultant().then((consultant) {
      consultantProfileSRV
          .changeSetting(
              consultant.username,
              consultant.authentication_string,
              'all',
              json.encode(consultantSetting.toJson()))
          .then((status) {
        if (status) {
          setState(() {
            consultantSetting.timeVolumeConsultantTableMode = value;
            cTableTypeLoading = false;
          });
          LSM.setConsultantSetting(consultantSetting);
        } else {
          setState(() {
            consultantSetting.timeVolumeConsultantTableMode = !value;
            cTableTypeLoading = false;
          });
        }
      });
    });
  }

  void changeVariableTime(bool value) {
    setState(() {
      cTableTimeTypeAccessLoading = true;
    });
    consultantSetting.variableTime = value;
    LSM.getConsultant().then((consultant) {
      consultantProfileSRV
          .changeSetting(consultant.username, consultant.authentication_string,
              'all', json.encode(consultantSetting.toJson()))
          .then((status) {
        if (status) {
          setState(() {
            consultantSetting.variableTime = value;
            cTableTimeTypeAccessLoading = false;
          });
          LSM.setConsultantSetting(consultantSetting);
        } else {
          setState(() {
            consultantSetting.variableTime = !value;
            cTableTimeTypeAccessLoading = false;
          });
        }
      });
    });
  }
}
