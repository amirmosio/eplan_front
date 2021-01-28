import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:mhamrah/ConnectionService/AppService.dart';
import 'package:mhamrah/ConnectionService/BlueTable1SRV.dart';
import 'package:mhamrah/ConnectionService/StudentProfileSRV.dart';
import 'package:mhamrah/Models/BlueTable1MV.dart';
import 'package:mhamrah/Models/UserMV.dart';
import 'package:mhamrah/Pages/Chart/CircularChart2.dart';
import 'package:mhamrah/Pages/Chart/StackedFillColorBarChart.dart';
import 'package:mhamrah/Pages/ConsultantMainPage.dart';
import 'package:mhamrah/Pages/StudentMainPage.dart';
import 'package:mhamrah/Pages/StudentProfile/EditStudentProfile.dart';
import 'package:mhamrah/Pages/StudentProfile/NewConsultantRequest.dart';
import 'package:mhamrah/Pages/Support/Support.dart';
import 'package:mhamrah/Utils/AppUtils.dart';
import 'package:mhamrah/Utils/LocalFileUtils.dart';
import 'package:mhamrah/Utils/SocketUtils.dart';
import 'package:mhamrah/Values/Models.dart';
import 'package:mhamrah/Values/Utils.dart';
import 'package:mhamrah/Values/string.dart';
import 'package:mhamrah/Values/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'ConsultantPrfileDetail.dart';
import 'StudentProfileTitleBar.dart';

class StudentTabBarChart extends StatefulWidget {
  StudentTabBarChart({
    Key key,
  }) : super(key: key);

  @override
  StudentTabBarChartState createState() => StudentTabBarChartState();
}

