import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/BlueTable1SRV.dart';
import 'package:mhamrah/ConnectionService/LeagueSRV.dart';
import 'package:mhamrah/ConnectionService/StudentProfileSRV.dart';
import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/Chart/CircularChart2.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/SharedProfile/LeagueList.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/StudentProfile/EditStudentProfile.dart';
import 'package:mhamrah/Pages/StudentProfile/NewConsultantRequest.dart';
import 'package:mhamrah/Pages/Support/Support.dart';
import 'package:mhamrah/Utils/AutoTextUtils.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SnackAnFlushBarUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'ConsultantPrfileDetail.dart';
import 'StudentProfileTitleBar.dart';
import 'StudentTabBarChart.dart';

class StudentProfile extends StatefulWidget {
  final StudentMainPageState s;

  StudentProfile(
    this.s, {
    Key key,
  }) : super(key: key);

  @override
  StudentProfileState createState() => StudentProfileState(s);
}

class StudentProfileState extends State<StudentProfile>
    with TickerProviderStateMixin {
  BlueTable1SRV blueTable1SRV = new BlueTable1SRV();
  StudentMainPageState s;
  bool hasSubCons = false;
  bool hasBossCons = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  StudentProfileState(this.s);

  int userType = 0;
  bool parentAccount = false;
  StudentProfileSRV studentProfileSRV = StudentProfileSRV();
  Student student = new Student();

  double xSize;
  double ySize;

  bool loadingDetailToggle = false;
  bool supportFragToggle = false;
  bool consDetailFragToggle = false;
  bool loginLoading = false;

  Widget consultantWidget = SizedBox(
    width: 0,
    height: 0,
  );
  Timer socketTimer;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    /// socket connection checker
    socketConnectionChecker(
            [StudentMainPage.studentUsername], this, () {}, () {})
        .then((value) {
      socketTimer = value;
    });

    LSM.getUserMode().then((type) {
      setState(() {
        userType = type;
        if (type == 0) {
          LSM.getAcceptedStudentListData().then((studentListData) {
            if (studentListData != null) {
              Student localStudent = studentListData
                  .getStudentByUsername(StudentMainPage.studentUsername);
              if (localStudent != null) {
                setState(() {
                  student = localStudent;
                  bool bossCons = true;
                  setStateHasSubConsAndBossCons(student, bossCons);
                });
                fetchStudentData(false, false);
              } else {
                fetchStudentData(true, true);
              }
            } else {
              fetchStudentData(true, true);
            }
          });
        } else if (type == 1) {
          LSM.getStudent().then((student) {
            setState(() {
              parentAccount = student.parent != "";
            });
            setStateHasSubConsAndBossCons(
                student, student.boss_consultant_request_accept);
            studentProfileSRV
                .checkConsultantAcceptStatus(
                    student.username, student.authentication_string)
                .then((data) {
              if (data != null) {
//                bool subCons = data['subConsStatus'] ?? false;
                bool bossConsAccept = data['bossConsStatus'] ?? false;
                student.boss_consultant_request_accept = bossConsAccept;
                LSM.updateStudentInfo(student);
                setStateHasSubConsAndBossCons(student, bossConsAccept);
              }
            });

            /// setting data
            setState(() {
              this.student = student;
            });
          });
        }
      });
    });
  }

  void setStateHasSubConsAndBossCons(Student student, bool bossCons) {
    setState(() {
      if (bossCons &&
          student.sub_consultant_username != student.boss_consultant_username) {
        hasSubCons = true;
      } else {
        hasSubCons = false;
      }

      if (bossCons) {
        hasBossCons = true;
      } else {
        hasBossCons = false;
      }
    });
  }

  List<CircularChartModel> pieData = [];

  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    if (userType == 1) {
      Student student = LSM.getStudentSync();
      if (student != null) {
        this.student = student;
      }
    }

    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            new Container(
              color: prefix0.Theme.mainBG,
              height: MediaQuery.of(context).size.height -
                  ConsultantMainPageState.tabHeight,
              width: MediaQuery.of(context).size.width,
              child: new Stack(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.only(
                        top: 40 + ((60 / 100) * (15 / 100) * ySize)),
                    alignment: Alignment.topCenter,
                    child: new SingleChildScrollView(
                      child: new Column(
                        verticalDirection: VerticalDirection.down,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          loadingDetailToggle
                              ? getPageLoadingProgress()
                              : Column(
                                  children: [
                                    Container(
                                      height: ((40 / 100) * (15 / 100) * ySize),
                                    ),
                                    getStudentName(),
                                    getStudentBio(),
                                    getStudentDescription(),
                                    userType == 1 && !parentAccount
                                        ? getEditButton()
                                        : SizedBox(),
                                    getStudentItemBossCons()
                                  ],
                                ),
//                          StudentTabBarChart(),
                        ],
                      ),
                    ),
                  ),
                  new ProfileTitlePart(s, this),
