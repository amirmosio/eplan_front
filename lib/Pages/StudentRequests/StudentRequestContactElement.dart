import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/HTTPService.dart';
import 'package:mhamrah/ConnectionService/StudentListSRV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/StudentRequests/StudentRequestList.dart';
import 'package:mhamrah/Pages/User/RegisterPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/material.dart';

import '../StudentMainPage.dart';

class StudentRequestElement extends StatefulWidget {
  final ContactElement studentContactElement;
  final StudentRequestListPageState studentRequestListPageState;
  final Consultant consultant;

  StudentRequestElement(
    this.studentContactElement,
    this.studentRequestListPageState,
    this.consultant, {
    Key key,
  }) : super(key: key);

  @override
  _StudentRequestElementState createState() => _StudentRequestElementState(
      studentContactElement, studentRequestListPageState, this.consultant);
}

class _StudentRequestElementState extends State<StudentRequestElement> {
  ConnectionService httpRequestService = ConnectionService();
  ContactElement contactElement;
  double xSize;
  double ySize;
  StudentListSRV studentListSRV = StudentListSRV();
  String imageURL;
  StudentRequestListPageState studentRequestListPageState;
  Consultant consultant;

  final columns = 7;
  final rows = 13;
  bool acceptLoading = false;
  bool rejectLoading = false;

  _StudentRequestElementState(
      this.contactElement, this.studentRequestListPageState, this.consultant);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    String username = contactElement.username;
    if (contactElement.userType == "student") {
      imageURL = httpRequestService.getStudentImageURL(username);
    } else {
      imageURL = httpRequestService.getConsultantImageURL(username);
    }
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    return new Padding(
      padding: EdgeInsets.only(
          left: xSize * (5 / 100), right: xSize * (5 / 100), top: 15),
      child: new Container(
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(35)),
          color: prefix0.Theme.contactItemBG,
          boxShadow: [
            BoxShadow(
              color: prefix0.Theme.contactItemBG.withOpacity(0.5),
              spreadRadius: prefix0.Theme.spreadRadius + 1,
              blurRadius: prefix0.Theme.blurRadius + 1,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            getStudentContact(),
            contactElement.userType == "student"
                ? getStudentDescription()
                : getConsultantDescription()
          ],
        ),
      ),
    );
  }

  Widget getStudentDescription() {
    double minMobileScreenSize = 359;
    double minSchoolNameScreen = 361;

    print(xSize);
    return new Container(
      alignment: Alignment.center,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              getTextDescription(contactElement.studentEduLevel,
                  contactElement.studentEduLevel != ""),
              getTextDescription(contactElement.studentMajor,
                  contactElement.studentMajor != ""),
              xSize > minSchoolNameScreen
                  ? getTextDescription(contactElement.studentSchool,
                      contactElement.studentSchool != "")
                  : SizedBox(),
            ],
          ),
          xSize < minSchoolNameScreen
              ? getTextDescription(contactElement.studentSchool,
                  contactElement.studentSchool != "")
              : SizedBox(),
          xSize > minMobileScreenSize
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    getTextDescription("تلفن: " + contactElement.phone, false),
                    getTextDescription(
                        "تلفن پدر: " + contactElement.fatherPhone, false),
                  ],
                )
              : SizedBox(),
          xSize > minMobileScreenSize
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    getTextDescription(
                        "تلفن مادر: " + contactElement.motherPhone, false),
                    getTextDescription(
                        "خانه: " + contactElement.homeNumber, false),
                  ],
                )
              : SizedBox(),
          xSize < minMobileScreenSize
              ? getTextDescription("تلفن: " + contactElement.phone, false)
              : SizedBox(),
          xSize < minMobileScreenSize
              ? getTextDescription(
                  "تلفن پدر: " + contactElement.fatherPhone, false)
              : SizedBox(),
          xSize < minMobileScreenSize
              ? getTextDescription(
                  "تلفن مادر: " + contactElement.motherPhone, false)
              : SizedBox(),
          xSize < minMobileScreenSize
              ? getTextDescription("خانه: " + contactElement.homeNumber, false)
              : SizedBox(),
          contactElement.userType == "student"
              ? getTextDescription(
                  "پشتیبان: " +
                      (consultant.username == contactElement.subConsUsername
                          ? " - "
                          : contactElement.subConsName),
                  false)
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
          getStudentMainPageButton()
        ],
      ),
    );
  }

  Widget getConsultantDescription() {
    double minMobileScreenSize = 359;
    double minSchoolNameScreen = 361;

    print(xSize);
    return new Container(
      alignment: Alignment.center,
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          getTextDescription("تلفن: " + contactElement.phone, false),
          getStudentMainPageButton()
        ],
      ),
    );
  }

  Widget getStudentMainPageButton() {
    return new Container(
      width: xSize * (100 - 10) / 100,
      alignment: Alignment.center,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          GestureDetector(
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width * ((100 - 10) / 200),
              child: rejectLoading
                  ? getButtonLoadingProgress()
                  : AutoSizeText(
                      "حذف",
                      style: prefix0.getTextStyle(
                          18, prefix0.Theme.onWarningAndErrorBG),
                    ),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                      colors: [
                        prefix0.Theme.warningAndErrorBG,
                        Color.fromARGB(
                          255,
                          min(255, prefix0.Theme.warningAndErrorBG.red + 25),
                          min(255, prefix0.Theme.warningAndErrorBG.green + 25),
                          min(255, prefix0.Theme.warningAndErrorBG.blue + 25),
                        )
                      ]),
//                  color: prefix0.Theme.warningAndErrorBG,
                  borderRadius:
                      new BorderRadius.only(bottomLeft: Radius.circular(35))),
            ),
            onTap: () {
              if (!rejectLoading) {
                reject();
              }
            },
          ),
          GestureDetector(
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width * ((100 - 10) / 200),
              child: acceptLoading
                  ? getButtonLoadingProgress()
                  : AutoSizeText(
                      contactElement.userType == "student"
                          ? "پذیرش دانش اموز"
                          : "پذیرش پشتیبان ",
                      style:
                          prefix0.getTextStyle(18, prefix0.Theme.onApplyButton),
                    ),
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                  gradient: LinearGradient(
                      end: Alignment.bottomCenter,
                      begin: Alignment.topLeft,
                      colors: [
                        prefix0.Theme.applyButton,
                        Color.fromARGB(
                          255,
                          min(255, prefix0.Theme.applyButton.red + 25),
                          min(255, prefix0.Theme.applyButton.green + 25),
                          min(255, prefix0.Theme.applyButton.blue + 25),
                        )
                      ]),
                  color: prefix0.Theme.applyButton,
                  borderRadius:
                      new BorderRadius.only(bottomRight: Radius.circular(35))),
            ),
            onTap: () {
              if (!acceptLoading) {
                accept();
              }
            },
          )
        ],
      ),
    );
  }

  Widget getTextDescription(String text, bool) {
    return new Container(
      alignment: Alignment.center,
//      width: xSize * (20 / 100),
      padding: EdgeInsets.only(top: 10, bottom: 5),
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AutoSizeText(
            text,
            softWrap: true,
            wrapWords: true,
            textDirection: TextDirection.rtl,
            style: prefix0.getTextStyle(16, prefix0.Theme.contactDetailText),
          ),
          bool
              ? Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.fiber_manual_record,
                    size: 12,
                    color: prefix0.Theme.contactDetailText,
                  ),
                )
              : new SizedBox(
                  width: 0,
                  height: 0,
                )
        ],
      ),
    );
  }

  Widget getStudentContact() {
    return new Container(
      height: 65,
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(35), topLeft: Radius.circular(35))),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[getContactDetail(), getSplitLine()],
          ),
          getContactAvatar()
        ],
      ),
    );
  }

  Widget getContactDetail() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.fromLTRB(10, 15, ySize * (4 / 100), 0),
      child: new AutoSizeText(
        contactElement.name,
        style: prefix0.getTextStyle(18, prefix0.Theme.onContactItemBg),
      ),
    );
  }

  Widget getSplitLine() {
    return new Padding(
        padding: EdgeInsets.only(
            left: xSize * (1 / 100), right: xSize * (1 / 100), top: 15),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Container(
              color: prefix0.Theme.contactDetailText,
              height: 2,
              width: xSize - (15 / 100) * xSize - ySize * (7.5 / 100),
            ),
          ],
        ));
  }