class StudentTabBarChartState extends State<StudentTabBarChart>
    with TickerProviderStateMixin {
  StudentTabBarChartState();

  int userType = 0;
  StudentProfileSRV studentProfileSRV = StudentProfileSRV();
  Student student = new Student();
  static B1DayPlan emptyPlan1 = B1DayPlan.getEmptyInitial(0, "1");

  static BlueTable1Data b = BlueTable1Data.initialData(
      emptyInitialPlanNameInBlueTables,
      [
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
        emptyPlan1,
      ],
      "",
      "");

  static AllBlue1Tables totalBlue1Tables = AllBlue1Tables("", [b]);

  TabController tabController;
  double xSize;
  double ySize;

  bool loadingDetailToggle = false;
  bool loadingBlue1ChartToggle = false;
  bool loadingUsageChartToggle = false;

  String chartName = "";

  Map<String, List<dynamic>> studentPhoneUsage = {};

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    chartName = StudentMainPageState.selectedPlanName;

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
                });
                loadStudentDataFromLocalAndRemove(student);
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
            /// setting data
            setState(() {
              this.student = student;
            });
            loadStudentDataFromLocalAndRemove(student);
          });
        }
      });
    });

    tabController = TabController(
      length: 2, //TODO
      initialIndex: 1,
      vsync: this,
    );
    tabController.addListener(() {
      setState(() {});
    });
  }

  List<CircularChartModel> pieData = [];

  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(right: 15, left: 15, top: 20),
      child: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              tabs: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: AutoSizeText(
                    'استفاده از گوشی',
                    style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText),
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    chartName.trim() == ""
                        ? "داده ای در دسترس نیست"
                        : chartName,
                    style: prefix0.getTextStyle(18, prefix0.Theme.onMainBGText),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            AnimatedContainer(
              height: tabController.index == 1
                  ? xSize * (62 / 100) +
                      60 +
                      ((pieData.length + 2) * (70 / 100) * 40)
                  : xSize * (60 / 100) + 40,
              curve: Curves.decelerate,
              duration: Duration(milliseconds: 600),
              child: TabBarView(
                controller: tabController,
                children: [
                  getPhoneUsageChartAndDetails(),
                  getCircularChartAndDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPhoneUsageChartAndDetails() {
    return loadingUsageChartToggle
        ? getPageLoadingProgress()
        : Column(
            children: [getPhoneUsageChart(), getUsageDescription()],
          );
  }

  Widget getUsageDescription() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        getSingleLessonLabelColor(
            CircularChartModel(
                "شبکه های اجتماعی", 1, Color.fromARGB(255, 255, 150, 150)),
            fontSize: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            getSingleLessonLabelColor(
                CircularChartModel(
                    "مشاور همراه", 1, Color.fromARGB(255, 130, 200, 255)),
                fontSize: 16),
            getSingleLessonLabelColor(
                CircularChartModel(
                    "دیگر برنامه ها", 1, Color.fromARGB(255, 220, 220, 220)),
                fontSize: 16),
          ],
        ),
      ],
    );
  }

  Widget getPhoneUsageChart() {
    double height = xSize * (50 / 100);
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: height,
            child: PhoneUsageStackedFillChart.withSampleData(
                this.studentPhoneUsage),
          ),
          this.studentPhoneUsage.keys.length == 0
              ? Container(
                  alignment: Alignment.center,
                  height: height,
                  child: AutoSizeText(
                    "داده ای در دسترس نیست.",
                    style: prefix0.getTextStyle(16, prefix0.Theme.onMainBGText),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget getCircularChartAndDetails() {
    return loadingBlue1ChartToggle
        ? getPageLoadingProgress()
        : Column(
            children: <Widget>[getBlue1Chart(), getLessonLabelAndColor()],
          );
  }

  Widget getBlue1Chart() {
    int res1Sum = 0;
    int res2Sum = 0;
    String lessonIdentifier =
        student.student_edu_level + " " + student.student_major;
    for (int i = 0; i < pieData.length; i++) {
      if (getLessonType(lessonIdentifier, pieData[i].title) == 0) {
        res2Sum += pieData[i].value;
      } else {
        res1Sum += pieData[i].value;
      }
    }

    double shadow_width = 30;
    double t = 12;
    double o = 20;
    double shadow_radius = xSize * (60 / 100) + 30;
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CircularPercentIndicator(
            radius: shadow_radius,
            percent: res2Sum / (res1Sum + res2Sum),
            lineWidth: shadow_width,
            backgroundColor: Color.fromARGB(255, 40, 78, 111),
            progressColor: Color.fromARGB(0, 0, 0, 0),
          ),
          CircularPercentIndicator(
            radius: shadow_radius,
            percent: res2Sum / (res1Sum + res2Sum),
            lineWidth: shadow_width,
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            progressColor: Color.fromARGB(255, 45, 92, 88),
          ),
          CircularPercentIndicator(
            key: ValueKey(totalBlue1Tables.hashCode.toString()),
            radius: shadow_radius - (shadow_width - t),
            percent: res2Sum / (res1Sum + res2Sum),
            lineWidth: t,
            backgroundColor: Color.fromARGB(255, 32, 161, 234),
            progressColor: getLessonColor("عمومی"),
            center: new Container(
              height: shadow_radius - 10,
              width: shadow_radius - 10,
              child: Circular2Chart.withSampleData(pieData, shadow_radius - 10),
            ),
          ),
          CircularPercentIndicator(
            radius: shadow_radius - (shadow_width - o),
            percent: res2Sum / (res1Sum + res2Sum),
            lineWidth: o,
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            progressColor: Color.fromARGB(255, 55, 232, 120),
          ),
        ],
      ),
    );
  }

  Widget getLessonLabelAndColor() {
    List<Widget> res1 = [];
    List<Widget> res2 = [];
    int res1Sum = 0;
    String studentLessonIdentifier =
        student.student_edu_level + " " + student.student_major;
    String tableLessonIdentifier = totalBlue1Tables.getLast().lessonIdentifier;
    String lessonIdentifier = tableLessonIdentifier == ""
        ? studentLessonIdentifier
        : tableLessonIdentifier;
    int res2Sum = 0;
    for (int i = 0; i < pieData.length; i++) {
      int lessonType = getLessonType(lessonIdentifier, pieData[i].title);
      if (lessonType == 1) {
        res2.add(getSingleLessonLabelColor(pieData[i]));
        res2Sum += pieData[i].value;
      } else if (lessonType == 0) {
        res1.add(getSingleLessonLabelColor(pieData[i]));
        res1Sum += pieData[i].value;
      }
    }
    CircularChartModel g1 =
        CircularChartModel("عمومی", res1Sum, getLessonColor("عمومی"));
    CircularChartModel g2 =
        CircularChartModel("تخصصی", res2Sum, getLessonColor("تخصصی"));
    res1.insert(0, getSingleLessonLabelColor(g1));
    res2.insert(0, getSingleLessonLabelColor(g2));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: res2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: res1,
        )
      ],
    );
  }

  Widget getSingleLessonLabelColor(CircularChartModel lessonData,
      {double fontSize = 18}) {
    double xSize = MediaQuery.of(context).size.width;
    return Container(
        padding: EdgeInsets.only(
            right: xSize * (5 / 100),
            left: xSize * (5 / 100),
            top: 3,
            bottom: 3),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      right: 8, left: xSize * (3 / 100), top: 5, bottom: 5),
                  child: AutoSizeText(
                    lessonData.title.toString(),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: prefix0.getTextStyle(
                        fontSize, prefix0.Theme.onMainBGText),
                  ),
                ),
                Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        color: lessonData.color,
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
              ],
            ),
          ],
        ));
  }

  void loadStudentDataFromLocalAndRemove(Student student) {
    LSM.getBlue1AllTables(student.username).then((blue1AllTables) {
      if (blue1AllTables != null) {
        BlueTable1Data blueTable1Data = blue1AllTables
            .getBlueTable1ByName(StudentMainPageState.selectedPlanName);
        if (blueTable1Data != null) {
          setState(() {
            totalBlue1Tables = blue1AllTables;
            pieData = blueTable1Data.getCircularLessonData(
                student.student_edu_level + " " + student.student_major);
            chartName = StudentMainPageState.selectedPlanName;
          });
          fetchSelectedTable(false);
        } else {
          fetchSelectedTable(true);
        }
      } else {
        fetchSelectedTable(true);
      }
    });
    fetchStudentUsage();
  }

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
          loadingDetailToggle = false;
        }
        if (student == null) {
        } else {
          setState(() {
            this.student = student;
          });
          loadStudentDataFromLocalAndRemove(student);
        }
      });
    });
  }

  void fetchSelectedTable(bool withLoading) {
    BlueTable1SRV blueTable1SRV = new BlueTable1SRV();
    if (withLoading) {
      setState(() {
        loadingBlue1ChartToggle = true;
      });
    }
    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        blueTable1SRV
            .getTableByName(
                consultant.username,
                StudentMainPage.studentUsername,
                consultant.authentication_string,
                StudentMainPageState.selectedPlanName)
            .then((blue1AllTables) {
          if (blue1AllTables != null) {
            if (blue1AllTables.allTables.length != 0) {
              setState(() {
                totalBlue1Tables = blue1AllTables;
                pieData = totalBlue1Tables.getLast().getCircularLessonData(
                    student.student_edu_level + " " + student.student_major);
                chartName = StudentMainPageState.selectedPlanName;
                if (withLoading) {
                  loadingBlue1ChartToggle = false;
                }
              });
            } else {
              setState(() {
                totalBlue1Tables = AllBlue1Tables("", [b]);
                pieData = [];
                chartName = totalBlue1Tables.allTables.last.name;
                if (withLoading) {
                  loadingBlue1ChartToggle = false;
                }
              });
            }
          }
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        blueTable1SRV
            .getTableByName(
                student.sub_consultant_username,
                student.username,
                student.authentication_string,
                StudentMainPageState.selectedPlanName)
            .then((blue1AllTables) {
          if (blue1AllTables != null) {
            if (blue1AllTables.allTables.length != 0) {
              setState(() {
                totalBlue1Tables = blue1AllTables;
                pieData = totalBlue1Tables.getLast().getCircularLessonData(
                    student.student_edu_level + " " + student.student_major);
                chartName = StudentMainPageState.selectedPlanName;
                if (withLoading) {
                  loadingBlue1ChartToggle = false;
                }
              });
            } else {
              setState(() {
                totalBlue1Tables = AllBlue1Tables("", [b]);
                pieData = [];
                chartName = totalBlue1Tables.allTables.last.name;
                if (withLoading) {
                  loadingBlue1ChartToggle = false;
                }
              });
            }
          }
        });
      });
    }
  }

  void fetchStudentUsage() {
    Map<String, List> getProcessedUsages(Map<String, dynamic> usages) {
      String myAppString = appPackageName;
      Map<String, List> result = {};
      List keysList = usages.keys.toList();
      for (int dateIndex = 0; dateIndex < keysList.length; dateIndex++) {
        String dateString = keysList[dateIndex];
        double myAppSeconds = 0;
        double socialAppSeconds = 0;
        double otherAppsSeconds = 0;
        List appsList = usages[dateString].keys.toList();
        for (int appIndex = 0; appIndex < appsList.length; appIndex++) {
          String app = appsList[appIndex];
          double value = usages[dateString][app];
          if (app == myAppString) {
            myAppSeconds += value;
          } else if (socialApps.contains(app)) {
            socialAppSeconds += value;
          } else {
            otherAppsSeconds += value;
          }
        }

        result[dateString] = [myAppSeconds, socialAppSeconds, otherAppsSeconds];
      }
      return result;
    }

    AppSRV appSRV = AppSRV();

    setState(() {
      loadingUsageChartToggle = true;
    });

    if (userType == 0) {
      LSM.getConsultant().then((consultant) {
        appSRV
            .get7PrevDayPhoneUsage(
                consultant.username,
                consultant.authentication_string,
                StudentMainPage.studentUsername)
            .then((daysUsage) {
          if (daysUsage != null) {
            if (daysUsage.keys.length != 0) {
              this.studentPhoneUsage = getProcessedUsages(daysUsage);
            } else {}
          }
          setState(() {
            loadingUsageChartToggle = false;
          });
        });
      });
    } else if (userType == 1) {
      LSM.getStudent().then((student) {
        appSRV
            .get7PrevDayPhoneUsage(student.username,
                student.authentication_string, StudentMainPage.studentUsername)
            .then((daysUsage) {
          if (daysUsage != null) {
            if (daysUsage.keys.length != 0) {
              this.studentPhoneUsage = getProcessedUsages(daysUsage);
            } else {}
          }
          setState(() {
            loadingUsageChartToggle = false;
          });
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