//            getBottomNavigationBar()
                ],
              ),
            ),
            Visibility(
              child: SupportFragment.Student(this),
              visible: supportFragToggle,
            ),
            Visibility(
              child: consultantWidget,
              visible: consDetailFragToggle,
            )
          ],
        ),
      ),
    );
  }

  void closeSupportFragment() {
    setState(() {
      supportFragToggle = false;
    });
  }

  void closeConsultantDetail() {
    setState(() {
      consDetailFragToggle = false;
    });
  }

  Widget getEditButton() {
    return Padding(
      padding: EdgeInsets.only(left: 50, right: 50, top: 5, bottom: 10),
      child: Container(
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: Container(
                height: 2,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              child: new Container(
                alignment: Alignment.center,
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                child: AutoSizeText(
                  "ارتباط با مشاور",
                  style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText),
                ),
                decoration: new BoxDecoration(
                  color: prefix0.Theme.applyButton,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
              ),
              onTap: () {
                if (student.checkValidDataForConsultantRequest()) {
                  navigateToSubPage(context, RequestNewConsultant());
                } else {
                  showFlutterToastWithFlushBar(
                      completeInfoForConsultantRequest);
                }
              },
            ),
            new Expanded(
              child: Container(
                height: 2,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              child: new Container(
                alignment: Alignment.center,
                padding:
                    EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
                child: AutoSizeText(
                  student.checkValidDataForConsultantRequest()
                      ? "ویرایش"
                      : "تکمیل اطلاعات",
                  style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText),
                ),
                decoration: new BoxDecoration(
                  color: prefix0.Theme.applyButton,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
              ),
              onTap: () {
                navigateToSubPage(context, EditStudentProfile());
              },
            ),
            new Expanded(
              child: Container(
                height: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getStudentItemBossCons() {
    LSM.getConsultant().then((c) {
      if (c != null) {
        if (student.boss_consultant_username != "" &&
            student.boss_consultant_username != null) {
          hasBossCons = true;
        }
        if (student.sub_consultant_username != "" &&
            student.sub_consultant_username != null &&
            student.sub_consultant_username !=
                student.boss_consultant_username) {
          hasSubCons = true;
        }
      }
    });
    double iconSize = 0;
    if ((hasSubCons & !hasBossCons) ||
        (!hasSubCons && hasBossCons) ||
        (!hasSubCons && !hasBossCons)) {
      iconSize = xSize * (24 / 100);
    } else {
      iconSize = xSize * (30 / 100);
    }

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                    GestureDetector(
                      child: new Container(
                        decoration: new BoxDecoration(
                            borderRadius:
                                new BorderRadius.all(Radius.circular(15)),
                            color: Colors.white),
                        child: Column(
                          children: <Widget>[
                            Container(
                                child: ImageIcon(
                              AssetImage("assets/img/11.png"),
                              color: prefix0.Theme.blueIcon,
                              size: iconSize,
                            )),
                            Container(
                              child: AutoSizeText(contactUs,
                                  style: prefix0.getTextStyle(
                                      14, prefix0.Theme.blueIcon)),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          supportFragToggle = true;
                        });
                      },
                    ),
                    GestureDetector(
                      child: new Container(
                        decoration: new BoxDecoration(
                            borderRadius:
                                new BorderRadius.all(Radius.circular(15)),
                            color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                child: ImageIcon(
                              AssetImage("assets/img/11.png"),
                              color: prefix0.Theme.blueIcon,
                              size: iconSize,
                            )),
                            Container(
                                child: AutoSizeText(
                              leagueTitle,
                              style: prefix0.getTextStyle(
                                  15, prefix0.Theme.blueIcon),
                            ))
                          ],
                        ),
                      ),
                      onTap: () {
                        showLeaguePage();
                      },
                    ),
//                    GestureDetector(
//                      child: new Container(
//                        decoration: new BoxDecoration(
//                            borderRadius:
//                                new BorderRadius.all(Radius.circular(15)),
//                            color: Colors.white),
//                        child: Column(
//                          children: <Widget>[
//                            Container(
//                                child: ImageIcon(
//                              AssetImage("assets/img/14.png"),
//                              color: prefix0.Theme.blueIcon,
//                              size: iconSize,
//                            )),
//                            Container(
//                              child: AutoSizeText(examTitle,
//                                  style: prefix0.getTextStyle(
//                                      14, prefix0.Theme.blueIcon)),
//                            )
//                          ],
//                        ),
//                      ),
//                      onTap: () {
//                        showFlutterToastWithFlushBar(
//                            "این قسمت بزودی اماده می شود.");
//                      },
//                    ),
                  ] +
                  ((hasBossCons && !hasSubCons) || (!hasBossCons && hasSubCons)
                      ? [getConsultantAndSubCons(iconSize)]
                      : [])),
          hasSubCons && hasBossCons
              ? Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: getConsultantAndSubCons(iconSize))
              : SizedBox()
        ],
      ),
    );
  }

  void showLeaguePage() {
    if (LSM.getStudentSync().league_flag) {
      /// show league list
      LeagueList leagueList = LeagueList(_scaffoldKey.currentContext, this);
      leagueList.showLeagueListDialog();
    } else {
      /// show league login

      Widget d = BackdropFilter(
        filter: prefix0.Theme.fragmentBGFilter,
        child: new AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(25),
              ),
            ),
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter dialogStateSetter) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                        color: prefix0.Theme.settingBg),
//                height: MediaQuery.of(context).size.height * (20 / 100),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height: 150,
                              width: double.maxFinite - 20,
                              child: getAutoSizedDirectionText(
                                leagueInitialString,
                                textAlign: TextAlign.center,
                                style: prefix0.getTextStyle(
                                    20, prefix0.Theme.onSettingText1),
                              ),
                            )),
                        GestureDetector(
                          child: Container(
                            width: double.maxFinite,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(25),
                                  bottomLeft: Radius.circular(25),
                                ),
                                color: prefix0.Theme.warningAndErrorBG),
                            child: loginLoading
                                ? getButtonLoadingProgress(r: 22, stroke: 2.5)
                                : getAutoSizedDirectionText(
                                    "تایید",
                                    style: prefix0.getTextStyle(
                                        18, prefix0.Theme.onWarningAndErrorBG),
                                  ),
                          ),
                          onTap: () {
                            dialogStateSetter(() {
                              loginLoading = true;
                            });
                            LeagueSRV leagueSRV = LeagueSRV();
                            leagueSRV
                                .changeStudentLoginLogout(student.username,
                                    student.authentication_string, true)
                                .then((success) {
                              dialogStateSetter(() {
                                loginLoading = false;
                              });
                              if (success) {
                                student.league_flag = true;
                                LSM.updateStudentInfo(student);
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');

                                /// show league
                                LeagueList leagueList =
                                    LeagueList(_scaffoldKey.currentContext, this);
                                leagueList.showLeagueListDialog();
                              } else {
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                showFlutterToastWithFlushBar("درخواست ناموفق");
                              }
                            });
                          },
                        )
                      ],
                    ),
                  )
                ],
              );
            })),
      );
      showDialog(context: context, child: d, barrierDismissible: true);
    }
  }

  Widget getConsultantAndSubCons(double iconSize) {
    return Row(
      mainAxisAlignment: !hasSubCons && !hasBossCons
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceAround,
      children: (!hasSubCons
              ? (<Widget>[])
              : <Widget>[
                  GestureDetector(
                    child: new Container(
                      decoration: new BoxDecoration(
                          borderRadius:
                              new BorderRadius.all(Radius.circular(15)),
                          color: Colors.white),
                      child: Column(
                        children: <Widget>[
                          Container(
                              child: ImageIcon(
                            AssetImage("assets/img/17.png"),
                            color: prefix0.Theme.blueIcon,
                            size: iconSize,
                          )),
                          Container(
                            child: AutoSizeText(subConsultantLabel,
                                style: prefix0.getTextStyle(
                                    14, prefix0.Theme.blueIcon)),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (student != null) {
                          consultantWidget = ConsultantProfileDetail.Student(
                              this, student.sub_consultant_username);
                          consDetailFragToggle = true;
                        }
                      });
                    },
                  ),
                ]) +
          (!hasBossCons
              ? <Widget>[]
              : <Widget>[
                  GestureDetector(
                    child: new Container(
                      decoration: new BoxDecoration(
                          borderRadius:
                              new BorderRadius.all(Radius.circular(15)),
                          color: Colors.white),
                      child: Column(
                        children: <Widget>[
                          Container(
                              child: ImageIcon(
                            AssetImage("assets/img/15.png"),
                            color: prefix0.Theme.blueIcon,
                            size: iconSize,
                          )),
                          Container(
                            child: AutoSizeText(consultantLabel,
                                style: prefix0.getTextStyle(
                                    14, prefix0.Theme.blueIcon)),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (student != null) {
                          consultantWidget = ConsultantProfileDetail.Student(
                              this, student.boss_consultant_username);
                          consDetailFragToggle = true;
                        }
                      });
                    },
                  ),
                ]),
    );
  }

//
//  Widget getStudentItemWithoutBossCons() {
//    return Padding(
//      padding: EdgeInsets.all(10),
//      child: new Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          GestureDetector(
//            child: Padding(
//              padding: EdgeInsets.all(10),
//              child: new Container(
//                width: xSize * (35 / 100),
//                decoration: new BoxDecoration(
//                    borderRadius: new BorderRadius.all(Radius.circular(15)),
//                    color: Colors.white),
//                child: Column(
//                  children: <Widget>[
//                    Container(
//                        child: ImageIcon(
//                      AssetImage("assets/img/11.png"),
//                      color: prefix0.Theme.blueIcon,
//                      size: xSize * (30 / 100),
//                    )),
//                    Container(
//                      child: AutoSizeText("ارتباط با ما",
//                          style:
//                              prefix0.getTextStyle(14, prefix0.Theme.blueIcon)),
//                    )
//                  ],
//                ),
//              ),
//            ),
//            onTap: () {
//              setState(() {
//                supportFragToggle = true;
//              });
//            },
//          ),
//          GestureDetector(
//            child: Padding(
//              padding: EdgeInsets.all(10),
//              child: new Container(
//                width: xSize * (35 / 100),
//                decoration: new BoxDecoration(
//                    borderRadius: new BorderRadius.all(Radius.circular(15)),
//                    color: Colors.white),
//                child: Column(
//                  children: <Widget>[
//                    Container(
//                        child: ImageIcon(
//                      AssetImage("assets/img/15.png"),
//                      color: prefix0.Theme.blueIcon,
//                      size: xSize * (30 / 100),
//                    )),
//                    Container(
//                      child: AutoSizeText(consultantLabel,
//                          style:
//                              prefix0.getTextStyle(14, prefix0.Theme.blueIcon)),
//                    )
//                  ],
//                ),
//              ),
//            ),
//            onTap: () {
//              setState(() {
//                if (student != null) {
//                  consultantWidget = ConsultantProfileDetail.Student(
//                      this, student.sub_consultant_username);
//                  consDetailFragToggle = true;
//                }
//              });
//            },
//          ),
////          new Container(
////              decoration: new BoxDecoration(
////                  borderRadius: new BorderRadius.all(Radius.circular(15)),
////                  color: Colors.white),
////              child: Column(
////                children: <Widget>[
////                  Container(
////                      child: ImageIcon(
////                    AssetImage("assets/img/12.png"),
////                    color: prefix0.Theme.blueIcon,
////                    size: xSize * (24 / 100),
////                  )),
////                  Container(
////                    child: Text("اخبار و مقالات",
////                        style:
////                            prefix0.getTextStyle(14, prefix0.Theme.blueIcon)),
////                  )
////                ],
////              )),
////          new Container(
////              decoration: new BoxDecoration(
////                  borderRadius: new BorderRadius.all(Radius.circular(15)),
////                  color: Colors.white),
////              child: Column(
////                children: <Widget>[
////                  Container(
////                      child: ImageIcon(
////                    AssetImage("assets/img/14.png"),
////                    color: prefix0.Theme.blueIcon,
////                    size: xSize * (24 / 100),
////                  )),
////                  Container(
////                    child: AutoSizeText("صورت حساب",
////                        style:
////                            prefix0.getTextStyle(14, prefix0.Theme.blueIcon)),
////                  )
////                ],
////              )),
//        ],
//      ),
//    );
//  }

  Widget getStudentDescription() {
    return new Padding(
        padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
        child: new Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 5, top: 15),
                  child: Container(
                      child: AutoSizeText(
                    "همراه: " +
                        (student.phone != "" ? student.phone : "وارد نشده است"),
                    style: prefix0.getTextStyle(16, prefix0.Theme.onMainBGText),
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 5, top: 15),
                  child: Container(
                      child: AutoSizeText(
                    "منزل: " +
                        (student.home_number != ""
                            ? student.home_number
                            : "وارد نشده است"),
                    style: prefix0.getTextStyle(16, prefix0.Theme.onMainBGText),
                  )),
                ),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 5, top: 15),
                  child: Container(
                      child: AutoSizeText(
                    "پدر: " +
                        (student.father_phone != ""
                            ? student.father_phone
                            : "وارد نشده است"),
                    style: prefix0.getTextStyle(16, prefix0.Theme.onMainBGText),
                  )),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 5, top: 15),
                  child: Container(
                      child: AutoSizeText(
                    "مادر: " +
                        (student.mother_phone != ""
                            ? student.mother_phone
                            : "وارد نشده است"),
                    style: prefix0.getTextStyle(16, prefix0.Theme.onMainBGText),
                  )),
                ),
              ],
            ),
          ],
        ));
  }

  Widget getStudentBio() {
    return new Padding(
      padding: EdgeInsets.only(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              student.student_edu_level == null ||
                      student.student_edu_level == ""
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(left: 0, right: 10, top: 15),
                      child: Container(
                          child: AutoSizeText(
                        student.student_edu_level,
                        style: prefix0.getTextStyle(
                            14, prefix0.Theme.onMainBGText),
                      )),
                    ),
              (student.student_major == null ||
                      student.student_major == "" ||
                      student.student_edu_level == null ||
                      student.student_edu_level == "")
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(left: 5, right: 15, top: 15),
                      child: Container(
                          child: AutoSizeText(
                        "/",
                        style: prefix0.getTextStyle(
                            15, prefix0.Theme.onMainBGText),
                      )),
                    ),
              student.student_major == null || student.student_major == ""
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(left: 0, right: 0, top: 15),
                      child: Container(
                        child: AutoSizeText(
                          student.student_major,
                          style: prefix0.getTextStyle(
                              14, prefix0.Theme.onMainBGText),
                        ),
                      ),
                    )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 10, top: 15),
            child: Container(
                child: AutoSizeText(
              student.school,
              style: prefix0.getTextStyle(16, prefix0.Theme.onMainBGText),
            )),
          ),
        ],
      ),
    );
  }

  Widget getStudentName() {
    return new Padding(
      padding: EdgeInsets.only(top: 10, bottom: 5),
      child: new Container(
        child: AutoSizeText(
          student.first_name + " " + student.last_name,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: prefix0.getTextStyle(22, prefix0.Theme.onMainBGText),
        ),
      ),
    );
  }

//  Widget getStudentChart() {
//    return TabBar(
//      controller: tabController,
//      tabs: [
//        Tab(
//          text: "نمودار ۲",
//        ),
////        Tab(
////          text: "نمودار هفته به هفته",
////        )
//      ],
//    );
//  }

  void fetchStudentData(bool withStudentLoading, bool withBlue1TableData) {
    setState(() {
      if (withStudentLoading) {
        loadingDetailToggle = true;
      }
    });
    LSM.getConsultant().then((consultant) {
      studentProfileSRV
          .getStudentProfile(consultant.username,
              consultant.authentication_string, StudentMainPage.studentUsername)
          .then((student) {
        if (withStudentLoading) {
          setState(() {
            loadingDetailToggle = false;
          });
        }
        if (student == null) {
        } else {
          this.student = student;
          setStateHasSubConsAndBossCons(
              student, student.boss_consultant_request_accept);
          LSM.getAcceptedStudentListData().then((studentListData) {
            if (studentListData != null) {
              studentListData.setStudentByUsername(student);
              LSM.setAcceptedStudentListData(studentListData);
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    if (socketTimer != null) {
      socketTimer.cancel();
    }
    super.dispose();
  }
}
