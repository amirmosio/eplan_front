import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/StudentProfileSRV.dart';
import 'package:mhamrah/Models/StudentListPageMV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/ChatRoom/ChatContactListElement.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/StudentList/StudnetListTitlePart.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/User/FirstPage.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ChatContactTitlePart.dart';

class ChatContactList extends StatefulWidget {
  final StudentMainPageState studentMainPageState;

  ChatContactList(
    this.studentMainPageState, {
    Key key,
  }) : super(key: key);

  @override
  _ChatContactListState createState() =>
      _ChatContactListState(studentMainPageState);
}

class _ChatContactListState extends State<ChatContactList> {
  StudentProfileSRV studentProfileSRV = StudentProfileSRV();
  int userType = -1;
  bool parentAccount = false;
  static ContactElement studentContact = ContactElement();
  static ContactElement subConsContact = ContactElement();
  static ContactElement bosConsContact = ContactElement();

  Student student;

  Consultant consultant;
  StudentMainPageState studentMainPageState;
  Timer socketTimer;
  bool pageLoading = false;

  _ChatContactListState(this.studentMainPageState);

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    LSM.getUserMode().then((type) {
      setState(() {
        userType = type;
      });

      /// socket connection checker
      socketConnectionChecker(
              [StudentMainPage.studentUsername], this, () {}, () {})
          .then((value) {
        socketTimer = value;
      });

      if (userType == 0) {
        LSM.getConsultant().then((consultant) {
          setState(() {
            this.consultant = consultant;
          });
          String stuUsername = StudentMainPage.studentUsername;
          LSM.getAcceptedStudentListData().then((studentListData) {
            Student student = studentListData.getStudentByUsername(stuUsername);
            if (student != null) {
              setState(() {
                this.student = student;
                bosConsContact.username = student.boss_consultant_username;
                bosConsContact.userType = "00";
                subConsContact.username = student.sub_consultant_username;
                subConsContact.userType = "0";
                studentContact.username = student.username;
                studentContact.userType = "1";
              });
            } else {
              setState(() {
                pageLoading = true;
              });
              studentProfileSRV
                  .getStudentProfile(consultant.username,
                      consultant.authentication_string, stuUsername)
                  .then((student) {
                setState(() {
                  pageLoading = false;
                  this.student = student;
                  bosConsContact.username = student.boss_consultant_username;
                  bosConsContact.userType = "00";
                  subConsContact.username = student.sub_consultant_username;
                  subConsContact.userType = "0";
                  studentContact.username = student.username;
                  studentContact.userType = "1";
                });
              });
            }
          });
        });
      } else if (userType == 1) {
        LSM.getStudent().then((student) {
          setState(() {
            parentAccount = student.parent != "";
          });
          if (student.sub_consultant_username == "" &&
              student.boss_consultant_username == "") {
            this.student = null;
          } else {
            if (student.boss_consultant_request_accept) {
              setState(() {
                this.student = student;
                studentContact.username = student.username;
                studentContact.userType = "1";
                subConsContact.username = student.sub_consultant_username;
                subConsContact.userType = "0";
                bosConsContact.username = student.boss_consultant_username;
                bosConsContact.userType = "00";
              });
            } else {
              setState(() {
                this.student = null;
              });
            }

            studentProfileSRV
                .checkConsultantAcceptStatus(
                    student.username, student.authentication_string)
                .then((data) {
              if (data == null) {
                setState(() {
                  this.student = null;
                });
              } else {
                bool bosCons = data['bossConsStatus'] ?? false;
                if (bosCons) {
                  setState(() {
                    this.student = student;
                    studentContact.username = student.username;
                    studentContact.userType = "1";
                    subConsContact.username = student.sub_consultant_username;
                    subConsContact.userType = "0";
                    bosConsContact.username = student.boss_consultant_username;
                    bosConsContact.userType = "00";
                  });
                } else {
                  setState(() {
                    this.student = null;
                  });
                  student.boss_consultant_request_accept = bosCons;
                  LSM.updateStudentInfo(student);
                }
              }
            });
          }
        });
      }
    });
  }

  Widget build(BuildContext context) {
    double ySize = MediaQuery.of(context).size.height;
    double freeSpace = ySize -
        (15 +
            ySize * (15 / 100) * (60 / 100) -
            35 +
            FirstPage.androidTitleBarHeight) -
        StudentMainPageState.kBottomNavigationBarHeight -
        20;
    return new Container(
        color: prefix0.Theme.mainBG,
        height: MediaQuery.of(context).size.height -
            ConsultantMainPageState.tabHeight,
        width: MediaQuery.of(context).size.width,
        child: new Column(
          children: <Widget>[
            ChatContactTitlePart(), //TODO
            Container(
              height: freeSpace,
              child: new SingleChildScrollView(
                child: false
                    ? Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Text(
                          commingSoon,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: prefix0.Theme.onMainBGText),
                        ),
                      )
                    : (pageLoading
                        ? getLoadingBar()
                        : Container(
                            height: freeSpace + 3,
                            child: new Column(
                              verticalDirection: VerticalDirection.down,
                              children: userType == 1
                                  ? getStudentContactList()
                                  : (userType == 0
                                      ? getConsultantContactList()
                                      : []),
                            ),
                          )),
              ),
            ),
          ],
        ));
  }

  Widget getLoadingBar() {
    Widget w = new Padding(
      padding: EdgeInsets.only(top: 100),
      child: new Container(
        height: 150,
        width: 150,
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
    return w;
  }

  List<Widget> getStudentContactList() {
    if (student == null) {
      return [getNoAvailableContact()];
    }
    String subConsUsername = student.sub_consultant_username;
    String bossConsUsername = student.boss_consultant_username;

    return <Widget>[
      /// boss cons chat room
      parentAccount
          ? SizedBox()
          : GestureDetector(
              child: ChatContactElement(studentMainPageState,
                  [studentContact, bosConsContact], false),
              onTap: () {
                studentMainPageState
                    .chatRoomPage([student.username, bossConsUsername]);
              },
            ),

      /// if there us group with sub and boss
      subConsUsername != bossConsUsername
          ? GestureDetector(
              child: ChatContactElement(studentMainPageState,
                  [studentContact, subConsContact, bosConsContact], false),
              onTap: () {
                studentMainPageState.chatRoomPage([
                  student.username,
                  "mother:" + student.username,
                  "father:" + student.username,
                  subConsUsername,
                  bossConsUsername
                ]);
              },
            )
          : GestureDetector(
              child: ChatContactElement(studentMainPageState,
                  [studentContact, subConsContact, bosConsContact], false),
              onTap: () {
                studentMainPageState.chatRoomPage([
                  student.username,
                  "mother:" + student.username,
                  "father:" + student.username,
                  bossConsUsername
                ]);
              },
            ),
      parentAccount
          ? GestureDetector(
              child: ChatContactElement(studentMainPageState,
                  [subConsContact, bosConsContact, ContactElement()], false),
              onTap: () {
                studentMainPageState.chatRoomPage([
                      "mother:" + student.username,
                      "father:" + student.username,
                      bossConsUsername
                    ] +
                    (subConsUsername != bossConsUsername
                        ? [subConsUsername]
                        : []));
              },
            )
          : SizedBox(),

      /// boss cons channel
      bossConsUsername != null && bossConsUsername != ""
          ? GestureDetector(
              child: ChatContactElement(
                  studentMainPageState, [bosConsContact], true),
              onTap: () {
                studentMainPageState.studentChannelPage(bossConsUsername);
              },
            )
          : SizedBox(),

      /// sub cons channel
      subConsUsername != null &&
              subConsUsername != "" &&
              subConsUsername != bossConsUsername
          ? GestureDetector(
              child: ChatContactElement(
                  studentMainPageState, [subConsContact], true),
              onTap: () {
                studentMainPageState.studentChannelPage(subConsUsername);
              },
            )
          : SizedBox(),
    ];
  }

  List<Widget> getConsultantContactList() {
    if (consultant == null || student == null) {
      return [getNoAvailableContact()];
    }
    String bossConsUsername = student.boss_consultant_username;
    String subConsUsername = student.sub_consultant_username;
    if (student.boss_consultant_username == consultant.username) {
      /// we are boss cons
      if (bossConsUsername != subConsUsername) {
        /// there is a sub cons
        return <Widget>[
          /// boss cons chat room
          GestureDetector(
            child: ChatContactElement(
                studentMainPageState, [studentContact, bosConsContact], false),
            onTap: () {
              studentMainPageState.chatRoomPage([
                bossConsUsername,
                student.username,
              ]);
            },
          ),

          /// student sub boss cons group
          GestureDetector(
            child: ChatContactElement(studentMainPageState,
                [studentContact, subConsContact, bosConsContact], false),
            onTap: () {
              studentMainPageState.chatRoomPage([
                student.username,
                "mother:" + student.username,
                "father:" + student.username,
                bossConsUsername,
                subConsUsername
              ]);
            },
          ),

          GestureDetector(
            child: ChatContactElement(studentMainPageState,
                [subConsContact, bosConsContact, ContactElement()], false),
            onTap: () {
              studentMainPageState.chatRoomPage([
                "mother:" + student.username,
                "father:" + student.username,
                bossConsUsername,
                subConsUsername
              ]);
            },
          ),

          /// subcons channel
          GestureDetector(
            child: ChatContactElement(
                studentMainPageState, [subConsContact], true),
            onTap: () {
              studentMainPageState.studentChannelPage(subConsUsername);
            },
          )
        ];
      } else {
        /// no sub cons
        return <Widget>[
          /// boss cons chat room
          GestureDetector(
            child: ChatContactElement(
                studentMainPageState, [studentContact, bosConsContact], false),
            onTap: () {
              studentMainPageState
                  .chatRoomPage([student.username, bossConsUsername]);
            },
          ),

          /// student sub boss cons group
          GestureDetector(
            child: ChatContactElement(studentMainPageState,
                [studentContact, subConsContact, bosConsContact], false),
            onTap: () {
              studentMainPageState.chatRoomPage([
                student.username,
                "mother:" + student.username,
                "father:" + student.username,
                bossConsUsername,
              ]);
            },
          ),

          GestureDetector(
            child: ChatContactElement(studentMainPageState,
                [subConsContact, bosConsContact, ContactElement()], false),
            onTap: () {
              studentMainPageState.chatRoomPage([
                "mother:" + student.username,
                "father:" + student.username,
                bossConsUsername,
              ]);
            },
          ),
        ];
      }
    } else {
      /// we are sub cons

      return <Widget>[
        /// student sub boss cons group
        GestureDetector(
          child: ChatContactElement(studentMainPageState,
              [studentContact, subConsContact, bosConsContact], false),
          onTap: () {
            studentMainPageState.chatRoomPage([
              subConsUsername,
              student.username,
              "mother:" + student.username,
              "father:" + student.username,
              bossConsUsername
            ]);
          },
        ),
        GestureDetector(
          child: ChatContactElement(studentMainPageState,
              [subConsContact, bosConsContact, ContactElement()], false),
          onTap: () {
            studentMainPageState.chatRoomPage([
              subConsUsername,
              "mother:" + student.username,
              "father:" + student.username,
              bossConsUsername
            ]);
          },
        ),

        /// boss cons channel
        GestureDetector(
          child:
              ChatContactElement(studentMainPageState, [bosConsContact], true),
          onTap: () {
            studentMainPageState.studentChannelPage(bossConsUsername);
          },
        ),
      ];
    }
    return <Widget>[];
  }

  Widget getNoAvailableContact() {
    return Container(
      padding: EdgeInsets.only(top: 100),
      alignment: Alignment.center,
      child: AutoSizeText(
        noAvailableContact,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: getTextStyle(22, prefix0.Theme.onMainBGText),
      ),
    );
  }

  @override
  void dispose() {
    if (socketTimer != null) {
      socketTimer.cancel();
    }
    super.dispose();
  }
}
