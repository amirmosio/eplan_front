import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/ConsultantProfileSRV.dart';
import 'package:mhamrah/ConnectionService/StudentProfileSRV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/StudentProfile/StudentProfile.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix1;
import 'package:mhamrah/Values/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudentSettingFrag extends StatefulWidget {
  final StudentProfileState studentProfileState;

  StudentSettingFrag(this.studentProfileState, {Key key}) : super(key: key);

  @override
  StudentSettingState createState() => StudentSettingState(studentProfileState);
}

class StudentSettingState extends State<StudentSettingFrag> {
  StudentProfileSRV studentProfileSRV = new StudentProfileSRV();
  final StudentProfileState studentProfileState;
  StudentSetting studentSetting = StudentSetting();
  String selectedTheme = "";
  double titleHeight = 45;
  double blue2TableSwitchHeight = 100;
  double colorPickerHeight = 70;

  bool hideBlue2TableLoading = false;

  ///0 means bossConsultant and  1 means subConsultant

  StudentSettingState(this.studentProfileState);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    studentSetting = LSM.getStudentSettingSync();
    selectedTheme = LSM.getThemeSync();
  }

  @override
  Widget build(BuildContext context) {
    double xsize = MediaQuery.of(context).size.width;
    return Container(
        alignment: Alignment.center,
        width: xsize > 350 ? 350 : xsize,
        height: titleHeight + blue2TableSwitchHeight + colorPickerHeight,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
            color: prefix1.Theme.settingBg),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            getTitleText(),
            getSwitchSettingField(
                hideBlue2TableLabel,
                hideBlue2ActiveDes,
                hideBlue2DeActiveDes,
                blue2TableAvailability,
                studentSetting.hideBlue2Table,
                hideBlue2TableLoading),
            getThemeColorPicker()
          ],
        ));
  }

  void blue2TableAvailability(bool value) {

    setState(() {
      hideBlue2TableLoading = true;
    });
    studentSetting.hideBlue2Table = value;

    LSM.getStudent().then((student) {
      studentProfileSRV
          .changeSetting(student.username, student.authentication_string,
          'all', json.encode(studentSetting.toJson()))
          .then((status) {
        if (status) {
          setState(() {
            studentSetting.hideBlue2Table = value;
            hideBlue2TableLoading = false;
          });
          studentProfileState.setState(() {});
          LSM.setStudentSetting(studentSetting);
          StudentMainPage.selectedIndex = 0;
          StudentMainPage.state.setState(() {});
        } else {
          setState(() {
            studentSetting.hideBlue2Table = !value;
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
          studentProfileState.setState(() {
            prefix1.Theme.changeThemeByName(themeName);
          });
          studentSetting.theme = selectedTheme;
          LSM.setStudentSetting(studentSetting);
          LSM.setTheme(selectedTheme);
        },
      );
      res.add(colorIcon);
    }
    return res;
  }

  void changeColor() async {
    prefix1.Theme.titleBar1 = Color.fromARGB(100, 255, 150, 0);
    studentProfileState.setState(() {});
  }

  Widget getTitleText() {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        child: AutoSizeText(
          studentSettingLabel,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: getTextStyle(25, prefix1.Theme.blueIcon),
        ),
      ),
    );
  }

  Widget getLoadingProgress() {
    double r = 15;
    return Container(
      child: CircleAvatar(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
        radius: r,
      ),
      width: r,
      height: r,
    );
  }
}