//
//  Widget getLastSeenTime() {
//    return new Expanded(
//      child: new Text(
//        studentContactElement.lastSeenTime,
//        style: TextStyle(fontSize: 18),
//      ),
//    );
//  }
//
//  Widget getDeleteForLogPressText() {
//    return new Expanded(
//      child: new Text(
//        "مطمینی؟",
//        style: TextStyle(fontSize: 18),
//      ),
//    );
//  }

  Widget getContactAvatar() {
    return new Container(
      width: ySize * (7.5) / 100,
      height: ySize * (7.5) / 100,
      decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
              fit: BoxFit.fill, image: new NetworkImage(imageURL))),
    );
  }

  void accept() {
    setState(() {
      acceptLoading = true;
    });
    LSM.getConsultant().then((consultant) {
      if (contactElement.userType == "student") {
        studentListSRV
            .acceptStudent(consultant.username,
                consultant.authentication_string, contactElement.username)
            .then((value) {
          if (value) {
            studentRequestListPageState
                .removeItemByUserName(contactElement.username);
            setState(() {
              acceptLoading = false;
            });
          }
        });
      } else if (contactElement.userType == "consultant") {
        studentListSRV
            .acceptSubConsultant(consultant.username,
                consultant.authentication_string, contactElement.username)
            .then((value) {
          studentRequestListPageState
              .removeItemByUserName(contactElement.username);
          setState(() {
            acceptLoading = false;
          });
        });
      }
    });
  }

  void reject() {
    setState(() {
      rejectLoading = true;
    });
    LSM.getConsultant().then((value) {
      if (contactElement.userType == "student") {
        studentListSRV
            .rejectStudent(value.username, value.authentication_string,
                contactElement.username)
            .then((value) {
          studentRequestListPageState
              .removeItemByUserName(contactElement.username);
          setState(() {
            rejectLoading = false;
          });
        });
      } else if (contactElement.userType == "consultant") {
        studentListSRV
            .rejectSubConsultant(value.username, value.authentication_string,
                contactElement.username)
            .then((value) {
          studentRequestListPageState
              .removeItemByUserName(contactElement.username);
          setState(() {
            rejectLoading = false;
          });
        });
      }
    });
  }
}
